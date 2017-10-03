/*
 * 
 */

`include "defines.vh"

import meta_package::*;

module piarb #(
parameter INST_DATA_NBITS = `DATA_PATH_NBITS,
parameter DATA_NBITS = `HOP_INFO_NBITS,
parameter INST_BPTR_NBITS = `PIARB_INST_BUF_PTR_NBITS,
parameter INST_BPTR_LSB_NBITS = `PIARB_INST_BUF_PTR_LSB_NBITS,
parameter BPTR_NBITS = `PIARB_BUF_PTR_NBITS,
parameter BPTR_LSB_NBITS = `PIARB_BUF_PTR_LSB_NBITS,
parameter ID_NBITS = `PU_ID_NBITS,
parameter QUEUE_ID_NBITS = `PU_ID_NBITS,
parameter QUEUE_DEPTH = `NUM_OF_PU,
parameter DESC_NBITS = `PU_QUEUE_PAYLOAD_NBITS,
parameter QUEUE_ENTRIES_NBITS = `PU_QUEUE_ENTRIES_NBITS,
parameter QUEUE_PAYLOAD_NBITS = `PU_QUEUE_PAYLOAD_NBITS
) 
  (
   input      clk,
   input      `RESET_SIG,

   input         pio_start,
   input         pio_rw,
   input [`PIO_RANGE] pio_addr_wdata,
   
   output clk_div,
   output pio_ack,
   output pio_rvalid,
   output [`PIO_RANGE] pio_rdata,
   
   input ecdsa_piarb_wr,
   input [`FID_NBITS-1:0] ecdsa_piarb_waddr,
   input [`FLOW_PU_NBITS-1:0] ecdsa_piarb_wdata,

   input pp_pu_hop_valid,
   input [DATA_NBITS-1:0] pp_pu_hop_data,
   input pp_pu_hop_sop,
   input pp_pu_hop_eop,
   input pp_piarb_meta_type pp_pu_meta_data,
   input [`CHUNK_LEN_NBITS-1:0] pp_pu_pp_loc,
   
   input  pp_pu_valid,
   input  pp_pu_sop,
   input  pp_pu_eop,
   input  [`DATA_PATH_RANGE] pp_pu_data,
   input  [`DATA_PATH_VB_RANGE] pp_pu_valid_bytes,
   input [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_loc,
   input [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_len,
   input  pp_pu_inst_pd,

   input pu_fid_done, 
   input [ID_NBITS-1:0] pu_id,
   input pu_fid_sel,

   output logic pu_pp_buf_fifo_rd,
   output logic [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count,

   output piarb_asa_valid,
   output piarb_asa_type3,
   output [`PU_ID_NBITS-1:0] piarb_asa_pu_id,				
   output piarb_asa_meta_type piarb_asa_meta_data,				

   output piarb_pu_valid,
   output [ID_NBITS-1:0] piarb_pu_pid,
   output piarb_pu_sop,
   output piarb_pu_eop,
   output piarb_pu_fid_sel,
   output [`HOP_INFO_NBITS-1:0] piarb_pu_data,
  
   output pu_hop_meta_type piarb_pu_meta_data,

   output piarb_pu_inst_valid,
   output [ID_NBITS-1:0] piarb_pu_inst_pid,
   output piarb_pu_inst_sop,
   output piarb_pu_inst_eop,
   output [INST_DATA_NBITS-1:0] piarb_pu_inst_data,
   output piarb_pu_inst_pd
   
   );

/**************************************************************************/

wire inst_free_buf_valid;       
wire [INST_BPTR_NBITS-1:0] inst_free_buf_ptr;  
wire inst_free_buf_available;   

wire free_buf_valid;       
wire [BPTR_NBITS-1:0] free_buf_ptr;  
wire free_buf_available;   

wire fid_lookup_ack;
wire [1:0] fid_lookup_fid_valid[QUEUE_DEPTH-1:0];
wire [1:0] fid_lookup_fid_hit[QUEUE_DEPTH-1:0];

wire inst_free_buf_req;
wire free_buf_req;

wire pu_pp_hop_ready;

wire fid_lookup_req;
wire [`FID_NBITS-1:0] fid_lookup_fid;

wire wr_fid_req;
wire [`FID_NBITS-1:0] wr_fid;
wire [ID_NBITS-1:0] wr_fid_sel_id;
wire wr_fid_sel;

wire enq_req; 
wire [QUEUE_ID_NBITS-1:0] enq_qid;
wire pu_queue_payload_type enq_desc;
wire enq_fid_sel;

wire inst_write_data_valid;
wire [INST_DATA_NBITS-1:0] inst_write_data;
wire [INST_BPTR_NBITS-1:0] inst_write_buf_ptr;    
wire [INST_BPTR_LSB_NBITS-1:0] inst_write_buf_ptr_lsb;    
wire [ID_NBITS-1:0] inst_write_port_id;
wire inst_write_sop;

wire write_data_valid;
wire [DATA_NBITS-1:0] write_data;
wire [BPTR_NBITS-1:0] write_buf_ptr;    
wire [BPTR_LSB_NBITS-1:0] write_buf_ptr_lsb;    
wire [ID_NBITS-1:0] write_port_id;
wire write_sop;

wire deq_ack;
wire [ID_NBITS-1:0] deq_ack_qid;
wire pu_queue_payload_type deq_ack_desc; 

wire data_ack_valid;
wire [ID_NBITS-1:0] data_ack_port_id;
wire data_ack_sop;
wire data_ack_eop;
wire [DATA_NBITS-1:0] data_ack_data;

pp_piarb_meta_type data_ack_meta;

wire deq_req; 
wire [QUEUE_ID_NBITS-1:0] deq_qid;

wire head_wr;
wire [QUEUE_ID_NBITS-1:0] head_raddr;
wire [QUEUE_ID_NBITS-1:0] head_waddr;
wire [QUEUE_ENTRIES_NBITS-1:0] head_wdata;
wire [QUEUE_ENTRIES_NBITS-1:0] head_rdata;

wire tail_wr;
wire [QUEUE_ID_NBITS-1:0] tail_raddr;
wire [QUEUE_ID_NBITS-1:0] tail_waddr;
wire [QUEUE_ENTRIES_NBITS-1:0] tail_wdata;
wire [QUEUE_ENTRIES_NBITS-1:0] tail_rdata;

wire depth_wr;
wire [QUEUE_ID_NBITS-1:0] depth_raddr;
wire [QUEUE_ID_NBITS-1:0] depth_waddr;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_wdata;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_rdata;

wire depth_fid0_wr;
wire [QUEUE_ID_NBITS-1:0] depth_fid0_raddr;
wire [QUEUE_ID_NBITS-1:0] depth_fid0_waddr;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_wdata;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_rdata;

wire depth_fid1_wr;
wire [QUEUE_ID_NBITS-1:0] depth_fid1_raddr;
wire [QUEUE_ID_NBITS-1:0] depth_fid1_waddr;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_wdata;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_rdata;

wire ll_wr;
wire [QUEUE_ENTRIES_NBITS-1:0] ll_raddr;
wire [QUEUE_ENTRIES_NBITS-1:0] ll_waddr;
wire [QUEUE_ENTRIES_NBITS-1:0] ll_wdata;
wire [QUEUE_ENTRIES_NBITS-1:0] ll_rdata;

wire desc_wr;
wire [QUEUE_ENTRIES_NBITS-1:0] desc_raddr;
wire [QUEUE_ENTRIES_NBITS-1:0] desc_waddr;
wire pu_queue_payload_type desc_wdata;
wire pu_queue_payload_type desc_rdata;

wire enq_ack; 
wire enq_to_empty; 
wire [QUEUE_ID_NBITS-1:0] enq_ack_qid;

wire deq_depth_ack; 
wire deq_depth_from_emptyp2; 

wire flow_value_wr;
wire [`FLOW_PU_NBITS-1:0] flow_value_wdata;
wire [`FID_NBITS-1:0]   flow_value_raddr;
wire [`FID_NBITS-1:0]   flow_value_waddr;

wire [`FLOW_PU_NBITS-1:0] flow_value_rdata;

wire topic_value_ack;
wire [`SWITCH_TAG_NBITS-1:0] topic_value_rdata;

wire topic_value_rd;
wire [`TID_NBITS-1:0] topic_value_raddr;

wire         reg_bs;
wire         reg_wr;
wire         reg_rd;
wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_din;

wire topic_value_mem_ack;
wire [`PIO_RANGE] topic_value_mem_rdata;

wire reg_ms_topic_value;

/**************************************************************************/

/**************************************************************************/


piarb_enq u_piarb_enq(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.pp_pu_hop_valid(pp_pu_hop_valid),
	.pp_pu_hop_data(pp_pu_hop_data),
	.pp_pu_hop_sop(pp_pu_hop_sop),
	.pp_pu_hop_eop(pp_pu_hop_eop),
	.pp_pu_meta_data(pp_pu_meta_data),    
    	.pp_pu_pp_loc(pp_pu_pp_loc),

	.pp_pu_valid(pp_pu_valid),
        .pp_pu_sop(pp_pu_sop),
        .pp_pu_eop(pp_pu_eop),
        .pp_pu_data(pp_pu_data),
        .pp_pu_valid_bytes(pp_pu_valid_bytes),
    	.pp_pu_pd_loc(pp_pu_pd_loc),
    	.pp_pu_pd_len(pp_pu_pd_len),
        .pp_pu_inst_pd(pp_pu_inst_pd),

	.inst_free_buf_valid(inst_free_buf_valid),        
	.inst_free_buf_ptr(inst_free_buf_ptr),   
	.inst_free_buf_available(inst_free_buf_available),    

	.free_buf_valid(free_buf_valid),        
	.free_buf_ptr(free_buf_ptr),   
	.free_buf_available(free_buf_available),    

	.fid_lookup_ack(fid_lookup_ack),
	.fid_lookup_fid_valid(fid_lookup_fid_valid),
	.fid_lookup_fid_hit(fid_lookup_fid_hit),

	.piarb_asa_valid(piarb_asa_valid),
	.piarb_asa_type3(piarb_asa_type3),
	.piarb_asa_pu_id(piarb_asa_pu_id),				
	.piarb_asa_meta_data(piarb_asa_meta_data),				

	.inst_free_buf_req(inst_free_buf_req),
	.free_buf_req(free_buf_req),

	.pu_pp_buf_fifo_rd(pu_pp_buf_fifo_rd),
	.pu_pp_inst_buf_fifo_count(pu_pp_inst_buf_fifo_count),

	.fid_lookup_req(fid_lookup_req),
	.fid_lookup_fid(fid_lookup_fid),

	.wr_fid_req(wr_fid_req),
	.wr_fid(wr_fid),
	.wr_fid_sel_id(wr_fid_sel_id),
	.wr_fid_sel(wr_fid_sel),

	.enq_req(enq_req), 
	.enq_qid(enq_qid),
	.enq_desc(enq_desc),
	.enq_fid_sel(enq_fid_sel),

	.inst_write_data_valid(inst_write_data_valid),
	.inst_write_data(inst_write_data),
	.inst_write_buf_ptr(inst_write_buf_ptr),    
	.inst_write_buf_ptr_lsb(inst_write_buf_ptr_lsb),    
	.inst_write_port_id(inst_write_port_id),
	.inst_write_sop(inst_write_sop),

	.write_data_valid(write_data_valid),
	.write_data(write_data),
	.write_buf_ptr(write_buf_ptr),    
	.write_buf_ptr_lsb(write_buf_ptr_lsb),    
	.write_port_id(write_port_id),
	.write_sop(write_sop)
);

piarb_tcam u_piarb_tcam(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.fid_lookup_req(fid_lookup_req),
	.fid_lookup_fid(fid_lookup_fid),

	.wr_fid_req(wr_fid_req),
	.wr_fid(wr_fid),
	.wr_fid_sel_id(wr_fid_sel_id),
	.wr_fid_sel(wr_fid_sel),

	.enq_req(enq_req), 
	.enq_qid(enq_qid),
	.enq_fid_sel(enq_fid_sel),

	.pu_fid_done(pu_fid_done), 
	.pu_id(pu_id), 
	.pu_fid_sel(pu_fid_sel), 

	.fid_lookup_ack(fid_lookup_ack),
	.fid_lookup_fid_valid(fid_lookup_fid_valid),
	.fid_lookup_fid_hit(fid_lookup_fid_hit)

);

piarb_bm #(`PIARB_BUF_PTR_NBITS, `PIARB_BUF_PTR_LSB_NBITS, `HOP_INFO_NBITS, `PU_ID_NBITS, `PU_QUEUE_PAYLOAD_NBITS, `PATH_CHUNK_NBITS, 1, 2, 0) u_piarb_bm_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.deq_ack(deq_ack),
	.deq_ack_qid(deq_ack_qid),
	.deq_ack_desc(deq_ack_desc),

	.write_data_valid(write_data_valid),
	.write_data(write_data),
	.write_buf_ptr(write_buf_ptr),    
	.write_buf_ptr_lsb(write_buf_ptr_lsb),    
	.write_port_id(write_port_id),
	.write_sop(write_sop),

	.free_buf_req(free_buf_req),

	.free_buf_valid(free_buf_valid),        
	.free_buf_ptr(free_buf_ptr),   
	.free_buf_available(free_buf_available),    

	.data_ack_valid(data_ack_valid),
	.data_ack_port_id(data_ack_port_id),
	.data_ack_sop(data_ack_sop),
	.data_ack_eop(data_ack_eop),
	.data_ack_data(data_ack_data),
	.data_ack_inst(),
	.data_ack_meta(data_ack_meta)

);

piarb_bm #(`PIARB_INST_BUF_PTR_NBITS, `PIARB_INST_BUF_PTR_LSB_NBITS, `DATA_PATH_NBITS, `PU_ID_NBITS, `PU_QUEUE_PAYLOAD_NBITS, `INST_CHUNK_NBITS, 1, 2, 1) u_piarb_bm_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.deq_ack(deq_ack),
	.deq_ack_qid(deq_ack_qid),
	.deq_ack_desc(deq_ack_desc),

	.write_data_valid(inst_write_data_valid),
	.write_data(inst_write_data),
	.write_buf_ptr(inst_write_buf_ptr),    
	.write_buf_ptr_lsb(inst_write_buf_ptr_lsb),    
	.write_port_id(inst_write_port_id),
	.write_sop(inst_write_sop),

	.free_buf_req(inst_free_buf_req),

	.free_buf_valid(inst_free_buf_valid),        
	.free_buf_ptr(inst_free_buf_ptr),   
	.free_buf_available(inst_free_buf_available),    

	.data_ack_valid(piarb_pu_inst_valid),
	.data_ack_port_id(piarb_pu_inst_pid),
	.data_ack_sop(piarb_pu_inst_sop),
	.data_ack_eop(piarb_pu_inst_eop),
	.data_ack_data(piarb_pu_inst_data),
	.data_ack_inst(piarb_pu_inst_pd),
	.data_ack_meta()
);

piarb_sch u_piarb_sch(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.enq_ack(enq_ack), 
	.enq_to_empty(enq_to_empty), 
	.enq_ack_qid(enq_ack_qid), 

	.deq_depth_ack(deq_depth_ack), 
	.deq_depth_from_emptyp2(deq_depth_from_emptyp2), 

	.deq_req(deq_req), 
	.deq_qid(deq_qid)
);

piarb_qm u_piarb_qm(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.enq_req(enq_req), 
	.enq_qid(enq_qid),
	.enq_desc(enq_desc),
	.enq_fid_sel(enq_fid_sel),

	.deq_req(deq_req), 
	.deq_qid(deq_qid),

	.pu_fid_done(pu_fid_done), 
	.pu_id(pu_id), 
	.pu_fid_sel(pu_fid_sel), 

	.head_wr(head_wr), 
	.head_raddr(head_raddr), 
	.head_waddr(head_waddr), 
	.head_wdata(head_wdata), 
	.head_rdata(head_rdata), 

	.tail_wr(tail_wr), 
	.tail_raddr(tail_raddr), 
	.tail_waddr(tail_waddr), 
	.tail_wdata(tail_wdata), 
	.tail_rdata(tail_rdata), 

	.depth_wr(depth_wr), 
	.depth_raddr(depth_raddr), 
	.depth_waddr(depth_waddr), 
	.depth_wdata(depth_wdata), 
	.depth_rdata(depth_rdata), 

	.depth_fid0_wr(depth_fid0_wr), 
	.depth_fid0_raddr(depth_fid0_raddr), 
	.depth_fid0_waddr(depth_fid0_waddr), 
	.depth_fid0_wdata(depth_fid0_wdata), 
	.depth_fid0_rdata(depth_fid0_rdata), 

	.depth_fid1_wr(depth_fid1_wr), 
	.depth_fid1_raddr(depth_fid1_raddr), 
	.depth_fid1_waddr(depth_fid1_waddr), 
	.depth_fid1_wdata(depth_fid1_wdata), 
	.depth_fid1_rdata(depth_fid1_rdata), 

	.ll_wr(ll_wr), 
	.ll_raddr(ll_raddr), 
	.ll_waddr(ll_waddr), 
	.ll_wdata(ll_wdata), 
	.ll_rdata(ll_rdata), 

	.desc_wr(desc_wr), 
	.desc_raddr(desc_raddr), 
	.desc_waddr(desc_waddr), 
	.desc_wdata(desc_wdata), 
	.desc_rdata(desc_rdata), 

	.enq_ack(enq_ack), 
	.enq_to_empty(enq_to_empty), 
	.enq_ack_qid(enq_ack_qid), 
	.enq_ack_dst_port(), 

	.deq_depth_ack(deq_depth_ack), 
	.deq_depth_from_emptyp2(deq_depth_from_emptyp2), 

	.deq_ack(deq_ack), 
	.deq_ack_qid(deq_ack_qid), 
	.deq_ack_desc(deq_ack_desc) 
);

piarb_qm_ds u_piarb_qm_ds(
        .clk(clk),

	.head_wr(head_wr), 
	.head_raddr(head_raddr), 
	.head_waddr(head_waddr), 
	.head_wdata(head_wdata), 
	.head_rdata(head_rdata), 

	.tail_wr(tail_wr), 
	.tail_raddr(tail_raddr), 
	.tail_waddr(tail_waddr), 
	.tail_wdata(tail_wdata), 
	.tail_rdata(tail_rdata), 

	.depth_wr(depth_wr), 
	.depth_raddr(depth_raddr), 
	.depth_waddr(depth_waddr), 
	.depth_wdata(depth_wdata), 
	.depth_rdata(depth_rdata), 

	.depth_fid0_wr(depth_fid0_wr), 
	.depth_fid0_raddr(depth_fid0_raddr), 
	.depth_fid0_waddr(depth_fid0_waddr), 
	.depth_fid0_wdata(depth_fid0_wdata), 
	.depth_fid0_rdata(depth_fid0_rdata), 

	.depth_fid1_wr(depth_fid1_wr), 
	.depth_fid1_raddr(depth_fid1_raddr), 
	.depth_fid1_waddr(depth_fid1_waddr), 
	.depth_fid1_wdata(depth_fid1_wdata), 
	.depth_fid1_rdata(depth_fid1_rdata), 

	.ll_wr(ll_wr), 
	.ll_raddr(ll_raddr), 
	.ll_waddr(ll_waddr), 
	.ll_wdata(ll_wdata), 
	.ll_rdata(ll_rdata), 

	.desc_wr(desc_wr), 
	.desc_raddr(desc_raddr), 
	.desc_waddr(desc_waddr), 
	.desc_wdata(desc_wdata), 
	.desc_rdata(desc_rdata) 

);

piarb_lookup u_piarb_lookup(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.ecdsa_piarb_wr(ecdsa_piarb_wr),
	.ecdsa_piarb_waddr(ecdsa_piarb_waddr),
	.ecdsa_piarb_wdata(ecdsa_piarb_wdata),

	.data_ack_valid(data_ack_valid),
	.data_ack_port_id(data_ack_port_id),
	.data_ack_sop(data_ack_sop),
	.data_ack_eop(data_ack_eop),
	.data_ack_data(data_ack_data),
	.data_ack_meta(data_ack_meta),

	.flow_value_rdata(flow_value_rdata),

	.topic_value_ack(topic_value_ack),
	.topic_value_rdata(topic_value_rdata),

	.topic_value_rd(topic_value_rd),
	.topic_value_raddr(topic_value_raddr),

	.flow_value_wr(flow_value_wr),
	.flow_value_wdata(flow_value_wdata),
	.flow_value_waddr(flow_value_waddr),
	.flow_value_raddr(flow_value_raddr),

	.piarb_pu_valid(piarb_pu_valid),
	.piarb_pu_pid(piarb_pu_pid),
	.piarb_pu_data(piarb_pu_data),
	.piarb_pu_meta_data(piarb_pu_meta_data),
	.piarb_pu_fid_sel(piarb_pu_fid_sel),
	.piarb_pu_sop(piarb_pu_sop),
	.piarb_pu_eop(piarb_pu_eop)

);

ram_1r1w #(`FLOW_PU_NBITS, `FID_NBITS) u_ram_1r1w_2(
		.clk(clk),
		.wr(flow_value_wr),
		.raddr(flow_value_raddr),
		.waddr(flow_value_waddr),
		.din(flow_value_wdata),

		.dout(flow_value_rdata)
);

pio_mem #(`SWITCH_TAG_NBITS, `TID_NBITS) u_pio_mem0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_value),

		.app_mem_rd(topic_value_rd),
		.app_mem_raddr(topic_value_raddr),

        	.mem_ack(topic_value_mem_ack),
        	.mem_rdata(topic_value_mem_rdata),

		.app_mem_ack(topic_value_ack),
		.app_mem_rdata(topic_value_rdata)
);

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`PIARB_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`PIARB_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(0),
  .REG_BLOCK_ADDR(0)
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
    .mem_bs(mem_bs),
    .reg_bs(reg_bs)

);

piarb_pio u_piarb_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .topic_value_mem_ack(topic_value_mem_ack),
    .topic_value_mem_rdata(topic_value_mem_rdata),

    .reg_ms_topic_value(reg_ms_topic_value),

    .pio_ack(pio_ack),
    .pio_rvalid(pio_rvalid),
    .pio_rdata(pio_rdata)

);

endmodule 
