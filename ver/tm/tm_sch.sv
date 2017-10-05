//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm_sch # (

parameter QUEUE_NBITS = `FIRST_LVL_QUEUE_ID_NBITS,
parameter SCH_NBITS = `FIRST_LVL_SCH_ID_NBITS,
parameter QUEUE_PROFILE_NBITS = `FIRST_LVL_QUEUE_PROFILE_NBITS
) (

input clk, `RESET_SIG,

input qm_enq_ack,			
input qm_enq_to_empty,
input [`PORT_ID_NBITS-1:0] qm_enq_ack_dst_port,
input [QUEUE_NBITS-1:0] qm_enq_ack_qid,

input sch_deq_depth_ack,
input sch_deq_depth_from_emptyp2,

input sch_deq_ack,
input [QUEUE_NBITS-1:0] sch_deq_ack_qid,
input sch_pkt_desc_type sch_deq_pkt_desc,

input next_qm_avail_ack,	
input next_qm_available,	

input [`NUM_OF_PORTS-1:0] next_qm_enq_dst_available,

input [7:0] pri_sch_ctrl_wr,
input [SCH_NBITS-1:0] pri_sch_ctrl_waddr,
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_wdata,

input pri_sch_ctrl0_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl0_rdata,
input pri_sch_ctrl1_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl1_rdata,
input pri_sch_ctrl2_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl2_rdata,
input pri_sch_ctrl3_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl3_rdata,
input pri_sch_ctrl4_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl4_rdata,
input pri_sch_ctrl5_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl5_rdata,
input pri_sch_ctrl6_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl6_rdata,
input pri_sch_ctrl7_ack, 
input [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl7_rdata,

input queue_profile_ack, 
input [QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata,

input wdrr_quantum_ack, 
input [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata,

input shaping_profile_cir_ack, 
input [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata,

input shaping_profile_eir_ack, 
input [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata,

input wdrr_sch_ctrl_ack, 
input [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata,

input fill_tb_dst_ack, 
input [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata,


output pri_sch_ctrl0_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl0_raddr,
output pri_sch_ctrl1_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl1_raddr,
output pri_sch_ctrl2_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl2_raddr,
output pri_sch_ctrl3_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl3_raddr,
output pri_sch_ctrl4_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl4_raddr,
output pri_sch_ctrl5_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl5_raddr,
output pri_sch_ctrl6_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl6_raddr,
output pri_sch_ctrl7_rd, 
output [SCH_NBITS-1:0] pri_sch_ctrl7_raddr,

output reg queue_profile_rd, 
output reg [QUEUE_NBITS-1:0] queue_profile_raddr,

output wdrr_quantum_rd, 
output [QUEUE_NBITS-1:0] wdrr_quantum_raddr,

output shaping_profile_cir_rd, 
output [QUEUE_NBITS-1:0] shaping_profile_cir_raddr,
output reg shaping_profile_cir_wr, 
output reg [QUEUE_NBITS-1:0] shaping_profile_cir_waddr,
output reg [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata,

output shaping_profile_eir_rd, 
output [QUEUE_NBITS-1:0] shaping_profile_eir_raddr,
output reg shaping_profile_eir_wr, 
output reg [QUEUE_NBITS-1:0] shaping_profile_eir_waddr,
output reg [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata,

output wdrr_sch_ctrl_rd, 
output [SCH_NBITS-1:0] wdrr_sch_ctrl_raddr,

output fill_tb_dst_rd, 
output [QUEUE_NBITS-1:0] fill_tb_dst_raddr,
output reg fill_tb_dst_wr, 
output reg [QUEUE_NBITS-1:0] fill_tb_dst_waddr,
output reg [`PORT_ID_NBITS-1:0] fill_tb_dst_wdata,

output reg deficit_counter_wr,			
output reg [QUEUE_NBITS-1:0] deficit_counter_waddr,
output reg [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata,
output [QUEUE_NBITS-1:0] deficit_counter_raddr,
input [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata,

output reg token_bucket_wr,			
output reg [QUEUE_NBITS-1:0] token_bucket_waddr,
output reg [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata,
output [QUEUE_NBITS-1:0] token_bucket_raddr,
input [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata,

output reg eir_tb_wr,			
output reg [`PORT_ID_NBITS-1:0] eir_tb_waddr,
output reg [`EIR_NBITS+2-1:0] eir_tb_wdata,
output [`PORT_ID_NBITS-1:0] eir_tb_raddr,
input [`EIR_NBITS+2-1:0] eir_tb_rdata,

output reg event_fifo_wr,			
output reg [QUEUE_NBITS-1:0] event_fifo_waddr,
output reg [QUEUE_NBITS+2-1:0] event_fifo_wdata,
output reg [QUEUE_NBITS-1:0] event_fifo_raddr,
input [QUEUE_NBITS+2-1:0] event_fifo_rdata,

output reg event_fifo_rd_ptr_wr0,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr0,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata0,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr0,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata0,

output reg event_fifo_rd_ptr_wr1,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr1,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata1,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr1,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata1,

output reg event_fifo_rd_ptr_wr2,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr2,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata2,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr2,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata2,

output reg event_fifo_rd_ptr_wr3,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr3,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata3,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr3,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata3,

output reg event_fifo_rd_ptr_wr4,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr4,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata4,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr4,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata4,

output reg event_fifo_rd_ptr_wr5,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr5,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata5,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr5,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata5,

output reg event_fifo_rd_ptr_wr6,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr6,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata6,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr6,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata6,

output reg event_fifo_rd_ptr_wr7,			
output reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr7,
output reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata7,
output [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr7,
input [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata7,

output reg event_fifo_wr_ptr_wr0,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr0,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata0,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr0,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata0,

output reg event_fifo_wr_ptr_wr1,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr1,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata1,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr1,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata1,

output reg event_fifo_wr_ptr_wr2,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr2,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata2,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr2,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata2,

output reg event_fifo_wr_ptr_wr3,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr3,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata3,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr3,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata3,

output reg event_fifo_wr_ptr_wr4,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr4,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata4,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr4,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata4,

output reg event_fifo_wr_ptr_wr5,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr5,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata5,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr5,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata5,

output reg event_fifo_wr_ptr_wr6,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr6,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata6,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr6,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata6,

output reg event_fifo_wr_ptr_wr7,			
output reg [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr7,
output reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata7,
output [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr7,
input [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata7,

output reg event_fifo_count_wr0,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr0,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata0,
output [SCH_NBITS-1:0] event_fifo_count_raddr0,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata0,

output reg event_fifo_count_wr1,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr1,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata1,
output [SCH_NBITS-1:0] event_fifo_count_raddr1,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata1,

output reg event_fifo_count_wr2,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr2,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata2,
output [SCH_NBITS-1:0] event_fifo_count_raddr2,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata2,

output reg event_fifo_count_wr3,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr3,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata3,
output [SCH_NBITS-1:0] event_fifo_count_raddr3,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata3,

output reg event_fifo_count_wr4,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr4,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata4,
output [SCH_NBITS-1:0] event_fifo_count_raddr4,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata4,

output reg event_fifo_count_wr5,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr5,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata5,
output [SCH_NBITS-1:0] event_fifo_count_raddr5,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata5,

output reg event_fifo_count_wr6,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr6,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata6,
output [SCH_NBITS-1:0] event_fifo_count_raddr6,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata6,

output reg event_fifo_count_wr7,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr7,
output reg [QUEUE_NBITS-1:0] event_fifo_count_wdata7,
output [SCH_NBITS-1:0] event_fifo_count_raddr7,
input [QUEUE_NBITS-1:0] event_fifo_count_rdata7,

output reg event_fifo_count_wr,			
output reg [SCH_NBITS-1:0] event_fifo_count_waddr,
output reg [(QUEUE_NBITS<<1)-1:0] event_fifo_count_wdata,
output [SCH_NBITS-1:0] event_fifo_count_raddr,
input [(QUEUE_NBITS<<1)-1:0] event_fifo_count_rdata,

output reg event_fifo_f1_count_wr,			
output reg [SCH_NBITS-1:0] event_fifo_f1_count_waddr,
output reg [QUEUE_NBITS-1:0] event_fifo_f1_count_wdata,
output [SCH_NBITS-1:0] event_fifo_f1_count_raddr,
input [QUEUE_NBITS-1:0] event_fifo_f1_count_rdata,

output reg wdrr_sch_tqna_wr,			
output reg [SCH_NBITS-1:0] wdrr_sch_tqna_waddr,
output reg [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata,
output [SCH_NBITS-1:0] wdrr_sch_tqna_raddr,
input [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata,

output reg semaphore_wr,			
output reg [QUEUE_NBITS-1:0] semaphore_waddr,
output reg semaphore_wdata,			
output [QUEUE_NBITS-1:0] semaphore_raddr,
input semaphore_rdata,			

output reg next_qm_avail_req,		
output reg [SCH_NBITS-1:0] next_qm_avail_req_qid,
			
output reg next_qm_enq_req,			
output reg [SCH_NBITS-1:0] next_qm_enq_qid,
output sch_pkt_desc_type next_qm_enq_pkt_desc,

output reg sch_deq,			
output reg [QUEUE_NBITS-1:0] sch_deq_qid
);

/***************************** LOCAL VARIABLES *******************************/

localparam [1:0]	 INIT_IDLE = 0,
		 INIT_COUNT = 1,
		 INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [QUEUE_NBITS-1:0] init_count;
reg init_wr;

reg init_wr1;
reg [QUEUE_NBITS-1:0] init_count1;

reg sch_deq_ack_d1;
sch_pkt_desc_type sch_deq_pkt_desc_d1;

reg sch_deq_from_emptyp2_d1;
reg [QUEUE_NBITS-1:0] sch_deq_ack_qid_d1;
reg [`PORT_ID_NBITS-1:0] sch_deq_dst_port_d1;

reg [`NUM_OF_PORTS-1:0] port_available_d1;
reg [`NUM_OF_PORTS-1:0] next_qm_enq_dst_available_d1;	

reg fill_tb_dst_ack_d1; 

reg [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata_d1;
reg [QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata_d1;
reg [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata_d1;
reg [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata_d1;
reg [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata_d1;
reg [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata_d1;
reg [`EIR_NBITS+2-1:0] eir_tb_rdata_d1;
reg [`EIR_NBITS+2-1:0] meir_tb_wdata;
reg [QUEUE_NBITS+2-1:0] event_fifo_rdata_d1;
reg [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata_d1;
reg [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata_d1;
reg [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata_d1;
reg semaphore_rdata_d1;

reg [QUEUE_NBITS-1:0] semaphore_waddr_d1;
reg [QUEUE_NBITS-1:0] semaphore_waddr_d2;

reg semaphore_wdata_d1;
reg semaphore_wdata_d2;

reg semaphore_wr_d1;
reg semaphore_wr_d2;

reg queue_profile_ack_d1; 

reg [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata_d1;
reg [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata_d2;

reg [`EIR_NBITS+2-1:0] eir_tb_wdata_d1;
reg [`EIR_NBITS+2-1:0] eir_tb_wdata_d2;

reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata0_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata1_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata2_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata3_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata4_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata5_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata6_d1;
reg [(QUEUE_NBITS<<1)-1:0] pri_sch_ctrl_rdata7_d1;

reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata0_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata1_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata2_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata3_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata4_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata5_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata6_d1;
reg [QUEUE_NBITS-1:0] event_fifo_rd_ptr_rdata7_d1;

reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata0_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata1_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata2_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata3_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata4_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata5_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata6_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_rdata7_d1;

reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata0_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata1_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata2_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata3_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata4_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata5_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata6_d1;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata7_d1;

reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata0_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata1_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata2_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata3_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata4_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata5_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata6_d2;
reg [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata7_d2;

reg event_fifo_wr_ptr_wr0_d1;
reg event_fifo_wr_ptr_wr1_d1;
reg event_fifo_wr_ptr_wr2_d1;
reg event_fifo_wr_ptr_wr3_d1;
reg event_fifo_wr_ptr_wr4_d1;
reg event_fifo_wr_ptr_wr5_d1;
reg event_fifo_wr_ptr_wr6_d1;
reg event_fifo_wr_ptr_wr7_d1;

reg event_fifo_wr_ptr_wr0_d2;
reg event_fifo_wr_ptr_wr1_d2;
reg event_fifo_wr_ptr_wr2_d2;
reg event_fifo_wr_ptr_wr3_d2;
reg event_fifo_wr_ptr_wr4_d2;
reg event_fifo_wr_ptr_wr5_d2;
reg event_fifo_wr_ptr_wr6_d2;
reg event_fifo_wr_ptr_wr7_d2;

reg [QUEUE_NBITS-1:0] event_fifo_count_rdata0_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata1_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata2_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata3_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata4_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata5_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata6_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_rdata7_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata0_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata1_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata2_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata3_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata4_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata5_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata6_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata7_d1;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata0_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata1_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata2_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata3_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata4_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata5_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata6_d2;
reg [QUEUE_NBITS-1:0] event_fifo_count_wdata7_d2;

reg event_fifo_count_wr0_d1;
reg event_fifo_count_wr1_d1;
reg event_fifo_count_wr2_d1;
reg event_fifo_count_wr3_d1;
reg event_fifo_count_wr4_d1;
reg event_fifo_count_wr5_d1;
reg event_fifo_count_wr6_d1;
reg event_fifo_count_wr7_d1;
reg event_fifo_count_wr0_d2;
reg event_fifo_count_wr1_d2;
reg event_fifo_count_wr2_d2;
reg event_fifo_count_wr3_d2;
reg event_fifo_count_wr4_d2;
reg event_fifo_count_wr5_d2;
reg event_fifo_count_wr6_d2;
reg event_fifo_count_wr7_d2;

reg [(QUEUE_NBITS<<1)-1:0] event_fifo_count_rdata_d1;
reg [QUEUE_NBITS-1:0] event_fifo_f1_count_rdata_d1;
reg [QUEUE_NBITS-1:0] event_fifo_f1_count_rdata_d2;
reg [QUEUE_NBITS-1:0] event_fifo_f1_count_rdata_d3;
reg [QUEUE_NBITS-1:0] event_fifo_f1_count_wdata_d1;
reg [QUEUE_NBITS-1:0] event_fifo_f1_count_wdata_d2;
reg [(QUEUE_NBITS<<1)-1:0] event_fifo_count_wdata_d1;
reg [(QUEUE_NBITS<<1)-1:0] event_fifo_count_wdata_d2;

reg event_fifo_count_wr_d1;
reg event_fifo_count_wr_d2;

reg event_fifo_f1_count_wr_d1;
reg event_fifo_f1_count_wr_d2;

reg en_enq_into_event_fifo_d1;
reg en_enq_into_event_fifo_d2;
reg en_enq_into_event_fifo_d3;
reg en_enq_into_event_fifo_d4;

reg en_deq_from_event_fifo_d1;
reg en_deq_from_event_fifo_d2;
reg en_deq_from_event_fifo_d3;
reg en_deq_from_event_fifo_d4;
reg en_deq_from_event_fifo_d5;
reg en_deq_from_event_fifo_d6;

reg enq_en_pri_sch_d1;
reg enq_en_pri_sch_d2;
reg [2:0] enq_pri_sel_d1;
reg [2:0] enq_pri_sel_d2;

reg [2:0] deq_event_fifo_sel;
reg [2:0] deq_event_fifo_sel_d1;
reg [2:0] deq_event_fifo_sel_d2;
reg [2:0] deq_event_fifo_sel_d3;
reg [2:0] deq_event_fifo_sel_d4;

reg deq_en_pri_sch_d1;
reg deq_en_pri_sch_d2;
reg deq_en_pri_sch_d3;
reg deq_en_pri_sch_d4;
reg deq_en_pri_sch_d5;
reg deq_en_pri_sch_d6;

reg [SCH_NBITS-1:0] event_fifo_count_raddr_d1;
reg [SCH_NBITS-1:0] event_fifo_count_raddr_d2;
reg [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr_d1;
reg [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr_d2;
reg [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr_d3;
reg [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr_d4;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr_d1;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr_d2;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr_d3;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr_d4;
reg [QUEUE_NBITS-1:0] deficit_counter_raddr_d1;
reg [QUEUE_NBITS-1:0] deficit_counter_raddr_d2;
reg [QUEUE_NBITS-1:0] deficit_counter_raddr_d3;

reg [QUEUE_NBITS-1:0] token_bucket_waddr_d1;
reg [QUEUE_NBITS-1:0] token_bucket_waddr_d2;

reg token_bucket_wr_d1;
reg token_bucket_wr_d2;

reg [`PORT_ID_NBITS-1:0] eir_tb_raddr_d1;
reg [`PORT_ID_NBITS-1:0] eir_tb_raddr_d2;
reg [`PORT_ID_NBITS-1:0] eir_tb_raddr_d3;

reg [`PORT_ID_NBITS-1:0] eir_tb_waddr_d1;
reg [`PORT_ID_NBITS-1:0] eir_tb_waddr_d2;

reg eir_tb_wr_d1;
reg eir_tb_wr_d2;

reg [QUEUE_NBITS-1:0] wdrr_quantum_raddr_d1;
reg [QUEUE_NBITS-1:0] wdrr_quantum_raddr_d2;
reg [QUEUE_NBITS-1:0] wdrr_quantum_raddr_d3;
reg [SCH_NBITS-1:0] wdrr_sch_tqna_raddr_d1;
reg [SCH_NBITS-1:0] wdrr_sch_tqna_raddr_d2;

reg [SCH_NBITS-1:0] event_fifo_count_waddr_d1;
reg [SCH_NBITS-1:0] event_fifo_count_waddr_d2;
reg [SCH_NBITS-1:0] event_fifo_count_waddr_d3;
reg [SCH_NBITS-1:0] event_fifo_count_waddr_d4;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr_d1;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr_d2;
reg [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr_d3;

reg re_enq_drop_d1;
reg re_enq_drop_d2;
reg re_enq_drop_d3;
reg re_enq_drop_d4;
reg re_enq_drop_d5;
reg re_enq_drop_d6;

reg re_enq_drop_f1_d1;
reg re_enq_drop_f1_d2;
reg re_enq_drop_f1_d3;
reg re_enq_drop_f1_d4;
reg re_enq_drop_f1_d5;
reg re_enq_drop_f1_d6;

reg re_enq_drop_disable_deq_d1;
reg re_enq_drop_disable_deq_d2;

reg [`PACKET_LENGTH_NBITS-1:0] sch_deq_frame_length_d1;
reg [`PACKET_LENGTH_NBITS-1:0] sch_deq_frame_length_d2;
reg [`PACKET_LENGTH_NBITS-1:0] sch_deq_frame_length_d3;

reg [`PACKET_LENGTH_NBITS-1:0] save_fifo_deq_frame_length_d1;
reg [`PACKET_LENGTH_NBITS-1:0] save_fifo_deq_frame_length_d2;

reg lat_fifo_rd3_d1;
reg lat_fifo_rd3_d2;
reg lat_fifo_rd3_d3;

reg lat_fifo_rd5_d1;
reg lat_fifo_rd5_d2;
reg lat_fifo_rd5_d3;

reg f0_flag_d1;
reg f0_flag_d2;
reg f0_flag_d3;

reg save_fifo_f0_flag_d1;
reg save_fifo_f0_flag_d2;

reg [1:0] ctr4;
reg [QUEUE_NBITS-1:0] ctr4k;

reg [QUEUE_NBITS-1:0] en_enq_into_event_fifo_qid_d1;
reg en_enq_into_event_fifo_f0_d1;
reg en_enq_into_event_fifo_f1_d1;
reg [QUEUE_NBITS-1:0] en_enq_into_event_fifo_qid_d2;
reg en_enq_into_event_fifo_f0_d2;
reg en_enq_into_event_fifo_f1_d2;

reg [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port_d1;
reg [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port_d2;
reg [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port_d3;
reg [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port_d4;
reg [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port_d5;
reg [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port_d6;

reg enable_deq_d1;
reg enable_deq_d2;
reg enable_deq_d3;
reg enable_deq_d4;
reg enable_deq_d5;
reg enable_deq_d6;

reg [QUEUE_NBITS-1:0] ave_count_d1;
reg [QUEUE_NBITS-1:0] ave_count_d2;
reg [QUEUE_NBITS-1:0] ave_count_d3;
reg [QUEUE_NBITS-1:0] ave_count_d4;

reg dis_enq_wr1_d1;
reg dis_deq_wr1_d1;

reg dis_f1_enq_wr1_d1;
reg dis_f1_deq_wr1_d1;

reg lat_fifo_rd2_d1;
reg lat_fifo_rd2_d2;
 
reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port_d1;
reg [QUEUE_NBITS-1:0] lat_fifo_enq_qid_d1;
reg lat_fifo_enq_en_pri_sch_d1;
reg [2:0] lat_fifo_enq_pri_sel_d1;
reg [SCH_NBITS-1:0] lat_fifo_enq_sch_id_d1;

reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port_d2;
reg [QUEUE_NBITS-1:0] lat_fifo_enq_qid_d2;
reg lat_fifo_enq_en_pri_sch_d2;
reg [2:0] lat_fifo_enq_pri_sel_d2;
reg [SCH_NBITS-1:0] lat_fifo_enq_sch_id_d2;

reg lat_fifo_rd22_d1;
reg lat_fifo_rd22_d2;

reg [(QUEUE_NBITS<<1)-1:0] mevent_fifo_count_rdata;

reg msemaphore_wdata;

reg same_s_addr0;
reg same_s_addr21;
reg asame_addr0;
reg asame_addr21;
reg [2:0] same_addr;
reg [2:0] same_wr_ptr_addr;
reg [2:0] f1_same_addr;
reg same_eir_tb_address0;
reg same_eir_tb_address21;
reg same_token_address21;
reg same_token_address0;

reg [`CIR_NBITS+2+`EIR_NBITS+2-1:0] mtoken_bucket_rdata;

reg [3:0] event_fifo_nempty0;
reg [3:0] event_fifo_nempty1;
reg [3:0] event_fifo_nempty2;
reg [3:0] event_fifo_nempty3;
reg [3:0] event_fifo_nempty4;
reg [3:0] event_fifo_nempty5;
reg [3:0] event_fifo_nempty6;
reg [3:0] event_fifo_nempty7;

reg re_enq_drop;
reg [QUEUE_NBITS-1:0] re_enq_drop_qid;
reg [SCH_NBITS-1:0] re_enq_drop_sch_id;
reg [2:0] re_enq_drop_pri_sel;
reg re_enq_drop_en_pri_sch;
reg re_enq_drop_f1;
reg re_enq_drop_disable_deq;
reg [`PORT_ID_NBITS-1:0] re_enq_drop_dst_port;

reg positive_cir_d1;
reg positive_eir_d1;

reg deq_req_qm_d1;

wire shaping_profile_cir_wr_p1; 
wire [QUEUE_NBITS-1:0] shaping_profile_cir_waddr_p1;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata_p1;

wire shaping_profile_eir_wr_p1; 
wire [QUEUE_NBITS-1:0] shaping_profile_eir_waddr_p1;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata_p1;

wire deficit_counter_wr_p1;			
wire [QUEUE_NBITS-1:0] deficit_counter_waddr_p1;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata_p1;

wire token_bucket_wr_p1;			
wire [QUEUE_NBITS-1:0] token_bucket_waddr_p1;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata_p1;

wire eir_tb_wr_p1;			
wire [`PORT_ID_NBITS-1:0] eir_tb_waddr_p1;
wire [`EIR_NBITS+2-1:0] eir_tb_wdata_p1;

wire event_fifo_wr_p1;			
reg [QUEUE_NBITS-1:0] event_fifo_waddr_p1;
wire [QUEUE_NBITS+2-1:0] event_fifo_wdata_p1;

wire event_fifo_rd_ptr_wr0_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr0_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata0_p1;

wire event_fifo_rd_ptr_wr1_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr1_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata1_p1;

wire event_fifo_rd_ptr_wr2_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr2_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata2_p1;

wire event_fifo_rd_ptr_wr3_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr3_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata3_p1;

wire event_fifo_rd_ptr_wr4_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr4_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata4_p1;

wire event_fifo_rd_ptr_wr5_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr5_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata5_p1;

wire event_fifo_rd_ptr_wr6_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr6_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata6_p1;

wire event_fifo_rd_ptr_wr7_p1;			
wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr7_p1;
wire [QUEUE_NBITS-1:0] event_fifo_rd_ptr_wdata7_p1;

wire event_fifo_wr_ptr_wr0_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr0_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata0_p1;

wire event_fifo_wr_ptr_wr1_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr1_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata1_p1;

wire event_fifo_wr_ptr_wr2_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr2_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata2_p1;

wire event_fifo_wr_ptr_wr3_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr3_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata3_p1;

wire event_fifo_wr_ptr_wr4_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr4_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata4_p1;

wire event_fifo_wr_ptr_wr5_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr5_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata5_p1;

wire event_fifo_wr_ptr_wr6_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr6_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata6_p1;

wire event_fifo_wr_ptr_wr7_p1;			
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_waddr7_p1;
wire [QUEUE_NBITS-1:0] event_fifo_wr_ptr_wdata7_p1;

wire event_fifo_count_wr0_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr0_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata0_p1;

wire event_fifo_count_wr1_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr1_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata1_p1;

wire event_fifo_count_wr2_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr2_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata2_p1;

wire event_fifo_count_wr3_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr3_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata3_p1;

wire event_fifo_count_wr4_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr4_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata4_p1;

wire event_fifo_count_wr5_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr5_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata5_p1;

wire event_fifo_count_wr6_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr6_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata6_p1;

wire event_fifo_count_wr7_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr7_p1;
wire [QUEUE_NBITS-1:0] event_fifo_count_wdata7_p1;

wire event_fifo_count_wr_p1;			
wire [SCH_NBITS-1:0] event_fifo_count_waddr_p1;
wire [(QUEUE_NBITS<<1)-1:0] event_fifo_count_wdata_p1;

wire event_fifo_f1_count_wr_p1;			
wire [SCH_NBITS-1:0] event_fifo_f1_count_waddr_p1;
wire [QUEUE_NBITS-1:0] event_fifo_f1_count_wdata_p1;

wire wdrr_sch_tqna_wr_p1;			
wire [SCH_NBITS-1:0] wdrr_sch_tqna_waddr_p1;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata_p1;

wire semaphore_wr_p1;			
wire [QUEUE_NBITS-1:0] semaphore_waddr_p1;
wire semaphore_wdata_p1;
			
wire push;

wire [SCH_NBITS-1:0] stored_fifo_sch_id;

wire [`PORT_ID_NBITS-1:0] acc_fifo_dst_port;
wire [QUEUE_NBITS-1:0] acc_fifo_qid;
wire [SCH_NBITS-1:0] acc_fifo_sch_id;
wire [2:0] acc_fifo_pri_sel;
wire acc_fifo_en_pri_sch;


wire [QUEUE_NBITS-1:0] lat_fifo_qm_enq_ack_qid;
wire [`PORT_ID_NBITS-1:0] lat_fifo_qm_enq_ack_dst_port;


wire re_enq_drop_p1;
wire [QUEUE_NBITS-1:0] re_enq_drop_qid_p1;
wire [SCH_NBITS-1:0] re_enq_drop_sch_id_p1;
wire [2:0] re_enq_drop_pri_sel_p1;
wire re_enq_drop_en_pri_sch_p1;
wire re_enq_drop_f1_p1;
wire re_enq_drop_disable_deq_p1;
wire [`PORT_ID_NBITS-1:0] re_enq_drop_dst_port_p1;

wire lat_fifo_empty7;
wire lat_fifo_empty8;
wire lat_fifo_empty9;
wire fifo_next_qm_available;
wire fifo_next_qm_available_emptyp2;

wire deq_emptyp2_p;
wire [`PORT_ID_NBITS-1:0] deq_dst_port_id_p;
wire deq_en_pri_sch_p;
wire [SCH_NBITS-1:0] deq_sch_id_p;

wire deq_emptyp2;
wire [`PORT_ID_NBITS-1:0] deq_dst_port_id;
wire deq_en_pri_sch;
wire [SCH_NBITS-1:0] deq_sch_id;

wire sch_fifo_empty = lat_fifo_empty7|(deq_emptyp2?lat_fifo_empty8:lat_fifo_empty9);
wire en_deq_from_event_fifo1 = ~sch_fifo_empty&~(en_deq_from_event_fifo_d1|en_deq_from_event_fifo_d2);
wire en_deq_from_event_fifo = ~re_enq_drop&en_deq_from_event_fifo1;

wire [`PACKET_LENGTH_NBITS-1:0] sch_deq_frame_length = sch_deq_pkt_desc.len;
wire [`PORT_ID_NBITS-1:0] sch_deq_dst_port = sch_deq_pkt_desc.dst_port;

wire [`PACKET_LENGTH_NBITS:0] frame_length_add = {1'b0, sch_deq_frame_length_d1};

wire [`PACKET_LENGTH_NBITS-1:0] deq_frame_length = frame_length_add[`PACKET_LENGTH_NBITS-1:0];
wire [`PACKET_LENGTH_NBITS-1:0] save_fifo_deq_frame_length;

wire [`PORT_ID_NBITS-1:0] lat_fifo_deq_dst_port;
wire [QUEUE_NBITS-1:0] lat_fifo_deq_qid;
wire [SCH_NBITS-1:0] lat_fifo_deq_sch_id;
wire [2:0] lat_fifo_deq_pri_sel;
wire lat_fifo_deq_en_pri_sch;
wire lat_fifo_deq_f0;
wire lat_fifo_empty22;
wire lat_fifo_rd22 = ~re_enq_drop&~en_deq_from_event_fifo1&~lat_fifo_empty22;

wire [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port;
wire [QUEUE_NBITS-1:0] lat_fifo_enq_qid;
wire [SCH_NBITS-1:0] lat_fifo_enq_sch_id;
wire [2:0] lat_fifo_enq_pri_sel;
wire lat_fifo_enq_en_pri_sch;
wire lat_fifo_empty2;
wire lat_fifo_rd2 = ~lat_fifo_empty2;

wire [QUEUE_NBITS-1:0] semaphore_raddr_d1 = lat_fifo_enq_qid_d1;

wire [2:0] same_s_addr_p1;
assign same_s_addr_p1[0] = (semaphore_raddr_d1==semaphore_waddr_p1)&semaphore_wr_p1;
assign same_s_addr_p1[1] = (semaphore_raddr_d1==semaphore_waddr)&semaphore_wr;
assign same_s_addr_p1[2] = (semaphore_raddr_d1==semaphore_waddr_d1)&semaphore_wr_d1;

wire msemaphore_wdata_p1 = same_s_addr_p1[1]?semaphore_wdata:semaphore_wdata_d1;

wire msemaphore_rdata_d1 = same_s_addr0?semaphore_wdata:
							same_s_addr21?msemaphore_wdata:
							semaphore_rdata_d1;

wire buf_fifo_wr = lat_fifo_rd2_d2&~msemaphore_rdata_d1;
wire [`PORT_ID_NBITS-1:0] buf_fifo_enq_dst_port;
wire [QUEUE_NBITS-1:0] buf_fifo_enq_qid;
wire buf_fifo_enq_en_pri_sch;
wire [2:0] buf_fifo_enq_pri_sel;
wire [SCH_NBITS-1:0] buf_fifo_enq_sch_id;
wire buf_fifo_f0;
wire buf_fifo_empty;
wire buf_fifo_rd = ~re_enq_drop&~en_deq_from_event_fifo1&lat_fifo_empty22&~buf_fifo_empty;
wire en_enq_into_event_fifo = re_enq_drop|(~buf_fifo_empty|~lat_fifo_empty22)&~en_deq_from_event_fifo1;

wire [QUEUE_NBITS-1:0] en_enq_into_event_fifo_qid = re_enq_drop?re_enq_drop_qid:~lat_fifo_empty22?lat_fifo_deq_qid:buf_fifo_enq_qid;

wire [`PORT_ID_NBITS-1:0] en_event_fifo_dst_port = re_enq_drop?re_enq_drop_dst_port:~sch_fifo_empty?deq_dst_port_id:~lat_fifo_empty22?lat_fifo_deq_dst_port:buf_fifo_enq_dst_port;

wire en_enq_into_event_fifo_f0 = re_enq_drop?1'b0:~lat_fifo_empty22?lat_fifo_deq_f0:buf_fifo_f0;
wire en_enq_into_event_fifo_f1 = re_enq_drop?re_enq_drop_f1:1'b0;

wire deq_req_qm;

wire [SCH_NBITS-1:0] pri_sch_ctrl_raddr;

wire [SCH_NBITS-1:0] event_fifo_rd_ptr_raddr;
wire [SCH_NBITS-1:0] event_fifo_wr_ptr_raddr;

wire [SCH_NBITS-1:0] event_fifo_rd_ptr_waddr = event_fifo_rd_ptr_waddr0;

wire lat_fifo_empty3;
wire lat_fifo_empty5;
wire lat_fifo_rd3;

wire queue_profile_rd_p1 = qm_enq_ack&qm_enq_to_empty;

wire lat_fifo_wr7_req_en;
wire next_qm_avail_req1_p1 = sch_deq_depth_ack&sch_deq_depth_from_emptyp2;
wire next_qm_avail_req_p1 = next_qm_avail_req1_p1|lat_fifo_wr7_req_en;

wire fill_token_bucket = (ctr4==3);

/***************************** NON REGISTERED OUTPUTS ************************/

assign semaphore_raddr = lat_fifo_enq_qid;

assign pri_sch_ctrl0_rd = re_enq_drop|~sch_fifo_empty|~buf_fifo_empty|~lat_fifo_empty22;
assign pri_sch_ctrl1_rd = pri_sch_ctrl0_rd;
assign pri_sch_ctrl2_rd = pri_sch_ctrl0_rd;
assign pri_sch_ctrl3_rd = pri_sch_ctrl0_rd;
assign pri_sch_ctrl4_rd = pri_sch_ctrl0_rd;
assign pri_sch_ctrl5_rd = pri_sch_ctrl0_rd;
assign pri_sch_ctrl6_rd = pri_sch_ctrl0_rd;
assign pri_sch_ctrl7_rd = pri_sch_ctrl0_rd;

assign wdrr_sch_ctrl_rd = pri_sch_ctrl0_rd;

assign fill_tb_dst_rd = fill_token_bucket;

assign pri_sch_ctrl0_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl1_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl2_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl3_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl4_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl5_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl6_raddr = pri_sch_ctrl_raddr;
assign pri_sch_ctrl7_raddr = pri_sch_ctrl_raddr;

assign event_fifo_count_raddr0 = event_fifo_count_raddr;
assign event_fifo_count_raddr1 = event_fifo_count_raddr;
assign event_fifo_count_raddr2 = event_fifo_count_raddr;
assign event_fifo_count_raddr3 = event_fifo_count_raddr;
assign event_fifo_count_raddr4 = event_fifo_count_raddr;
assign event_fifo_count_raddr5 = event_fifo_count_raddr;
assign event_fifo_count_raddr6 = event_fifo_count_raddr;
assign event_fifo_count_raddr7 = event_fifo_count_raddr;

assign event_fifo_rd_ptr_raddr0 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr1 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr2 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr3 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr4 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr5 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr6 = event_fifo_rd_ptr_raddr;
assign event_fifo_rd_ptr_raddr7 = event_fifo_rd_ptr_raddr;

assign event_fifo_wr_ptr_raddr0 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr1 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr2 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr3 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr4 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr5 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr6 = event_fifo_wr_ptr_raddr;
assign event_fifo_wr_ptr_raddr7 = event_fifo_wr_ptr_raddr;

assign wdrr_quantum_rd = lat_fifo_rd3;
assign shaping_profile_cir_rd = en_deq_from_event_fifo_d4|~lat_fifo_empty3|~lat_fifo_empty5;
assign shaping_profile_eir_rd = en_deq_from_event_fifo_d4|~lat_fifo_empty3|~lat_fifo_empty5;

/***************************** REGISTERED OUTPUTS ****************************/

assign fill_tb_dst_raddr = ctr4k;

always @(posedge clk) begin
		queue_profile_raddr <= qm_enq_ack_qid;

		sch_deq_qid <= wdrr_quantum_raddr_d2;

		next_qm_avail_req_qid <= next_qm_avail_req1_p1?acc_fifo_sch_id:deq_sch_id_p;

		next_qm_enq_qid <= stored_fifo_sch_id;
		next_qm_enq_pkt_desc <= sch_deq_pkt_desc_d1;

		shaping_profile_cir_wr <= init_wr1; 
		shaping_profile_cir_waddr <= init_count1;
		shaping_profile_cir_wdata <= 0;

		shaping_profile_eir_wr <= init_wr1; 
		shaping_profile_eir_waddr <= init_count1;
		shaping_profile_eir_wdata <= 0;

		fill_tb_dst_wr <= init_wr1; 
		fill_tb_dst_waddr <= init_count1;
		fill_tb_dst_wdata <= 0;

		deficit_counter_waddr <= deficit_counter_waddr_p1;
		deficit_counter_wdata <= deficit_counter_wdata_p1;

		token_bucket_waddr <= token_bucket_waddr_p1;
		token_bucket_wdata <= token_bucket_wdata_p1;

		eir_tb_waddr <= eir_tb_waddr_p1;
		eir_tb_wdata <= eir_tb_wdata_p1;

		event_fifo_waddr <= event_fifo_waddr_p1;
		event_fifo_wdata <= event_fifo_wdata_p1;

		event_fifo_count_waddr <= event_fifo_count_waddr_p1;
		event_fifo_count_wdata <= event_fifo_count_wdata_p1;

		event_fifo_f1_count_waddr <= event_fifo_f1_count_waddr_p1;
		event_fifo_f1_count_wdata <= event_fifo_f1_count_wdata_p1;

		wdrr_sch_tqna_waddr <= wdrr_sch_tqna_waddr_p1;
		wdrr_sch_tqna_wdata <= wdrr_sch_tqna_wdata_p1;

		semaphore_waddr <= semaphore_waddr_p1;
		semaphore_wdata <= semaphore_wdata_p1;

		event_fifo_count_waddr0 <= event_fifo_count_waddr0_p1;
		event_fifo_count_waddr1 <= event_fifo_count_waddr1_p1;
		event_fifo_count_waddr2 <= event_fifo_count_waddr2_p1;
		event_fifo_count_waddr3 <= event_fifo_count_waddr3_p1;
		event_fifo_count_waddr4 <= event_fifo_count_waddr4_p1;
		event_fifo_count_waddr5 <= event_fifo_count_waddr5_p1;
		event_fifo_count_waddr6 <= event_fifo_count_waddr6_p1;
		event_fifo_count_waddr7 <= event_fifo_count_waddr7_p1;

		event_fifo_wr_ptr_waddr0 <= event_fifo_wr_ptr_waddr0_p1;
		event_fifo_wr_ptr_waddr1 <= event_fifo_wr_ptr_waddr1_p1;
		event_fifo_wr_ptr_waddr2 <= event_fifo_wr_ptr_waddr2_p1;
		event_fifo_wr_ptr_waddr3 <= event_fifo_wr_ptr_waddr3_p1;
		event_fifo_wr_ptr_waddr4 <= event_fifo_wr_ptr_waddr4_p1;
		event_fifo_wr_ptr_waddr5 <= event_fifo_wr_ptr_waddr5_p1;
		event_fifo_wr_ptr_waddr6 <= event_fifo_wr_ptr_waddr6_p1;
		event_fifo_wr_ptr_waddr7 <= event_fifo_wr_ptr_waddr7_p1;

		event_fifo_rd_ptr_waddr0 <= event_fifo_rd_ptr_waddr0_p1;
		event_fifo_rd_ptr_waddr1 <= event_fifo_rd_ptr_waddr1_p1;
		event_fifo_rd_ptr_waddr2 <= event_fifo_rd_ptr_waddr2_p1;
		event_fifo_rd_ptr_waddr3 <= event_fifo_rd_ptr_waddr3_p1;
		event_fifo_rd_ptr_waddr4 <= event_fifo_rd_ptr_waddr4_p1;
		event_fifo_rd_ptr_waddr5 <= event_fifo_rd_ptr_waddr5_p1;
		event_fifo_rd_ptr_waddr6 <= event_fifo_rd_ptr_waddr6_p1;
		event_fifo_rd_ptr_waddr7 <= event_fifo_rd_ptr_waddr7_p1;

		event_fifo_count_wdata0 <= event_fifo_count_wdata0_p1;
		event_fifo_count_wdata1 <= event_fifo_count_wdata1_p1;
		event_fifo_count_wdata2 <= event_fifo_count_wdata2_p1;
		event_fifo_count_wdata3 <= event_fifo_count_wdata3_p1;
		event_fifo_count_wdata4 <= event_fifo_count_wdata4_p1;
		event_fifo_count_wdata5 <= event_fifo_count_wdata5_p1;
		event_fifo_count_wdata6 <= event_fifo_count_wdata6_p1;
		event_fifo_count_wdata7 <= event_fifo_count_wdata7_p1;

		event_fifo_wr_ptr_wdata0 <= event_fifo_wr_ptr_wdata0_p1;
		event_fifo_wr_ptr_wdata1 <= event_fifo_wr_ptr_wdata1_p1;
		event_fifo_wr_ptr_wdata2 <= event_fifo_wr_ptr_wdata2_p1;
		event_fifo_wr_ptr_wdata3 <= event_fifo_wr_ptr_wdata3_p1;
		event_fifo_wr_ptr_wdata4 <= event_fifo_wr_ptr_wdata4_p1;
		event_fifo_wr_ptr_wdata5 <= event_fifo_wr_ptr_wdata5_p1;
		event_fifo_wr_ptr_wdata6 <= event_fifo_wr_ptr_wdata6_p1;
		event_fifo_wr_ptr_wdata7 <= event_fifo_wr_ptr_wdata7_p1;

		event_fifo_rd_ptr_wdata0 <= event_fifo_rd_ptr_wdata0_p1;
		event_fifo_rd_ptr_wdata1 <= event_fifo_rd_ptr_wdata1_p1;
		event_fifo_rd_ptr_wdata2 <= event_fifo_rd_ptr_wdata2_p1;
		event_fifo_rd_ptr_wdata3 <= event_fifo_rd_ptr_wdata3_p1;
		event_fifo_rd_ptr_wdata4 <= event_fifo_rd_ptr_wdata4_p1;
		event_fifo_rd_ptr_wdata5 <= event_fifo_rd_ptr_wdata5_p1;
		event_fifo_rd_ptr_wdata6 <= event_fifo_rd_ptr_wdata6_p1;
		event_fifo_rd_ptr_wdata7 <= event_fifo_rd_ptr_wdata7_p1;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		queue_profile_rd <= 0;

		next_qm_avail_req <= 0;
		next_qm_enq_req <= 0;
		sch_deq <= 0;

		deficit_counter_wr <= 0;			
		token_bucket_wr <= 0;			
		eir_tb_wr <= 0;			
		event_fifo_wr <= 0;

		event_fifo_count_wr <= 0;			
		event_fifo_f1_count_wr <= 0;			
		wdrr_sch_tqna_wr <= 0;			
		semaphore_wr <= 0;			

		event_fifo_count_wr0 <= 0;
		event_fifo_count_wr1 <= 0;
		event_fifo_count_wr2 <= 0;
		event_fifo_count_wr3 <= 0;
		event_fifo_count_wr4 <= 0;
		event_fifo_count_wr5 <= 0;
		event_fifo_count_wr6 <= 0;
		event_fifo_count_wr7 <= 0;

		event_fifo_wr_ptr_wr0 <= 0;
		event_fifo_wr_ptr_wr1 <= 0;
		event_fifo_wr_ptr_wr2 <= 0;
		event_fifo_wr_ptr_wr3 <= 0;
		event_fifo_wr_ptr_wr4 <= 0;
		event_fifo_wr_ptr_wr5 <= 0;
		event_fifo_wr_ptr_wr6 <= 0;
		event_fifo_wr_ptr_wr7 <= 0;

		event_fifo_rd_ptr_wr0 <= 0;
		event_fifo_rd_ptr_wr1 <= 0;
		event_fifo_rd_ptr_wr2 <= 0;
		event_fifo_rd_ptr_wr3 <= 0;
		event_fifo_rd_ptr_wr4 <= 0;
		event_fifo_rd_ptr_wr5 <= 0;
		event_fifo_rd_ptr_wr6 <= 0;
		event_fifo_rd_ptr_wr7 <= 0;

	end else begin
		queue_profile_rd <= queue_profile_rd_p1;

		next_qm_avail_req <= next_qm_avail_req_p1;
		next_qm_enq_req <= sch_deq_ack_d1;
		sch_deq <= deq_req_qm;

		deficit_counter_wr <= deficit_counter_wr_p1;			
		token_bucket_wr <= token_bucket_wr_p1;			
		eir_tb_wr <= eir_tb_wr_p1;			
		event_fifo_wr <= event_fifo_wr_p1;

		event_fifo_count_wr <= event_fifo_count_wr_p1;			
		event_fifo_f1_count_wr <= event_fifo_f1_count_wr_p1;			
		wdrr_sch_tqna_wr <= wdrr_sch_tqna_wr_p1;			
		semaphore_wr <= semaphore_wr_p1;
					
		event_fifo_count_wr0 <= event_fifo_count_wr0_p1;
		event_fifo_count_wr1 <= event_fifo_count_wr1_p1;
		event_fifo_count_wr2 <= event_fifo_count_wr2_p1;
		event_fifo_count_wr3 <= event_fifo_count_wr3_p1;
		event_fifo_count_wr4 <= event_fifo_count_wr4_p1;
		event_fifo_count_wr5 <= event_fifo_count_wr5_p1;
		event_fifo_count_wr6 <= event_fifo_count_wr6_p1;
		event_fifo_count_wr7 <= event_fifo_count_wr7_p1;

		event_fifo_wr_ptr_wr0 <= event_fifo_wr_ptr_wr0_p1;
		event_fifo_wr_ptr_wr1 <= event_fifo_wr_ptr_wr1_p1;
		event_fifo_wr_ptr_wr2 <= event_fifo_wr_ptr_wr2_p1;
		event_fifo_wr_ptr_wr3 <= event_fifo_wr_ptr_wr3_p1;
		event_fifo_wr_ptr_wr4 <= event_fifo_wr_ptr_wr4_p1;
		event_fifo_wr_ptr_wr5 <= event_fifo_wr_ptr_wr5_p1;
		event_fifo_wr_ptr_wr6 <= event_fifo_wr_ptr_wr6_p1;
		event_fifo_wr_ptr_wr7 <= event_fifo_wr_ptr_wr7_p1;

		event_fifo_rd_ptr_wr0 <= event_fifo_rd_ptr_wr0_p1;
		event_fifo_rd_ptr_wr1 <= event_fifo_rd_ptr_wr1_p1;
		event_fifo_rd_ptr_wr2 <= event_fifo_rd_ptr_wr2_p1;
		event_fifo_rd_ptr_wr3 <= event_fifo_rd_ptr_wr3_p1;
		event_fifo_rd_ptr_wr4 <= event_fifo_rd_ptr_wr4_p1;
		event_fifo_rd_ptr_wr5 <= event_fifo_rd_ptr_wr5_p1;
		event_fifo_rd_ptr_wr6 <= event_fifo_rd_ptr_wr6_p1;
		event_fifo_rd_ptr_wr7 <= event_fifo_rd_ptr_wr7_p1;
	end

/***************************** PROGRAM BODY **********************************/

// d0: event_fifo_count read required for both enq and deq
assign event_fifo_count_raddr = re_enq_drop?re_enq_drop_sch_id:en_deq_from_event_fifo?deq_sch_id:~lat_fifo_empty22?lat_fifo_deq_sch_id:buf_fifo_enq_sch_id;


// d0: wdrr scheduler control read required for deq
assign wdrr_sch_ctrl_raddr = event_fifo_count_raddr;

// d0: priority scheduler control read required for both enq and deq
assign pri_sch_ctrl_raddr = event_fifo_count_raddr;

// d0: event_fifo_wr_ptr read required for enq
assign event_fifo_wr_ptr_raddr = re_enq_drop?re_enq_drop_sch_id:~lat_fifo_empty22?lat_fifo_deq_sch_id:buf_fifo_enq_sch_id;

// wire [SCH_NBITS-1:0] enq_addr = event_fifo_wr_ptr_raddr;
wire [SCH_NBITS-1:0] enq_addr_d1 = event_fifo_wr_ptr_raddr_d1;
wire [SCH_NBITS-1:0] enq_addr_d2 = event_fifo_wr_ptr_raddr_d2;

// d0: event_fifo_rd_ptr read required for deq
assign event_fifo_rd_ptr_raddr = deq_sch_id;

// wire [SCH_NBITS-1:0] deq_addr = event_fifo_rd_ptr_raddr;
wire [SCH_NBITS-1:0] deq_addr_d1 = event_fifo_rd_ptr_raddr_d1;
wire [SCH_NBITS-1:0] deq_addr_d2 = event_fifo_rd_ptr_raddr_d2;

// d2: event_fifo_count write required for both enq and deq

wire men_enq_into_event_fifo_d2 = en_enq_into_event_fifo_d2&~(re_enq_drop_disable_deq_d2&re_enq_drop_d2);
wire men_deq_from_event_fifo_d2 = en_deq_from_event_fifo_d2&enable_deq_d2;

wire dis_enq_wr1 = (enq_addr_d2==deq_addr_d1)&en_deq_from_event_fifo_d1;
wire dis_enq_wr = dis_enq_wr1|dis_deq_wr1_d1;
wire dis_deq_wr1 = (deq_addr_d2==enq_addr_d1)&en_enq_into_event_fifo_d1;
wire dis_deq_wr = dis_deq_wr1|dis_enq_wr1_d1;

wire mmen_enq_into_event_fifo_d2 = men_enq_into_event_fifo_d2&~dis_enq_wr;
wire mmen_deq_from_event_fifo_d2 = men_deq_from_event_fifo_d2&~dis_deq_wr;

assign event_fifo_count_wr0_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==0)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==0);
assign event_fifo_count_wr1_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==1)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==1);
assign event_fifo_count_wr2_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==2)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==2);
assign event_fifo_count_wr3_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==3)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==3);
assign event_fifo_count_wr4_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==4)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==4);
assign event_fifo_count_wr5_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==5)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==5);
assign event_fifo_count_wr6_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==6)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==6);
assign event_fifo_count_wr7_p1 = init_wr|(mmen_deq_from_event_fifo_d2&deq_event_fifo_sel==7)|(mmen_enq_into_event_fifo_d2&enq_pri_sel_d2==7);
assign event_fifo_count_wr_p1 = init_wr|mmen_deq_from_event_fifo_d2|mmen_enq_into_event_fifo_d2;

assign event_fifo_count_waddr_p1 = init_wr?init_count[SCH_NBITS-1:0]:event_fifo_count_raddr_d2;
assign event_fifo_count_waddr0_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr1_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr2_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr3_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr4_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr5_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr6_p1 = event_fifo_count_waddr_p1;
assign event_fifo_count_waddr7_p1 = event_fifo_count_waddr_p1;

wire [2:0] same_addr_p1;
assign same_addr_p1[0] = (event_fifo_count_raddr_d1==event_fifo_count_raddr_d2);
assign same_addr_p1[1] = (event_fifo_count_raddr_d1==event_fifo_count_waddr);
assign same_addr_p1[2] = (event_fifo_count_raddr_d1==event_fifo_count_waddr_d1);

wire [2:0] asame_addr_p1;
assign asame_addr_p1[0] = same_addr_p1[0]&event_fifo_count_wr_p1;
assign asame_addr_p1[1] = same_addr_p1[1]&event_fifo_count_wr;
assign asame_addr_p1[2] = same_addr_p1[2]&event_fifo_count_wr_d1;
wire asame_addr21_p1 = |asame_addr_p1[2:1];

wire [(QUEUE_NBITS<<1)-1:0] mevent_fifo_count_rdata_p1 = asame_addr_p1[1]?event_fifo_count_wdata:event_fifo_count_wdata_d1;

wire [(QUEUE_NBITS<<1)-1:0] mevent_fifo_count_rdata_d1 = asame_addr0?event_fifo_count_wdata:
														asame_addr21?mevent_fifo_count_rdata:event_fifo_count_rdata_d1;

	// check if event fifo empty
	wire event_fifo_empty = dis_enq_wr?(mevent_fifo_count_rdata_d1[QUEUE_NBITS-1:0]==1):(mevent_fifo_count_rdata_d1[QUEUE_NBITS-1:0]==0);

	// check if event fifo emptyp2
	wire event_fifo_emptyp2 = (mevent_fifo_count_rdata_d1[QUEUE_NBITS-1:0]>1);

wire [QUEUE_NBITS:0] cur_count = {1'b0, mevent_fifo_count_rdata_d1[QUEUE_NBITS-1:0]};
wire [QUEUE_NBITS:0] ave_count = {1'b0, mevent_fifo_count_rdata_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]};
/*
wire [QUEUE_NBITS:0] delta_count = cur_count - ave_count;
wire [`WDRR_N_NBITS+QUEUE_NBITS:0] extended_delta_count = {{(`WDRR_N_NBITS){delta_count[QUEUE_NBITS]}}, delta_count[QUEUE_NBITS-1:0]}>>wdrr_sch_ctrl_rdata_d1;

wire [QUEUE_NBITS:0] new_ave_count = ave_count+extended_delta_count[QUEUE_NBITS:0];
*/
wire [QUEUE_NBITS-1:0] new_ave_count = (ave_count - (ave_count>>wdrr_sch_ctrl_rdata_d1))+(cur_count>>wdrr_sch_ctrl_rdata_d1);

wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata0_d1 = same_addr[0]&event_fifo_count_wr0?event_fifo_count_wdata0:
													same_addr[1]&event_fifo_count_wr0_d1?event_fifo_count_wdata0_d1:
													same_addr[2]&event_fifo_count_wr0_d2?event_fifo_count_wdata0_d2:
													event_fifo_count_rdata0_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata1_d1 = same_addr[0]&event_fifo_count_wr1?event_fifo_count_wdata1:
													same_addr[1]&event_fifo_count_wr1_d1?event_fifo_count_wdata1_d1:
													same_addr[2]&event_fifo_count_wr1_d2?event_fifo_count_wdata1_d2:
													event_fifo_count_rdata1_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata2_d1 = same_addr[0]&event_fifo_count_wr2?event_fifo_count_wdata2:
													same_addr[1]&event_fifo_count_wr2_d1?event_fifo_count_wdata2_d1:
													same_addr[2]&event_fifo_count_wr2_d2?event_fifo_count_wdata2_d2:
													event_fifo_count_rdata2_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata3_d1 = same_addr[0]&event_fifo_count_wr3?event_fifo_count_wdata3:
													same_addr[1]&event_fifo_count_wr3_d1?event_fifo_count_wdata3_d1:
													same_addr[2]&event_fifo_count_wr3_d2?event_fifo_count_wdata3_d2:
													event_fifo_count_rdata3_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata4_d1 = same_addr[0]&event_fifo_count_wr4?event_fifo_count_wdata4:
													same_addr[1]&event_fifo_count_wr4_d1?event_fifo_count_wdata4_d1:
													same_addr[2]&event_fifo_count_wr4_d2?event_fifo_count_wdata4_d2:
													event_fifo_count_rdata4_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata5_d1 = same_addr[0]&event_fifo_count_wr5?event_fifo_count_wdata5:
													same_addr[1]&event_fifo_count_wr5_d1?event_fifo_count_wdata5_d1:
													same_addr[2]&event_fifo_count_wr5_d2?event_fifo_count_wdata5_d2:
													event_fifo_count_rdata5_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata6_d1 = same_addr[0]&event_fifo_count_wr6?event_fifo_count_wdata6:
													same_addr[1]&event_fifo_count_wr6_d1?event_fifo_count_wdata6_d1:
													same_addr[2]&event_fifo_count_wr6_d2?event_fifo_count_wdata6_d2:
													event_fifo_count_rdata6_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_count_rdata7_d1 = same_addr[0]&event_fifo_count_wr7?event_fifo_count_wdata7:
													same_addr[1]&event_fifo_count_wr7_d1?event_fifo_count_wdata7_d1:
													same_addr[2]&event_fifo_count_wr7_d2?event_fifo_count_wdata7_d2:
													event_fifo_count_rdata7_d1;

assign event_fifo_count_wdata0_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata0_d1-1):(mevent_fifo_count_rdata0_d1+1);
assign event_fifo_count_wdata1_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata1_d1-1):(mevent_fifo_count_rdata1_d1+1);
assign event_fifo_count_wdata2_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata2_d1-1):(mevent_fifo_count_rdata2_d1+1);
assign event_fifo_count_wdata3_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata3_d1-1):(mevent_fifo_count_rdata3_d1+1);
assign event_fifo_count_wdata4_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata4_d1-1):(mevent_fifo_count_rdata4_d1+1);
assign event_fifo_count_wdata5_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata5_d1-1):(mevent_fifo_count_rdata5_d1+1);
assign event_fifo_count_wdata6_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata6_d1-1):(mevent_fifo_count_rdata6_d1+1);
assign event_fifo_count_wdata7_p1 = init_wr?0:en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata7_d1-1):(mevent_fifo_count_rdata7_d1+1);
assign event_fifo_count_wdata_p1 = init_wr?0:{new_ave_count[QUEUE_NBITS-1:0], (en_deq_from_event_fifo_d2?(mevent_fifo_count_rdata_d1[QUEUE_NBITS-1:0]-1'b1):(mevent_fifo_count_rdata_d1[QUEUE_NBITS-1:0]+1'b1))};

// d2: event_fifo write required for enq
assign event_fifo_wr_p1 = en_enq_into_event_fifo_d2;
wire [2:0] wr_pri_sel = ~enq_en_pri_sch_d2?3'd7:enq_pri_sel_d2;


wire [2:0] same_wr_ptr_addr_p1;
assign same_wr_ptr_addr_p1[0] = (event_fifo_wr_ptr_raddr_d1==event_fifo_count_raddr_d2);
assign same_wr_ptr_addr_p1[1] = (event_fifo_wr_ptr_raddr_d1==event_fifo_count_waddr);
assign same_wr_ptr_addr_p1[2] = (event_fifo_wr_ptr_raddr_d1==event_fifo_count_waddr_d1);

wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata0_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr0?event_fifo_wr_ptr_wdata0:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr0_d1?event_fifo_wr_ptr_wdata0_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr0_d2?event_fifo_wr_ptr_wdata0_d2:
													event_fifo_wr_ptr_rdata0_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata1_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr1?event_fifo_wr_ptr_wdata1:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr1_d1?event_fifo_wr_ptr_wdata1_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr1_d2?event_fifo_wr_ptr_wdata1_d2:
													event_fifo_wr_ptr_rdata1_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata2_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr2?event_fifo_wr_ptr_wdata2:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr2_d1?event_fifo_wr_ptr_wdata2_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr2_d2?event_fifo_wr_ptr_wdata2_d2:
													event_fifo_wr_ptr_rdata2_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata3_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr3?event_fifo_wr_ptr_wdata3:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr3_d1?event_fifo_wr_ptr_wdata3_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr3_d2?event_fifo_wr_ptr_wdata3_d2:
													event_fifo_wr_ptr_rdata3_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata4_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr4?event_fifo_wr_ptr_wdata4:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr4_d1?event_fifo_wr_ptr_wdata4_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr4_d2?event_fifo_wr_ptr_wdata4_d2:
													event_fifo_wr_ptr_rdata4_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata5_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr5?event_fifo_wr_ptr_wdata5:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr5_d1?event_fifo_wr_ptr_wdata5_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr5_d2?event_fifo_wr_ptr_wdata5_d2:
													event_fifo_wr_ptr_rdata5_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata6_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr6?event_fifo_wr_ptr_wdata6:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr6_d1?event_fifo_wr_ptr_wdata6_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr6_d2?event_fifo_wr_ptr_wdata6_d2:
													event_fifo_wr_ptr_rdata6_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_wr_ptr_rdata7_d1 = same_wr_ptr_addr[0]&event_fifo_wr_ptr_wr7?event_fifo_wr_ptr_wdata7:
													same_wr_ptr_addr[1]&event_fifo_wr_ptr_wr7_d1?event_fifo_wr_ptr_wdata7_d1:
													same_wr_ptr_addr[2]&event_fifo_wr_ptr_wr7_d2?event_fifo_wr_ptr_wdata7_d2:
													event_fifo_wr_ptr_rdata7_d1;

wire [QUEUE_NBITS-1:0] event_fifo_waddr0 = mevent_fifo_wr_ptr_rdata0_d1;
wire wr_wrap_around0 = (event_fifo_waddr0==pri_sch_ctrl_rdata0_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr1 = mevent_fifo_wr_ptr_rdata1_d1;
wire wr_wrap_around1 = (event_fifo_waddr1==pri_sch_ctrl_rdata1_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr2 = mevent_fifo_wr_ptr_rdata2_d1;
wire wr_wrap_around2 = (event_fifo_waddr2==pri_sch_ctrl_rdata2_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr3 = mevent_fifo_wr_ptr_rdata3_d1;
wire wr_wrap_around3 = (event_fifo_waddr3==pri_sch_ctrl_rdata3_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr4 = mevent_fifo_wr_ptr_rdata4_d1;
wire wr_wrap_around4 = (event_fifo_waddr4==pri_sch_ctrl_rdata4_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr5 = mevent_fifo_wr_ptr_rdata5_d1;
wire wr_wrap_around5 = (event_fifo_waddr5==pri_sch_ctrl_rdata5_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr6 = mevent_fifo_wr_ptr_rdata6_d1;
wire wr_wrap_around6 = (event_fifo_waddr6==pri_sch_ctrl_rdata6_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_waddr7 = mevent_fifo_wr_ptr_rdata7_d1;
wire wr_wrap_around7 = (event_fifo_waddr7==pri_sch_ctrl_rdata7_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);

always @(*) begin
	case (wr_pri_sel)
		3'd0: event_fifo_waddr_p1 = event_fifo_waddr0;
		3'd1: event_fifo_waddr_p1 = event_fifo_waddr1;
		3'd2: event_fifo_waddr_p1 = event_fifo_waddr2;
		3'd3: event_fifo_waddr_p1 = event_fifo_waddr3;
		3'd4: event_fifo_waddr_p1 = event_fifo_waddr4;
		3'd5: event_fifo_waddr_p1 = event_fifo_waddr5;
		3'd6: event_fifo_waddr_p1 = event_fifo_waddr6;
		default: event_fifo_waddr_p1 = event_fifo_waddr7;
	endcase
end

assign event_fifo_wdata_p1 = {en_enq_into_event_fifo_f1_d2, 
											en_enq_into_event_fifo_f0_d2, 
											en_enq_into_event_fifo_qid_d2};

	// d2: push into scheduler event FIFO (note not queue event FIFO)
	assign push = re_enq_drop_disable_deq_d2&re_enq_drop_d2|event_fifo_empty&en_enq_into_event_fifo_d2|event_fifo_emptyp2&en_deq_from_event_fifo_d2;
	wire [1+`PORT_ID_NBITS+1+SCH_NBITS-1:0] push_data = {lat_fifo_rd22_d2, en_event_fifo_dst_port_d2,
														(en_enq_into_event_fifo_d2?enq_en_pri_sch_d2:deq_en_pri_sch_d2), 
														event_fifo_count_waddr_p1};

// d2: event_fifo_wr_ptr write required for enq
assign event_fifo_wr_ptr_waddr0_p1 = pri_sch_ctrl_wr[0]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr1_p1 = pri_sch_ctrl_wr[1]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr2_p1 = pri_sch_ctrl_wr[2]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr3_p1 = pri_sch_ctrl_wr[3]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr4_p1 = pri_sch_ctrl_wr[4]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr5_p1 = pri_sch_ctrl_wr[5]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr6_p1 = pri_sch_ctrl_wr[6]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;
assign event_fifo_wr_ptr_waddr7_p1 = pri_sch_ctrl_wr[7]?pri_sch_ctrl_waddr:event_fifo_count_raddr_d2;

assign event_fifo_wr_ptr_wr0_p1 = pri_sch_ctrl_wr[0]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==0);
assign event_fifo_wr_ptr_wr1_p1 = pri_sch_ctrl_wr[1]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==1);
assign event_fifo_wr_ptr_wr2_p1 = pri_sch_ctrl_wr[2]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==2);
assign event_fifo_wr_ptr_wr3_p1 = pri_sch_ctrl_wr[3]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==3);
assign event_fifo_wr_ptr_wr4_p1 = pri_sch_ctrl_wr[4]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==4);
assign event_fifo_wr_ptr_wr5_p1 = pri_sch_ctrl_wr[5]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==5);
assign event_fifo_wr_ptr_wr6_p1 = pri_sch_ctrl_wr[6]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==6);
assign event_fifo_wr_ptr_wr7_p1 = pri_sch_ctrl_wr[7]|(en_enq_into_event_fifo_d2&enq_pri_sel_d2==7);

assign event_fifo_wr_ptr_wdata0_p1 = pri_sch_ctrl_wr[0]?pri_sch_ctrl_wdata:wr_wrap_around0?pri_sch_ctrl_rdata0_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata0_d1+1;
assign event_fifo_wr_ptr_wdata1_p1 = pri_sch_ctrl_wr[1]?pri_sch_ctrl_wdata:wr_wrap_around1?pri_sch_ctrl_rdata1_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata1_d1+1;
assign event_fifo_wr_ptr_wdata2_p1 = pri_sch_ctrl_wr[2]?pri_sch_ctrl_wdata:wr_wrap_around2?pri_sch_ctrl_rdata2_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata2_d1+1;
assign event_fifo_wr_ptr_wdata3_p1 = pri_sch_ctrl_wr[3]?pri_sch_ctrl_wdata:wr_wrap_around3?pri_sch_ctrl_rdata3_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata3_d1+1;
assign event_fifo_wr_ptr_wdata4_p1 = pri_sch_ctrl_wr[4]?pri_sch_ctrl_wdata:wr_wrap_around4?pri_sch_ctrl_rdata4_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata4_d1+1;
assign event_fifo_wr_ptr_wdata5_p1 = pri_sch_ctrl_wr[5]?pri_sch_ctrl_wdata:wr_wrap_around5?pri_sch_ctrl_rdata5_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata5_d1+1;
assign event_fifo_wr_ptr_wdata6_p1 = pri_sch_ctrl_wr[6]?pri_sch_ctrl_wdata:wr_wrap_around6?pri_sch_ctrl_rdata6_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata6_d1+1;
assign event_fifo_wr_ptr_wdata7_p1 = pri_sch_ctrl_wr[7]?pri_sch_ctrl_wdata:wr_wrap_around7?pri_sch_ctrl_rdata7_d1[QUEUE_NBITS-1:0]:mevent_fifo_wr_ptr_rdata7_d1+1;

// d2: event fifo read required for deq

wire [3:0] event_fifo_nempty0_p1;
assign event_fifo_nempty0_p1[0] = event_fifo_count_wdata0_p1!=0;
assign event_fifo_nempty0_p1[1] = event_fifo_count_wdata0!=0;
assign event_fifo_nempty0_p1[2] = event_fifo_count_wdata0_d1!=0;
assign event_fifo_nempty0_p1[3] = event_fifo_count_rdata0!=0;
wire [3:0] event_fifo_nempty1_p1;
assign event_fifo_nempty1_p1[0] = event_fifo_count_wdata1_p1!=0;
assign event_fifo_nempty1_p1[1] = event_fifo_count_wdata1!=0;
assign event_fifo_nempty1_p1[2] = event_fifo_count_wdata1_d1!=0;
assign event_fifo_nempty1_p1[3] = event_fifo_count_rdata1!=0;
wire [3:0] event_fifo_nempty2_p1;
assign event_fifo_nempty2_p1[0] = event_fifo_count_wdata2_p1!=0;
assign event_fifo_nempty2_p1[1] = event_fifo_count_wdata2!=0;
assign event_fifo_nempty2_p1[2] = event_fifo_count_wdata2_d1!=0;
assign event_fifo_nempty2_p1[3] = event_fifo_count_rdata2!=0;
wire [3:0] event_fifo_nempty3_p1;
assign event_fifo_nempty3_p1[0] = event_fifo_count_wdata3_p1!=0;
assign event_fifo_nempty3_p1[1] = event_fifo_count_wdata3!=0;
assign event_fifo_nempty3_p1[2] = event_fifo_count_wdata3_d1!=0;
assign event_fifo_nempty3_p1[3] = event_fifo_count_rdata3!=0;
wire [3:0] event_fifo_nempty4_p1;
assign event_fifo_nempty4_p1[0] = event_fifo_count_wdata4_p1!=0;
assign event_fifo_nempty4_p1[1] = event_fifo_count_wdata4!=0;
assign event_fifo_nempty4_p1[2] = event_fifo_count_wdata4_d1!=0;
assign event_fifo_nempty4_p1[3] = event_fifo_count_rdata4!=0;
wire [3:0] event_fifo_nempty5_p1;
assign event_fifo_nempty5_p1[0] = event_fifo_count_wdata5_p1!=0;
assign event_fifo_nempty5_p1[1] = event_fifo_count_wdata5!=0;
assign event_fifo_nempty5_p1[2] = event_fifo_count_wdata5_d1!=0;
assign event_fifo_nempty5_p1[3] = event_fifo_count_rdata5!=0;
wire [3:0] event_fifo_nempty6_p1;
assign event_fifo_nempty6_p1[0] = event_fifo_count_wdata6_p1!=0;
assign event_fifo_nempty6_p1[1] = event_fifo_count_wdata6!=0;
assign event_fifo_nempty6_p1[2] = event_fifo_count_wdata6_d1!=0;
assign event_fifo_nempty6_p1[3] = event_fifo_count_rdata6!=0;
wire [3:0] event_fifo_nempty7_p1;
assign event_fifo_nempty7_p1[0] = event_fifo_count_wdata7_p1!=0;
assign event_fifo_nempty7_p1[1] = event_fifo_count_wdata7!=0;
assign event_fifo_nempty7_p1[2] = event_fifo_count_wdata7_d1!=0;
assign event_fifo_nempty7_p1[3] = event_fifo_count_rdata7!=0;

wire [7:0] pri_event_fifo_nempty;

assign pri_event_fifo_nempty[0] = same_addr[0]&event_fifo_count_wr0?event_fifo_nempty0[0]:
													same_addr[1]&event_fifo_count_wr0_d1?event_fifo_nempty0[1]:
													same_addr[2]&event_fifo_count_wr0_d2?event_fifo_nempty0[2]:
													event_fifo_nempty0[3];
assign pri_event_fifo_nempty[1] = same_addr[0]&event_fifo_count_wr1?event_fifo_nempty1[0]:
													same_addr[1]&event_fifo_count_wr1_d1?event_fifo_nempty1[1]:
													same_addr[2]&event_fifo_count_wr1_d2?event_fifo_nempty1[2]:
													event_fifo_nempty1[3];
assign pri_event_fifo_nempty[2] = same_addr[0]&event_fifo_count_wr2?event_fifo_nempty2[0]:
													same_addr[1]&event_fifo_count_wr2_d1?event_fifo_nempty2[1]:
													same_addr[2]&event_fifo_count_wr2_d2?event_fifo_nempty2[2]:
													event_fifo_nempty2[3];
assign pri_event_fifo_nempty[3] = same_addr[0]&event_fifo_count_wr3?event_fifo_nempty3[0]:
													same_addr[1]&event_fifo_count_wr3_d1?event_fifo_nempty3[1]:
													same_addr[2]&event_fifo_count_wr3_d2?event_fifo_nempty3[2]:
													event_fifo_nempty3[3];
assign pri_event_fifo_nempty[4] = same_addr[0]&event_fifo_count_wr4?event_fifo_nempty4[0]:
													same_addr[1]&event_fifo_count_wr4_d1?event_fifo_nempty4[1]:
													same_addr[2]&event_fifo_count_wr4_d2?event_fifo_nempty4[2]:
													event_fifo_nempty4[3];
assign pri_event_fifo_nempty[5] = same_addr[0]&event_fifo_count_wr5?event_fifo_nempty5[0]:
													same_addr[1]&event_fifo_count_wr5_d1?event_fifo_nempty5[1]:
													same_addr[2]&event_fifo_count_wr5_d2?event_fifo_nempty5[2]:
													event_fifo_nempty5[3];
assign pri_event_fifo_nempty[6] = same_addr[0]&event_fifo_count_wr6?event_fifo_nempty6[0]:
													same_addr[1]&event_fifo_count_wr6_d1?event_fifo_nempty6[1]:
													same_addr[2]&event_fifo_count_wr6_d2?event_fifo_nempty6[2]:
													event_fifo_nempty6[3];
assign pri_event_fifo_nempty[7] = same_addr[0]&event_fifo_count_wr7?event_fifo_nempty7[0]:
													same_addr[1]&event_fifo_count_wr7_d1?event_fifo_nempty7[1]:
													same_addr[2]&event_fifo_count_wr7_d2?event_fifo_nempty7[2]:
													event_fifo_nempty7[3];

always @(*) begin
	case(1'b1)
		~deq_en_pri_sch_d2|pri_event_fifo_nempty[7]: deq_event_fifo_sel = 3'd7;
		pri_event_fifo_nempty[6]: deq_event_fifo_sel = 3'd6;
		pri_event_fifo_nempty[5]: deq_event_fifo_sel = 3'd5;
		pri_event_fifo_nempty[4]: deq_event_fifo_sel = 3'd4;
		pri_event_fifo_nempty[3]: deq_event_fifo_sel = 3'd3;
		pri_event_fifo_nempty[2]: deq_event_fifo_sel = 3'd2;
		pri_event_fifo_nempty[1]: deq_event_fifo_sel = 3'd1;
		default: deq_event_fifo_sel = 3'd0;
	endcase

end

wire [QUEUE_NBITS-1:0] event_fifo_raddr0 = event_fifo_rd_ptr_rdata0_d1;
wire rd_wrap_around0 = (event_fifo_raddr0==pri_sch_ctrl_rdata0_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr1 = event_fifo_rd_ptr_rdata1_d1;
wire rd_wrap_around1 = (event_fifo_raddr1==pri_sch_ctrl_rdata1_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr2 = event_fifo_rd_ptr_rdata2_d1;
wire rd_wrap_around2 = (event_fifo_raddr2==pri_sch_ctrl_rdata2_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr3 = event_fifo_rd_ptr_rdata3_d1;
wire rd_wrap_around3 = (event_fifo_raddr3==pri_sch_ctrl_rdata3_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr4 = event_fifo_rd_ptr_rdata4_d1;
wire rd_wrap_around4 = (event_fifo_raddr4==pri_sch_ctrl_rdata4_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr5 = event_fifo_rd_ptr_rdata5_d1;
wire rd_wrap_around5 = (event_fifo_raddr5==pri_sch_ctrl_rdata5_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr6 = event_fifo_rd_ptr_rdata6_d1;
wire rd_wrap_around6 = (event_fifo_raddr6==pri_sch_ctrl_rdata6_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);
wire [QUEUE_NBITS-1:0] event_fifo_raddr7 = event_fifo_rd_ptr_rdata7_d1;
wire rd_wrap_around7 = (event_fifo_raddr7==pri_sch_ctrl_rdata7_d1[(QUEUE_NBITS<<1)-1:QUEUE_NBITS]);

always @(*)
	case(1'b1)
		~deq_en_pri_sch_d2|pri_event_fifo_nempty[7]: event_fifo_raddr = event_fifo_raddr7;
		pri_event_fifo_nempty[6]: event_fifo_raddr = event_fifo_raddr6;
		pri_event_fifo_nempty[5]: event_fifo_raddr = event_fifo_raddr5;
		pri_event_fifo_nempty[4]: event_fifo_raddr = event_fifo_raddr4;
		pri_event_fifo_nempty[3]: event_fifo_raddr = event_fifo_raddr3;
		pri_event_fifo_nempty[2]: event_fifo_raddr = event_fifo_raddr2;
		pri_event_fifo_nempty[1]: event_fifo_raddr = event_fifo_raddr1;
		default: event_fifo_raddr = event_fifo_raddr0;
	endcase

// d2: event_fifo_rd_ptr write required for deq
assign event_fifo_rd_ptr_wr0_p1 = pri_sch_ctrl_wr[0]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd0);
assign event_fifo_rd_ptr_wr1_p1 = pri_sch_ctrl_wr[1]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd1);
assign event_fifo_rd_ptr_wr2_p1 = pri_sch_ctrl_wr[2]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd2);
assign event_fifo_rd_ptr_wr3_p1 = pri_sch_ctrl_wr[3]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd3);
assign event_fifo_rd_ptr_wr4_p1 = pri_sch_ctrl_wr[4]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd4);
assign event_fifo_rd_ptr_wr5_p1 = pri_sch_ctrl_wr[5]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd5);
assign event_fifo_rd_ptr_wr6_p1 = pri_sch_ctrl_wr[6]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd6);
assign event_fifo_rd_ptr_wr7_p1 = pri_sch_ctrl_wr[7]|en_deq_from_event_fifo_d2&(deq_event_fifo_sel==3'd7);
assign event_fifo_rd_ptr_waddr0_p1 = pri_sch_ctrl_wr[0]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr1_p1 = pri_sch_ctrl_wr[1]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr2_p1 = pri_sch_ctrl_wr[2]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr3_p1 = pri_sch_ctrl_wr[3]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr4_p1 = pri_sch_ctrl_wr[4]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr5_p1 = pri_sch_ctrl_wr[5]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr6_p1 = pri_sch_ctrl_wr[6]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_waddr7_p1 = pri_sch_ctrl_wr[7]?pri_sch_ctrl_waddr:event_fifo_rd_ptr_raddr_d2;
assign event_fifo_rd_ptr_wdata0_p1 = pri_sch_ctrl_wr[0]?pri_sch_ctrl_wdata:rd_wrap_around0?pri_sch_ctrl_rdata0_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata0_d1+1;
assign event_fifo_rd_ptr_wdata1_p1 = pri_sch_ctrl_wr[1]?pri_sch_ctrl_wdata:rd_wrap_around1?pri_sch_ctrl_rdata1_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata1_d1+1;
assign event_fifo_rd_ptr_wdata2_p1 = pri_sch_ctrl_wr[2]?pri_sch_ctrl_wdata:rd_wrap_around2?pri_sch_ctrl_rdata2_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata2_d1+1;
assign event_fifo_rd_ptr_wdata3_p1 = pri_sch_ctrl_wr[3]?pri_sch_ctrl_wdata:rd_wrap_around3?pri_sch_ctrl_rdata3_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata3_d1+1;
assign event_fifo_rd_ptr_wdata4_p1 = pri_sch_ctrl_wr[4]?pri_sch_ctrl_wdata:rd_wrap_around4?pri_sch_ctrl_rdata4_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata4_d1+1;
assign event_fifo_rd_ptr_wdata5_p1 = pri_sch_ctrl_wr[5]?pri_sch_ctrl_wdata:rd_wrap_around5?pri_sch_ctrl_rdata5_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata5_d1+1;
assign event_fifo_rd_ptr_wdata6_p1 = pri_sch_ctrl_wr[6]?pri_sch_ctrl_wdata:rd_wrap_around6?pri_sch_ctrl_rdata6_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata6_d1+1;
assign event_fifo_rd_ptr_wdata7_p1 = pri_sch_ctrl_wr[7]?pri_sch_ctrl_wdata:rd_wrap_around7?pri_sch_ctrl_rdata7_d1[QUEUE_NBITS-1:0]:event_fifo_rd_ptr_rdata7_d1+1;

// d2: f1 counter read after event fifo read data available
assign event_fifo_f1_count_raddr = event_fifo_count_raddr_d2;

// wire [SCH_NBITS-1:0] f1_enq_addr = event_fifo_wr_ptr_raddr_d2;
wire [SCH_NBITS-1:0] f1_enq_addr_d1 = event_fifo_wr_ptr_raddr_d3;
wire [SCH_NBITS-1:0] f1_enq_addr_d2 = event_fifo_wr_ptr_raddr_d4;

// wire [SCH_NBITS-1:0] f1_deq_addr = event_fifo_rd_ptr_raddr_d2;
wire [SCH_NBITS-1:0] f1_deq_addr_d1 = event_fifo_rd_ptr_raddr_d3;
wire [SCH_NBITS-1:0] f1_deq_addr_d2 = event_fifo_rd_ptr_raddr_d4;

wire dis_f1_enq_wr1 = (f1_enq_addr_d2==f1_deq_addr_d1)&en_deq_from_event_fifo_d3;
wire dis_f1_enq_wr = dis_f1_enq_wr1|dis_f1_deq_wr1_d1;
wire dis_f1_deq_wr1 = (f1_deq_addr_d2==f1_enq_addr_d1)&en_enq_into_event_fifo_d3;
wire dis_f1_deq_wr = dis_f1_deq_wr1|dis_f1_enq_wr1_d1;

wire [SCH_NBITS-1:0] event_fifo_f1_count_raddr_d1 = event_fifo_count_waddr;
wire [SCH_NBITS-1:0] event_fifo_f1_count_raddr_d2 = event_fifo_count_waddr_d1;
wire [SCH_NBITS-1:0] event_fifo_f1_count_waddr_d1 = event_fifo_count_waddr_d3;
wire [SCH_NBITS-1:0] event_fifo_f1_count_waddr_d2 = event_fifo_count_waddr_d4;

wire [2:0] f1_same_addr_p1;
assign f1_same_addr_p1[0] = (event_fifo_f1_count_raddr_d1==event_fifo_f1_count_raddr_d2)&event_fifo_f1_count_wr_p1;
assign f1_same_addr_p1[1] = (event_fifo_f1_count_raddr_d1==event_fifo_f1_count_waddr)&event_fifo_f1_count_wr;
assign f1_same_addr_p1[2] = (event_fifo_f1_count_raddr_d1==event_fifo_f1_count_waddr_d1)&event_fifo_f1_count_wr_d1;
wire [QUEUE_NBITS-1:0] mevent_fifo_f1_count_rdata_d1 = f1_same_addr[0]?event_fifo_f1_count_wdata:
													f1_same_addr[1]?event_fifo_f1_count_wdata_d1:
													f1_same_addr[2]?event_fifo_f1_count_wdata_d2:
													event_fifo_f1_count_rdata_d1;

// d4: f1 counter update
wire [QUEUE_NBITS-1:0] event_fifo_rdata_qid = event_fifo_rdata_d1[QUEUE_NBITS-1:0]; 
wire f0_flag = event_fifo_rdata_d1[QUEUE_NBITS];
wire f1_flag = event_fifo_rdata_d1[QUEUE_NBITS+1];

assign event_fifo_f1_count_wr_p1 = init_wr|(f1_flag&enable_deq_d4&en_deq_from_event_fifo_d4&~dis_f1_deq_wr)|(re_enq_drop_f1_d4&re_enq_drop_d4&~dis_f1_enq_wr);

assign event_fifo_f1_count_waddr_p1 = init_wr?init_count[SCH_NBITS-1:0]:event_fifo_f1_count_raddr_d2;
assign event_fifo_f1_count_wdata_p1 = init_wr?0:en_deq_from_event_fifo_d4?(mevent_fifo_f1_count_rdata_d1-1):(mevent_fifo_f1_count_rdata_d1+1);

// d4: read tgna counter; needs to be aligned with deficit counter read
wire [SCH_NBITS-1:0] save_fifo_sch_id;
assign wdrr_sch_tqna_raddr = en_deq_from_event_fifo_d4?event_fifo_count_waddr_d1:save_fifo_sch_id;

// d6: tgna counter update for re-enqueue when dequeue is disabled because deficit counter<0
assign wdrr_sch_tqna_wr_p1 = init_wr|re_enq_drop_f1_d6&re_enq_drop_d6&(event_fifo_f1_count_rdata_d3>ave_count_d4);
assign wdrr_sch_tqna_waddr_p1 = init_wr?init_count[SCH_NBITS-1:0]:wdrr_sch_tqna_raddr_d2;
assign wdrr_sch_tqna_wdata_p1 = init_wr?0:wdrr_sch_tqna_rdata_d1+1;

// token bucket filling

wire [QUEUE_NBITS-1:0] lat_fifo_ctr4k;
wire [`PORT_ID_NBITS-1:0] lat_fifo_ctr4k_dst_port;

wire lat_fifo_rd5 = lat_fifo_empty3&~en_deq_from_event_fifo_d4&~lat_fifo_empty5;

// token bucket check
// d4: read token bucket for deq
wire [QUEUE_NBITS-1:0] save_fifo_sch_deq_ack_qid; 
wire [`PORT_ID_NBITS-1:0] save_fifo_sch_deq_dst_port; 

assign lat_fifo_rd3 = ~en_deq_from_event_fifo_d4&~lat_fifo_empty3;

assign token_bucket_raddr = en_deq_from_event_fifo_d4?event_fifo_rdata_qid:~lat_fifo_empty3?save_fifo_sch_deq_ack_qid:lat_fifo_ctr4k;
assign eir_tb_raddr = en_deq_from_event_fifo_d4?en_event_fifo_dst_port_d4:~lat_fifo_empty3?save_fifo_sch_deq_dst_port:lat_fifo_ctr4k_dst_port;


// d4: read shaper profile for deq
assign shaping_profile_cir_raddr = token_bucket_raddr;
assign shaping_profile_eir_raddr = token_bucket_raddr;

// d4: read deficit counter and WDRR quantum for deq

assign deficit_counter_raddr = token_bucket_raddr;
assign wdrr_quantum_raddr = token_bucket_raddr;

// d6: token bucket data available

wire [2:0] same_eir_tb_address_p1;
assign same_eir_tb_address_p1[0] = (eir_tb_raddr_d1==eir_tb_raddr_d2)&eir_tb_wr_p1;
assign same_eir_tb_address_p1[1] = (eir_tb_raddr_d1==eir_tb_waddr)&eir_tb_wr;
assign same_eir_tb_address_p1[2] = (eir_tb_raddr_d1==eir_tb_waddr_d1)&eir_tb_wr_d1;

wire [`EIR_NBITS+2-1:0] meir_tb_wdata_p1 = same_eir_tb_address_p1[1]?eir_tb_wdata:eir_tb_wdata_d1;

wire [`EIR_NBITS+2-1:0] meir_tb_rdata_d1 = same_eir_tb_address0?eir_tb_wdata:same_eir_tb_address21?meir_tb_wdata:eir_tb_rdata_d1;

wire [2:0] same_token_address_p1;
assign same_token_address_p1[0] = (deficit_counter_raddr_d1==deficit_counter_raddr_d2)&token_bucket_wr_p1;
assign same_token_address_p1[1] = (deficit_counter_raddr_d1==token_bucket_waddr)&token_bucket_wr;
assign same_token_address_p1[2] = (deficit_counter_raddr_d1==token_bucket_waddr_d1)&token_bucket_wr_d1;

wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] mtoken_bucket_rdata_p1 = same_token_address_p1[1]?token_bucket_wdata:token_bucket_wdata_d1;

wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] mtoken_bucket_rdata_d1 = same_token_address0?token_bucket_wdata:same_token_address21?mtoken_bucket_rdata:token_bucket_rdata_d1;

wire [`CIR_NBITS+2-1:0] cir = mtoken_bucket_rdata_d1[`CIR_NBITS+2-1:0];
wire [`EIR_NBITS+2-1:0] eir = mtoken_bucket_rdata_d1[`CIR_NBITS+2+`EIR_NBITS+2-1:`CIR_NBITS+2];

wire negative_cir = cir[`CIR_NBITS+2-1]; 
wire negative_eir = eir[`EIR_NBITS+2-1]; 
wire shaping_no_deq = negative_cir&negative_eir; // negative CIR and EIR tokens

wire positive_cir = ~negative_cir;
wire positive_eir = ~negative_eir;

// d6: deficit counter data available
wire wdrr_no_deq = ~deq_en_pri_sch_d6&deficit_counter_rdata_d1[`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1]; // negative counter value

// d6: re-enqueue when dropped
wire en_deq = ~(shaping_no_deq|wdrr_no_deq|~enable_deq_d6);
assign re_enq_drop_p1 = en_deq_from_event_fifo_d6&~en_deq;
assign re_enq_drop_qid_p1 = wdrr_quantum_raddr_d2;
assign re_enq_drop_sch_id_p1 = wdrr_sch_tqna_raddr_d2;
assign re_enq_drop_pri_sel_p1 = deq_event_fifo_sel_d4;
assign re_enq_drop_en_pri_sch_p1 = deq_en_pri_sch_d6;
assign re_enq_drop_f1_p1 = wdrr_no_deq;
assign re_enq_drop_disable_deq_p1 = ~enable_deq_d6;
assign re_enq_drop_dst_port_p1 = en_event_fifo_dst_port_d6;

assign semaphore_wr_p1 = init_wr|en_deq_from_event_fifo_d6;
assign semaphore_waddr_p1 = init_wr?init_count:re_enq_drop_qid_p1;
assign semaphore_wdata_p1 = init_wr?0:~en_deq;

// d6: deq_req to qm

assign deq_req_qm = en_deq_from_event_fifo_d6&en_deq;

// update deficit counter and token bucket after deq_req is acknowledged

// Token bucket update

assign token_bucket_wr_p1 = init_wr|lat_fifo_rd3_d2|lat_fifo_rd5_d2;
assign token_bucket_waddr_p1 = init_wr?init_count:deficit_counter_raddr_d2;

wire [`CIR_NBITS+2-1:0] new_cir = cir[`CIR_NBITS+2-1]?cir:(cir-save_fifo_deq_frame_length_d2);
wire [`EIR_NBITS+2-1:0] new_eir = (~eir[`CIR_NBITS+2-1]&cir[`CIR_NBITS+2-1])?(eir-save_fifo_deq_frame_length_d2):eir;

wire [`CIR_NBITS-1:0] cir_token = shaping_profile_cir_rdata_d1[`CIR_NBITS-1:0];
wire [`CIR_NBITS-1:0] cir_burst = shaping_profile_cir_rdata_d1[(`CIR_NBITS*2)-1:`CIR_NBITS];
wire [`EIR_NBITS-1:0] eir_token = shaping_profile_eir_rdata_d1[`EIR_NBITS-1:0];
wire [`EIR_NBITS-1:0] eir_burst = shaping_profile_eir_rdata_d1[(`EIR_NBITS*2)-1:`EIR_NBITS];

//wire [`CIR_NBITS+2-1:0] cir_minus_burst = {1'b0, cir[`CIR_NBITS+2-1-1:0]}-cir_burst;
//wire over_cir_burst = ~cir[`CIR_NBITS+2-1]&~cir_minus_burst[`CIR_NBITS+2-1];
wire over_cir_burst = ~cir[`CIR_NBITS+2-1]&(cir[`CIR_NBITS+2-1-1:0]>cir_burst);
wire [`CIR_NBITS+2-1:0] new_fill_cir = over_cir_burst?cir:cir + cir_token;

//wire [`EIR_NBITS+2-1:0] eir_minus_burst = {1'b0, eir[`EIR_NBITS+2-1-1:0]}-eir_burst;
//wire over_eir_burst = ~eir[`EIR_NBITS+2-1]&~eir_minus_burst[`EIR_NBITS+2-1];
wire over_eir_burst = ~eir[`EIR_NBITS+2-1]&(eir[`EIR_NBITS+2-1-1:0]>eir_burst);
wire eir_available = ~meir_tb_rdata_d1[`EIR_NBITS+1];

wire [`EIR_NBITS+2-1:0] new_fill_eir = over_cir_burst|over_eir_burst|~eir_available?eir:eir+eir_token;
assign token_bucket_wdata_p1 = init_wr?0:lat_fifo_rd3_d2?{new_eir, new_cir}:{new_fill_eir, new_fill_cir};

// EIR Token bucket

assign eir_tb_wr_p1 = init_wr|lat_fifo_rd5_d2;
assign eir_tb_waddr_p1 = init_wr?init_count:eir_tb_raddr_d2;
assign eir_tb_wdata_p1 = init_wr?0:over_cir_burst&~meir_tb_rdata_d1[`EIR_NBITS]?meir_tb_rdata_d1+cir_token:(~over_eir_burst&eir_available&~over_cir_burst)?meir_tb_rdata_d1-eir_token:meir_tb_rdata_d1;

// deficit counter update
wire save_fifo_f0_flag;

assign deficit_counter_wr_p1 = init_wr|lat_fifo_rd3_d2;
assign deficit_counter_waddr_p1 = init_wr?init_count:deficit_counter_raddr_d2;
wire [`TQNA_NBITS-1:0] cur_tqna = deficit_counter_rdata_d1[`TQNA_NBITS-1:0];
wire overflow = cur_tqna[`TQNA_NBITS-1]^wdrr_sch_tqna_rdata_d1[`TQNA_NBITS-1];
wire over_tqna = {overflow, wdrr_sch_tqna_rdata_d1[`TQNA_NBITS-1-1:0]}>{1'b0, cur_tqna[`TQNA_NBITS-1-1:0]};

wire [`TQNA_NBITS-1:0] nxt_tgna = save_fifo_f0_flag_d2?wdrr_sch_tqna_rdata_d1:
									over_tqna?cur_tqna+1:cur_tqna;

wire [`DEFICIT_COUNTER_NBITS-1:0] cur_deficit = deficit_counter_rdata_d1[`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:`TQNA_NBITS];
wire [`DEFICIT_COUNTER_NBITS-1:0] nxt_deficit = save_fifo_f0_flag_d2?wdrr_quantum_rdata_d1-save_fifo_deq_frame_length_d2:
												over_tqna?cur_deficit+wdrr_quantum_rdata_d1-save_fifo_deq_frame_length_d2:
															cur_deficit-save_fifo_deq_frame_length_d2;

assign deficit_counter_wdata_p1 = init_wr?0:{nxt_deficit, nxt_tgna};


always @(posedge clk) begin
		sch_deq_pkt_desc_d1 <= sch_deq_pkt_desc;
		sch_deq_ack_qid_d1 <= sch_deq_ack_qid;
		sch_deq_dst_port_d1 <= sch_deq_dst_port;
		sch_deq_frame_length_d1 <= sch_deq_frame_length;
		sch_deq_frame_length_d2 <= sch_deq_frame_length_d1;
		sch_deq_frame_length_d3 <= sch_deq_frame_length_d2;

		semaphore_wr_d1 <= semaphore_wr;
		semaphore_wr_d2 <= semaphore_wr_d1;

		semaphore_waddr_d1 <= semaphore_waddr;
		semaphore_waddr_d2 <= semaphore_waddr_d1;

		semaphore_wdata_d1 <= semaphore_wdata;
		semaphore_wdata_d2 <= semaphore_wdata_d1;

		fill_tb_dst_rdata_d1 <= fill_tb_dst_rdata;
		semaphore_rdata_d1 <= semaphore_rdata;
		queue_profile_rdata_d1 <= queue_profile_rdata;
		shaping_profile_cir_rdata_d1 <= shaping_profile_cir_rdata;
		shaping_profile_eir_rdata_d1 <= shaping_profile_eir_rdata;
		deficit_counter_rdata_d1 <= deficit_counter_rdata;
		token_bucket_rdata_d1 <= token_bucket_rdata;
		token_bucket_wdata_d1 <= token_bucket_wdata;
		token_bucket_wdata_d2 <= token_bucket_wdata_d1;
		eir_tb_rdata_d1 <= eir_tb_rdata;
		eir_tb_wdata_d1 <= eir_tb_wdata;
		eir_tb_wdata_d2 <= eir_tb_wdata_d1;
		event_fifo_rdata_d1 <= event_fifo_rdata;
		wdrr_sch_ctrl_rdata_d1 <= wdrr_sch_ctrl_rdata;
		wdrr_sch_tqna_rdata_d1 <= wdrr_sch_tqna_rdata;
		wdrr_quantum_rdata_d1 <= wdrr_quantum_rdata;
		pri_sch_ctrl_rdata0_d1 <= pri_sch_ctrl0_rdata;
		pri_sch_ctrl_rdata1_d1 <= pri_sch_ctrl1_rdata;
		pri_sch_ctrl_rdata2_d1 <= pri_sch_ctrl2_rdata;
		pri_sch_ctrl_rdata3_d1 <= pri_sch_ctrl3_rdata;
		pri_sch_ctrl_rdata4_d1 <= pri_sch_ctrl4_rdata;
		pri_sch_ctrl_rdata5_d1 <= pri_sch_ctrl5_rdata;
		pri_sch_ctrl_rdata6_d1 <= pri_sch_ctrl6_rdata;
		pri_sch_ctrl_rdata7_d1 <= pri_sch_ctrl7_rdata;
		event_fifo_rd_ptr_rdata0_d1 <= event_fifo_rd_ptr_rdata0;
		event_fifo_rd_ptr_rdata1_d1 <= event_fifo_rd_ptr_rdata1;
		event_fifo_rd_ptr_rdata2_d1 <= event_fifo_rd_ptr_rdata2;
		event_fifo_rd_ptr_rdata3_d1 <= event_fifo_rd_ptr_rdata3;
		event_fifo_rd_ptr_rdata4_d1 <= event_fifo_rd_ptr_rdata4;
		event_fifo_rd_ptr_rdata5_d1 <= event_fifo_rd_ptr_rdata5;
		event_fifo_rd_ptr_rdata6_d1 <= event_fifo_rd_ptr_rdata6;
		event_fifo_rd_ptr_rdata7_d1 <= event_fifo_rd_ptr_rdata7;
		event_fifo_wr_ptr_rdata0_d1 <= event_fifo_wr_ptr_rdata0;
		event_fifo_wr_ptr_rdata1_d1 <= event_fifo_wr_ptr_rdata1;
		event_fifo_wr_ptr_rdata2_d1 <= event_fifo_wr_ptr_rdata2;
		event_fifo_wr_ptr_rdata3_d1 <= event_fifo_wr_ptr_rdata3;
		event_fifo_wr_ptr_rdata4_d1 <= event_fifo_wr_ptr_rdata4;
		event_fifo_wr_ptr_rdata5_d1 <= event_fifo_wr_ptr_rdata5;
		event_fifo_wr_ptr_rdata6_d1 <= event_fifo_wr_ptr_rdata6;
		event_fifo_wr_ptr_rdata7_d1 <= event_fifo_wr_ptr_rdata7;

		event_fifo_wr_ptr_wdata0_d1 <= event_fifo_wr_ptr_wdata0;
		event_fifo_wr_ptr_wdata1_d1 <= event_fifo_wr_ptr_wdata1;
		event_fifo_wr_ptr_wdata2_d1 <= event_fifo_wr_ptr_wdata2;
		event_fifo_wr_ptr_wdata3_d1 <= event_fifo_wr_ptr_wdata3;
		event_fifo_wr_ptr_wdata4_d1 <= event_fifo_wr_ptr_wdata4;
		event_fifo_wr_ptr_wdata5_d1 <= event_fifo_wr_ptr_wdata5;
		event_fifo_wr_ptr_wdata6_d1 <= event_fifo_wr_ptr_wdata6;
		event_fifo_wr_ptr_wdata7_d1 <= event_fifo_wr_ptr_wdata7;

		event_fifo_wr_ptr_wdata0_d2 <= event_fifo_wr_ptr_wdata0_d1;
		event_fifo_wr_ptr_wdata1_d2 <= event_fifo_wr_ptr_wdata1_d1;
		event_fifo_wr_ptr_wdata2_d2 <= event_fifo_wr_ptr_wdata2_d1;
		event_fifo_wr_ptr_wdata3_d2 <= event_fifo_wr_ptr_wdata3_d1;
		event_fifo_wr_ptr_wdata4_d2 <= event_fifo_wr_ptr_wdata4_d1;
		event_fifo_wr_ptr_wdata5_d2 <= event_fifo_wr_ptr_wdata5_d1;
		event_fifo_wr_ptr_wdata6_d2 <= event_fifo_wr_ptr_wdata6_d1;
		event_fifo_wr_ptr_wdata7_d2 <= event_fifo_wr_ptr_wdata7_d1;

		event_fifo_wr_ptr_wr0_d1 <= event_fifo_wr_ptr_wr0;
		event_fifo_wr_ptr_wr1_d1 <= event_fifo_wr_ptr_wr1;
		event_fifo_wr_ptr_wr2_d1 <= event_fifo_wr_ptr_wr2;
		event_fifo_wr_ptr_wr3_d1 <= event_fifo_wr_ptr_wr3;
		event_fifo_wr_ptr_wr4_d1 <= event_fifo_wr_ptr_wr4;
		event_fifo_wr_ptr_wr5_d1 <= event_fifo_wr_ptr_wr5;
		event_fifo_wr_ptr_wr6_d1 <= event_fifo_wr_ptr_wr6;
		event_fifo_wr_ptr_wr7_d1 <= event_fifo_wr_ptr_wr7;

		event_fifo_wr_ptr_wr0_d2 <= event_fifo_wr_ptr_wr0_d1;
		event_fifo_wr_ptr_wr1_d2 <= event_fifo_wr_ptr_wr1_d1;
		event_fifo_wr_ptr_wr2_d2 <= event_fifo_wr_ptr_wr2_d1;
		event_fifo_wr_ptr_wr3_d2 <= event_fifo_wr_ptr_wr3_d1;
		event_fifo_wr_ptr_wr4_d2 <= event_fifo_wr_ptr_wr4_d1;
		event_fifo_wr_ptr_wr5_d2 <= event_fifo_wr_ptr_wr5_d1;
		event_fifo_wr_ptr_wr6_d2 <= event_fifo_wr_ptr_wr6_d1;
		event_fifo_wr_ptr_wr7_d2 <= event_fifo_wr_ptr_wr7_d1;

		event_fifo_count_rdata0_d1 <= event_fifo_count_rdata0;
		event_fifo_count_rdata1_d1 <= event_fifo_count_rdata1;
		event_fifo_count_rdata2_d1 <= event_fifo_count_rdata2;
		event_fifo_count_rdata3_d1 <= event_fifo_count_rdata3;
		event_fifo_count_rdata4_d1 <= event_fifo_count_rdata4;
		event_fifo_count_rdata5_d1 <= event_fifo_count_rdata5;
		event_fifo_count_rdata6_d1 <= event_fifo_count_rdata6;
		event_fifo_count_rdata7_d1 <= event_fifo_count_rdata7;
		event_fifo_count_rdata_d1 <= event_fifo_count_rdata;

		event_fifo_count_wdata0_d1 <= event_fifo_count_wdata0;
		event_fifo_count_wdata1_d1 <= event_fifo_count_wdata1;
		event_fifo_count_wdata2_d1 <= event_fifo_count_wdata2;
		event_fifo_count_wdata3_d1 <= event_fifo_count_wdata3;
		event_fifo_count_wdata4_d1 <= event_fifo_count_wdata4;
		event_fifo_count_wdata5_d1 <= event_fifo_count_wdata5;
		event_fifo_count_wdata6_d1 <= event_fifo_count_wdata6;
		event_fifo_count_wdata7_d1 <= event_fifo_count_wdata7;

		event_fifo_count_wdata0_d2 <= event_fifo_count_wdata0_d1;
		event_fifo_count_wdata1_d2 <= event_fifo_count_wdata1_d1;
		event_fifo_count_wdata2_d2 <= event_fifo_count_wdata2_d1;
		event_fifo_count_wdata3_d2 <= event_fifo_count_wdata3_d1;
		event_fifo_count_wdata4_d2 <= event_fifo_count_wdata4_d1;
		event_fifo_count_wdata5_d2 <= event_fifo_count_wdata5_d1;
		event_fifo_count_wdata6_d2 <= event_fifo_count_wdata6_d1;
		event_fifo_count_wdata7_d2 <= event_fifo_count_wdata7_d1;

		event_fifo_count_wr0_d1 <= event_fifo_count_wr0;
		event_fifo_count_wr1_d1 <= event_fifo_count_wr1;
		event_fifo_count_wr2_d1 <= event_fifo_count_wr2;
		event_fifo_count_wr3_d1 <= event_fifo_count_wr3;
		event_fifo_count_wr4_d1 <= event_fifo_count_wr4;
		event_fifo_count_wr5_d1 <= event_fifo_count_wr5;
		event_fifo_count_wr6_d1 <= event_fifo_count_wr6;
		event_fifo_count_wr7_d1 <= event_fifo_count_wr7;

		event_fifo_count_wr0_d2 <= event_fifo_count_wr0_d1;
		event_fifo_count_wr1_d2 <= event_fifo_count_wr1_d1;
		event_fifo_count_wr2_d2 <= event_fifo_count_wr2_d1;
		event_fifo_count_wr3_d2 <= event_fifo_count_wr3_d1;
		event_fifo_count_wr4_d2 <= event_fifo_count_wr4_d1;
		event_fifo_count_wr5_d2 <= event_fifo_count_wr5_d1;
		event_fifo_count_wr6_d2 <= event_fifo_count_wr6_d1;
		event_fifo_count_wr7_d2 <= event_fifo_count_wr7_d1;

		event_fifo_count_wr_d1 <= event_fifo_count_wr;
		event_fifo_count_wr_d2 <= event_fifo_count_wr_d1;
		event_fifo_count_wdata_d1 <= event_fifo_count_wdata;
		event_fifo_count_wdata_d2 <= event_fifo_count_wdata_d1;
		event_fifo_f1_count_rdata_d1 <= event_fifo_f1_count_rdata;
		event_fifo_f1_count_rdata_d2 <= mevent_fifo_f1_count_rdata_d1;
		event_fifo_f1_count_rdata_d3 <= event_fifo_f1_count_rdata_d2;
		event_fifo_f1_count_wdata_d1 <= event_fifo_f1_count_wdata;
		event_fifo_f1_count_wdata_d2 <= event_fifo_f1_count_wdata_d1;
		event_fifo_f1_count_wr_d1 <= event_fifo_f1_count_wr;
		event_fifo_f1_count_wr_d2 <= event_fifo_f1_count_wr_d1;

		event_fifo_wr_ptr_raddr_d1 <= event_fifo_wr_ptr_raddr;
		event_fifo_wr_ptr_raddr_d2 <= event_fifo_wr_ptr_raddr_d1;
		event_fifo_wr_ptr_raddr_d3 <= event_fifo_wr_ptr_raddr_d2;
		event_fifo_wr_ptr_raddr_d4 <= event_fifo_wr_ptr_raddr_d3;
		event_fifo_rd_ptr_raddr_d1 <= event_fifo_rd_ptr_raddr;
		event_fifo_rd_ptr_raddr_d2 <= event_fifo_rd_ptr_raddr_d1;
		event_fifo_rd_ptr_raddr_d3 <= event_fifo_rd_ptr_raddr_d2;
		event_fifo_rd_ptr_raddr_d4 <= event_fifo_rd_ptr_raddr_d3;
		event_fifo_count_raddr_d1 <= event_fifo_count_raddr;
		event_fifo_count_raddr_d2 <= event_fifo_count_raddr_d1;
		deficit_counter_raddr_d1 <= deficit_counter_raddr;
		deficit_counter_raddr_d2 <= deficit_counter_raddr_d1;
		deficit_counter_raddr_d3 <= deficit_counter_raddr_d2;
		token_bucket_waddr_d1 <= token_bucket_waddr;
		token_bucket_waddr_d2 <= token_bucket_waddr_d1;
		token_bucket_wr_d1 <= token_bucket_wr;
		token_bucket_wr_d2 <= token_bucket_wr_d1;
		eir_tb_raddr_d1 <= eir_tb_raddr;
		eir_tb_raddr_d2 <= eir_tb_raddr_d1;
		eir_tb_raddr_d3 <= eir_tb_raddr_d2;
		eir_tb_waddr_d1 <= eir_tb_waddr;
		eir_tb_waddr_d2 <= eir_tb_waddr_d1;
		eir_tb_wr_d1 <= eir_tb_wr;
		eir_tb_wr_d2 <= eir_tb_wr_d1;
		wdrr_quantum_raddr_d1 <= wdrr_quantum_raddr;
		wdrr_quantum_raddr_d2 <= wdrr_quantum_raddr_d1;
		wdrr_quantum_raddr_d3 <= wdrr_quantum_raddr_d2;
		wdrr_sch_tqna_raddr_d1 <= wdrr_sch_tqna_raddr;
		wdrr_sch_tqna_raddr_d2 <= wdrr_sch_tqna_raddr_d1;

		event_fifo_count_waddr_d1 <= event_fifo_count_waddr;
		event_fifo_count_waddr_d2 <= event_fifo_count_waddr_d1;
		event_fifo_count_waddr_d3 <= event_fifo_count_waddr_d2;
		event_fifo_count_waddr_d4 <= event_fifo_count_waddr_d3;
		event_fifo_rd_ptr_waddr_d1 <= event_fifo_rd_ptr_waddr;
		event_fifo_rd_ptr_waddr_d2 <= event_fifo_rd_ptr_waddr_d1;
		event_fifo_rd_ptr_waddr_d3 <= event_fifo_rd_ptr_waddr_d2;

		dis_deq_wr1_d1 <= dis_deq_wr1&en_deq_from_event_fifo_d2;
		dis_enq_wr1_d1 <= dis_enq_wr1&en_enq_into_event_fifo_d2;

		dis_f1_deq_wr1_d1 <= dis_f1_deq_wr1&en_deq_from_event_fifo_d4;
		dis_f1_enq_wr1_d1 <= dis_f1_enq_wr1&en_enq_into_event_fifo_d4;

		enq_en_pri_sch_d1 <= re_enq_drop?re_enq_drop_en_pri_sch:~lat_fifo_empty22?lat_fifo_deq_en_pri_sch:buf_fifo_enq_en_pri_sch;
		enq_en_pri_sch_d2 <= enq_en_pri_sch_d1;
		enq_pri_sel_d1 <= re_enq_drop?re_enq_drop_pri_sel:~lat_fifo_empty22?lat_fifo_deq_pri_sel:buf_fifo_enq_pri_sel;
		enq_pri_sel_d2 <= enq_pri_sel_d1;
		deq_event_fifo_sel_d1 <= deq_event_fifo_sel;
		deq_event_fifo_sel_d2 <= deq_event_fifo_sel_d1;
		deq_event_fifo_sel_d3 <= deq_event_fifo_sel_d2;
		deq_event_fifo_sel_d4 <= deq_event_fifo_sel_d3;

		deq_en_pri_sch_d1 <= deq_en_pri_sch;
		deq_en_pri_sch_d2 <= deq_en_pri_sch_d1;
		deq_en_pri_sch_d3 <= deq_en_pri_sch_d2;
		deq_en_pri_sch_d4 <= deq_en_pri_sch_d3;
		deq_en_pri_sch_d5 <= deq_en_pri_sch_d4;
		deq_en_pri_sch_d6 <= deq_en_pri_sch_d5;

		re_enq_drop_disable_deq_d1 <= re_enq_drop_disable_deq;
		re_enq_drop_disable_deq_d2 <= re_enq_drop_disable_deq_d1;
		re_enq_drop_f1_d1 <= re_enq_drop_f1;
		re_enq_drop_f1_d2 <= re_enq_drop_f1_d1;
		re_enq_drop_f1_d3 <= re_enq_drop_f1_d2;
		re_enq_drop_f1_d4 <= re_enq_drop_f1_d3;
		re_enq_drop_f1_d5 <= re_enq_drop_f1_d4;
		re_enq_drop_f1_d6 <= re_enq_drop_f1_d5;
		re_enq_drop_d1 <= re_enq_drop;
		re_enq_drop_d2 <= re_enq_drop_d1;
		re_enq_drop_d3 <= re_enq_drop_d2;
		re_enq_drop_d4 <= re_enq_drop_d3;
		re_enq_drop_d5 <= re_enq_drop_d4;
		re_enq_drop_d6 <= re_enq_drop_d5;
		f0_flag_d1 <= f0_flag;
		f0_flag_d2 <= f0_flag_d1;
		f0_flag_d3 <= f0_flag_d2;
		save_fifo_f0_flag_d1 <= save_fifo_f0_flag;
		save_fifo_f0_flag_d2 <= save_fifo_f0_flag_d1;
		save_fifo_deq_frame_length_d1 <= save_fifo_deq_frame_length;
		save_fifo_deq_frame_length_d2 <= save_fifo_deq_frame_length_d1;

		en_enq_into_event_fifo_qid_d1 <= en_enq_into_event_fifo_qid;
		en_enq_into_event_fifo_f0_d1 <= en_enq_into_event_fifo_f0;
		en_enq_into_event_fifo_f1_d1 <= en_enq_into_event_fifo_f1;

		en_enq_into_event_fifo_qid_d2 <= en_enq_into_event_fifo_qid_d1;
		en_enq_into_event_fifo_f0_d2 <= en_enq_into_event_fifo_f0_d1;
		en_enq_into_event_fifo_f1_d2 <= en_enq_into_event_fifo_f1_d1;

		en_event_fifo_dst_port_d1 <= en_event_fifo_dst_port;
		en_event_fifo_dst_port_d2 <= en_event_fifo_dst_port_d1;
		en_event_fifo_dst_port_d3 <= en_event_fifo_dst_port_d2;
		en_event_fifo_dst_port_d4 <= en_event_fifo_dst_port_d3;
		en_event_fifo_dst_port_d5 <= en_event_fifo_dst_port_d4;
		en_event_fifo_dst_port_d6 <= en_event_fifo_dst_port_d5;

		enable_deq_d1 <= next_qm_enq_dst_available_d1[deq_dst_port_id]&
						(deq_emptyp2?fifo_next_qm_available_emptyp2:fifo_next_qm_available);
		enable_deq_d2 <= enable_deq_d1;
		enable_deq_d3 <= enable_deq_d2;
		enable_deq_d4 <= enable_deq_d3;
		enable_deq_d5 <= enable_deq_d4;
		enable_deq_d6 <= enable_deq_d5;

		ave_count_d1 <= ave_count[QUEUE_NBITS-1:0];
		ave_count_d2 <= ave_count_d1;
		ave_count_d3 <= ave_count_d2;
		ave_count_d4 <= ave_count_d3;

		lat_fifo_rd2_d1 <= lat_fifo_rd2;
		lat_fifo_rd2_d2 <= lat_fifo_rd2_d1;

		lat_fifo_rd22_d1 <= lat_fifo_rd22;
		lat_fifo_rd22_d2 <= lat_fifo_rd22_d1;

		lat_fifo_enq_dst_port_d1 <= lat_fifo_enq_dst_port;
		lat_fifo_enq_qid_d1 <= lat_fifo_enq_qid;
		lat_fifo_enq_en_pri_sch_d1 <= lat_fifo_enq_en_pri_sch;
		lat_fifo_enq_pri_sel_d1 <= lat_fifo_enq_pri_sel;
		lat_fifo_enq_sch_id_d1 <= lat_fifo_enq_sch_id;

		lat_fifo_enq_dst_port_d2 <= lat_fifo_enq_dst_port_d1;
		lat_fifo_enq_qid_d2 <= lat_fifo_enq_qid_d1;
		lat_fifo_enq_en_pri_sch_d2 <= lat_fifo_enq_en_pri_sch_d1;
		lat_fifo_enq_pri_sel_d2 <= lat_fifo_enq_pri_sel_d1;
		lat_fifo_enq_sch_id_d2 <= lat_fifo_enq_sch_id_d1;

		msemaphore_wdata <= msemaphore_wdata_p1;
		same_s_addr0 <= same_s_addr_p1[0];
		same_s_addr21 <= |same_s_addr_p1[2:1];

		mevent_fifo_count_rdata <= mevent_fifo_count_rdata_p1;
		asame_addr0 <= asame_addr_p1[0];
		asame_addr21 <= asame_addr21_p1;
		same_addr <= same_addr_p1;
		same_wr_ptr_addr <= same_wr_ptr_addr_p1;
		f1_same_addr <= f1_same_addr_p1;
		same_eir_tb_address0 <= same_eir_tb_address_p1[0];
		same_eir_tb_address21 <= |same_eir_tb_address_p1[2:1];
		same_token_address0 <= same_token_address_p1[0];
		same_token_address21 <= |same_token_address_p1[2:1];

		meir_tb_wdata <= meir_tb_wdata_p1;
		mtoken_bucket_rdata <= mtoken_bucket_rdata_p1;

		event_fifo_nempty0 <= event_fifo_nempty0_p1;
		event_fifo_nempty1 <= event_fifo_nempty1_p1;
		event_fifo_nempty2 <= event_fifo_nempty2_p1;
		event_fifo_nempty3 <= event_fifo_nempty3_p1;
		event_fifo_nempty4 <= event_fifo_nempty4_p1;
		event_fifo_nempty5 <= event_fifo_nempty5_p1;
		event_fifo_nempty6 <= event_fifo_nempty6_p1;
		event_fifo_nempty7 <= event_fifo_nempty7_p1;

		re_enq_drop <= re_enq_drop_p1;
		re_enq_drop_qid <= re_enq_drop_qid_p1;
		re_enq_drop_sch_id <= re_enq_drop_sch_id_p1;
		re_enq_drop_pri_sel <= re_enq_drop_pri_sel_p1;
		re_enq_drop_en_pri_sch <= re_enq_drop_en_pri_sch_p1;
		re_enq_drop_f1 <= re_enq_drop_f1_p1;
		re_enq_drop_disable_deq <= re_enq_drop_disable_deq_p1;
		re_enq_drop_dst_port <= re_enq_drop_dst_port_p1;

		deq_req_qm_d1 <= deq_req_qm;
		positive_cir_d1 <= positive_cir;
		positive_eir_d1 <= positive_eir;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		init_wr <= 0;
		init_count <= 0;
		init_wr1 <= 0;
		init_count1 <= 0;
		ctr4 <= 0;
		ctr4k <= 0;
		sch_deq_ack_d1 <= 0;
		next_qm_enq_dst_available_d1 <= 0;

		fill_tb_dst_ack_d1 <= 0;
		queue_profile_ack_d1 <= 0;

		en_enq_into_event_fifo_d1 <= 0;
		en_enq_into_event_fifo_d2 <= 0;
		en_enq_into_event_fifo_d3 <= 0;
		en_enq_into_event_fifo_d4 <= 0;

		en_deq_from_event_fifo_d1 <= 0;
		en_deq_from_event_fifo_d2 <= 0;
		en_deq_from_event_fifo_d3 <= 0;
		en_deq_from_event_fifo_d4 <= 0;
		en_deq_from_event_fifo_d5 <= 0;
		en_deq_from_event_fifo_d6 <= 0;

		lat_fifo_rd3_d1 <= 0;
		lat_fifo_rd3_d2 <= 0;
		lat_fifo_rd3_d3 <= 0;
		lat_fifo_rd5_d1 <= 0;
		lat_fifo_rd5_d2 <= 0;
		lat_fifo_rd5_d3 <= 0;
	end else begin
		init_wr <= (nxt_init_st==INIT_COUNT);
		init_count <= init_wr?(init_count+1):init_count;
		init_wr1 <= (nxt_init_st==INIT_COUNT);
		init_count1 <= init_wr1?(init_count1+1):init_count1;
		ctr4 <= fill_token_bucket?0:ctr4+1;
		ctr4k <= ~fill_token_bucket?ctr4k:ctr4k+1;
		sch_deq_ack_d1 <= sch_deq_ack;
		next_qm_enq_dst_available_d1 <= next_qm_enq_dst_available;

		fill_tb_dst_ack_d1 <= fill_tb_dst_ack;
		queue_profile_ack_d1 <= queue_profile_ack;

		en_enq_into_event_fifo_d1 <= en_enq_into_event_fifo;
		en_enq_into_event_fifo_d2 <= en_enq_into_event_fifo_d1;
		en_enq_into_event_fifo_d3 <= en_enq_into_event_fifo_d2;
		en_enq_into_event_fifo_d4 <= en_enq_into_event_fifo_d3;

		en_deq_from_event_fifo_d1 <= en_deq_from_event_fifo;
		en_deq_from_event_fifo_d2 <= en_deq_from_event_fifo_d1;
		en_deq_from_event_fifo_d3 <= en_deq_from_event_fifo_d2;
		en_deq_from_event_fifo_d4 <= en_deq_from_event_fifo_d3;
		en_deq_from_event_fifo_d5 <= en_deq_from_event_fifo_d4;
		en_deq_from_event_fifo_d6 <= en_deq_from_event_fifo_d5;

		lat_fifo_rd3_d1 <= lat_fifo_rd3;
		lat_fifo_rd3_d2 <= lat_fifo_rd3_d1;
		lat_fifo_rd3_d3 <= lat_fifo_rd3_d2;
		lat_fifo_rd5_d1 <= lat_fifo_rd5;
		lat_fifo_rd5_d2 <= lat_fifo_rd5_d1;
		lat_fifo_rd5_d3 <= lat_fifo_rd5_d2;
	end


/***************************** NEXT STATE ASSIGNMENT **************************/
	always @(*)  begin
		nxt_init_st = init_st;
		case (init_st)		
			INIT_IDLE: nxt_init_st = INIT_COUNT;
			INIT_COUNT: if (&init_count) nxt_init_st = INIT_DONE;
			INIT_DONE: nxt_init_st = INIT_DONE;
			default: nxt_init_st = INIT_IDLE;
		endcase
	end

/***************************** STATE MACHINE *******************************/

	always @(`CLK_RST) 
		if (`ACTIVE_RESET)
			init_st <= INIT_IDLE;
		else 
			init_st <= nxt_init_st;

/***************************** FIFO ***************************************/
sfifo2f_fo #(`PORT_ID_NBITS+QUEUE_NBITS, 3) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({qm_enq_ack_dst_port, qm_enq_ack_qid}),				
		.rd(queue_profile_ack_d1),
		.wr(queue_profile_rd_p1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_qm_enq_ack_dst_port, lat_fifo_qm_enq_ack_qid})       
	);

wire enq_en_pri_sch = queue_profile_rdata_d1[0];
wire [2:0] enq_pri_sel = ~enq_en_pri_sch?3'd0:queue_profile_rdata_d1[3:1];
wire [SCH_NBITS-1:0] enq_sch_id = queue_profile_rdata_d1[SCH_NBITS-1+4:0+4];

sfifo2f_fo #(QUEUE_NBITS+1+3+SCH_NBITS+`PORT_ID_NBITS, 2) u_sfifo2f_fo_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_qm_enq_ack_qid, enq_en_pri_sch, enq_pri_sel, enq_sch_id, lat_fifo_qm_enq_ack_dst_port}),				
		.rd(lat_fifo_rd2),
		.wr(queue_profile_ack_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty2),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_qid, lat_fifo_enq_en_pri_sch, lat_fifo_enq_pri_sel, lat_fifo_enq_sch_id, lat_fifo_enq_dst_port})       
	);

sfifo2f_fo #(QUEUE_NBITS+1+3+SCH_NBITS+`PORT_ID_NBITS, 2) u_sfifo2f_fo_24(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_enq_qid_d2, lat_fifo_enq_en_pri_sch_d2, lat_fifo_enq_pri_sel_d2, lat_fifo_enq_sch_id_d2, lat_fifo_enq_dst_port_d2}),				
		.rd(buf_fifo_rd),
		.wr(buf_fifo_wr),

		.ncount(),
		.count(),
		.full(),
		.empty(buf_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({buf_fifo_enq_qid, buf_fifo_enq_en_pri_sch, buf_fifo_enq_pri_sel, buf_fifo_enq_sch_id, buf_fifo_enq_dst_port})       
	);

assign buf_fifo_f0 = 1;

sfifo2f_fo #(QUEUE_NBITS+1+3+SCH_NBITS+`PORT_ID_NBITS, 2) u_sfifo2f_fo_22(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({acc_fifo_qid, acc_fifo_en_pri_sch, acc_fifo_pri_sel, acc_fifo_sch_id, acc_fifo_dst_port}),				
		.rd(lat_fifo_rd22),
		.wr(next_qm_avail_req1_p1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty22),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_deq_qid, lat_fifo_deq_en_pri_sch, lat_fifo_deq_pri_sel, lat_fifo_deq_sch_id, lat_fifo_deq_dst_port})       
	);

assign lat_fifo_deq_f0 = 0;

sfifo2f_fo #(`PACKET_LENGTH_NBITS+QUEUE_NBITS+`PORT_ID_NBITS, 2) u_sfifo2f_fo_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({deq_frame_length, sch_deq_ack_qid_d1, sch_deq_dst_port_d1}),				
		.rd(lat_fifo_rd3),
		.wr(sch_deq_ack_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty3),
		.fullm1(),
		.emptyp2(), 
		.dout({save_fifo_deq_frame_length, save_fifo_sch_deq_ack_qid, save_fifo_sch_deq_dst_port})       
	);

sfifo2f_fo #(1+SCH_NBITS, 6) u_sfifo2f_fo_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({f0_flag_d3, event_fifo_rd_ptr_waddr_d3}),				
		.rd(lat_fifo_rd3),
		.wr(deq_req_qm_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({save_fifo_f0_flag, save_fifo_sch_id})       
	);


sfifo2f_fo #(QUEUE_NBITS, 6) u_sfifo2f_fo_50(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(ctr4k),				
		.rd(lat_fifo_rd5),
		.wr(fill_token_bucket),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_ctr4k)       
	);


sfifo2f_fo #(`PORT_ID_NBITS, 6) u_sfifo2f_fo_51(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(fill_tb_dst_rdata_d1),				
		.rd(lat_fifo_rd5),
		.wr(fill_tb_dst_ack_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty5),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_ctr4k_dst_port)       
	);



wire sch_fifo_empty_p, lat_fifo_full7;
wire lat_fifo_wr7_en = ~sch_fifo_empty_p&~lat_fifo_full7;
wire lat_fifo_wr7 = lat_fifo_wr7_en&(deq_emptyp2_p|~next_qm_avail_req1_p1);
assign lat_fifo_wr7_req_en = ~deq_emptyp2_p&lat_fifo_wr7_en;

tm_sch_event_fifo #(1+`PORT_ID_NBITS+1+SCH_NBITS, SCH_NBITS) u_tm_sch_event_fifo_0(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.push(push),  		
	.push_data(push_data),  

	.pop(lat_fifo_wr7), 

	// outputs

	.pop_data({deq_emptyp2_p, deq_dst_port_id_p, deq_en_pri_sch_p, deq_sch_id_p}), 
	.sch_fifo_empty(sch_fifo_empty_p), 
	.fifo_count()
);

sfifo2f_fo #(1+`PORT_ID_NBITS+1+SCH_NBITS, 4) u_sfifo2f_fo_10(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({deq_emptyp2_p, deq_dst_port_id_p, deq_en_pri_sch_p, deq_sch_id_p}),				
		.rd(en_deq_from_event_fifo),
		.wr(lat_fifo_wr7),

		.ncount(),
		.count(),
		.full(lat_fifo_full7),
		.empty(lat_fifo_empty7),
		.fullm1(),
		.emptyp2(),
		.dout({deq_emptyp2, deq_dst_port_id, deq_en_pri_sch, deq_sch_id})       
	);

wire next_qm_avail_for_emptyp2;

sfifo2f_fo #(1, 3) sfifo2f_fo_30(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.din(next_qm_avail_req1_p1),  
	.rd(next_qm_avail_ack), 
	.wr(next_qm_avail_req_p1),  		

	// outputs

	.ncount(),
	.count(),
	.full(),
	.empty(),
	.fullm1(),
	.emptyp2(),
	.dout(next_qm_avail_for_emptyp2) 
);

tm_sch_event_fifo #(1, SCH_NBITS) u_tm_sch_event_fifo_1(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.push(next_qm_avail_ack&next_qm_avail_for_emptyp2),  		
	.push_data(next_qm_available),  

	.pop(en_deq_from_event_fifo&deq_emptyp2), 

	// outputs

	.pop_data(fifo_next_qm_available_emptyp2), 
	.sch_fifo_empty(lat_fifo_empty8), 
	.fifo_count()
);

sfifo2f_fo #(1, 4) u_sfifo2f_fo_92(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(next_qm_available),				
		.rd(en_deq_from_event_fifo&~deq_emptyp2),
		.wr(next_qm_avail_ack&~next_qm_avail_for_emptyp2),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty9),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_next_qm_available)       
	);

sfifo2f_fo #(SCH_NBITS, 4) u_sfifo2f_fo_91(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({re_enq_drop_sch_id}),				
		.rd(sch_deq_ack_d1),
		.wr(deq_req_qm_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({stored_fifo_sch_id})       
	);

//
sfifo2f_fo #(QUEUE_NBITS+4+SCH_NBITS+`PORT_ID_NBITS, 4) u_sfifo2f_fo_9(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({re_enq_drop_qid, re_enq_drop_en_pri_sch, re_enq_drop_pri_sel, re_enq_drop_sch_id, re_enq_drop_dst_port}),				
		.rd(sch_deq_depth_ack),
		.wr(deq_req_qm_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({acc_fifo_qid, acc_fifo_en_pri_sch, acc_fifo_pri_sel, acc_fifo_sch_id, acc_fifo_dst_port})       
	);


/***************************** DIAGNOSTICS **********************************/

	// synopsys translate_off

	// synopsys translate_on

endmodule

