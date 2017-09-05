//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module edit_mem #(
parameter BPTR_NBITS = `EM_BUF_PTR_NBITS,
parameter DATA_NBITS = `DATA_PATH_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS,
parameter LEN_NBITS = `PD_CHUNK_DEPTH_NBITS,
parameter RC_NBITS = `READ_COUNT_NBITS,
parameter ADDR_NBITS = `ENQ_ED_CMD_PD_BP_NBITS+`PD_CHUNK_DEPTH_NBITS-`DATA_PATH_VB_NBITS
) (

input clk, 
input `RESET_SIG,

input pu_em_data_valid,
input pu_em_sop,
input pu_em_eop,
input [`PU_ID_NBITS-1:0] pu_em_port_id,        
input [DATA_NBITS-1:0] pu_em_packet_data,

input asa_em_read_count_valid,
input [BPTR_NBITS-1:0] asa_em_buf_ptr,
input [`PORT_ID_NBITS-1:0] asa_em_rc_port_id,
input [RC_NBITS-1:0] asa_em_read_count,
input [LEN_NBITS-1:0] asa_em_pd_length,

input edit_mem_req,
input [ADDR_NBITS-1:0] edit_mem_raddr,
input [`PORT_ID_NBITS-1:0] edit_mem_port_id,
input edit_mem_eop,

output em_asa_valid,
output [BPTR_NBITS-1:0] em_asa_buf_ptr,				
output [`PU_ID_NBITS-1:0] em_asa_pu_id,				
output [LEN_NBITS-1:0] em_asa_len,				
output em_asa_discard,

output edit_mem_ack,
output [DATA_NBITS-1:0] edit_mem_rdata

);

/***************************** LOCAL VARIABLES *******************************/
wire pu_buf_req; 

wire pu_buf_valid; 
wire [BPTR_NBITS-1:0] pu_buf_ptr;    
wire pu_buf_available;   

wire pu_data_valid; 
wire [BPTR_NBITS-1:0] pu_data_buf_ptr;    
wire [`DATA_PATH_NBITS-1:0] pu_data;   

wire data_req;
wire [ID_NBITS-1:0] data_req_dst_port_id;
wire data_req_sop;
wire data_req_eop;
wire [BPTR_NBITS-1:0] data_req_buf_ptr;

wire buf_req;
wire [BPTR_NBITS-1:0] buf_req_ptr;

wire buf_ack_valid;
wire [BPTR_NBITS-1:0] buf_ack_ptr;

wire em_rel_buf_valid;
wire [BPTR_NBITS-1:0] em_rel_buf_ptr;

wire rel_buf_valid;
wire [BPTR_NBITS-1:0] rel_buf_ptr;

wire enq_buf_valid;
wire [BPTR_NBITS-1:0] enq_buf_ptr_cur;
wire [BPTR_NBITS-1:0] enq_buf_ptr_nxt;

wire read_count_valid; 
wire [ID_NBITS-1:0] read_count_port_id;
wire [BPTR_NBITS-1:0] read_count_buf_ptr;
wire [RC_NBITS-1:0] read_count;

wire init_read_count_valid;
wire [`EM_BUF_PTR_NBITS-1:0] init_read_count_ptr;

wire freeb_init_done;
wire          freeb_init;
wire          inc_freeb_rd_count;
wire          inc_freeb_wr_count;
wire          inc_ll_rd_count;
wire          inc_ll_wr_count;


/***************************** NON-REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ************************/


/***************************** PROGRAM BODY **********************************/

edit_mem_read_data u_edit_mem_read_data(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .edit_mem_req(edit_mem_req), 
        .edit_mem_raddr(edit_mem_raddr), 
        .edit_mem_port_id(edit_mem_port_id), 
        .edit_mem_eop(edit_mem_eop), 

        .buf_ack_valid(buf_ack_valid), 
        .buf_ack_ptr(buf_ack_ptr), 

        .buf_req(buf_req), 
        .buf_req_ptr(buf_req_ptr), 

        .data_req(data_req), 
        .data_req_dst_port_id(data_req_dst_port_id), 
        .data_req_sop(data_req_sop), 
        .data_req_eop(data_req_eop), 
        .data_req_buf_ptr(data_req_buf_ptr) 

);

edit_mem_write_data u_edit_mem_write_data(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.pu_em_data_valid(pu_em_data_valid),
	.pu_em_packet_data(pu_em_packet_data),
	.pu_em_sop(pu_em_sop),
	.pu_em_eop(pu_em_eop),
	.pu_em_port_id(pu_em_port_id),		

	.pu_buf_valid(pu_buf_valid),
        .pu_buf_ptr(pu_buf_ptr),
	.pu_buf_available(pu_buf_available),

	// outputs

	.em_asa_valid(em_asa_valid), 
	.em_asa_buf_ptr(em_asa_buf_ptr), 
	.em_asa_pu_id(em_asa_pu_id), 
	.em_asa_len(em_asa_len), 
	.em_asa_discard(em_asa_discard), 

	.enq_buf_valid(enq_buf_valid), 
	.enq_buf_ptr_cur(enq_buf_ptr_cur),
	.enq_buf_ptr_nxt(enq_buf_ptr_nxt),

	.pu_buf_req(pu_em_req),

	.pu_data_valid(pu_data_valid),
	.pu_data_buf_ptr(pu_data_buf_ptr),
	.pu_data(pu_data)

);


edit_mem_freeb_ctrl u_edit_mem_freeb_ctrl(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.freeb_init(1'b0),      

        .rel_buf_valid(rel_buf_valid), 
        .rel_buf_ptr(rel_buf_ptr),

	.pu_buf_req(pu_em_req),

	// outputs

	.init_read_count_valid(init_read_count_valid), 
	.init_read_count_ptr(init_read_count_ptr), 

	.inc_freeb_rd_count(inc_freeb_rd_count), 
	.inc_freeb_wr_count(inc_freeb_wr_count),

        .freeb_init_done(freeb_init_done),  

	.pu_buf_valid(pu_buf_valid),
        .pu_buf_ptr(pu_buf_ptr),
	.pu_buf_available(pu_buf_available)

);

edit_mem_linked_list u_edit_mem_linked_list(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.enq_buf_valid(enq_buf_valid), 
	.enq_buf_ptr_cur(enq_buf_ptr_cur),
	.enq_buf_ptr_nxt(enq_buf_ptr_nxt),

	.buf_req(buf_req), 
	.buf_req_ptr(buf_req_ptr), 

	.asa_em_read_count_valid(asa_em_read_count_valid), 
	.asa_em_buf_ptr(asa_em_buf_ptr), 
	.asa_em_rc_port_id(asa_em_rc_port_id), 
	.asa_em_read_count(asa_em_read_count), 
	.asa_em_pd_length(asa_em_pd_length), 

	// outputs

	.inc_ll_rd_count(inc_ll_rd_count), 
	.inc_ll_wr_count(inc_ll_wr_count),

	.buf_ack_valid(buf_ack_valid), 
	.buf_ack_ptr(buf_ack_ptr),

	.read_count_valid(read_count_valid), 
	.read_count_buf_ptr(read_count_buf_ptr), 
	.read_count_port_id(read_count_port_id), 
	.read_count(read_count) 
);

edit_mem_buf_release u_edit_mem_buf_release(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.init_read_count_valid(init_read_count_valid), 
	.init_read_count_ptr(init_read_count_ptr), 

	.read_count_valid(read_count_valid), 
	.read_count_buf_ptr(read_count_buf_ptr), 
	.read_count_port_id(read_count_port_id), 
	.read_count(read_count),

	.em_rel_buf_valid(em_rel_buf_valid), 
	.em_rel_buf_ptr(em_rel_buf_ptr), 

	.rel_buf_valid(rel_buf_valid), 
	.rel_buf_ptr(rel_buf_ptr) 

);


edit_mem_shared_memory u_edit_mem_shared_memory(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.pu_data_valid(pu_data_valid),
	.pu_data_buf_ptr(pu_data_buf_ptr),
	.pu_data(pu_data),

	.data_req(data_req),
	.data_req_dst_port_id(data_req_dst_port_id),
	.data_req_sop(data_req_sop),
	.data_req_eop(data_req_eop),
	.data_req_buf_ptr(data_req_buf_ptr),

	// outputs

	.em_rel_buf_valid(em_rel_buf_valid), 
	.em_rel_buf_ptr(em_rel_buf_ptr), 

	.edit_mem_ack(edit_mem_ack),
	.edit_mem_rdata(edit_mem_rdata)

);

endmodule   						
