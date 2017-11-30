//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_read_data #(
parameter BPTR_NBITS = `PIARB_BUF_PTR_NBITS,
parameter BPTR_LSB_NBITS = `PIARB_BUF_PTR_LSB_NBITS,
parameter ID_NBITS = `PU_ID_NBITS,
parameter LEN_NBITS = `PATH_CHUNK_NBITS,
parameter DESC_NBITS = `PU_QUEUE_PAYLOAD_NBITS,
parameter DATA_NBITS = `HOP_INFO_NBITS,
parameter DATA_SIZE = 1,
parameter BUF_SIZE = 2,
parameter TYPE = 0
) (

input clk, 
input `RESET_SIG,

input deq_ack,
input [ID_NBITS-1:0] deq_ack_qid,
input pu_queue_payload_type deq_ack_desc,

input data_ack_valid,
input [ID_NBITS-1:0] data_ack_qid,
input data_ack_sop,

input buf_ack_valid,
input [BPTR_NBITS-1:0] buf_ack_ptr,

output logic buf_req,
output logic [BPTR_NBITS-1:0] buf_req_ptr,
			
output logic data_req,			
output logic [ID_NBITS-1:0] data_req_src_port_id,
output logic [ID_NBITS-1:0] data_req_dst_port_id,
output logic data_req_sop,
output logic data_req_eop,
output logic [BPTR_NBITS-1:0] data_req_buf_ptr,
output logic [BPTR_LSB_NBITS-1:0] data_req_buf_ptr_lsb,
output logic data_req_inst,

output pp_piarb_meta_type data_ack_meta

);
/***************************** LOCAL VARIABLES *******************************/

localparam BUF_FIFO_DEPTH_NBITS = 5;
localparam BUF_FIFO_DEPTH = (1<<BUF_FIFO_DEPTH_NBITS);
localparam BUF_FIFO_AVAIL_LEVEL = BUF_FIFO_DEPTH - (BUF_FIFO_DEPTH>>2);

integer i;

logic deq_ack_d1;
logic [ID_NBITS-1:0] deq_ack_qid_d1;
pu_queue_payload_type deq_ack_desc_d1;
logic [ID_NBITS-1:0] deq_ack_src_port_d1;
logic [ID_NBITS-1:0] deq_ack_dst_port_d1;

logic buf_ack_valid_d1;
logic [BPTR_NBITS-1:0] buf_ack_ptr_d1;

logic buf_req_p1;
logic data_req_p1;
			
logic data_ack_valid_d1;
logic [ID_NBITS-1:0] data_ack_qid_d1;
logic data_ack_sop_d1;

logic data_req_d1;			
logic [ID_NBITS-1:0] data_req_dst_port_id_d1;
logic data_req_sop_d1;

logic data_req_d2;			
logic [ID_NBITS-1:0] data_req_dst_port_id_d2;
logic data_req_sop_d2;

logic [`NUM_OF_PU-1:0] tran_sop /* synthesis maxfan = 16 preserve */;

logic [LEN_NBITS-1:0] tran_length_ctr[`NUM_OF_PU-1:0];
logic [LEN_NBITS-1:0] inst_length_ctr[`NUM_OF_PU-1:0];
logic [LEN_NBITS-1:0] length_ctr[`NUM_OF_PU-1:0];
logic [BPTR_LSB_NBITS-1:0] data_req_lsb[`NUM_OF_PU-1:0];
logic [`NUM_OF_PU-1:0] first_buf;

pp_piarb_meta_type meta_fifo_data[`NUM_OF_PU-1:0];

logic [BUF_FIFO_DEPTH_NBITS:0] pre_buf_fifo_count[`NUM_OF_PU-1:0];
logic [LEN_NBITS-1:0] pre_buf_fifo_length[`NUM_OF_PU-1:0];
logic [LEN_NBITS-1:0] pre_buf_fifo_inst_length[`NUM_OF_PU-1:0];
logic [BPTR_NBITS-1:0] pre_buf_fifo_buf_ptr[`NUM_OF_PU-1:0];
logic [ID_NBITS-1:0] pre_buf_fifo_src_port[`NUM_OF_PU-1:0];

logic [LEN_NBITS-1:0] buf_fifo_length[`NUM_OF_PU-1:0];
logic [LEN_NBITS-1:0] buf_fifo_inst_length[`NUM_OF_PU-1:0];
logic [BPTR_NBITS-1:0] buf_fifo_buf_ptr[`NUM_OF_PU-1:0];
logic [ID_NBITS-1:0] buf_fifo_src_port[`NUM_OF_PU-1:0];

logic [BPTR_NBITS-1:0] first_ptr_fifo_buf_ptr[`NUM_OF_PU-1:0];
logic [BPTR_NBITS-1:0] ptr_fifo_buf_ptr[`NUM_OF_PU-1:0];

logic [BPTR_NBITS-1:0] pb_fifo_buf_ptr[`NUM_OF_PU-1:0];

logic [BPTR_NBITS-1:0] pb_req_fifo_buf_ptr[`NUM_OF_PU-1:0];

logic [BPTR_LSB_NBITS-1:0] req_fifo_data_req_lsb[`NUM_OF_PU-1:0];
logic [BPTR_NBITS-1:0] req_fifo_data_req_buf_ptr[`NUM_OF_PU-1:0];
logic [`NUM_OF_PU-1:0] req_fifo_data_req_sop;
logic [ID_NBITS-1:0] req_fifo_data_req_src_port[`NUM_OF_PU-1:0];
logic [`NUM_OF_PU-1:0] req_fifo_data_req_eop;
logic [`NUM_OF_PU-1:0] req_fifo_data_req_inst;

logic [`NUM_OF_PU-1:0] tran_fifo_sop;
logic [`NUM_OF_PU-1:0] tran_fifo_eop;

logic [`NUM_OF_PU-1:0] pre_buf_fifo_empty;
logic [`NUM_OF_PU-1:0] tran_fifo_full, buf_fifo_full, meta_fifo_full, first_ptr_fifo_full;
logic [`NUM_OF_PU-1:0] tran_eop;
logic [`NUM_OF_PU-1:0] tran_fifo_wr;

logic [`NUM_OF_PU-1:0] pre_buf_fifo_rd;
logic [`NUM_OF_PU-1:0] buf_fifo_wr;
logic [`NUM_OF_PU-1:0] meta_fifo_wr;
logic [`NUM_OF_PU-1:0] meta_fifo_rd;
logic [`NUM_OF_PU-1:0] first_ptr_fifo_wr;

logic [`NUM_OF_PU-1:0] tran_fifo_rd;
logic [`NUM_OF_PU-1:0] pb_req_fifo_wr;
logic [`NUM_OF_PU-1:0] first_ptr_fifo_rd;
logic [`NUM_OF_PU-1:0] pb_fifo_rd;
logic [`NUM_OF_PU-1:0] ptr_fifo_wr;

logic [`NUM_OF_PU-1:0] pb_req_fifo_full, tran_fifo_empty, pb_fifo_empty, first_ptr_fifo_empty, ptr_fifo_full;


logic [`NUM_OF_PU-1:0] pb_req_fifo_empty;
logic [`NUM_OF_PU-1:0] pb_req_fifo_rd;

logic [`NUM_OF_PU-1:0] sop_eop;
logic [`NUM_OF_PU-1:0] nsop_eop;
logic [`NUM_OF_PU-1:0] data_req_sop_in;
logic [`NUM_OF_PU-1:0] data_req_eop_in;

logic [`NUM_OF_PU-1:0] sop_inst;
logic [`NUM_OF_PU-1:0] nsop_inst;
logic [`NUM_OF_PU-1:0] data_req_inst_in;

logic [`NUM_OF_PU-1:0] req_fifo_full;

logic [`NUM_OF_PU-1:0] ptr_fifo_empty;
logic [`NUM_OF_PU-1:0] buf_fifo_empty;
logic [`NUM_OF_PU-1:0] req_fifo_wr;
logic [`NUM_OF_PU-1:0] buf_fifo_rd;
logic [`NUM_OF_PU-1:0] ptr_fifo_rd;

logic [`NUM_OF_PU-1:0] req_fifo_empty;
logic [`NUM_OF_PU-1:0] req_fifo_rd;

logic [`NUM_OF_PU-1:0] sel_port;
logic [ID_NBITS-1:0] sel_port_id /* synthesis maxfan = 16 preserve */;

logic [`NUM_OF_PU-1:0] data_sel_port;
logic [ID_NBITS-1:0] data_sel_port_id /* synthesis maxfan = 16 preserve */;

logic [ID_NBITS-1:0] save_fifo_sel_port_id;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		data_req_dst_port_id <= data_sel_port_id;
		data_req_src_port_id <= req_fifo_data_req_src_port[data_sel_port_id];	
		data_req_sop <= req_fifo_data_req_sop[data_sel_port_id];	
		data_req_eop <= req_fifo_data_req_eop[data_sel_port_id];	
		data_req_buf_ptr <= req_fifo_data_req_buf_ptr[data_sel_port_id];	
		data_req_buf_ptr_lsb <= req_fifo_data_req_lsb[data_sel_port_id];	
		data_req_inst <= req_fifo_data_req_inst[data_sel_port_id];	

		data_ack_meta <= meta_fifo_data[data_req_dst_port_id_d2];	

		buf_req_ptr <= pb_req_fifo_buf_ptr[sel_port_id];	

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		buf_req <= 0;
		data_req <= 0;
	end else begin
		buf_req <= buf_req_p1;
		data_req <= data_req_p1;
	end

/***************************** PROGRAM BODY **********************************/

logic [`NUM_OF_PU-1:0] pb_req_fifo_av;
rr_arb20 u_rr_arb20_1 (.clk(clk), .`RESET_SIG(`RESET_SIG), .req(pb_req_fifo_av), .en(1'b1), .ack(sel_port), .sel(sel_port_id), .gnt(buf_req_p1));

logic [`NUM_OF_PU-1:0] data_req_fifo_av;
rr_arb20 u_rr_arb20_2 (.clk(clk), .`RESET_SIG(`RESET_SIG), .req(data_req_fifo_av), .en(1'b1), .ack(data_sel_port), .sel(data_sel_port_id), .gnt(data_req_p1));

always @(*) begin
	for (i=0; i<`NUM_OF_PU; i++) begin
		pb_req_fifo_av[i] = ~pb_req_fifo_empty[i]&~sel_port[i];
		data_req_fifo_av[i] = ~req_fifo_empty[i]&~data_sel_port[i];
	end
end

always @(posedge clk) begin
		deq_ack_desc_d1 <= deq_ack_desc;
		deq_ack_qid_d1 <= deq_ack_qid;
		deq_ack_src_port_d1 <= deq_ack_qid;
		deq_ack_dst_port_d1 <= deq_ack_qid;

		buf_ack_ptr_d1 <= buf_ack_ptr;

		data_ack_sop_d1 <= data_ack_sop;
		data_ack_qid_d1 <= data_ack_qid;

		data_req_dst_port_id_d1 <= data_req_dst_port_id;
		data_req_sop_d1 <= data_req_sop;

		data_req_dst_port_id_d2 <= data_req_dst_port_id_d1;
		data_req_sop_d2 <= data_req_sop_d1;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		deq_ack_d1 <= 0;

		buf_ack_valid_d1 <= 0;

		data_ack_valid_d1 <= 0;

		data_req_sop_in <= {(`NUM_OF_PU){1'b1}};

		tran_sop <= {(`NUM_OF_PU){1'b1}};

		for (i=0; i<`NUM_OF_PU; i++) begin
			tran_length_ctr[i] <= 0;
			length_ctr[i] <= 0;
			inst_length_ctr[i] <= 0;
			data_req_lsb[i] <= 0;
		end

		first_buf <= {(`NUM_OF_PU){1'b1}};

		data_req_d1 <= 0;
		data_req_d2 <= 0;

	end else begin

		deq_ack_d1 <= deq_ack;

		buf_ack_valid_d1 <= buf_ack_valid;

		data_ack_valid_d1 <= data_ack_valid;

		for (i=0; i<`NUM_OF_PU; i++) begin
			data_req_sop_in[i] <= req_fifo_wr[i]?data_req_eop_in[i]:data_req_sop_in[i];
			tran_sop[i] <= tran_fifo_wr[i]?tran_eop[i]:tran_sop[i];
			tran_length_ctr[i] <= tran_fifo_wr[i]?(tran_eop[i]?0:tran_sop[i]?pre_buf_fifo_length[i]-BUF_SIZE:tran_length_ctr[i]-BUF_SIZE):tran_length_ctr[i];
			length_ctr[i] <= req_fifo_wr[i]?(data_req_eop_in[i]?0:data_req_sop_in[i]?buf_fifo_length[i]-DATA_SIZE:length_ctr[i]-DATA_SIZE):length_ctr[i];
			inst_length_ctr[i] <= req_fifo_wr[i]?(data_req_eop_in[i]?0:data_req_sop_in[i]?(buf_fifo_inst_length[i]<=DATA_SIZE?0:buf_fifo_inst_length[i]-DATA_SIZE):nsop_inst[i]?0:inst_length_ctr[i]-DATA_SIZE):inst_length_ctr[i];
			data_req_lsb[i] <= req_fifo_wr[i]?(data_req_eop_in[i]?0:&data_req_lsb[i]?0:data_req_lsb[i]+1):data_req_lsb[i];
			first_buf[i] <= req_fifo_wr[i]&data_req_eop_in[i]?1:req_fifo_wr[i]&(&data_req_lsb[i])?0:first_buf[i];
		end

		data_req_d1 <= data_req;
		data_req_d2 <= data_req_d1;

	end


pp_piarb_meta_type pre_buf_fifo_pp_meta[`NUM_OF_PU-1:0];

wire [LEN_NBITS-1:0] deq_ack_len = deq_ack_desc_d1.len;
wire [`PD_CHUNK_NBITS-1:0] deq_ack_pd_len = deq_ack_desc_d1.pd_len;
wire [LEN_NBITS-1:0] deq_ack_inst_len = deq_ack_desc_d1.inst_len;
wire [BPTR_NBITS-1:0] deq_ack_buf_ptr = deq_ack_desc_d1.buf_ptr;
wire [BPTR_NBITS-1:0] deq_ack_inst_buf_ptr = deq_ack_desc_d1.inst_buf_ptr;
pp_piarb_meta_type deq_ack_pp_meta;
assign deq_ack_pp_meta = deq_ack_desc_d1.pp_piarb_meta;

wire [LEN_NBITS-1:0] deq_in_len = TYPE==0?deq_ack_len:deq_ack_pd_len+deq_ack_inst_len;
wire [BPTR_NBITS-1:0] deq_in_buf_ptr = TYPE==0?deq_ack_buf_ptr:deq_ack_inst_buf_ptr;


genvar gi;

generate
for (gi=0; gi<`NUM_OF_PU; gi++) begin

assign meta_fifo_rd[gi] = data_req_d2&data_req_sop_d2&(data_req_dst_port_id_d2==gi);

assign tran_eop[gi] = tran_sop[gi]?~(pre_buf_fifo_length[gi]>BUF_SIZE):~(tran_length_ctr[gi]>BUF_SIZE);
assign tran_fifo_wr[gi] = (tran_sop[gi]?~pre_buf_fifo_empty[gi]&~buf_fifo_full[gi]&~meta_fifo_full[gi]&~first_ptr_fifo_full[gi]:1)&~tran_fifo_full[gi];

assign pre_buf_fifo_rd[gi] = tran_fifo_wr[gi]&tran_sop[gi];
assign buf_fifo_wr[gi] = pre_buf_fifo_rd[gi];
assign meta_fifo_wr[gi] = pre_buf_fifo_rd[gi];
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

assign nsop_eop[gi] = length_ctr[gi]<=DATA_SIZE;
assign data_req_eop_in[gi] = data_req_sop_in[gi]?sop_eop[gi]:nsop_eop[gi];

assign sop_inst[gi] = 1'b1;
assign nsop_inst[gi] = inst_length_ctr[gi]<=DATA_SIZE;
assign data_req_inst_in[gi] = data_req_sop_in[gi]?sop_inst[gi]:inst_length_ctr[gi]!=0;

assign req_fifo_wr[gi] = ~buf_fifo_empty[gi]&~req_fifo_full[gi]&(first_buf[gi]|~ptr_fifo_empty[gi]);
assign buf_fifo_rd[gi] = req_fifo_wr[gi]&data_req_eop_in[gi];
assign ptr_fifo_rd[gi] = req_fifo_wr[gi]&~first_buf[gi]&(&data_req_lsb[gi]|data_req_eop_in[gi]);

assign req_fifo_rd[gi] = data_sel_port[gi]&~req_fifo_empty[gi];

/***************************** FIFO ***************************************/


sfifo2f_fo #(ID_NBITS+BPTR_NBITS+LEN_NBITS*2, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({deq_ack_src_port_d1, deq_in_buf_ptr, deq_in_len, deq_ack_inst_len}),				
		.rd(pre_buf_fifo_rd[gi]),
		.wr(deq_ack_d1&(deq_ack_qid_d1==gi)),

		.ncount(),
		.count(pre_buf_fifo_count[gi]),
		.full(),
		.empty(pre_buf_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({pre_buf_fifo_src_port[gi], pre_buf_fifo_buf_ptr[gi], pre_buf_fifo_length[gi], pre_buf_fifo_inst_length[gi]})       
	);

sfifo_pp_piarb #(BUF_FIFO_DEPTH_NBITS) u_sfifo_pp_piarb_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(deq_ack_pp_meta),				
		.rd(pre_buf_fifo_rd[gi]),
		.wr(deq_ack_d1&(deq_ack_qid_d1==gi)),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(pre_buf_fifo_pp_meta[gi])       
	);

sfifo2f1 #(ID_NBITS+BPTR_NBITS+LEN_NBITS+1+LEN_NBITS) u_sfifo2f1_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pre_buf_fifo_src_port[gi], pre_buf_fifo_buf_ptr[gi], pre_buf_fifo_length[gi], (pre_buf_fifo_length[gi]==1), pre_buf_fifo_inst_length[gi]}),				
		.rd(buf_fifo_rd[gi]),
		.wr(buf_fifo_wr[gi]),

		.count(),
		.full(buf_fifo_full[gi]),
		.empty(buf_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({buf_fifo_src_port[gi], buf_fifo_buf_ptr[gi], buf_fifo_length[gi], sop_eop[gi], buf_fifo_inst_length[gi]})       
	);

sfifo_pp_piarb #(1) u_sfifo_pp_piarb_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pre_buf_fifo_pp_meta[gi]),       
		.rd(meta_fifo_rd[gi]),
		.wr(meta_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(meta_fifo_full[gi]),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(meta_fifo_data[gi])       
	);

sfifo2f1 #(BPTR_NBITS) u_sfifo2f1_4(
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

sfifo2f_fo #(BPTR_NBITS, 2) u_sfifo2f_fo_6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(buf_ack_ptr_d1),				
		.rd(pb_fifo_rd[gi]),
		.wr(buf_ack_valid_d1&(save_fifo_sel_port_id==gi)),

		.ncount(),
		.count(),
		.full(),
		.empty(pb_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(pb_fifo_buf_ptr[gi])       
	);

sfifo2f1 #(BPTR_NBITS) u_sfifo2f1_7(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(~pb_fifo_rd[gi]?first_ptr_fifo_buf_ptr[gi]:pb_fifo_buf_ptr[gi]),				
		.rd(pb_req_fifo_rd[gi]),
		.wr(pb_req_fifo_wr[gi]),

		.count(),
		.full(pb_req_fifo_full[gi]),
		.empty(pb_req_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout(pb_req_fifo_buf_ptr[gi])       
	);

sfifo2f_fo #(BPTR_NBITS, 2) u_sfifo2f_fo_8(
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

sfifo2f_fo #(BPTR_NBITS+BPTR_LSB_NBITS+ID_NBITS+3, 3) u_sfifo2f_fo_9(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({(first_buf[gi]?buf_fifo_buf_ptr[gi]:ptr_fifo_buf_ptr[gi]), data_req_lsb[gi], buf_fifo_src_port[gi], data_req_sop_in[gi], data_req_eop_in[gi], data_req_inst_in[gi]}),				
		.rd(req_fifo_rd[gi]),
		.wr(req_fifo_wr[gi]),

		.ncount(),
		.count(),
		.full(req_fifo_full[gi]),
		.empty(req_fifo_empty[gi]),
		.fullm1(),
		.emptyp2(),
		.dout({req_fifo_data_req_buf_ptr[gi], req_fifo_data_req_lsb[gi], req_fifo_data_req_src_port[gi], req_fifo_data_req_sop[gi], req_fifo_data_req_eop[gi], req_fifo_data_req_inst[gi]})       
	);

end
endgenerate


sfifo2f_fo #(ID_NBITS, 3) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(sel_port_id),				
		.rd(buf_ack_valid_d1),
		.wr(buf_req_p1),

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

