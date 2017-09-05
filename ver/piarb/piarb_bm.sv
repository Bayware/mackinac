//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_bm #(
parameter BPTR_NBITS = `PIARB_INST_BUF_PTR_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter ID_NBITS = `PU_ID_NBITS,
parameter DESC_NBITS = `PU_QUEUE_PAYLOAD_NBITS,
parameter LEN_NBITS = `INST_CHUNK_NBITS,
parameter BUF_SIZE = `DATA_PATH_NBYTES,
parameter TYPE = 1
) (

input clk, 
input `RESET_SIG,

input deq_ack,
input [ID_NBITS-1:0] deq_ack_qid,
input pu_queue_payload_type deq_ack_desc, 

input write_data_valid,
input [BPTR_NBITS-1:0] write_buf_ptr,
input [DATA_NBITS-1:0] write_data,
input write_sop,
input [ID_NBITS-1:0] write_port_id,

input free_buf_req,


output free_buf_valid,
output [BPTR_NBITS-1:0] free_buf_ptr,
output free_buf_available,

output data_ack_valid,
output [ID_NBITS-1:0] data_ack_port_id,
output data_ack_sop,
output data_ack_eop,
output [DATA_NBITS-1:0] data_ack_data,
output data_ack_inst,

output pp_piarb_meta_type data_ack_meta


);

/***************************** LOCAL VARIABLES *******************************/
wire data_req;
wire [ID_NBITS-1:0] data_req_src_port_id;
wire [ID_NBITS-1:0] data_req_dst_port_id;
wire data_req_sop;
wire data_req_eop;
wire [BPTR_NBITS-1:0] data_req_buf_ptr;
wire data_req_inst;

wire buf_req;
wire [BPTR_NBITS-1:0] buf_req_ptr;

wire buf_ack_valid;
wire [BPTR_NBITS-1:0] buf_ack_ptr;

wire rel_buf_valid;
wire [ID_NBITS-1:0] rel_buf_port_id;
wire [BPTR_NBITS-1:0] rel_buf_ptr;

wire enq_buf_valid;
wire [BPTR_NBITS-1:0] fb_buf_ptr_cur;
wire [BPTR_NBITS-1:0] fb_buf_ptr_prev;

wire freeb_init_done;
wire          freeb_init;
wire          inc_freeb_rd_count;
wire          inc_freeb_wr_count;
wire          inc_ll_rd_count;
wire          inc_ll_wr_count;


/***************************** NON-REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ************************/


/***************************** PROGRAM BODY **********************************/

piarb_read_data #(BPTR_NBITS, ID_NBITS, LEN_NBITS, DESC_NBITS, DATA_NBITS, BUF_SIZE, TYPE) u_piarb_read_data(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .deq_ack(deq_ack), 
        .deq_ack_qid(deq_ack_qid), 
        .deq_ack_desc(deq_ack_desc), 

        .data_ack_valid(data_ack_valid), 
        .data_ack_sop(data_ack_sop), 

        .buf_ack_valid(buf_ack_valid), 
        .buf_ack_ptr(buf_ack_ptr), 

        .buf_req(buf_req), 
        .buf_req_ptr(buf_req_ptr), 

        .data_req(data_req), 
        .data_req_src_port_id(data_req_src_port_id), 
        .data_req_dst_port_id(data_req_dst_port_id), 
        .data_req_sop(data_req_sop), 
        .data_req_eop(data_req_eop), 
        .data_req_buf_ptr(data_req_buf_ptr), 
        .data_req_inst(data_req_inst), 

        .data_ack_meta(data_ack_meta) 
);

piarb_freeb_ctrl #(ID_NBITS, BPTR_NBITS) u_piarb_freeb_ctrl(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

		.freeb_init(1'b0),      

        .rel_buf_valid(rel_buf_valid), 
        .rel_buf_ptr(rel_buf_ptr),

		.free_buf_req(free_buf_req),

		.write_data_valid(write_data_valid),
		.write_buf_ptr(write_buf_ptr),
		.write_sop(write_sop),
		.write_port_id(write_port_id),		

		// outputs

	    .inc_freeb_rd_count(inc_freeb_rd_count), 
		.inc_freeb_wr_count(inc_freeb_wr_count),

        .freeb_init_done(freeb_init_done),  

		.enq_buf_valid(enq_buf_valid), 
		.fb_buf_ptr_prev(fb_buf_ptr_prev),
		.fb_buf_ptr_cur(fb_buf_ptr_cur),

		.free_buf_valid(free_buf_valid),
        .free_buf_ptr(free_buf_ptr),
		.free_buf_available(free_buf_available)

);

piarb_linked_list #(BPTR_NBITS) u_piarb_linked_list(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

		.enq_buf_valid(enq_buf_valid), 
		.enq_buf_ptr_cur(fb_buf_ptr_prev),
		.enq_buf_ptr_nxt(fb_buf_ptr_cur),

		.buf_req(buf_req), 
		.buf_req_ptr(buf_req_ptr), 

		// outputs

		.inc_ll_rd_count(inc_ll_rd_count), 
		.inc_ll_wr_count(inc_ll_wr_count),

		.buf_ack_valid(buf_ack_valid), 
		.buf_ack_ptr(buf_ack_ptr)

);


piarb_shared_memory #(ID_NBITS, BPTR_NBITS, DATA_NBITS) u_piarb_shared_memory(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.write_data_valid(write_data_valid),
	.write_buf_ptr(write_buf_ptr),
	.write_data(write_data),

	.data_req(data_req),
	.data_req_src_port_id(data_req_src_port_id),
	.data_req_dst_port_id(data_req_dst_port_id),
	.data_req_sop(data_req_sop),
	.data_req_eop(data_req_eop),
	.data_req_buf_ptr(data_req_buf_ptr),
        .data_req_inst(data_req_inst), 

	// outputs

	.rel_buf_valid(rel_buf_valid), 
	.rel_buf_port_id(rel_buf_port_id), 
	.rel_buf_ptr(rel_buf_ptr), 

	.data_ack_valid(data_ack_valid),
	.data_ack_port_id(data_ack_port_id),
	.data_ack_sop(data_ack_sop),
	.data_ack_eop(data_ack_eop),
	.data_ack_inst(data_ack_inst),
	.data_ack_data(data_ack_data)

);

endmodule   						
