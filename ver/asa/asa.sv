//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module asa #(
parameter LEN_NBITS = `PD_CHUNK_DEPTH_NBITS  
)(

input clk, 
input `RESET_SIG, 

input         pio_start,
input         pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

output clk_div,
output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata,

input [`REAL_TIME_NBITS-1:0] current_time,		

input         ecdsa_asa_fp_wr,
input [`FID_NBITS-1:0] ecdsa_asa_fp_waddr,				
input [`FLOW_POLICY2_NBITS-1:0] ecdsa_asa_fp_wdata,				

input         pu_asa_start,
input         pu_asa_valid,
input [`PU_ASA_NBITS-1:0] pu_asa_data,				
input         pu_asa_eop,
input [`PU_ID_NBITS-1:0] pu_asa_pu_id,				

input         em_asa_valid,
input [`EM_BUF_PTR_NBITS-1:0] em_asa_buf_ptr,				
input [`PU_ID_NBITS-1:0] em_asa_pu_id,				
input [LEN_NBITS-1:0] em_asa_len,				
input em_asa_discard,

input         piarb_asa_valid,
input         piarb_asa_type3,
input [`PU_ID_NBITS-1:0] piarb_asa_pu_id,				
input piarb_asa_meta_type piarb_asa_meta_data,				

input tm_asa_poll_ack,
input tm_asa_poll_drop,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id,
input [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id,


output logic   asa_pu_table_wr,
output logic [`RCI_NBITS-1:0] asa_pu_table_waddr,
output logic [`SCI_NBITS-1:0] asa_pu_table_wdata,

output logic asa_classifier_valid,
output logic [`FID_NBITS-1:0] asa_classifier_fid,

output logic int_rep_bp,

output logic asa_tm_poll_req,		
output logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid,				
output logic [`PORT_ID_NBITS-1:0] asa_tm_poll_src_port,				

output logic asa_tm_enq_req,					
output logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_qid,				
output logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_id,
output logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_group_id,
output logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_port_queue_id,
output enq_pkt_desc_type asa_tm_enq_desc,				

output logic asa_em_read_count_valid,
output logic [`EM_BUF_PTR_NBITS-1:0] asa_em_buf_ptr,
output logic [`PORT_ID_NBITS-1:0] asa_em_rc_port_id,
output logic [`READ_COUNT_NBITS-1:0] asa_em_read_count,
output logic [`PD_CHUNK_DEPTH_NBITS-1:0] asa_em_pd_length,

output logic asa_bm_read_count_valid,
output logic [`READ_COUNT_NBITS-1:0] asa_bm_read_count,
output logic [`PACKET_LENGTH_NBITS-1:0] asa_bm_packet_length,
output logic [`PORT_ID_NBITS-1:0] asa_bm_rc_port_id,
output logic [`BUF_PTR_NBITS-1:0] asa_bm_buf_ptr

);

/***************************** LOCAL VARIABLES *******************************/

localparam RAS_WIDTH = (`RAS_FLAG_NBITS+(1+`SCI_NBITS)*9);

wire mem_bs;
wire reg_wr;
wire reg_rd;
wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_din;

logic pio_ack0;
logic pio_rvalid0;
logic [`PIO_RANGE] pio_rdata0;

logic pio_ack1;
logic pio_rvalid1;
logic [`PIO_RANGE] pio_rdata1;

logic [`SCI_NBITS-1:0] ram_rdata1;

logic [`SCI_NBITS-1:0] ram_rdata;
logic [`RCI_NBITS-1:0] ram_raddr;

logic rci2sci_table_rd;
logic [`RCI_NBITS*2-1:0] rci2sci_table_raddr;

logic rci2sci_table_ack;
logic [`SCI_NBITS*2-1:0] rci2sci_table_rdata;

logic [`PIO_RANGE] rci2sci_table_mem_rdata;

logic asa_proc_valid;
logic asa_proc_type3;
asa_proc_meta_type asa_proc_meta;
logic [RAS_WIDTH-1:0] asa_proc_ras;

logic [`SUB_EXP_TIME_NBITS-1:0] default_sub_exp_time;

logic [`SCI_NBITS-1:0] supervisor_sci;				
logic [15:0] class2pri;				

logic tset_wr;
logic [`TID_NBITS+`SCI_NBITS-1:0] tset_waddr;				
logic [`SUB_EXP_TIME_NBITS-1:0] tset_wdata;

logic asa_rep_enq_req;
logic asa_rep_enq_discard;
logic asa_rep_enq_allow_mcast;
logic [`SCI_VEC_NBITS-1:0] asa_rep_enq_vec;
logic [`PRI_NBITS-1:0] asa_rep_enq_pri;
enq_pkt_desc_type asa_rep_enq_desc;		
logic [`TID_NBITS - 1 : 0] asa_rep_enq_tid;

logic rep_enq_req;			
logic rep_enq_drop;						
logic rep_enq_ucast;						
logic rep_enq_last;						
logic [`PACKET_ID_NBITS-1:0] rep_enq_packet_id;				
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] rep_enq_qid;			
enq_pkt_desc_type rep_enq_desc;

logic discard_req;		
logic [`EM_BUF_PTR_NBITS-1:0] discard_em_buf_ptr;
logic [LEN_NBITS-1:0] discard_em_len;
discard_info_type discard_info;
wire [`PACKET_LENGTH_NBITS-1:0] discard_packet_length = discard_info.len;
wire [`PORT_ID_NBITS-1:0] discard_src_port = discard_info.src_port;
wire [`BUF_PTR_NBITS-1:0] discard_buf_ptr = discard_info.buf_ptr;

logic   wr_active;
logic [`RCI_NBITS-1:0] wr_addr;
logic [`SCI_NBITS-1:0] wr_data;

/***************************** NON REGISTERED OUTPUTS ****************************/

assign pio_ack = pio_ack0|pio_ack1;
assign pio_rvalid = pio_rvalid0|pio_rvalid1;
assign pio_rdata = pio_rvalid0?pio_rdata0:pio_rdata1;

assign asa_pu_table_wr = wr_active;
assign asa_pu_table_waddr = wr_addr;
assign asa_pu_table_wdata = wr_data;

/***************************** REGISTERED OUTPUTS ****************************/

/***************************** PROGRAM BODY **********************************/

asa_front_end u_asa_front_end(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.pu_asa_start(pu_asa_start),
		.pu_asa_valid(pu_asa_valid),
		.pu_asa_data(pu_asa_data),
		.pu_asa_eop(pu_asa_eop),
		.pu_asa_pu_id(pu_asa_pu_id),

		.em_asa_valid(em_asa_valid),
		.em_asa_buf_ptr(em_asa_buf_ptr),
		.em_asa_pu_id(em_asa_pu_id),
		.em_asa_len(em_asa_len),
		.em_asa_discard(em_asa_discard),

		.piarb_asa_valid(piarb_asa_valid),
		.piarb_asa_type3(piarb_asa_type3),
		.piarb_asa_pu_id(piarb_asa_pu_id),
		.piarb_asa_meta_data(piarb_asa_meta_data),

		.rci2sci_table_ack(rci2sci_table_ack),
		.rci2sci_table_rdata(rci2sci_table_rdata),

		.ram_rdata(ram_rdata),

		.ram_raddr(ram_raddr),

		.rci2sci_table_rd(rci2sci_table_rd),
		.rci2sci_table_raddr(rci2sci_table_raddr),

		.asa_proc_valid(asa_proc_valid),
		.asa_proc_type3(asa_proc_type3),
		.asa_proc_meta(asa_proc_meta),
		.asa_proc_ras(asa_proc_ras)

);

asa_process u_asa_process(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.current_time(current_time),
		.default_sub_exp_time(default_sub_exp_time),

		.supervisor_sci(supervisor_sci),
		.class2pri(class2pri),

		.ecdsa_asa_fp_wr(ecdsa_asa_fp_wr),
		.ecdsa_asa_fp_waddr(ecdsa_asa_fp_waddr),
		.ecdsa_asa_fp_wdata(ecdsa_asa_fp_wdata),

		.asa_proc_valid(asa_proc_valid),
		.asa_proc_type3(asa_proc_type3),
		.asa_proc_meta(asa_proc_meta),
		.asa_proc_ras(asa_proc_ras),

		.asa_classifier_valid(asa_classifier_valid),
		.asa_classifier_fid(asa_classifier_fid),

		.tset_wr(tset_wr),
		.tset_waddr(tset_waddr),
		.tset_wdata(tset_wdata),

		.asa_rep_enq_req(asa_rep_enq_req),
		.asa_rep_enq_discard(asa_rep_enq_discard),
		.asa_rep_enq_allow_mcast(asa_rep_enq_allow_mcast),
		.asa_rep_enq_vec(asa_rep_enq_vec),
		.asa_rep_enq_pri(asa_rep_enq_pri),
		.asa_rep_enq_desc(asa_rep_enq_desc),
		.asa_rep_enq_tid(asa_rep_enq_tid)
);

asa_replicator u_asa_replicator(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.current_time(current_time),

		.asa_rep_enq_req(asa_rep_enq_req),
		.asa_rep_enq_discard(asa_rep_enq_discard),
		.asa_rep_enq_allow_mcast(asa_rep_enq_allow_mcast),
		.asa_rep_enq_vec(asa_rep_enq_vec),
		.asa_rep_enq_pri(asa_rep_enq_pri),
		.asa_rep_enq_desc(asa_rep_enq_desc),
		.asa_rep_enq_tid(asa_rep_enq_tid),

		.int_rep_bp(int_rep_bp),

		.tset_wr(tset_wr),
		.tset_waddr(tset_waddr),
		.tset_wdata(tset_wdata),

    		.discard_req(discard_req),        
    		.discard_info(discard_info),
    		.discard_em_buf_ptr(discard_em_buf_ptr),
    		.discard_em_len(discard_em_len),
   
		.rep_enq_req(rep_enq_req),
		.rep_enq_drop(rep_enq_drop),
		.rep_enq_ucast(rep_enq_ucast),
		.rep_enq_last(rep_enq_last),
		.rep_enq_packet_id(rep_enq_packet_id),
		.rep_enq_qid(rep_enq_qid),
		.rep_enq_desc(rep_enq_desc)

);

asa_tm_interface u_asa_tm_interface(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.discard_req(discard_req),
		.discard_packet_length(discard_packet_length),
		.discard_src_port(discard_src_port),
		.discard_buf_ptr(discard_buf_ptr),
    		.discard_em_buf_ptr(discard_em_buf_ptr),
    		.discard_em_len(discard_em_len),

		.rep_enq_req(rep_enq_req),
		.rep_enq_drop(rep_enq_drop),
		.rep_enq_ucast(rep_enq_ucast),
		.rep_enq_last(rep_enq_last),
		.rep_enq_packet_id(rep_enq_packet_id),
		.rep_enq_qid(rep_enq_qid),
		.rep_enq_desc(rep_enq_desc),

		.tm_asa_poll_ack(tm_asa_poll_ack),
		.tm_asa_poll_drop(tm_asa_poll_drop),
		.tm_asa_poll_conn_id(tm_asa_poll_conn_id),
		.tm_asa_poll_conn_group_id(tm_asa_poll_conn_group_id),
		.tm_asa_poll_port_queue_id(tm_asa_poll_port_queue_id),
		.tm_asa_poll_port_id(tm_asa_poll_port_id),

		.int_rep_bp(int_rep_bp),

		.asa_tm_poll_req(asa_tm_poll_req),
		.asa_tm_poll_qid(asa_tm_poll_qid),
		.asa_tm_poll_src_port(asa_tm_poll_src_port),

		.asa_tm_enq_req(asa_tm_enq_req),
		.asa_tm_enq_qid(asa_tm_enq_qid),
		.asa_tm_enq_conn_id(asa_tm_enq_conn_id),
		.asa_tm_enq_conn_group_id(asa_tm_enq_conn_group_id),
		.asa_tm_enq_port_queue_id(asa_tm_enq_port_queue_id),
		.asa_tm_enq_desc(asa_tm_enq_desc),

		.asa_em_read_count_valid(asa_em_read_count_valid),
		.asa_em_read_count(asa_em_read_count),
		.asa_em_pd_length(asa_em_pd_length),
		.asa_em_rc_port_id(asa_em_rc_port_id),
		.asa_em_buf_ptr(asa_em_buf_ptr),

		.asa_bm_read_count_valid(asa_bm_read_count_valid),
		.asa_bm_read_count(asa_bm_read_count),
		.asa_bm_packet_length(asa_bm_packet_length),
		.asa_bm_rc_port_id(asa_bm_rc_port_id),
		.asa_bm_buf_ptr(asa_bm_buf_ptr)
);


pio2reg_bus #(
  .BLOCK_ADDR_LSB(`ASA_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`ASA_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(`ASA_REG_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`ASA_REG_BLOCK_ADDR)
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

asa_pio u_asa_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .rci2sci_table_mem_ack(rci2sci_table_mem_ack),

    .rci2sci_table_mem_rdata(rci2sci_table_mem_rdata),

    .reg_ms_rci2sci_table(reg_ms_rci2sci_table),

    .pio_ack(pio_ack0),
    .pio_rvalid(pio_rvalid0),
    .pio_rdata(pio_rdata0)

);

asa_reg u_asa_reg(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(reg_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .pio_ack(pio_ack1),
    .pio_rvalid(pio_rvalid1),
    .pio_rdata(pio_rdata1),

    .default_sub_exp_time(default_sub_exp_time),
    .supervisor_sci(supervisor_sci),
    .class2pri(class2pri)

);

pio_mem_wo #(`SCI_NBITS, `RCI_NBITS) u_pio_mem_wo(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci2sci_table),

		.app_mem_rd(rci2sci_table_rd),
		.app_mem_raddr(rci2sci_table_raddr[`RCI_NBITS-1:0]),

        	.wr_active(wr_active),
        	.wr_addr(wr_addr),
        	.wr_data(wr_data),

        	.mem_ack(rci2sci_table_mem_ack),
        	.mem_rdata(rci2sci_table_mem_rdata),

		.app_mem_ack(rci2sci_table_ack),
		.app_mem_rdata(rci2sci_table_rdata[`SCI_NBITS-1:0])
);

logic [`RCI_NBITS-1:0] ram_raddr1;
flop #(`RCI_NBITS) u_flop_1(.clk(clk), .din({rci2sci_table_raddr[`RCI_NBITS*2-1:`RCI_NBITS]}), .dout(ram_raddr1));
ram_1r1w #(`SCI_NBITS, `RCI_NBITS) u_ram_1r1w_0(
		.clk(clk),
		.wr(wr_active),
		.raddr(ram_raddr1),
		.waddr(wr_addr),
		.din(wr_data),

		.dout(ram_rdata1)
);

flop #(`SCI_NBITS) u_flop_0(.clk(clk), .din({ram_rdata1}), .dout({rci2sci_table_rdata[`SCI_NBITS*2-1:`SCI_NBITS]}));

ram_1r1w #(`SCI_NBITS, `RCI_NBITS) u_ram_1r1w_1(
		.clk(clk),
		.wr(wr_active),
		.raddr(ram_raddr),
		.waddr(wr_addr),
		.din(wr_data),

		.dout(ram_rdata)
);


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

