//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : buffer manager top level
//===========================================================================

`include "defines.vh"

import meta_package::*;

module bm(

input clk, 
input `RESET_SIG,

input         pio_start,
input         pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

output clk_div,
output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata,

input aggr_bm_packet_valid,
input [`BUF_PTR_RANGE] aggr_bm_buf_ptr,
input [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb,
input [`DATA_PATH_RANGE] aggr_bm_packet_data,
input aggr_bm_sop,
input [`PORT_ID_RANGE] aggr_bm_port_id,

input aggr_bm_buf_req,

input [`NUM_OF_PORTS-1:0] ed_bm_bp,
input asa_bm_bp,

input asa_bm_read_count_valid,
input [`PORT_ID_RANGE] asa_bm_rc_port_id,
input [`BUF_PTR_RANGE] asa_bm_buf_ptr,
input [`READ_COUNT_RANGE] asa_bm_read_count,
input [`PACKET_LENGTH_RANGE] asa_bm_packet_length,

input tm_bm_enq_req,
input enq_pkt_desc_type tm_bm_enq_pkt_desc,


output [`NUM_OF_PORTS-1:0] bm_tm_bp,


output bm_aggr_rel_buf_valid,
output [`PORT_ID_RANGE] bm_aggr_rel_buf_port_id,
output [3:0] bm_aggr_rel_alpha,

output bm_aggr_buf_valid,
output [`BUF_PTR_RANGE] bm_aggr_buf_ptr,
output bm_aggr_buf_available,

output bm_ed_data_valid,
output [`PORT_ID_RANGE] bm_ed_port_id,
output bm_ed_sop,
output bm_ed_eop,
output [`DATA_PATH_VB_RANGE] bm_ed_valid_bytes,
output [`DATA_PATH_RANGE] bm_ed_packet_data,

output enq_ed_cmd_type bm_ed_cmd

);

/***************************** LOCAL VARIABLES *******************************/
wire         reg_bs;
wire         reg_wr;
wire         reg_rd;
wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_din;

wire packet_buf_req;
wire [`BUF_PTR_RANGE] packet_buf_req_ptr;

wire packet_req;
wire [`PORT_ID_RANGE] packet_req_src_port_id;
wire [`PORT_ID_RANGE] packet_req_dst_port_id;
wire packet_req_sop;
wire packet_req_eop;
wire [`DATA_PATH_VB_RANGE] packet_req_valid_bytes;
wire [`BUF_PTR_RANGE] packet_req_buf_ptr;
wire [`BUF_PTR_LSB_RANGE] packet_req_buf_ptr_lsb;

wire packet_ack_buf_valid;
wire [`BUF_PTR_RANGE] packet_ack_buf_ptr;

wire packet_ack_data_valid;
wire [`PORT_ID_RANGE] packet_ack_port_id;
wire packet_ack_sop;

wire freeb_init_done;

wire [`BUF_PTR_RANGE] fb_buf_ptr_cur;
wire [`BUF_PTR_RANGE] fb_buf_ptr_prev;

wire rel_buf_valid;
wire [`PORT_ID_RANGE] rel_buf_port_id;
wire [`BUF_PTR_RANGE] rel_buf_ptr;

wire init_read_count_valid;
wire [`BUF_PTR_RANGE] init_read_count_ptr;


wire tm_rel_buf_valid;
wire [`BUF_PTR_RANGE] tm_rel_buf_ptr;
wire [`PORT_ID_RANGE] tm_rel_buf_port_id;

wire enq_buf_valid;

wire deq_ack_buf_valid;
wire [`BUF_PTR_RANGE] deq_ack_buf_ptr;

wire read_count_valid; 
wire [`PORT_ID_RANGE] read_count_port_id;
wire [`BUF_PTR_RANGE] read_count_buf_ptr;
wire [`READ_COUNT_RANGE] read_count;


wire          freeb_init;
wire          inc_freeb_rd_count;
wire          inc_freeb_wr_count;
wire          inc_ll_rd_count;
wire          inc_ll_wr_count;
wire   [3:0]  dt_alpha;


/***************************** NON-REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ************************/

assign bm_aggr_rel_buf_valid = rel_buf_valid;
assign bm_aggr_rel_buf_port_id = rel_buf_port_id;
assign bm_aggr_rel_alpha = dt_alpha;

/***************************** PROGRAM BODY **********************************/

bm_read_pkt u_bm_read_pkt(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

    .tm_bm_enq_req(tm_bm_enq_req), 
    .tm_bm_enq_pkt_desc(tm_bm_enq_pkt_desc),

    .packet_ack_data_valid(packet_ack_data_valid),  
    .packet_ack_port_id(packet_ack_port_id),
    .packet_ack_sop(packet_ack_sop),

    .packet_ack_buf_valid(packet_ack_buf_valid), 
    .packet_ack_buf_ptr(packet_ack_buf_ptr),  

    .ed_bm_bp(ed_bm_bp),   

    // outputs

    .bm_tm_bp(bm_tm_bp), 
     
    .packet_buf_req(packet_buf_req), 
    .packet_buf_req_ptr(packet_buf_req_ptr), 
     
    .packet_req(packet_req), 
    .packet_req_src_port_id(packet_req_src_port_id), 
    .packet_req_dst_port_id(packet_req_dst_port_id), 
    .packet_req_sop(packet_req_sop), 
    .packet_req_eop(packet_req_eop), 
    .packet_req_valid_bytes(packet_req_valid_bytes), 
    .packet_req_buf_ptr(packet_req_buf_ptr),   
    .packet_req_buf_ptr_lsb(packet_req_buf_ptr_lsb),  

    .bm_ed_cmd(bm_ed_cmd)

);

bm_freeb_ctrl u_bm_freeb_ctrl(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

		.freeb_init(freeb_init),      

        .rel_buf_valid(rel_buf_valid), 
        .rel_buf_ptr(rel_buf_ptr),

		.asa_bm_bp(asa_bm_bp),

		.aggr_bm_buf_req(aggr_bm_buf_req),

		.aggr_bm_packet_valid(aggr_bm_packet_valid),
		.aggr_bm_buf_ptr(aggr_bm_buf_ptr),
		.aggr_bm_buf_ptr_lsb(aggr_bm_buf_ptr_lsb),
		.aggr_bm_sop(aggr_bm_sop),
		.aggr_bm_port_id(aggr_bm_port_id),		

		// outputs

		.init_read_count_valid(init_read_count_valid),
		.init_read_count_ptr(init_read_count_ptr),

	    .inc_freeb_rd_count(inc_freeb_rd_count), 
		.inc_freeb_wr_count(inc_freeb_wr_count),

        .freeb_init_done(freeb_init_done),  

		.enq_buf_valid(enq_buf_valid), 
		.fb_buf_ptr_cur(fb_buf_ptr_cur),
		.fb_buf_ptr_prev(fb_buf_ptr_prev),

		.bm_aggr_buf_valid(bm_aggr_buf_valid),
        .bm_aggr_buf_ptr(bm_aggr_buf_ptr),
		.bm_aggr_buf_available(bm_aggr_buf_available)

);

bm_linked_list u_bm_linked_list(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

		.enq_buf_valid(enq_buf_valid), 
		.enq_buf_ptr_cur(fb_buf_ptr_prev),
		.enq_buf_ptr_nxt(fb_buf_ptr_cur),

		.packet_buf_req(packet_buf_req), 
		.packet_buf_req_ptr(packet_buf_req_ptr), 

		.asa_bm_read_count_valid(asa_bm_read_count_valid), 
		.asa_bm_read_count(asa_bm_read_count), 
		.asa_bm_rc_port_id(asa_bm_rc_port_id),
		.asa_bm_buf_ptr(asa_bm_buf_ptr),
		.asa_bm_packet_length(asa_bm_packet_length), 

		// outputs

		.inc_ll_rd_count(inc_ll_rd_count), 
		.inc_ll_wr_count(inc_ll_wr_count),

		.packet_ack_buf_valid(packet_ack_buf_valid), 
		.packet_ack_buf_ptr(packet_ack_buf_ptr),

		.read_count_valid(read_count_valid),
		.read_count_port_id(read_count_port_id),
		.read_count_buf_ptr(read_count_buf_ptr),
		.read_count(read_count)

);


bm_buf_release u_bm_buf_release(

        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

		.init_read_count_valid(init_read_count_valid),
		.init_read_count_ptr(init_read_count_ptr),

        .read_count_valid(read_count_valid),
		.read_count_port_id(read_count_port_id),
		.read_count_buf_ptr(read_count_buf_ptr),
		.read_count(read_count),

	    .tm_rel_buf_valid(tm_rel_buf_valid), 
	    .tm_rel_buf_ptr(tm_rel_buf_ptr), 
		.tm_rel_buf_port_id(tm_rel_buf_port_id), 

	// outputs

	    .rel_buf_valid(rel_buf_valid),
	    .rel_buf_port_id(rel_buf_port_id),
	    .rel_buf_ptr(rel_buf_ptr)

);

bm_shared_memory u_bm_shared_memory(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.aggr_bm_packet_valid(aggr_bm_packet_valid),
	.aggr_bm_buf_ptr(aggr_bm_buf_ptr),
	.aggr_bm_buf_ptr_lsb(aggr_bm_buf_ptr_lsb),
	.aggr_bm_packet_data(aggr_bm_packet_data),

	.packet_req(packet_req),
	.packet_req_src_port_id(packet_req_src_port_id),
	.packet_req_dst_port_id(packet_req_dst_port_id),
	.packet_req_sop(packet_req_sop),
	.packet_req_eop(packet_req_eop),
	.packet_req_valid_bytes(packet_req_valid_bytes),
	.packet_req_buf_ptr(packet_req_buf_ptr),
	.packet_req_buf_ptr_lsb(packet_req_buf_ptr_lsb),	

	// outputs

	.tm_rel_buf_valid(tm_rel_buf_valid), 
	.tm_rel_buf_port_id(tm_rel_buf_port_id), 
	.tm_rel_buf_ptr(tm_rel_buf_ptr), 

	.packet_ack_data_valid(packet_ack_data_valid),
	.packet_ack_port_id(packet_ack_port_id),
	.packet_ack_sop(packet_ack_sop),

	.bm_ed_data_valid(bm_ed_data_valid),
	.bm_ed_port_id(bm_ed_port_id),
	.bm_ed_sop(bm_ed_sop),
	.bm_ed_eop(bm_ed_eop),
	.bm_ed_valid_bytes(bm_ed_valid_bytes),
	.bm_ed_packet_data(bm_ed_packet_data)

);

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`BM_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`BM_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(`BM_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`BM_BLOCK_ADDR)
) u_pio2reg_bus (

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 
    
    .pio_start(pio_start),
    .pio_rw(pio_rw),
    .pio_addr_wdata(pio_addr_wdata),
    
    .clk_div(clk_div), 

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .mem_bs(),
    .reg_bs(reg_bs)

);


bm_reg u_bm_reg (
  .clk( clk                           ),
  .`RESET_SIG( `RESET_SIG                           ),

    .clk_div(clk_div), 

    .reg_bs(reg_bs),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

  .pio_ack( pio_ack                      ),
  .pio_rvalid( pio_rvalid                      ),
  .pio_rdata( pio_rdata                      ),

  .freeb_init_done    ( freeb_init_done    ),
  .inc_freeb_rd_count    ( inc_freeb_rd_count    ),
  .inc_freeb_wr_count    ( inc_freeb_wr_count    ),
  .inc_ll_rd_count       ( inc_ll_rd_count       ),
  .inc_ll_wr_count       ( inc_ll_wr_count       ),

  .freeb_init            ( freeb_init            ),
  .dt_alpha              ( dt_alpha              )
);
endmodule   						
