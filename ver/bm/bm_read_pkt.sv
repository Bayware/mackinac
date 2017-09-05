//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : request packet data from the buffer manager 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module bm_read_pkt (


input clk, 
input `RESET_SIG,

input tm_bm_enq_req,
input enq_pkt_desc_type tm_bm_enq_pkt_desc,

input packet_ack_data_valid,
input [`PORT_ID_NBITS-1:0] packet_ack_port_id,
input packet_ack_sop,

input packet_ack_buf_valid,
input [`BUF_PTR_NBITS-1:0] packet_ack_buf_ptr,

input [`NUM_OF_PORTS-1:0] ed_bm_bp,

output logic [`NUM_OF_PORTS-1:0] bm_tm_bp,

output logic packet_buf_req,
output logic [`BUF_PTR_NBITS-1:0] packet_buf_req_ptr,
			
output logic packet_req,			
output logic [`PORT_ID_NBITS-1:0] packet_req_src_port_id,
output logic [`PORT_ID_NBITS-1:0] packet_req_dst_port_id,
output logic packet_req_sop,
output logic packet_req_eop,
output logic [`DATA_PATH_VB_RANGE] packet_req_valid_bytes,
output logic [`BUF_PTR_NBITS-1:0] packet_req_buf_ptr,
output logic [`BUF_PTR_LSB_RANGE] packet_req_buf_ptr_lsb,

output enq_ed_cmd_type bm_ed_cmd

);
/***************************** LOCAL VARIABLES *******************************/

`define BUF_FIFO_DEPTH_NBITS 5
`define BUF_FIFO_DEPTH (1<<`BUF_FIFO_DEPTH_NBITS)
`define BUF_FIFO_AVAIL_LEVEL `BUF_FIFO_DEPTH - (`BUF_FIFO_DEPTH>>2)

integer i;

logic tm_bm_enq_req_d1;
enq_pkt_desc_type tm_bm_enq_pkt_desc_d1;

logic packet_ack_data_valid_d1;
logic [`PORT_ID_NBITS-1:0] packet_ack_port_id_d1;
logic packet_ack_sop_d1;

logic packet_ack_buf_valid_d1;
logic [`BUF_PTR_NBITS-1:0] packet_ack_buf_ptr_d1;

logic [`NUM_OF_PORTS-1:0] ed_bm_bp_d1;
logic [`NUM_OF_PORTS-1:0] ed_bm_bp_d2;

enq_pkt_desc_type pre_buf_fifo_pkt_desc[`NUM_OF_PORTS-1:0];
enq_pkt_desc_type buf_fifo_pkt_desc[`NUM_OF_PORTS-1:0];

logic packet_buf_req_p1;
			
logic [`PORT_ID_NBITS-1:0] tm_bm_enq_dst_port_d1 = tm_bm_enq_pkt_desc_d1.dst_port;
logic [`PACKET_LENGTH_NBITS-1:0] pre_buf_fifo_pkt_len[`NUM_OF_PORTS-1:0];
logic [`PORT_ID_NBITS-1:0] pre_buf_fifo_src_port[`NUM_OF_PORTS-1:0];
logic [`PORT_ID_NBITS-1:0] pre_buf_fifo_dst_port[`NUM_OF_PORTS-1:0];
logic [`BUF_PTR_NBITS-1:0] pre_buf_fifo_buf_ptr[`NUM_OF_PORTS-1:0];
enq_ed_cmd_type pre_buf_fifo_ed_cmd[`NUM_OF_PORTS-1:0];

logic [`BUF_FIFO_DEPTH_NBITS:0] pre_buf_fifo_count[`NUM_OF_PORTS-1:0];
logic [`PACKET_LENGTH_NBITS-1:0] pre_buf_fifo_packet_length[`NUM_OF_PORTS-1:0];
logic [`ENQ_ED_CMD_NBITS-1:0] pre_buf_fifo_edit_command[`NUM_OF_PORTS-1:0];

logic [`PACKET_LENGTH_NBITS-1:0] buf_fifo_pkt_len[`NUM_OF_PORTS-1:0];
logic [`BUF_PTR_NBITS-1:0] buf_fifo_buf_ptr[`NUM_OF_PORTS-1:0];
logic [`PORT_ID_NBITS-1:0] buf_fifo_src_port[`NUM_OF_PORTS-1:0];

logic [`BUF_PTR_NBITS-1:0] first_ptr_fifo_buf_ptr[`NUM_OF_PORTS-1:0];
logic [`BUF_PTR_NBITS-1:0] ptr_fifo_buf_ptr[`NUM_OF_PORTS-1:0];

enq_ed_cmd_type edit_fifo_edit_command[`NUM_OF_PORTS-1:0];

logic [`BUF_PTR_NBITS-1:0] pb_fifo_buf_ptr[`NUM_OF_PORTS-1:0];

logic [`BUF_PTR_NBITS-1:0] pb_req_fifo_buf_ptr[`NUM_OF_PORTS-1:0];

logic [`BUF_PTR_NBITS-1:0] req_fifo_packet_req_buf_ptr[`NUM_OF_PORTS-1:0];
logic [`DATA_PATH_VB_RANGE] req_fifo_packet_req_valid_bytes[`NUM_OF_PORTS-1:0];
logic [`PORT_ID_NBITS-1:0] req_fifo_packet_req_src_port[`NUM_OF_PORTS-1:0];

logic [`BUF_PTR_LSB_NBITS-1:0] req_fifo_packet_req_lsb[`NUM_OF_PORTS-1:0];
logic [`NUM_OF_PORTS-1:0] req_fifo_packet_req_sop;
logic [`NUM_OF_PORTS-1:0] req_fifo_packet_req_eop;

logic [`NUM_OF_PORTS-1:0] tran_fifo_sop;
logic [`NUM_OF_PORTS-1:0] tran_fifo_eop;

logic [`NUM_OF_PORTS-1:0] pre_buf_fifo_empty;
logic [`NUM_OF_PORTS-1:0] ptr_fifo_wr;

logic [`NUM_OF_PORTS-1:0] tran_fifo_rd;
logic [`NUM_OF_PORTS-1:0] pb_req_fifo_wr;
logic [`NUM_OF_PORTS-1:0] first_ptr_fifo_rd;
logic [`NUM_OF_PORTS-1:0] pb_fifo_rd;

logic [`NUM_OF_PORTS-1:0] pb_req_fifo_full, tran_fifo_empty, pb_fifo_empty, first_ptr_fifo_empty, ptr_fifo_full;

logic [`NUM_OF_PORTS-1:0] tran_fifo_full, buf_fifo_full, edit_fifo_full, first_ptr_fifo_full;

logic [`NUM_OF_PORTS-1:0] tran_eop;
logic [`NUM_OF_PORTS-1:0] tran_fifo_wr;
logic [`NUM_OF_PORTS-1:0] pre_buf_fifo_rd;
logic [`NUM_OF_PORTS-1:0] buf_fifo_wr;
logic [`NUM_OF_PORTS-1:0] edit_fifo_wr;
logic [`NUM_OF_PORTS-1:0] first_ptr_fifo_wr;

logic [`NUM_OF_PORTS-1:0] pb_req_fifo_empty;
logic [`NUM_OF_PORTS-1:0] pb_req_fifo_rd;

logic [`NUM_OF_PORTS-1:0] sop_eop;
logic [`NUM_OF_PORTS-1:0] nsop_eop;
logic [`NUM_OF_PORTS-1:0] port_packet_req_eop;
logic [`DATA_PATH_VB_RANGE] sop_valid_bytes[`NUM_OF_PORTS-1:0];
logic [`DATA_PATH_VB_RANGE] nsop_valid_bytes[`NUM_OF_PORTS-1:0];
logic [`DATA_PATH_VB_RANGE] port_packet_req_valid_bytes[`NUM_OF_PORTS-1:0];

logic [`NUM_OF_PORTS-1:0] req_fifo_full;
logic [`NUM_OF_PORTS-1:0] buf_fifo_empty;
logic [`NUM_OF_PORTS-1:0] ptr_fifo_empty;
logic [`NUM_OF_PORTS-1:0] req_fifo_wr;
logic [`NUM_OF_PORTS-1:0] buf_fifo_rd;
logic [`NUM_OF_PORTS-1:0] ptr_fifo_rd;

logic [`NUM_OF_PORTS-1:0] req_fifo_empty;
logic [`NUM_OF_PORTS-1:0] req_fifo_rd;

logic [`NUM_OF_PORTS-1:0] port_packet_req_sop;

logic [`NUM_OF_PORTS-1:0] tran_sop /* synthesis maxfan = 16 preserve */;

logic [`PACKET_LENGTH_NBITS-1:0] tran_packet_length_ctr[`NUM_OF_PORTS-1:0];
logic [`PACKET_LENGTH_NBITS-1:0] packet_length_ctr[`NUM_OF_PORTS-1:0];
logic [`BUF_PTR_LSB_NBITS-1:0] packet_req_lsb[`NUM_OF_PORTS-1:0];
logic [`NUM_OF_PORTS-1:0] first_buf;

logic [`NUM_OF_PORTS-1:0] sel_port;
logic [`PORT_ID_NBITS-1:0] sel_port_id /* synthesis maxfan = 16 preserve */;

logic [`NUM_OF_PORTS-1:0] data_sel_port;
logic [`PORT_ID_NBITS-1:0] data_sel_port_id /* synthesis maxfan = 16 preserve */;

logic [`PORT_ID_NBITS-1:0] save_fifo_sel_port_id;

logic [`NUM_OF_PORTS-1:0] fifo_avail;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		packet_req_dst_port_id <= data_sel_port_id;
		packet_req_src_port_id <= req_fifo_packet_req_src_port[data_sel_port_id];	
		packet_req_sop <= req_fifo_packet_req_sop[data_sel_port_id];	
		packet_req_eop <= req_fifo_packet_req_eop[data_sel_port_id];	
		packet_req_valid_bytes <= req_fifo_packet_req_valid_bytes[data_sel_port_id];	
		packet_req_buf_ptr <= req_fifo_packet_req_buf_ptr[data_sel_port_id];	
		packet_req_buf_ptr_lsb <= req_fifo_packet_req_lsb[data_sel_port_id];	
		bm_ed_cmd <= edit_fifo_edit_command[packet_ack_port_id_d1];	
		packet_buf_req_ptr <= pb_req_fifo_buf_ptr[sel_port_id];	

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		bm_tm_bp <= 0;
		packet_buf_req <= 0;
		packet_req <= 0;
	end else begin
		bm_tm_bp <= ~fifo_avail;
		packet_buf_req <= packet_buf_req_p1;
		packet_req <= req_fifo_rd[data_sel_port_id];
	end

/***************************** PROGRAM BODY **********************************/

always @(*) begin
	packet_buf_req_p1 = ~pb_req_fifo_empty[sel_port_id];
	for (i=0; i<`NUM_OF_PORTS; i++) begin
		fifo_avail[i] <= pre_buf_fifo_count[i]<`BUF_FIFO_AVAIL_LEVEL;
	end
end

always @(posedge clk) begin
		tm_bm_enq_pkt_desc_d1 <= tm_bm_enq_pkt_desc;
		packet_ack_buf_ptr_d1 <= packet_ack_buf_ptr;
		packet_ack_port_id_d1 <= packet_ack_port_id;
		packet_ack_sop_d1 <= packet_ack_sop;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		tm_bm_enq_req_d1 <= 0;
		packet_ack_data_valid_d1 <= 0;
		packet_ack_buf_valid_d1 <= 0;
		ed_bm_bp_d1 <= 0;
		ed_bm_bp_d2 <= 0;

		port_packet_req_sop <= {(`NUM_OF_PORTS){1'b1}};
		tran_sop <= {(`NUM_OF_PORTS){1'b1}};

		for (i=0; i<`NUM_OF_PORTS; i++) begin
			tran_packet_length_ctr[i] <= 0;
			packet_length_ctr[i] <= 0;
			packet_req_lsb[i] <= 0;
		end
		first_buf <= 1;

	end else begin

		tm_bm_enq_req_d1 <= tm_bm_enq_req;
		packet_ack_data_valid_d1 <= packet_ack_data_valid;
		packet_ack_buf_valid_d1 <= packet_ack_buf_valid;
		ed_bm_bp_d1 <= ed_bm_bp;
		ed_bm_bp_d2 <= ed_bm_bp_d1;

		for (i=0; i<`NUM_OF_PORTS; i++) begin
			port_packet_req_sop[i] <= req_fifo_wr[i]?(port_packet_req_eop[i]?1:0):port_packet_req_sop[i];
			tran_sop[i] <= tran_fifo_wr[i]?(tran_eop[i]?1:0):tran_sop[i];
			tran_packet_length_ctr[i] <= tran_fifo_wr[i]?(tran_eop[i]?0:tran_sop[i]?pre_buf_fifo_packet_length[i]-`BUF_SIZE:tran_packet_length_ctr[i]-`BUF_SIZE):tran_packet_length_ctr[i];
			packet_length_ctr[i] <= req_fifo_wr[i]?(port_packet_req_eop[i]?0:port_packet_req_sop[i]?buf_fifo_pkt_len[i]-`DATA_PATH_NBYTES:packet_length_ctr[i]-`DATA_PATH_NBYTES):packet_length_ctr[i];
			packet_req_lsb[i] <= req_fifo_wr[i]?(port_packet_req_eop[i]?0:&packet_req_lsb[i]?0:packet_req_lsb[i]+1):packet_req_lsb[i];
			first_buf[i] <= req_fifo_wr[i]&port_packet_req_eop[i]?1:req_fifo_wr[i]&(&packet_req_lsb[i])?0:first_buf[i];
		end

	end


/***************************** Port Scheduler ***************************************/

port_scheduler u_port_scheduler_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),
		.en(1'b1),

		// outputs

		.rot_cnt(),
		.sel_port(sel_port),
		.sel_port_id(sel_port_id)

	);

port_scheduler u_port_scheduler_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),
		.en(1'b1),

		// outputs

		.rot_cnt(),
		.sel_port(data_sel_port),
		.sel_port_id(data_sel_port_id)

	);


always @(*)
	for (i=0; i<`NUM_OF_PORTS; i++) begin
		pre_buf_fifo_src_port[i] = pre_buf_fifo_pkt_desc[i].src_port;
		pre_buf_fifo_dst_port[i] = pre_buf_fifo_pkt_desc[i].dst_port;
		pre_buf_fifo_buf_ptr[i] = pre_buf_fifo_pkt_desc[i].buf_ptr;
		pre_buf_fifo_ed_cmd[i] = pre_buf_fifo_pkt_desc[i].ed_cmd;
		pre_buf_fifo_pkt_len[i] = pre_buf_fifo_pkt_desc[i].ed_cmd.len;
	end

genvar gi;

generate
for (gi=0; gi<`NUM_OF_PORTS; gi++) begin

assign tran_eop[gi] = tran_sop[gi]?~(pre_buf_fifo_packet_length[gi]>`BUF_SIZE):~(tran_packet_length_ctr[gi]>`BUF_SIZE);
assign tran_fifo_wr[gi] = (tran_sop[gi]?~pre_buf_fifo_empty[gi]&~buf_fifo_full[gi]&~edit_fifo_full[gi]&~first_ptr_fifo_full[gi]:1)&~tran_fifo_full[gi];
assign pre_buf_fifo_rd[gi] = tran_fifo_wr[gi]&tran_sop[gi];
assign buf_fifo_wr[gi] = pre_buf_fifo_rd[gi];
assign edit_fifo_wr[gi] = pre_buf_fifo_rd[gi];
assign first_ptr_fifo_wr[gi] = pre_buf_fifo_rd[gi];

always @(*) begin
	case({tran_fifo_sop[gi], tran_fifo_eop[gi]})
		0: begin
			tran_fifo_rd[gi] = ~tran_fifo_empty[gi]&~pb_req_fifo_full[gi]&~pb_fifo_empty[gi]&~ptr_fifo_full[gi];
			pb_req_fifo_wr[gi] = tran_fifo_rd[gi];
			first_ptr_fifo_rd[gi] = 0;
			pb_fifo_rd[gi] = tran_fifo_rd[gi];
			ptr_fifo_wr[gi] = tran_fifo_rd[gi];
		end
		1: begin
			tran_fifo_rd[gi] = ~tran_fifo_empty[gi]&~pb_fifo_empty[gi]&~ptr_fifo_full[gi];
			pb_req_fifo_wr[gi] = 0;
			first_ptr_fifo_rd[gi] = 0;
			pb_fifo_rd[gi] = tran_fifo_rd[gi];
			ptr_fifo_wr[gi] = tran_fifo_rd[gi];
		end
		2: begin
			tran_fifo_rd[gi] = ~tran_fifo_empty[gi]&~pb_req_fifo_full[gi]&~first_ptr_fifo_empty[gi];
			pb_req_fifo_wr[gi] = tran_fifo_rd[gi];
			first_ptr_fifo_rd[gi] = tran_fifo_rd[gi];
			pb_fifo_rd[gi] = 0;
			ptr_fifo_wr[gi] = 0;
		end
		default: begin
			tran_fifo_rd[gi] = ~tran_fifo_empty[gi]&~first_ptr_fifo_empty[gi];
			pb_req_fifo_wr[gi] = 0;
			first_ptr_fifo_rd[gi] = tran_fifo_rd[gi];
			pb_fifo_rd[gi] = 0;
			ptr_fifo_wr[gi] = 0;
		end
	endcase
end

assign pb_req_fifo_rd[gi] = sel_port[gi]&~pb_req_fifo_empty[gi];

assign nsop_eop[gi] = packet_length_ctr[gi]<(`DATA_PATH_NBYTES+1);
assign port_packet_req_eop[gi] = port_packet_req_sop[gi]?sop_eop[gi]:nsop_eop[gi];
assign sop_valid_bytes[gi] = sop_eop[gi]?buf_fifo_pkt_len[gi]:`DATA_PATH_NBYTES;
assign nsop_valid_bytes[gi] = nsop_eop[gi]?packet_length_ctr[gi]:`DATA_PATH_NBYTES;
assign port_packet_req_valid_bytes[gi] = port_packet_req_sop[gi]?sop_valid_bytes[gi]:nsop_valid_bytes[gi];

assign req_fifo_wr[gi] = ~buf_fifo_empty[gi]&~req_fifo_full[gi]&(first_buf[gi]|~ptr_fifo_empty[gi]);
assign buf_fifo_rd[gi] = req_fifo_wr[gi]&port_packet_req_eop[gi];
assign ptr_fifo_rd[gi] = req_fifo_wr[gi]&~first_buf[gi]&(&packet_req_lsb[gi]|port_packet_req_eop[gi]);

assign req_fifo_rd[gi] = data_sel_port[gi]&~req_fifo_empty[gi]&~ed_bm_bp_d2[gi];

/***************************** FIFO ***************************************/

sfifo_enq_pkt_desc #(`BUF_FIFO_DEPTH_NBITS) u_sfifo_enq_pkt_desc_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(tm_bm_enq_pkt_desc_d1),				
		.rd(pre_buf_fifo_rd[gi]),
		.wr(tm_bm_enq_req_d1&(tm_bm_enq_dst_port_d1==gi)),

		.ncount(),
		.count(pre_buf_fifo_count[gi]),
		.full(),
		.empty(pre_buf_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(pre_buf_fifo_pkt_desc[gi])       
	);

sfifo2f1 #(`PORT_ID_NBITS+`BUF_PTR_NBITS+`PACKET_LENGTH_NBITS+1) u_sfifo2f1_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pre_buf_fifo_src_port[gi], pre_buf_fifo_buf_ptr[gi], pre_buf_fifo_pkt_len[gi], (pre_buf_fifo_pkt_len[gi]<(`DATA_PATH_NBYTES+1)?1'b1:1'b0)}),				
		.rd(buf_fifo_rd[gi]),
		.wr(buf_fifo_wr[gi]),

		.count(),
		.full(buf_fifo_full[gi]),
		.empty(buf_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({buf_fifo_src_port[gi], buf_fifo_buf_ptr[gi], buf_fifo_pkt_len[gi], sop_eop[gi]})       
	);

sfifo_enq_ed_cmd #(1) u_sfifo_enq_ed_cmd_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pre_buf_fifo_ed_cmd[gi]),       
		.rd(buf_fifo_rd[gi]),
		.wr(buf_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(edit_fifo_edit_command[gi])       
	);

sfifo2f1 #(`BUF_PTR_NBITS) u_sfifo2f1_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pre_buf_fifo_buf_ptr[gi]),				
		.rd(first_ptr_fifo_rd[gi]),
		.wr(first_ptr_fifo_wr[gi]),

		.count(),
		.full(first_ptr_fifo_full[gi]),
		.empty(first_ptr_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(first_ptr_fifo_buf_ptr[gi])       
	);

sfifo2f_fo #(2, 2) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({tran_sop[gi], tran_eop[gi]}),				
		.rd(tran_fifo_rd[gi]),
		.wr(tran_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(tran_fifo_full[gi]),
		.empty(tran_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({tran_fifo_sop[gi], tran_fifo_eop[gi]})       
	);

sfifo2f_fo #(`BUF_PTR_NBITS, 2) u_sfifo2f_fo_6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(packet_ack_buf_ptr_d1),				
		.rd(pb_fifo_rd[gi]),
		.wr(packet_ack_buf_valid_d1&(save_fifo_sel_port_id==gi)),

		.ncount(),
		.count(),
		.full(),
		.empty(pb_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(pb_fifo_buf_ptr[gi])       
	);

sfifo2f1 #(`BUF_PTR_NBITS) u_sfifo2f1_7(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(ptr_fifo_rd[gi]?first_ptr_fifo_buf_ptr[gi]:pb_fifo_buf_ptr[gi]),				
		.rd(pb_req_fifo_rd[gi]),
		.wr(pb_req_fifo_wr[gi]),

		.count(),
		.full(pb_req_fifo_full[gi]),
		.empty(pb_req_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(pb_req_fifo_buf_ptr[gi])       
	);

sfifo2f_fo #(`BUF_PTR_NBITS, 2) u_sfifo2f_fo_8(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pb_fifo_buf_ptr[gi]),				
		.rd(ptr_fifo_rd[gi]),
		.wr(ptr_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(ptr_fifo_full[gi]),
		.empty(ptr_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(ptr_fifo_buf_ptr[gi])       
	);

sfifo2f_fo #(`DATA_PATH_VB_NBITS+`BUF_PTR_NBITS+`BUF_PTR_LSB_NBITS+`PORT_ID_NBITS+2, 3) u_sfifo2f_fo_9(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({port_packet_req_valid_bytes[gi], (first_buf[gi]?buf_fifo_buf_ptr[gi]:ptr_fifo_buf_ptr[gi]), packet_req_lsb[gi], buf_fifo_src_port[gi], port_packet_req_sop[gi], port_packet_req_eop[gi]}),				
		.rd(req_fifo_rd[gi]),
		.wr(req_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(req_fifo_full[gi]),
		.empty(req_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({req_fifo_packet_req_valid_bytes[gi], req_fifo_packet_req_buf_ptr[gi], req_fifo_packet_req_lsb[gi], req_fifo_packet_req_src_port[gi], req_fifo_packet_req_sop[gi], req_fifo_packet_req_eop[gi]})       
	);

end
endgenerate


sfifo2f_fo #(`PORT_ID_NBITS, 3) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(sel_port_id),				
		.rd(packet_ack_buf_valid_d1),
		.wr(packet_buf_req_p1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(save_fifo_sel_port_id)       
	);


/***************************** MEMORY ***************************************/

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

