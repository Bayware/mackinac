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
parameter ID_NBITS = `PU_ID_NBITS,
parameter LEN_NBITS = `PATH_CHUNK_NBITS,
parameter DESC_NBITS = `PU_QUEUE_PAYLOAD_NBITS,
parameter DATA_NBITS = `HOP_INFO_NBITS,
parameter BUF_SIZE = 1,
parameter TYPE = 0
) (


input clk, 
input `RESET_SIG,

input deq_ack,
input [ID_NBITS-1:0] deq_ack_qid,
input pu_queue_payload_type deq_ack_desc, 

input data_ack_valid,
input data_ack_sop,

input buf_ack_valid,
input [BPTR_NBITS-1:0] buf_ack_ptr,

output reg buf_req,
output reg [BPTR_NBITS-1:0] buf_req_ptr,
			
output reg data_req,			
output reg [ID_NBITS-1:0] data_req_src_port_id,
output reg [ID_NBITS-1:0] data_req_dst_port_id,
output reg data_req_sop,
output reg data_req_eop,
output reg [BPTR_NBITS-1:0] data_req_buf_ptr,
output reg data_req_inst,

output pp_piarb_meta_type data_ack_meta
);

/***************************** LOCAL VARIABLES *******************************/

localparam BUF_FIFO_DEPTH_NBITS = 5;
localparam BUF_FIFO_DEPTH = (1<<BUF_FIFO_DEPTH_NBITS);
localparam BUF_FIFO_AVAIL_LEVEL = BUF_FIFO_DEPTH - (BUF_FIFO_DEPTH>>2);

reg deq_ack_d1;
pu_queue_payload_type deq_ack_desc_d1;
reg [ID_NBITS-1:0] deq_ack_src_port_d1;
reg [ID_NBITS-1:0] deq_ack_dst_port_d1;

reg buf_ack_valid_d1;
reg [BPTR_NBITS-1:0] buf_ack_ptr_d1;

reg buf_req_p1;
			
reg data_ack_valid_d1;
reg data_ack_sop_d1;




reg tran_sop /* synthesis maxfan = 16 preserve */;

reg [LEN_NBITS-1:0] tran_length_ctr;
reg [LEN_NBITS-1:0] inst_length_ctr;
reg [LEN_NBITS-1:0] length_ctr;
reg first_buf;

pp_piarb_meta_type meta_fifo_data;

wire [BUF_FIFO_DEPTH_NBITS:0] pre_buf_fifo_count;
wire [LEN_NBITS-1:0] pre_buf_fifo_length;
wire [LEN_NBITS-1:0] pre_buf_fifo_inst_length;
wire [BPTR_NBITS-1:0] pre_buf_fifo_buf_ptr;
wire [ID_NBITS-1:0] pre_buf_fifo_src_port;

wire [LEN_NBITS-1:0] buf_fifo_length;
wire [LEN_NBITS-1:0] buf_fifo_inst_length;
wire [BPTR_NBITS-1:0] buf_fifo_buf_ptr;
wire [ID_NBITS-1:0] buf_fifo_src_port;

wire [BPTR_NBITS-1:0] first_ptr_fifo_buf_ptr;
wire [BPTR_NBITS-1:0] ptr_fifo_buf_ptr;

wire [BPTR_NBITS-1:0] pb_fifo_buf_ptr;



wire [BPTR_NBITS-1:0] pb_req_fifo_buf_ptr;

wire [BPTR_NBITS-1:0] req_fifo_data_req_buf_ptr;
wire req_fifo_data_req_sop;
wire [ID_NBITS-1:0] req_fifo_data_req_src_port;
wire req_fifo_data_req_eop;
wire req_fifo_data_req_inst;

wire tran_fifo_sop;
wire tran_fifo_eop;

wire pre_buf_fifo_empty;
wire tran_fifo_full, buf_fifo_full, meta_fifo_full, first_ptr_fifo_full;
wire tran_eop = tran_sop?~(pre_buf_fifo_length>BUF_SIZE):~(tran_length_ctr>BUF_SIZE);
wire tran_fifo_wr = (tran_sop?~pre_buf_fifo_empty&~buf_fifo_full&~meta_fifo_full&~first_ptr_fifo_full:1)&~tran_fifo_full;

wire pre_buf_fifo_rd = tran_fifo_wr&tran_sop;
wire buf_fifo_wr = pre_buf_fifo_rd;
wire meta_fifo_wr = pre_buf_fifo_rd;
wire first_ptr_fifo_wr = pre_buf_fifo_rd;

reg tran_fifo_rd;
reg pb_req_fifo_wr;
reg first_ptr_fifo_rd;
reg pb_fifo_rd;
reg ptr_fifo_wr;

wire pb_req_fifo_full, tran_fifo_empty, pb_fifo_empty, first_ptr_fifo_empty, ptr_fifo_full;
always @* begin
	case({tran_fifo_sop, tran_fifo_eop})
		0: begin
			tran_fifo_rd = ~tran_fifo_empty&~pb_req_fifo_full&~pb_fifo_empty&~ptr_fifo_full;
			pb_req_fifo_wr = tran_fifo_rd;
			first_ptr_fifo_rd = 0;
			pb_fifo_rd = tran_fifo_rd;
			ptr_fifo_wr = tran_fifo_rd;
		end
		1: begin
			tran_fifo_rd = ~tran_fifo_empty&~pb_fifo_empty&~ptr_fifo_full;
			pb_req_fifo_wr = 0;
			first_ptr_fifo_rd = 0;
			pb_fifo_rd = tran_fifo_rd;
			ptr_fifo_wr = tran_fifo_rd;
		end
		2: begin
			tran_fifo_rd = ~tran_fifo_empty&~pb_req_fifo_full&~first_ptr_fifo_empty;
			pb_req_fifo_wr = tran_fifo_rd;
			first_ptr_fifo_rd = tran_fifo_rd;
			pb_fifo_rd = 0;
			ptr_fifo_wr = 0;
		end
		default: begin
			tran_fifo_rd = ~tran_fifo_empty&~first_ptr_fifo_empty;
			pb_req_fifo_wr = 0;
			first_ptr_fifo_rd = tran_fifo_rd;
			pb_fifo_rd = 0;
			ptr_fifo_wr = 0;
		end
	endcase
end

wire pb_req_fifo_empty;
wire pb_req_fifo_rd = ~pb_req_fifo_empty;

wire sop_eop;
wire nsop_eop = length_ctr<=BUF_SIZE;
reg data_req_sop_in;
wire data_req_eop_in = data_req_sop_in?sop_eop:nsop_eop;

wire sop_inst = 1'b1;
wire nsop_inst = inst_length_ctr<=BUF_SIZE;
wire data_req_inst_in = data_req_sop_in?sop_inst:inst_length_ctr!=0;

wire req_fifo_full;

wire ptr_fifo_empty;
wire buf_fifo_empty;
wire req_fifo_wr = ~buf_fifo_empty&~req_fifo_full&(first_buf|~ptr_fifo_empty);
wire buf_fifo_rd = req_fifo_wr&data_req_eop_in;
wire ptr_fifo_rd = ~buf_fifo_empty&~req_fifo_full&~first_buf&~ptr_fifo_empty;

wire req_fifo_empty;
wire req_fifo_rd = ~req_fifo_empty;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++


/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		data_req_src_port_id <= req_fifo_data_req_src_port;
		data_req_sop <= req_fifo_data_req_sop;
		data_req_eop <= req_fifo_data_req_eop;
		data_req_inst <= req_fifo_data_req_inst;
		data_req_buf_ptr <= req_fifo_data_req_buf_ptr;
		data_ack_meta <= meta_fifo_data;
		buf_req_ptr <= pb_req_fifo_buf_ptr;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		buf_req <= 0;
		data_req <= 0;
	end else begin
		buf_req <= ~pb_req_fifo_empty;
		data_req <= req_fifo_rd;
	end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
		deq_ack_desc_d1 <= deq_ack_desc;
		deq_ack_src_port_d1 <= deq_ack_qid;
		deq_ack_dst_port_d1 <= deq_ack_qid;
		buf_ack_ptr_d1 <= buf_ack_ptr;
		data_ack_sop_d1 <= data_ack_sop;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		deq_ack_d1 <= 0;
		buf_ack_valid_d1 <= 0;

		data_req_sop_in <= 1;

		data_ack_valid_d1 <= 0;

		tran_sop <= 1;

		tran_length_ctr <= 0;
		length_ctr <= 0;
		first_buf <= 1;

	end else begin

		deq_ack_d1 <= deq_ack;
		buf_ack_valid_d1 <= buf_ack_valid;

		data_req_sop_in <= req_fifo_wr?data_req_eop_in:data_req_sop_in;

		data_ack_valid_d1 <= data_ack_valid;

		tran_sop <= tran_fifo_wr?tran_eop:tran_sop;

		tran_length_ctr <= tran_fifo_wr?(tran_eop?0:tran_sop?pre_buf_fifo_length-BUF_SIZE:tran_length_ctr-BUF_SIZE):tran_length_ctr;
		length_ctr <= req_fifo_wr?(data_req_eop_in?0:data_req_sop_in?buf_fifo_length-BUF_SIZE:length_ctr-BUF_SIZE):length_ctr;
		inst_length_ctr <= req_fifo_wr?(data_req_eop_in?0:data_req_sop_in?(buf_fifo_inst_length<=BUF_SIZE?0:buf_fifo_inst_length-BUF_SIZE):nsop_inst?0:inst_length_ctr-BUF_SIZE):inst_length_ctr;
		first_buf <= req_fifo_wr&data_req_eop_in?1:req_fifo_wr?0:first_buf;

	end


/***************************** FIFO ***************************************/
pp_piarb_meta_type pre_buf_fifo_pp_meta;

wire [LEN_NBITS-1:0] deq_ack_len = deq_ack_desc_d1.len;
wire [`PD_CHUNK_NBITS-1:0] deq_ack_pd_len = deq_ack_desc_d1.pd_len;
wire [LEN_NBITS-1:0] deq_ack_inst_len = deq_ack_desc_d1.inst_len;
wire [BPTR_NBITS-1:0] deq_ack_buf_ptr = deq_ack_desc_d1.buf_ptr;
wire [BPTR_NBITS-1:0] deq_ack_inst_buf_ptr = deq_ack_desc_d1.inst_buf_ptr;
pp_piarb_meta_type deq_ack_pp_meta = deq_ack_desc_d1.pp_piarb_meta;

wire [LEN_NBITS-1:0] deq_in_len = TYPE==0?deq_ack_len:deq_ack_pd_len+deq_ack_inst_len;
wire [BPTR_NBITS-1:0] deq_in_buf_ptr = TYPE==0?deq_ack_buf_ptr:deq_ack_inst_buf_ptr;

// buffer packet descriptor for port 
sfifo2f_fo #(ID_NBITS+BPTR_NBITS+LEN_NBITS*2, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({deq_ack_src_port_d1, deq_in_buf_ptr, deq_in_len, deq_ack_inst_len}),				
		.rd(pre_buf_fifo_rd),
		.wr(deq_ack_d1),

		.ncount(),
		.count(pre_buf_fifo_count),
		.full(),
		.empty(pre_buf_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({pre_buf_fifo_src_port, pre_buf_fifo_buf_ptr, pre_buf_fifo_length, pre_buf_fifo_inst_length})       
	);

sfifo_pp_piarb #(BUF_FIFO_DEPTH_NBITS) u_sfifo_pp_piarb_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(deq_ack_pp_meta),				
		.rd(pre_buf_fifo_rd),
		.wr(deq_ack_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(pre_buf_fifo_pp_meta)       
	);

// frame information for frame data request
sfifo2f1 #(ID_NBITS+BPTR_NBITS+LEN_NBITS+1+LEN_NBITS) u_sfifo2f1_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pre_buf_fifo_src_port, pre_buf_fifo_buf_ptr, pre_buf_fifo_length, (pre_buf_fifo_length==1?1'b1:1'b0), pre_buf_fifo_inst_length}),				
		.rd(buf_fifo_rd),
		.wr(buf_fifo_wr),

		.count(),
		.full(buf_fifo_full),
		.empty(buf_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({buf_fifo_src_port, buf_fifo_buf_ptr, buf_fifo_length, sop_eop, buf_fifo_inst_length})       
);

sfifo_pp_piarb #(1) sfifo_pp_piarb_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pre_buf_fifo_pp_meta),				
		.rd(data_ack_valid_d1&data_ack_sop_d1),
		.wr(meta_fifo_wr),

		.ncount(),
		.count(),
		.full(meta_fifo_full),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(meta_fifo_data)       
);


// buf_ptr FIFO for packet buffer request
sfifo2f1 #(BPTR_NBITS) u_sfifo2f1_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pre_buf_fifo_buf_ptr),				
		.rd(first_ptr_fifo_rd),
		.wr(first_ptr_fifo_wr),

		.count(),
		.full(first_ptr_fifo_full),
		.empty(first_ptr_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout(first_ptr_fifo_buf_ptr)       
	);


// transaction FIFO {sop, eop} for packet buffer request
sfifo2f_fo #(2, 2) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({tran_sop, tran_eop}),				
		.rd(tran_fifo_rd),
		.wr(tran_fifo_wr),

		.ncount(),
		.count(),
		.full(tran_fifo_full),
		.empty(tran_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({tran_fifo_sop, tran_fifo_eop})       
	);


// next Packet buffer FIFO
sfifo2f_fo #(BPTR_NBITS, 2) u_sfifo2f_fo_6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(buf_ack_ptr_d1),				
		.rd(pb_fifo_rd),
		.wr(buf_ack_valid_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(pb_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout(pb_fifo_buf_ptr)       
	);

// packet buffer request FIFO
sfifo2f1 #(BPTR_NBITS) u_sfifo2f1_7(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(ptr_fifo_rd?first_ptr_fifo_buf_ptr:pb_fifo_buf_ptr),				
		.rd(pb_req_fifo_rd),
		.wr(pb_req_fifo_wr),

		.count(),
		.full(pb_req_fifo_full),
		.empty(pb_req_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout(pb_req_fifo_buf_ptr)       
	);


// buf_ptr FIFO for frame data request
sfifo2f_fo #(BPTR_NBITS, 2) u_sfifo2f_fo_8(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(pb_fifo_buf_ptr),				
		.rd(ptr_fifo_rd),
		.wr(ptr_fifo_wr),

		.ncount(),
		.count(),
		.full(ptr_fifo_full),
		.empty(ptr_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout(ptr_fifo_buf_ptr)       
	);

// frame data request FIFO 
sfifo2f_fo #(BPTR_NBITS+ID_NBITS+3, 3) u_sfifo2f_fo_9(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({(first_buf?buf_fifo_buf_ptr:ptr_fifo_buf_ptr), buf_fifo_src_port, data_req_sop_in, data_req_eop_in, data_req_inst_in}),				
		.rd(req_fifo_rd),
		.wr(req_fifo_wr),

		.ncount(),
		.count(),
		.full(req_fifo_full),
		.empty(req_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({req_fifo_data_req_buf_ptr, req_fifo_data_req_src_port, req_fifo_data_req_sop, req_fifo_data_req_eop, req_fifo_data_req_inst})       
	);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

