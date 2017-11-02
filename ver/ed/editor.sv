//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module editor #(
parameter ID_NBITS = `PORT_ID_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter VB_NBITS = `DATA_PATH_VB_NBITS,
parameter PKT_LEN_NBITS = `PACKET_LENGTH_NBITS,
parameter LEN_NBITS = `HEADER_LENGTH_NBITS,
parameter ADDR_NBITS = `ENQ_ED_CMD_PD_BP_NBITS+`PD_CHUNK_DEPTH_NBITS-`DATA_PATH_VB_NBITS
) (

input clk, 
input `RESET_SIG,

input bm_ed_data_valid,
input [ID_NBITS-1:0] bm_ed_port_id,
input bm_ed_sop,
input bm_ed_eop,
input [VB_NBITS-1:0] bm_ed_valid_bytes,
input [DATA_NBITS-1:0] bm_ed_packet_data,

input enq_ed_cmd_type bm_ed_cmd,

input edit_mem_ack,
input [DATA_NBITS-1:0] edit_mem_rdata,

output logic edit_mem_req,
output logic [ADDR_NBITS-1:0] edit_mem_raddr,
output logic [ID_NBITS-1:0] edit_mem_port_id,
output logic edit_mem_sop,
output logic edit_mem_eop,

output logic ed_dstr_data_valid,
output logic [DATA_NBITS-1:0] ed_dstr_packet_data,
output logic [ID_NBITS-1:0] ed_dstr_port_id,
output logic ed_dstr_sop,
output logic ed_dstr_eop,
output logic [`RCI_NBITS-1:0] ed_dstr_rci,	
output logic [`PACKET_LENGTH_NBITS-1:0] ed_dstr_pkt_len,	
output logic [VB_NBITS-1:0] ed_dstr_valid_bytes	

);

/***************************** LOCAL VARIABLES *******************************/

localparam PD_FIFO_DEPTH_NBITS = 2;
localparam DATA_PATH_NBYTES = (1<<VB_NBITS);
localparam NUM_OF_PORTS = `NUM_OF_PORTS;

integer i, j;

logic [DATA_NBITS-1:0] n_ed_dstr_packet_data;

logic bm_ed_data_valid_d1;
logic [ID_NBITS-1:0] bm_ed_port_id_d1;
logic bm_ed_sop_d1;
logic bm_ed_eop_d1;
logic [VB_NBITS-1:0] bm_ed_valid_bytes_d1;
logic [DATA_NBITS-1:0] bm_ed_packet_data_d1;
enq_ed_cmd_type bm_ed_cmd_d1;

logic edit_mem_ack_d1;
logic [DATA_NBITS-1:0] edit_mem_rdata_d1;

logic [NUM_OF_PORTS-1:0] sel_port;
logic [ID_NBITS-1:0] sel_port_id;
logic [ID_NBITS-1:0] sel_port_id_d1;
logic [NUM_OF_PORTS-1:0] edit_mem_req_port;

logic [PKT_LEN_NBITS-1:0] pkt_len[NUM_OF_PORTS-1:0];

logic [NUM_OF_PORTS-1:0] cmd_fifo_wr;
logic [NUM_OF_PORTS-1:0] cmd_fifo_rd;
logic [NUM_OF_PORTS-1:0] cmd_fifo_empty;
enq_ed_cmd_type cmd_fifo_data[NUM_OF_PORTS-1:0];

logic [`ENQ_ED_CMD_PTR_UPDATE_RANGE] cmd_fifo_ptr_update[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_CUR_PTR_RANGE] cmd_fifo_cur_ptr[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PTR_LOC_RANGE] cmd_fifo_ptr_loc[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_UPDATE_RANGE] cmd_fifo_pd_update[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_LEN_RANGE] cmd_fifo_pd_len[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_LOC_RANGE] cmd_fifo_pd_loc[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_BP_RANGE] cmd_fifo_pd_bp[NUM_OF_PORTS-1:0];

logic [NUM_OF_PORTS-1:0] pd_fifo_empty;
logic [NUM_OF_PORTS-1:0] pd_fifo_wr;
logic [NUM_OF_PORTS-1:0] pd_fifo_rd;
logic [DATA_NBITS-1:0] pd_fifo_data[NUM_OF_PORTS-1:0];

logic [DATA_NBITS-1:0] mpd_fifo_data[NUM_OF_PORTS-1:0];
logic [DATA_NBITS-1:0] mpd_fifo_data_mask[NUM_OF_PORTS-1:0];
logic [DATA_NBITS-1:0] pd_fifo_data_mask[NUM_OF_PORTS-1:0];
logic [DATA_NBITS-1:0] pd_fifo_data_save[NUM_OF_PORTS-1:0];
logic [DATA_NBITS-1:0] use_pd_fifo_data[NUM_OF_PORTS-1:0];

logic [NUM_OF_PORTS-1:0] ptr_loc_hit;
logic [NUM_OF_PORTS-1:0] rd_done;
logic [NUM_OF_PORTS-1:0] pd_rd_st;
logic [`ENQ_ED_CMD_PD_LEN_NBITS:0] n_rd_len[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_LEN_NBITS:0] rd_len[NUM_OF_PORTS-1:0];
logic [NUM_OF_PORTS-1:0] last_rd;
logic [PD_FIFO_DEPTH_NBITS:0] pd_fifo_count[NUM_OF_PORTS-1:0];
logic [NUM_OF_PORTS-1:0] pd_fifo_full;

logic [`NUM_OF_PORTS-1:0] port_data_valid;

logic [`ENQ_ED_CMD_PD_LEN_NBITS:0] pd_len[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_LEN_NBITS:0] next_first_pd_len[NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_PD_LEN_NBITS:0] next_pd_len[NUM_OF_PORTS-1:0];
logic [NUM_OF_PORTS-1:0] start_pd;
logic [NUM_OF_PORTS-1:0] end_pd;
logic [VB_NBITS-1:0] start_pd_loc[NUM_OF_PORTS-1:0];
logic [VB_NBITS:0] end_pd_loc[NUM_OF_PORTS-1:0];

logic [NUM_OF_PORTS-1:0] pd_loc_hit_st;
logic [VB_NBITS:0] first_pd_len[NUM_OF_PORTS-1:0];

wire n_edit_mem_req = |edit_mem_req_port;

logic [ID_NBITS-1:0] port_fifo_data;
wire port_fifo_wr = n_edit_mem_req;
wire port_fifo_rd = edit_mem_ack_d1;

wire [`ENQ_ED_CMD_OUT_RCI_RANGE] bm_ed_rci_d1 = bm_ed_cmd_d1.out_rci;
wire [`ENQ_ED_CMD_PKT_LEN_RANGE] bm_ed_pkt_len_d1 = bm_ed_cmd_d1.len;

/***************************** NON-REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ************************/

always @(posedge clk) begin
	ed_dstr_port_id <= bm_ed_port_id_d1;
	ed_dstr_sop <= bm_ed_sop_d1;
	ed_dstr_eop <= bm_ed_eop_d1;
	ed_dstr_rci <= bm_ed_rci_d1;
	ed_dstr_pkt_len <= bm_ed_pkt_len_d1;
	ed_dstr_valid_bytes <= bm_ed_valid_bytes_d1;
	ed_dstr_packet_data <= n_ed_dstr_packet_data;
	edit_mem_raddr <= {cmd_fifo_pd_bp[sel_port_id_d1], rd_len[sel_port_id_d1][`PD_CHUNK_DEPTH_NBITS-1:`DATA_PATH_VB_NBITS]};
	edit_mem_port_id <= sel_port_id_d1;
	edit_mem_sop <= rd_len[sel_port_id_d1]==0;
	edit_mem_eop <= last_rd[sel_port_id_d1];

end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		ed_dstr_data_valid <= 1'b0;
		edit_mem_req <= 1'b0;
	end else begin
		ed_dstr_data_valid <= bm_ed_data_valid_d1;
		edit_mem_req <= n_edit_mem_req;
	end
/***************************** PROGRAM BODY **********************************/

always @* begin
	for(i=0; i<NUM_OF_PORTS; i++) begin

		cmd_fifo_ptr_update[i] = cmd_fifo_data[i].ptr_update;
		cmd_fifo_cur_ptr[i] = cmd_fifo_data[i].cur_ptr;
		cmd_fifo_ptr_loc[i] = cmd_fifo_data[i].ptr_loc;
		cmd_fifo_pd_update[i] = cmd_fifo_data[i].pd_update;
		cmd_fifo_pd_len[i] = cmd_fifo_data[i].pd_len;
		cmd_fifo_pd_loc[i] = cmd_fifo_data[i].pd_loc;
		cmd_fifo_pd_bp[i] = cmd_fifo_data[i].pd_buf_ptr;

		port_data_valid[i] = bm_ed_data_valid_d1&(bm_ed_port_id_d1==i);
		cmd_fifo_wr[i] = port_data_valid[i]&bm_ed_sop_d1;
		cmd_fifo_rd[i] = port_data_valid[i]&bm_ed_eop_d1;
		ptr_loc_hit[i] = pkt_len[i][PKT_LEN_NBITS-1:4]==cmd_fifo_ptr_loc[i][LEN_NBITS-1:4];
		pd_fifo_full[i] = pd_fifo_count[i]==(1<<PD_FIFO_DEPTH_NBITS);

		n_rd_len[i] = rd_len[i]+DATA_PATH_NBYTES;
		last_rd[i] = n_rd_len[i]>=cmd_fifo_pd_len[i];

		start_pd[i] = (pkt_len[i][PKT_LEN_NBITS-1:4]==cmd_fifo_pd_loc[i][LEN_NBITS-1:4])&~cmd_fifo_empty[i];
		start_pd_loc[i] = start_pd[i]?cmd_fifo_pd_loc[i]:{(VB_NBITS){1'b0}};
		end_pd[i] = (pd_len[i]+start_pd_loc[i])<(DATA_PATH_NBYTES+1);
		end_pd_loc[i] = start_pd[i]&end_pd[i]?pd_len[i][VB_NBITS:0]+start_pd_loc[i]:end_pd[i]?pd_len[i][VB_NBITS:0]:DATA_PATH_NBYTES;
		first_pd_len[i] = DATA_PATH_NBYTES - cmd_fifo_pd_loc[i][VB_NBITS-1:0];
		next_first_pd_len[i] = pd_len[i]>first_pd_len[i]?pd_len[i]-first_pd_len[i]:0;
		next_pd_len[i] = pd_len[i]>DATA_PATH_NBYTES?pd_len[i]-DATA_PATH_NBYTES:0;

		mpd_fifo_data[i] = rot(pd_fifo_data[i], cmd_fifo_pd_loc[i][VB_NBITS-1:0]);
		mpd_fifo_data_mask[i] = shift(cmd_fifo_pd_loc[i][VB_NBITS-1:0]);
		for(j=0; j<DATA_NBITS; j++) 
			use_pd_fifo_data[i][j] = mpd_fifo_data_mask[i][j]?mpd_fifo_data[i][j]:pd_fifo_data_save[i][j];

		pd_fifo_wr[i] = edit_mem_ack_d1&(port_fifo_data==i);
		pd_fifo_rd[i] = port_data_valid[i]&(start_pd[i]|pd_loc_hit_st[i])&~pd_fifo_empty[i];
	end


	n_ed_dstr_packet_data = bm_ed_packet_data_d1;
	if (cmd_fifo_ptr_update[bm_ed_port_id_d1]&ptr_loc_hit[bm_ed_port_id_d1])
		case(cmd_fifo_ptr_loc[bm_ed_port_id_d1][3:1])
			3'h7: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*1-1:`ENQ_ED_CMD_CUR_PTR_NBITS*0] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			3'h6: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*2-1:`ENQ_ED_CMD_CUR_PTR_NBITS*1] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			3'h5: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*3-1:`ENQ_ED_CMD_CUR_PTR_NBITS*2] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			3'h4: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*4-1:`ENQ_ED_CMD_CUR_PTR_NBITS*3] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			3'h3: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*5-1:`ENQ_ED_CMD_CUR_PTR_NBITS*4] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			3'h2: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*6-1:`ENQ_ED_CMD_CUR_PTR_NBITS*5] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			3'h1: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*7-1:`ENQ_ED_CMD_CUR_PTR_NBITS*6] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
			default: n_ed_dstr_packet_data[`ENQ_ED_CMD_CUR_PTR_NBITS*8-1:`ENQ_ED_CMD_CUR_PTR_NBITS*7] = cmd_fifo_cur_ptr[bm_ed_port_id_d1];
		endcase
	if (cmd_fifo_pd_update[bm_ed_port_id_d1]&(start_pd[bm_ed_port_id_d1]|pd_loc_hit_st[bm_ed_port_id_d1])) begin
		if(0>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&0<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*16-1:8*15] = use_pd_fifo_data[bm_ed_port_id_d1][8*16-1:8*15];
		if(1>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&1<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*15-1:8*14] = use_pd_fifo_data[bm_ed_port_id_d1][8*15-1:8*14];
		if(2>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&2<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*14-1:8*13] = use_pd_fifo_data[bm_ed_port_id_d1][8*14-1:8*13];
		if(3>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&3<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*13-1:8*12] = use_pd_fifo_data[bm_ed_port_id_d1][8*13-1:8*12];
		if(4>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&4<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*12-1:8*11] = use_pd_fifo_data[bm_ed_port_id_d1][8*12-1:8*11];
		if(5>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&5<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*11-1:8*10] = use_pd_fifo_data[bm_ed_port_id_d1][8*11-1:8*10];
		if(6>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&6<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*10-1:8*9] = use_pd_fifo_data[bm_ed_port_id_d1][8*10-1:8*9];
		if(7>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&7<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*9-1:8*8] = use_pd_fifo_data[bm_ed_port_id_d1][8*9-1:8*8];
		if(8>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&8<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*8-1:8*7] = use_pd_fifo_data[bm_ed_port_id_d1][8*8-1:8*7];
		if(9>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&9<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*7-1:8*6] = use_pd_fifo_data[bm_ed_port_id_d1][8*7-1:8*6];
		if(10>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&10<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*6-1:8*5] = use_pd_fifo_data[bm_ed_port_id_d1][8*6-1:8*5];
		if(11>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&11<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*5-1:8*4] = use_pd_fifo_data[bm_ed_port_id_d1][8*5-1:8*4];
		if(12>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&12<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*4-1:8*3] = use_pd_fifo_data[bm_ed_port_id_d1][8*4-1:8*3];
		if(13>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&13<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*3-1:8*2] = use_pd_fifo_data[bm_ed_port_id_d1][8*3-1:8*2];
		if(14>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&14<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*2-1:8*1] = use_pd_fifo_data[bm_ed_port_id_d1][8*2-1:8*1];
		if(15>=start_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]&&15<end_pd_loc[bm_ed_port_id_d1][VB_NBITS-1:0]) n_ed_dstr_packet_data[8*1-1:8*0] = use_pd_fifo_data[bm_ed_port_id_d1][8*1-1:8*0];
	end

end

always @(posedge clk) begin
	bm_ed_port_id_d1 <= bm_ed_port_id;
	bm_ed_sop_d1 <= bm_ed_sop;
	bm_ed_eop_d1 <= bm_ed_eop;
	bm_ed_valid_bytes_d1 <= bm_ed_valid_bytes;
	bm_ed_packet_data_d1 <= bm_ed_packet_data;
	bm_ed_cmd_d1 <= bm_ed_cmd;
	edit_mem_rdata_d1 <= edit_mem_rdata;
	for(i=0; i<NUM_OF_PORTS; i++) begin
		pd_fifo_data_save[i] <= ~port_data_valid[i]?pd_fifo_data_save[i]:mpd_fifo_data[i];
	end
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		bm_ed_data_valid_d1 <= 1'b0;
		edit_mem_ack_d1 <= 1'b0;

		sel_port_id_d1 <= 0;

		for(i=0; i<NUM_OF_PORTS; i++) begin
			pkt_len[i] <= 0;
			edit_mem_req_port[i] <= 1'b0;
			rd_done[i] <= 1'b0;
			rd_len[i] <= 0;
			pd_fifo_count[i] <= 0;

			pd_loc_hit_st[i] <= 1'b0;
			pd_len[i] <= 0;
		end
	end else begin
		bm_ed_data_valid_d1 <= bm_ed_data_valid;
		edit_mem_ack_d1 <= edit_mem_ack;

		sel_port_id_d1 <= sel_port_id;

		for(i=0; i<NUM_OF_PORTS; i++) begin
			pkt_len[i] <= port_data_valid[i]?(bm_ed_eop_d1?0:pkt_len[i]+`DATA_PATH_NBYTES):pkt_len[i];
			edit_mem_req_port[i] <= sel_port[i]&~cmd_fifo_empty[i]&cmd_fifo_pd_update[i]&~rd_done[i]&~pd_fifo_full[i];
			rd_done[i] <= cmd_fifo_rd[i]?1'b0:edit_mem_req_port[i]&last_rd[i]?1'b1:rd_done[i];
			rd_len[i] <= edit_mem_req_port[i]?rd_len[i]+DATA_PATH_NBYTES:cmd_fifo_rd[i]?0:rd_len[i];
			pd_fifo_count[i] <= ~pd_fifo_rd[i]^edit_mem_req_port[i]?pd_fifo_count[i]:pd_fifo_rd[i]?pd_fifo_count[i]-1'b1:pd_fifo_count[i]+1'b1;

			pd_loc_hit_st[i] <= ~port_data_valid[i]?pd_loc_hit_st[i]:bm_ed_eop_d1?1'b0:start_pd[i]?1'b1:end_pd[i]?1'b0:pd_loc_hit_st[i];
			pd_len[i] <= ~port_data_valid[i]?pd_len[i]:bm_ed_sop_d1?{~|bm_ed_cmd_d1.pd_len, bm_ed_cmd_d1.pd_len}:start_pd[i]?next_first_pd_len[i]:pd_loc_hit_st[i]?next_pd_len[i]:pd_len[i];
		end

	end

genvar gi;

generate
	for(gi=0; gi<NUM_OF_PORTS; gi++) begin

sfifo_enq_ed_cmd #(1) u_sfifo_enq_ed_cmd(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(bm_ed_cmd_d1),				
		.rd(cmd_fifo_rd[gi]),
		.wr(cmd_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(),
		.empty(cmd_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(cmd_fifo_data[gi])       
);

sfifo2f_fo #(DATA_NBITS, PD_FIFO_DEPTH_NBITS) u_sfifo2f_fo(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({edit_mem_rdata_d1}),				
		.rd(pd_fifo_rd[gi]),
		.wr(pd_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(),
		.empty(pd_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({pd_fifo_data[gi]})       
);

	end
endgenerate


port_scheduler u_port_scheduler(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
        .en(1'b1),

        // outputs

        .rot_cnt(),
        .sel_port(sel_port),
        .sel_port_id(sel_port_id)

    );

sfifo2f_fo #(ID_NBITS, PD_FIFO_DEPTH_NBITS+1+ID_NBITS) u_sfifo2f_fo1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({sel_port_id_d1}),				
		.rd(port_fifo_rd),
		.wr(port_fifo_wr),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({port_fifo_data})       
);

function [DATA_NBITS-1:0] rot;
input[DATA_NBITS-1:0] din;
input[3:0] rot_cnt;

reg[DATA_NBITS-1:0] din0;
reg[DATA_NBITS-1:0] din1;
reg[DATA_NBITS-1:0] din2;

begin
    din0 = rot_cnt[3]?{din[63:0], din[127:64]}:din;
    din1 = rot_cnt[2]?{din0[31:0], din0[127:32]}:din0;
    din2 = rot_cnt[1]?{din1[15:0], din1[127:16]}:din1;
    rot = rot_cnt[0]?{din2[7:0], din2[127:8]}:din2;
end
endfunction

function [DATA_NBITS-1:0] shift;
input[3:0] shift_cnt;

reg[DATA_NBITS-1:0] din0;
reg[DATA_NBITS-1:0] din1;
reg[DATA_NBITS-1:0] din2;

begin
    din0 = shift_cnt[3]?{{(64){1'b0}}, {(64){1'b1}}}:{(128){1'b1}};
    din1 = shift_cnt[2]?{{(32){1'b0}}, din0[127:32]}:din0;
    din2 = shift_cnt[1]?{{(16){1'b0}}, din1[127:16]}:din1;
    shift = shift_cnt[0]?{{(8){1'b0}}, din2[127:8]}:din2;
end
endfunction


endmodule   						
