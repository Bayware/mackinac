//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm(


input clk, 
input `RESET_SIG, 


input         pio_start,
input         pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

output clk_div,

output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata,

input [`NUM_OF_PORTS-1:0] bm_tm_bp,

input asa_tm_poll_req,		
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid,				
input [`PORT_ID_NBITS-1:0] asa_tm_poll_src_port,				

input asa_tm_enq_req,					
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_qid,				
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_port_queue_id,
input enq_pkt_desc_type asa_tm_enq_desc,				


output tm_asa_poll_ack,
output tm_asa_poll_drop,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id,
output [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id,
output [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id,
output [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id,

output tm_bm_enq_req,
output enq_pkt_desc_type tm_bm_enq_pkt_desc

);


/***************************** LOCAL VARIABLES *******************************/

wire wr_pkt_desc_ack;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_qid;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_conn_id;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_conn_group_id;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_port_queue_id;
sch_pkt_desc_type wr_pkt_desc_out;

// -------------------- level 0 ---------------------------------

wire [7:0] pri_sch_ctrl_wr0;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl_waddr0;
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl_wdata0;

wire pri_sch_ctrl00_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl00_raddr;
wire pri_sch_ctrl01_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl01_raddr;
wire pri_sch_ctrl02_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl02_raddr;
wire pri_sch_ctrl03_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl03_raddr;
wire pri_sch_ctrl04_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl04_raddr;
wire pri_sch_ctrl05_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl05_raddr;
wire pri_sch_ctrl06_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl06_raddr;
wire pri_sch_ctrl07_rd; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl07_raddr;

wire pri_sch_ctrl00_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl00_rdata;
wire pri_sch_ctrl01_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl01_rdata;
wire pri_sch_ctrl02_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl02_rdata;
wire pri_sch_ctrl03_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl03_rdata;
wire pri_sch_ctrl04_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl04_rdata;
wire pri_sch_ctrl05_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl05_rdata;
wire pri_sch_ctrl06_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl06_rdata;
wire pri_sch_ctrl07_ack; 
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl07_rdata;

wire queue_profile_rd0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_profile_raddr0;

wire wdrr_quantum_rd0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] wdrr_quantum_raddr0;

wire shaping_profile_cir_rd0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_raddr0;
wire shaping_profile_cir_wr0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_waddr0;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata0;

wire shaping_profile_eir_rd0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_raddr0;
wire shaping_profile_eir_wr0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_waddr0;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata0;

wire wdrr_sch_ctrl_rd0; 
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] wdrr_sch_ctrl_raddr0;

wire fill_tb_dst_rd0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_raddr0;
wire fill_tb_dst_wr0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_waddr0;
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_wdata0;

wire queue_profile_ack0; 
wire [`FIRST_LVL_QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata0;

wire wdrr_quantum_ack0; 
wire [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata0;

wire shaping_profile_cir_ack0; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata0;

wire shaping_profile_eir_ack0; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata0;

wire wdrr_sch_ctrl_ack0; 
wire [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata0;

wire fill_tb_dst_ack0; 
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata0;

wire deficit_counter_wr0;            
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_waddr0;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_raddr0;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata0;

wire token_bucket_wr0;           
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] token_bucket_waddr0;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] token_bucket_raddr0;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata0;

wire eir_tb_wr0;           
wire [`PORT_ID_NBITS-1:0] eir_tb_waddr0;
wire [`EIR_NBITS+2-1:0] eir_tb_wdata0;
wire [`PORT_ID_NBITS-1:0] eir_tb_raddr0;
wire [`EIR_NBITS+2-1:0] eir_tb_rdata0;

wire event_fifo_wr0;         
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_waddr0;
wire [`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_wdata0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_raddr0;
wire [`FIRST_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_rdata0;

wire event_fifo_rd_ptr_wr00;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr00;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata00;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr00;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata00;

wire event_fifo_rd_ptr_wr10;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr10;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata10;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr10;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata10;

wire event_fifo_rd_ptr_wr20;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr20;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata20;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr20;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata20;

wire event_fifo_rd_ptr_wr30;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr30;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata30;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr30;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata30;

wire event_fifo_rd_ptr_wr40;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr40;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata40;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr40;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata40;

wire event_fifo_rd_ptr_wr50;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr50;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata50;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr50;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata50;

wire event_fifo_rd_ptr_wr60;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr60;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata60;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr60;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata60;

wire event_fifo_rd_ptr_wr70;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr70;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata70;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr70;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata70;

wire event_fifo_wr_ptr_wr00;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr00;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata00;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr00;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata00;

wire event_fifo_wr_ptr_wr10;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr10;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata10;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr10;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata10;

wire event_fifo_wr_ptr_wr20;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr20;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata20;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr20;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata20;

wire event_fifo_wr_ptr_wr30;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr30;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata30;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr30;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata30;

wire event_fifo_wr_ptr_wr40;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr40;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata40;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr40;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata40;

wire event_fifo_wr_ptr_wr50;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr50;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata50;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr50;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata50;

wire event_fifo_wr_ptr_wr60;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr60;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata60;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr60;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata60;

wire event_fifo_wr_ptr_wr70;         
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr70;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata70;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr70;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata70;

wire event_fifo_count_wr00;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr00;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata00;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr00;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata00;

wire event_fifo_count_wr10;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr10;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata10;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr10;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata10;

wire event_fifo_count_wr20;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr20;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata20;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr20;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata20;

wire event_fifo_count_wr30;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr30;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata30;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr30;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata30;

wire event_fifo_count_wr40;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr40;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata40;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr40;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata40;

wire event_fifo_count_wr50;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr50;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata50;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr50;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata50;

wire event_fifo_count_wr60;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr60;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata60;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr60;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata60;

wire event_fifo_count_wr70;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr70;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata70;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr70;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata70;

wire event_fifo_count_wr0;           
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr0;
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_wdata0;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr0;
wire [(`FIRST_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_rdata0;

wire event_fifo_f1_count_wr0;            
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_waddr0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_wdata0;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_raddr0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_rdata0;

wire wdrr_sch_tqna_wr0;          
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_waddr0;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata0;
wire [`FIRST_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_raddr0;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata0;

wire semaphore_wr0;			
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] semaphore_waddr0;
wire semaphore_wdata0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] semaphore_raddr0;
wire semaphore_rdata0;

wire sch_deq_req0; 
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] sch_deq_qid0;

wire active_enq_ack0;          
wire active_enq_to_empty0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] active_enq_ack_qid0;
wire [`PORT_ID_NBITS-1:0] active_enq_ack_dst_port0;

wire esrh_enq_ack0;          
wire esrh_enq_to_empty0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] esrh_enq_ack_qid0;
wire [`PORT_ID_NBITS-1:0] esrh_enq_ack_dst_port0;

wire sch_deq_depth_ack0;
wire sch_deq_depth_from_emptyp20;

wire sch_deq_ack0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] sch_deq_ack_qid0;
sch_pkt_desc_type sch_deq_pkt_desc0;

wire next_qm_avail_ack0;    
wire next_qm_available0;    

wire [`NUM_OF_PORTS-1:0] next_qm_enq_src_available0;
wire [`NUM_OF_PORTS-1:0] next_qm_enq_dst_available0;

wire next_qm_avail_req0;        
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] next_qm_avail_req_qid0;

// -------------------- level 1 ---------------------------------

wire head_wr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] head_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] head_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] head_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] head_rdata1;

wire tail_wr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tail_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tail_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tail_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tail_rdata1;

wire depth_wr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_rdata1;

wire depth1_wr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth1_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth1_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth1_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth1_rdata1;

wire ll_wr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ll_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ll_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ll_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ll_rdata1;

wire pkt_desc_wr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_waddr1;
sch_pkt_desc_type pkt_desc_wdata1;
sch_pkt_desc_type pkt_desc_rdata1;

wire [7:0] pri_sch_ctrl_wr1;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl_waddr1;
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl_wdata1;

wire pri_sch_ctrl10_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl10_raddr;
wire pri_sch_ctrl11_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl11_raddr;
wire pri_sch_ctrl12_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl12_raddr;
wire pri_sch_ctrl13_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl13_raddr;
wire pri_sch_ctrl14_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl14_raddr;
wire pri_sch_ctrl15_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl15_raddr;
wire pri_sch_ctrl16_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl16_raddr;
wire pri_sch_ctrl17_rd; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl17_raddr;

wire pri_sch_ctrl10_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl10_rdata;
wire pri_sch_ctrl11_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl11_rdata;
wire pri_sch_ctrl12_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl12_rdata;
wire pri_sch_ctrl13_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl13_rdata;
wire pri_sch_ctrl14_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl14_rdata;
wire pri_sch_ctrl15_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl15_rdata;
wire pri_sch_ctrl16_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl16_rdata;
wire pri_sch_ctrl17_ack; 
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl17_rdata;

wire queue_profile_rd1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] queue_profile_raddr1;

wire wdrr_quantum_rd1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] wdrr_quantum_raddr1;

wire shaping_profile_cir_rd1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_raddr1;
wire shaping_profile_cir_wr1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_waddr1;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata1;

wire shaping_profile_eir_rd1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_raddr1;
wire shaping_profile_eir_wr1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_waddr1;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata1;

wire wdrr_sch_ctrl_rd1; 
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] wdrr_sch_ctrl_raddr1;

wire fill_tb_dst_rd1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_raddr1;
wire fill_tb_dst_wr1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_waddr1;
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_wdata1;

wire queue_profile_ack1; 
wire [`SECOND_LVL_QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata1;

wire wdrr_quantum_ack1; 
wire [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata1;

wire shaping_profile_cir_ack1; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata1;

wire shaping_profile_eir_ack1; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata1;

wire wdrr_sch_ctrl_ack1; 
wire [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata1;

wire fill_tb_dst_ack1; 
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata1;


wire deficit_counter_wr1;            
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_waddr1;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_raddr1;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata1;

wire token_bucket_wr1;           
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] token_bucket_waddr1;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] token_bucket_raddr1;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata1;

wire eir_tb_wr1;           
wire [`PORT_ID_NBITS-1:0] eir_tb_waddr1;
wire [`EIR_NBITS+2-1:0] eir_tb_wdata1;
wire [`PORT_ID_NBITS-1:0] eir_tb_raddr1;
wire [`EIR_NBITS+2-1:0] eir_tb_rdata1;

wire event_fifo_wr1;         
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_rdata1;

wire event_fifo_rd_ptr_wr01;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr01;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata01;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr01;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata01;

wire event_fifo_rd_ptr_wr11;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr11;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata11;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr11;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata11;

wire event_fifo_rd_ptr_wr21;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr21;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata21;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr21;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata21;

wire event_fifo_rd_ptr_wr31;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr31;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata31;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr31;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata31;

wire event_fifo_rd_ptr_wr41;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr41;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata41;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr41;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata41;

wire event_fifo_rd_ptr_wr51;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr51;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata51;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr51;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata51;

wire event_fifo_rd_ptr_wr61;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr61;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata61;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr61;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata61;

wire event_fifo_rd_ptr_wr71;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr71;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata71;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr71;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata71;

wire event_fifo_wr_ptr_wr01;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr01;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata01;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr01;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata01;

wire event_fifo_wr_ptr_wr11;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr11;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata11;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr11;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata11;

wire event_fifo_wr_ptr_wr21;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr21;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata21;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr21;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata21;

wire event_fifo_wr_ptr_wr31;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr31;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata31;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr31;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata31;

wire event_fifo_wr_ptr_wr41;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr41;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata41;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr41;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata41;

wire event_fifo_wr_ptr_wr51;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr51;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata51;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr51;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata51;

wire event_fifo_wr_ptr_wr61;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr61;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata61;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr61;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata61;

wire event_fifo_wr_ptr_wr71;         
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr71;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata71;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr71;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata71;

wire event_fifo_count_wr01;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr01;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata01;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr01;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata01;

wire event_fifo_count_wr11;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr11;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata11;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr11;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata11;

wire event_fifo_count_wr21;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr21;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata21;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr21;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata21;

wire event_fifo_count_wr31;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr31;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata31;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr31;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata31;

wire event_fifo_count_wr41;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr41;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata41;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr41;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata41;

wire event_fifo_count_wr51;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr51;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata51;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr51;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata51;

wire event_fifo_count_wr61;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr61;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata61;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr61;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata61;

wire event_fifo_count_wr71;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr71;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata71;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr71;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata71;

wire event_fifo_count_wr1;           
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr1;
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_wdata1;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr1;
wire [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_rdata1;

wire event_fifo_f1_count_wr1;            
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_waddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_wdata1;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_raddr1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_rdata1;

wire wdrr_sch_tqna_wr1;          
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_waddr1;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata1;
wire [`SECOND_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_raddr1;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata1;

wire semaphore_wr1;			
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] semaphore_waddr1;
wire semaphore_wdata1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] semaphore_raddr1;
wire semaphore_rdata1;

wire tm_enq_req1;                   
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_enq_qid1;             
sch_pkt_desc_type tm_enq_pkt_desc1;             

wire sch_deq_req1; 
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] sch_deq_qid1;

wire active_enq_ack1;          
wire active_enq_to_empty1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] active_enq_ack_qid1;
wire [`PORT_ID_NBITS-1:0] active_enq_ack_dst_port1;

wire esrh_enq_ack1;          
wire esrh_enq_to_empty1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] esrh_enq_ack_qid1;
wire [`PORT_ID_NBITS-1:0] esrh_enq_ack_dst_port1;

wire sch_deq_depth_ack1;
wire sch_deq_depth_from_emptyp21;

wire sch_deq_ack1;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] sch_deq_ack_qid1;
sch_pkt_desc_type sch_deq_pkt_desc1;

wire next_qm_avail_ack1;    
wire next_qm_available1;    

wire [`NUM_OF_PORTS-1:0] next_qm_enq_src_available1;
wire [`NUM_OF_PORTS-1:0] next_qm_enq_dst_available1;

wire next_qm_avail_req1;        
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] next_qm_avail_req_qid1;

// -------------------- level 2 ---------------------------------

wire head_wr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] head_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] head_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] head_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] head_rdata2;

wire tail_wr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tail_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tail_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tail_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tail_rdata2;

wire depth_wr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_rdata2;

wire depth1_wr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth1_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth1_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth1_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth1_rdata2;

wire ll_wr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ll_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ll_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ll_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ll_rdata2;

wire pkt_desc_wr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_waddr2;
sch_pkt_desc_type pkt_desc_wdata2;
sch_pkt_desc_type pkt_desc_rdata2;

wire [7:0] pri_sch_ctrl_wr2;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl_waddr2;
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl_wdata2;

wire pri_sch_ctrl20_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl20_raddr;
wire pri_sch_ctrl21_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl21_raddr;
wire pri_sch_ctrl22_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl22_raddr;
wire pri_sch_ctrl23_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl23_raddr;
wire pri_sch_ctrl24_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl24_raddr;
wire pri_sch_ctrl25_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl25_raddr;
wire pri_sch_ctrl26_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl26_raddr;
wire pri_sch_ctrl27_rd; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl27_raddr;

wire pri_sch_ctrl20_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl20_rdata;
wire pri_sch_ctrl21_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl21_rdata;
wire pri_sch_ctrl22_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl22_rdata;
wire pri_sch_ctrl23_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl23_rdata;
wire pri_sch_ctrl24_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl24_rdata;
wire pri_sch_ctrl25_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl25_rdata;
wire pri_sch_ctrl26_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl26_rdata;
wire pri_sch_ctrl27_ack; 
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl27_rdata;

wire queue_profile_rd2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] queue_profile_raddr2;

wire wdrr_quantum_rd2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] wdrr_quantum_raddr2;

wire shaping_profile_cir_rd2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_raddr2;
wire shaping_profile_cir_wr2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_waddr2;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata2;

wire shaping_profile_eir_rd2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_raddr2;
wire shaping_profile_eir_wr2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_waddr2;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata2;

wire wdrr_sch_ctrl_rd2; 
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] wdrr_sch_ctrl_raddr2;

wire fill_tb_dst_rd2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_raddr2;
wire fill_tb_dst_wr2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_waddr2;
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_wdata2;

wire queue_profile_ack2; 
wire [`THIRD_LVL_QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata2;

wire wdrr_quantum_ack2; 
wire [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata2;

wire shaping_profile_cir_ack2; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata2;

wire shaping_profile_eir_ack2; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata2;

wire wdrr_sch_ctrl_ack2; 
wire [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata2;

wire fill_tb_dst_ack2; 
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata2;

wire deficit_counter_wr2;            
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_waddr2;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_raddr2;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata2;

wire token_bucket_wr2;           
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] token_bucket_waddr2;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] token_bucket_raddr2;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata2;

wire eir_tb_wr2;           
wire [`PORT_ID_NBITS-1:0] eir_tb_waddr2;
wire [`EIR_NBITS+2-1:0] eir_tb_wdata2;
wire [`PORT_ID_NBITS-1:0] eir_tb_raddr2;
wire [`EIR_NBITS+2-1:0] eir_tb_rdata2;

wire event_fifo_wr2;         
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_rdata2;

wire event_fifo_rd_ptr_wr02;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr02;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata02;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr02;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata02;

wire event_fifo_rd_ptr_wr12;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr12;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata12;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr12;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata12;

wire event_fifo_rd_ptr_wr22;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr22;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata22;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr22;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata22;

wire event_fifo_rd_ptr_wr32;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr32;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata32;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr32;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata32;

wire event_fifo_rd_ptr_wr42;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr42;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata42;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr42;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata42;

wire event_fifo_rd_ptr_wr52;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr52;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata52;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr52;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata52;

wire event_fifo_rd_ptr_wr62;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr62;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata62;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr62;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata62;

wire event_fifo_rd_ptr_wr72;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr72;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata72;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr72;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata72;

wire event_fifo_wr_ptr_wr02;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr02;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata02;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr02;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata02;

wire event_fifo_wr_ptr_wr12;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr12;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata12;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr12;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata12;

wire event_fifo_wr_ptr_wr22;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr22;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata22;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr22;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata22;

wire event_fifo_wr_ptr_wr32;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr32;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata32;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr32;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata32;

wire event_fifo_wr_ptr_wr42;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr42;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata42;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr42;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata42;

wire event_fifo_wr_ptr_wr52;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr52;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata52;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr52;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata52;

wire event_fifo_wr_ptr_wr62;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr62;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata62;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr62;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata62;

wire event_fifo_wr_ptr_wr72;         
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr72;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata72;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr72;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata72;

wire event_fifo_count_wr02;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr02;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata02;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr02;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata02;

wire event_fifo_count_wr12;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr12;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata12;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr12;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata12;

wire event_fifo_count_wr22;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr22;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata22;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr22;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata22;

wire event_fifo_count_wr32;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr32;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata32;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr32;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata32;

wire event_fifo_count_wr42;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr42;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata42;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr42;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata42;

wire event_fifo_count_wr52;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr52;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata52;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr52;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata52;

wire event_fifo_count_wr62;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr62;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata62;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr62;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata62;

wire event_fifo_count_wr72;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr72;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata72;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr72;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata72;

wire event_fifo_count_wr2;           
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr2;
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_wdata2;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr2;
wire [(`THIRD_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_rdata2;

wire event_fifo_f1_count_wr2;            
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_waddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_wdata2;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_raddr2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_rdata2;

wire wdrr_sch_tqna_wr2;          
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_waddr2;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata2;
wire [`THIRD_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_raddr2;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata2;

wire semaphore_wr2;			
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] semaphore_waddr2;
wire semaphore_wdata2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] semaphore_raddr2;
wire semaphore_rdata2;

wire tm_enq_req2;                   
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_enq_qid2;             
sch_pkt_desc_type tm_enq_pkt_desc2;             

wire sch_deq_req2; 
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] sch_deq_qid2;

wire active_enq_ack2;          
wire active_enq_to_empty2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] active_enq_ack_qid2;
wire [`PORT_ID_NBITS-1:0] active_enq_ack_dst_port2;

wire sch_deq_depth_ack2;
wire sch_deq_depth_from_emptyp22;

wire sch_deq_ack2;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] sch_deq_ack_qid2;
sch_pkt_desc_type sch_deq_pkt_desc2;

wire next_qm_avail_ack2;    
wire next_qm_available2;    

wire [`NUM_OF_PORTS-1:0] next_qm_enq_src_available2;
wire [`NUM_OF_PORTS-1:0] next_qm_enq_dst_available2;

wire next_qm_avail_req2;        
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] next_qm_avail_req_qid2;


// -------------------- level 3 ---------------------------------

wire head_wr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] head_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] head_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] head_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] head_rdata3;

wire tail_wr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tail_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tail_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tail_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tail_rdata3;

wire depth_wr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_rdata3;

wire depth1_wr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth1_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth1_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth1_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth1_rdata3;

wire ll_wr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ll_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ll_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ll_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ll_rdata3;

wire pkt_desc_wr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_waddr3;
sch_pkt_desc_type pkt_desc_wdata3;
sch_pkt_desc_type pkt_desc_rdata3;

wire [7:0] pri_sch_ctrl_wr3;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl_waddr3;
wire [(`FOURTH_LVL_QUEUE_ID_NBITS<<1)-1:0] pri_sch_ctrl_wdata3;

wire pri_sch_ctrl30_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl30_raddr;
wire pri_sch_ctrl31_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl31_raddr;
wire pri_sch_ctrl32_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl32_raddr;
wire pri_sch_ctrl33_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl33_raddr;
wire pri_sch_ctrl34_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl34_raddr;
wire pri_sch_ctrl35_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl35_raddr;
wire pri_sch_ctrl36_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl36_raddr;
wire pri_sch_ctrl37_rd; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] pri_sch_ctrl37_raddr;

wire pri_sch_ctrl30_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl30_rdata;
wire pri_sch_ctrl31_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl31_rdata;
wire pri_sch_ctrl32_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl32_rdata;
wire pri_sch_ctrl33_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl33_rdata;
wire pri_sch_ctrl34_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl34_rdata;
wire pri_sch_ctrl35_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl35_rdata;
wire pri_sch_ctrl36_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl36_rdata;
wire pri_sch_ctrl37_ack; 
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] pri_sch_ctrl37_rdata;

wire queue_profile_rd3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] queue_profile_raddr3;

wire wdrr_quantum_rd3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] wdrr_quantum_raddr3;

wire shaping_profile_cir_rd3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_raddr3;
wire shaping_profile_cir_wr3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_cir_waddr3;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata3;

wire shaping_profile_eir_rd3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_raddr3;
wire shaping_profile_eir_wr3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] shaping_profile_eir_waddr3;
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata3;

wire wdrr_sch_ctrl_rd3; 
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] wdrr_sch_ctrl_raddr3;

wire fill_tb_dst_rd3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_raddr3;
wire fill_tb_dst_wr3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] fill_tb_dst_waddr3;
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_wdata3;

wire queue_profile_ack3; 
wire [`FOURTH_LVL_QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata3;

wire wdrr_quantum_ack3; 
wire [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata3;

wire shaping_profile_cir_ack3; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata3;

wire shaping_profile_eir_ack3; 
wire [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata3;

wire wdrr_sch_ctrl_ack3; 
wire [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata3;

wire fill_tb_dst_ack3; 
wire [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata3;


wire deficit_counter_wr3;            
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_waddr3;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_raddr3;
wire [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata3;

wire token_bucket_wr3;           
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] token_bucket_waddr3;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] token_bucket_raddr3;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata3;

wire eir_tb_wr3;           
wire [`PORT_ID_NBITS-1:0] eir_tb_waddr3;
wire [`EIR_NBITS+2-1:0] eir_tb_wdata3;
wire [`PORT_ID_NBITS-1:0] eir_tb_raddr3;
wire [`EIR_NBITS+2-1:0] eir_tb_rdata3;

wire event_fifo_wr3;         
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_rdata3;

wire event_fifo_rd_ptr_wr03;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr03;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata03;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr03;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata03;

wire event_fifo_rd_ptr_wr13;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr13;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata13;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr13;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata13;

wire event_fifo_rd_ptr_wr23;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr23;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata23;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr23;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata23;

wire event_fifo_rd_ptr_wr33;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr33;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata33;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr33;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata33;

wire event_fifo_rd_ptr_wr43;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr43;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata43;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr43;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata43;

wire event_fifo_rd_ptr_wr53;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr53;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata53;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr53;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata53;

wire event_fifo_rd_ptr_wr63;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr63;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata63;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr63;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata63;

wire event_fifo_rd_ptr_wr73;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr73;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata73;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr73;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata73;

wire event_fifo_wr_ptr_wr03;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr03;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata03;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr03;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata03;

wire event_fifo_wr_ptr_wr13;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr13;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata13;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr13;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata13;

wire event_fifo_wr_ptr_wr23;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr23;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata23;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr23;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata23;

wire event_fifo_wr_ptr_wr33;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr33;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata33;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr33;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata33;

wire event_fifo_wr_ptr_wr43;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr43;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata43;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr43;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata43;

wire event_fifo_wr_ptr_wr53;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr53;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata53;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr53;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata53;

wire event_fifo_wr_ptr_wr63;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr63;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata63;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr63;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata63;

wire event_fifo_wr_ptr_wr73;         
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr73;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata73;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr73;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata73;

wire event_fifo_count_wr03;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr03;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata03;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr03;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata03;

wire event_fifo_count_wr13;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr13;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata13;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr13;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata13;

wire event_fifo_count_wr23;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr23;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata23;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr23;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata23;

wire event_fifo_count_wr33;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr33;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata33;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr33;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata33;

wire event_fifo_count_wr43;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr43;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata43;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr43;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata43;

wire event_fifo_count_wr53;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr53;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata53;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr53;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata53;

wire event_fifo_count_wr63;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr63;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata63;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr63;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata63;

wire event_fifo_count_wr73;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr73;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata73;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr73;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata73;

wire event_fifo_count_wr3;           
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr3;
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] event_fifo_count_wdata3;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr3;
wire [((`FOURTH_LVL_QUEUE_ID_NBITS<<1))-1:0] event_fifo_count_rdata3;

wire event_fifo_f1_count_wr3;            
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_waddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_wdata3;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_raddr3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_rdata3;

wire wdrr_sch_tqna_wr3;          
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_waddr3;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata3;
wire [`FOURTH_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_raddr3;
wire [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata3;

wire semaphore_wr3;			
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] semaphore_waddr3;
wire semaphore_wdata3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] semaphore_raddr3;
wire semaphore_rdata3;

wire tm_enq_req3;                   
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_enq_qid3;             
sch_pkt_desc_type tm_enq_pkt_desc3;             

wire sch_deq_req3; 
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] sch_deq_qid3;


wire active_enq_ack3;          
wire active_enq_to_empty3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] active_enq_ack_qid3;
wire [`PORT_ID_NBITS-1:0] active_enq_ack_dst_port3;

wire sch_deq_depth_ack3;
wire sch_deq_depth_from_emptyp23;

wire sch_deq_ack3;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] sch_deq_ack_qid3;
sch_pkt_desc_type sch_deq_pkt_desc3;

wire next_qm_enq_req3;
sch_pkt_desc_type next_qm_enq_pkt_desc3;

wire next_qm_avail_req3;        

// -----------------------------------------------------
wire         mem_bs;
wire         reg_wr;
wire         reg_rd;
wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_din;

wire reg_ms_queue_association;
wire [3:0] reg_ms_queue_profile;
wire [3:0] reg_ms_wdrr_quantum;
wire [3:0] reg_ms_shaping_profile_cir;
wire [3:0] reg_ms_shaping_profile_eir;
wire [3:0] reg_ms_wdrr_sch_ctrl;
wire [3:0] reg_ms_fill_tb_dst;
wire [7:0] reg_ms_pri_sch_ctrl[3:0];

wire queue_association_mem_ack;
wire [3:0] queue_profile_mem_ack;
wire [3:0] wdrr_quantum_mem_ack;
wire [3:0] shaping_profile_cir_mem_ack;
wire [3:0] shaping_profile_eir_mem_ack;
wire [3:0] wdrr_sch_ctrl_mem_ack;
wire [3:0] fill_tb_dst_mem_ack;
wire [7:0] pri_sch_ctrl_mem_ack[3:0];

wire [`PIO_RANGE] queue_association_mem_rdata;
wire [`PIO_RANGE] queue_profile_mem_rdata[3:0];
wire [`PIO_RANGE] wdrr_quantum_mem_rdata[3:0];
wire [`PIO_RANGE] shaping_profile_cir_mem_rdata[3:0];
wire [`PIO_RANGE] shaping_profile_eir_mem_rdata[3:0];
wire [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata[3:0];
wire [`PIO_RANGE] fill_tb_dst_mem_rdata[3:0];
wire [`PIO_RANGE] pri_sch_ctrl_mem_rdata[3:0][7:0];

/***************************** NON-REGISTERED OUTPUTS ************************/



/***************************** PROGRAM BODY **********************************/ 

//`define DUPLICATE_RESET

`ifdef DUPLICATE_RESET

`define NUMBER_OF_RESETS 5
wire [`NUMBER_OF_RESETS-1:0] `RESET_SIG_DUP;
flop #(`NUM_OF_RESETS) u_flop(.clk(clk), .din({(`NUMBER_OF_RESETS){`RESET_SIG}}), .dout(`RESET_SIG_DUP));

`endif

wire [3:0] alpha = 0;

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`TM_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`TM_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(`TM_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`TM_BLOCK_ADDR)
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
    .reg_bs()

);

tm_pio u_tm_pio(

    .clk(), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .queue_association_mem_ack(queue_association_mem_ack),
    .queue_profile_mem_ack(queue_profile_mem_ack),
    .wdrr_quantum_mem_ack(wdrr_quantum_mem_ack),
    .shaping_profile_cir_mem_ack(shaping_profile_cir_mem_ack),
    .shaping_profile_eir_mem_ack(shaping_profile_eir_mem_ack),
    .wdrr_sch_ctrl_mem_ack(wdrr_sch_ctrl_mem_ack),
    .fill_tb_dst_mem_ack(fill_tb_dst_mem_ack),
    .pri_sch_ctrl_mem_ack(pri_sch_ctrl_mem_ack),

    .queue_association_mem_rdata(queue_association_mem_rdata),
    .queue_profile_mem_rdata(queue_profile_mem_rdata),
    .wdrr_quantum_mem_rdata(wdrr_quantum_mem_rdata),
    .shaping_profile_cir_mem_rdata(shaping_profile_cir_mem_rdata),
    .shaping_profile_eir_mem_rdata(shaping_profile_eir_mem_rdata),
    .wdrr_sch_ctrl_mem_rdata(wdrr_sch_ctrl_mem_rdata),
    .fill_tb_dst_mem_rdata(fill_tb_dst_mem_rdata),
    .pri_sch_ctrl_mem_rdata(pri_sch_ctrl_mem_rdata),

    .reg_ms_queue_association(reg_ms_queue_association),
    .reg_ms_queue_profile(reg_ms_queue_profile),
    .reg_ms_wdrr_quantum(reg_ms_wdrr_quantum),
    .reg_ms_shaping_profile_cir(reg_ms_shaping_profile_cir),
    .reg_ms_shaping_profile_eir(reg_ms_shaping_profile_eir),
    .reg_ms_wdrr_sch_ctrl(reg_ms_wdrr_sch_ctrl),
    .reg_ms_fill_tb_dst(reg_ms_fill_tb_dst),
    .reg_ms_pri_sch_ctrl(reg_ms_pri_sch_ctrl),

    .pio_ack(pio_ack),
    .pio_rvalid(pio_rvalid),
    .pio_rdata(pio_rdata)

);

// -------------------- level 0 ------------------------------------
tm_qm0 u_tm_qm0(
    .clk(clk),

`ifdef DUPLICATE_RESET
    .`RESET_SIG(`RESET_SIG_DUP[0]),
`else
    .`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .alpha(alpha),

    .reg_ms(reg_ms_queue_association),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .asa_tm_poll_req(asa_tm_poll_req),     
    .asa_tm_poll_qid(asa_tm_poll_qid),    
    .asa_tm_poll_src_port(asa_tm_poll_src_port),    

    .asa_tm_enq_req(wr_pkt_desc_ack),   
    .asa_tm_enq_qid(wr_pkt_desc_ack_qid),   
    .asa_tm_enq_conn_id(wr_pkt_desc_ack_conn_id),   
    .asa_tm_enq_conn_group_id(wr_pkt_desc_ack_conn_group_id),   
    .asa_tm_enq_port_queue_id(wr_pkt_desc_ack_port_queue_id),   
    .asa_tm_enq_pkt_desc(wr_pkt_desc_out),  

    .sch_deq_req(sch_deq_req0),    
    .sch_deq_qid(sch_deq_qid0),

    .next_qm_enq_src_available0(next_qm_enq_src_available0), 
    .next_qm_enq_src_available1(next_qm_enq_src_available1), 
    .next_qm_enq_src_available2(next_qm_enq_src_available2), 
	 
    // outputs

    .mem_ack(queue_association_mem_ack),
    .mem_rdata(queue_association_mem_rdata),

    .tm_asa_poll_ack(tm_asa_poll_ack),
    .tm_asa_poll_drop(tm_asa_poll_drop),
    .tm_asa_poll_conn_id(tm_asa_poll_conn_id),
    .tm_asa_poll_conn_group_id(tm_asa_poll_conn_group_id),
    .tm_asa_poll_port_queue_id(tm_asa_poll_port_queue_id),
    .tm_asa_poll_port_id(tm_asa_poll_port_id),

    .active_enq_ack(active_enq_ack0),   
    .active_enq_ack_qid(active_enq_ack_qid0),    
    .active_enq_ack_dst_port(active_enq_ack_dst_port0),    
    .active_enq_to_empty(active_enq_to_empty0),    

    .sch_deq_depth_ack(sch_deq_depth_ack0),
    .sch_deq_depth_from_emptyp2(sch_deq_depth_from_emptyp20),   

    .sch_deq_ack(sch_deq_ack0),
    .sch_deq_ack_qid(sch_deq_ack_qid0),
    .sch_deq_pkt_desc(sch_deq_pkt_desc0)

);

tm_sch #(`FIRST_LVL_QUEUE_ID_NBITS, `FIRST_LVL_SCH_ID_NBITS, `FIRST_LVL_QUEUE_PROFILE_NBITS) u_tm_sch_0(
    .clk(clk),

`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[0]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .qm_enq_ack(active_enq_ack0),   
    .qm_enq_ack_qid(active_enq_ack_qid0), 
    .qm_enq_ack_dst_port(active_enq_ack_dst_port0),    
    .qm_enq_to_empty(active_enq_to_empty0), 

    .sch_deq_depth_ack(sch_deq_depth_ack0),
    .sch_deq_depth_from_emptyp2(sch_deq_depth_from_emptyp20),  

    .sch_deq_ack(sch_deq_ack0),
    .sch_deq_ack_qid(sch_deq_ack_qid0),
    .sch_deq_pkt_desc(sch_deq_pkt_desc0),

    .next_qm_avail_ack(next_qm_avail_ack0),             
    .next_qm_available(next_qm_available0), 
            
    .next_qm_enq_dst_available(next_qm_enq_dst_available0),  

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr0),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr0),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata0),

    .pri_sch_ctrl0_ack(pri_sch_ctrl00_ack),  // fixed one clock delay 
    .pri_sch_ctrl0_rdata(pri_sch_ctrl00_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl01_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl01_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl02_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl02_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl03_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl03_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl04_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl04_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl05_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl05_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl06_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl06_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl07_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl07_rdata),

    .queue_profile_ack(queue_profile_ack0), 
    .queue_profile_rdata(queue_profile_rdata0),

    .wdrr_quantum_ack(wdrr_quantum_ack0),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata0),

    .shaping_profile_cir_ack(shaping_profile_cir_ack0),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata0),

    .shaping_profile_eir_ack(shaping_profile_eir_ack0),
    .shaping_profile_eir_rdata(shaping_profile_eir_rdata0),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack0),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata0),

    .fill_tb_dst_ack(fill_tb_dst_ack0),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata0),


    // outputs

    .pri_sch_ctrl0_rd(pri_sch_ctrl00_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl00_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl01_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl01_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl02_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl02_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl03_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl03_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl04_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl04_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl05_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl05_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl06_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl06_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl07_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl07_raddr),

    .queue_profile_rd(queue_profile_rd0), 
    .queue_profile_raddr(queue_profile_raddr0),

    .wdrr_quantum_rd(wdrr_quantum_rd0),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr0),

    .shaping_profile_cir_rd(shaping_profile_cir_rd0),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr0),
    .shaping_profile_cir_wr(shaping_profile_cir_wr0),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr0),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata0),

    .shaping_profile_eir_rd(shaping_profile_eir_rd0),
    .shaping_profile_eir_raddr(shaping_profile_eir_raddr0),
    .shaping_profile_eir_wr(shaping_profile_eir_wr0),
    .shaping_profile_eir_waddr(shaping_profile_eir_waddr0),
    .shaping_profile_eir_wdata(shaping_profile_eir_wdata0),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd0),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr0),
       
    .fill_tb_dst_rd(fill_tb_dst_rd0),  
    .fill_tb_dst_raddr(fill_tb_dst_raddr0),
    .fill_tb_dst_wr(fill_tb_dst_wr0),
    .fill_tb_dst_waddr(fill_tb_dst_waddr0),
    .fill_tb_dst_wdata(fill_tb_dst_wdata0),
       

    .deficit_counter_wr(deficit_counter_wr0),
    .deficit_counter_waddr(deficit_counter_waddr0),
    .deficit_counter_wdata(deficit_counter_wdata0),
    .deficit_counter_raddr(deficit_counter_raddr0),
    .deficit_counter_rdata(deficit_counter_rdata0),

    .token_bucket_wr(token_bucket_wr0),
    .token_bucket_waddr(token_bucket_waddr0),
    .token_bucket_wdata(token_bucket_wdata0),
    .token_bucket_raddr(token_bucket_raddr0),
    .token_bucket_rdata(token_bucket_rdata0),

    .eir_tb_wr(eir_tb_wr0),
    .eir_tb_waddr(eir_tb_waddr0),
    .eir_tb_wdata(eir_tb_wdata0),
    .eir_tb_raddr(eir_tb_raddr0),
    .eir_tb_rdata(eir_tb_rdata0),

    .event_fifo_wr(event_fifo_wr0),
    .event_fifo_waddr(event_fifo_waddr0),
    .event_fifo_wdata(event_fifo_wdata0),
    .event_fifo_raddr(event_fifo_raddr0),
    .event_fifo_rdata(event_fifo_rdata0),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr00),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr00),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata00),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr00),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata00),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr10),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr10),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata10),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr10),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata10),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr20),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr20),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata20),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr20),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata20),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr30),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr30),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata30),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr30),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata30),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr40),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr40),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata40),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr40),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata40),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr50),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr50),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata50),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr50),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata50),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr60),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr60),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata60),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr60),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata60),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr70),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr70),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata70),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr70),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata70),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr00),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr00),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata00),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr00),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata00),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr10),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr10),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata10),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr10),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata10),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr20),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr20),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata20),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr20),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata20),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr30),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr30),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata30),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr30),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata30),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr40),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr40),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata40),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr40),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata40),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr50),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr50),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata50),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr50),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata50),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr60),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr60),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata60),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr60),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata60),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr70),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr70),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata70),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr70),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata70),

    .event_fifo_count_wr0(event_fifo_count_wr00),   
    .event_fifo_count_waddr0(event_fifo_count_waddr00),
    .event_fifo_count_wdata0(event_fifo_count_wdata00),
    .event_fifo_count_raddr0(event_fifo_count_raddr00),
    .event_fifo_count_rdata0(event_fifo_count_rdata00),

    .event_fifo_count_wr1(event_fifo_count_wr10),   
    .event_fifo_count_waddr1(event_fifo_count_waddr10),
    .event_fifo_count_wdata1(event_fifo_count_wdata10),
    .event_fifo_count_raddr1(event_fifo_count_raddr10),
    .event_fifo_count_rdata1(event_fifo_count_rdata10),

    .event_fifo_count_wr2(event_fifo_count_wr20),   
    .event_fifo_count_waddr2(event_fifo_count_waddr20),
    .event_fifo_count_wdata2(event_fifo_count_wdata20),
    .event_fifo_count_raddr2(event_fifo_count_raddr20),
    .event_fifo_count_rdata2(event_fifo_count_rdata20),

    .event_fifo_count_wr3(event_fifo_count_wr30),   
    .event_fifo_count_waddr3(event_fifo_count_waddr30),
    .event_fifo_count_wdata3(event_fifo_count_wdata30),
    .event_fifo_count_raddr3(event_fifo_count_raddr30),
    .event_fifo_count_rdata3(event_fifo_count_rdata30),

    .event_fifo_count_wr4(event_fifo_count_wr40),   
    .event_fifo_count_waddr4(event_fifo_count_waddr40),
    .event_fifo_count_wdata4(event_fifo_count_wdata40),
    .event_fifo_count_raddr4(event_fifo_count_raddr40),
    .event_fifo_count_rdata4(event_fifo_count_rdata40),

    .event_fifo_count_wr5(event_fifo_count_wr50),   
    .event_fifo_count_waddr5(event_fifo_count_waddr50),
    .event_fifo_count_wdata5(event_fifo_count_wdata50),
    .event_fifo_count_raddr5(event_fifo_count_raddr50),
    .event_fifo_count_rdata5(event_fifo_count_rdata50),

    .event_fifo_count_wr6(event_fifo_count_wr60),   
    .event_fifo_count_waddr6(event_fifo_count_waddr60),
    .event_fifo_count_wdata6(event_fifo_count_wdata60),
    .event_fifo_count_raddr6(event_fifo_count_raddr60),
    .event_fifo_count_rdata6(event_fifo_count_rdata60),

    .event_fifo_count_wr7(event_fifo_count_wr70),   
    .event_fifo_count_waddr7(event_fifo_count_waddr70),
    .event_fifo_count_wdata7(event_fifo_count_wdata70),
    .event_fifo_count_raddr7(event_fifo_count_raddr70),
    .event_fifo_count_rdata7(event_fifo_count_rdata70),

    .event_fifo_count_wr(event_fifo_count_wr0),
    .event_fifo_count_waddr(event_fifo_count_waddr0),
    .event_fifo_count_wdata(event_fifo_count_wdata0),
    .event_fifo_count_raddr(event_fifo_count_raddr0),
    .event_fifo_count_rdata(event_fifo_count_rdata0),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr0), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr0),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata0),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr0),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata0),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr0),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr0),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata0),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr0),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata0),

    .semaphore_wr(semaphore_wr0),   
    .semaphore_waddr(semaphore_waddr0),
    .semaphore_wdata(semaphore_wdata0),
    .semaphore_raddr(semaphore_raddr0),
    .semaphore_rdata(semaphore_rdata0),

    .next_qm_avail_req(next_qm_avail_req0),             
    .next_qm_avail_req_qid(next_qm_avail_req_qid0), 
            
    .next_qm_enq_req(tm_enq_req1),   
    .next_qm_enq_qid(tm_enq_qid1),
    .next_qm_enq_pkt_desc(tm_enq_pkt_desc1),

    .sch_deq(sch_deq_req0), 
    .sch_deq_qid(sch_deq_qid0)

);

tm_sch_ds0 u_tm_sch_ds0(
    .clk(clk),

    .deficit_counter_wr(deficit_counter_wr0),
    .deficit_counter_waddr(deficit_counter_waddr0),
    .deficit_counter_wdata(deficit_counter_wdata0),
    .deficit_counter_raddr(deficit_counter_raddr0),
    .deficit_counter_rdata(deficit_counter_rdata0),

    .token_bucket_wr(token_bucket_wr0),
    .token_bucket_waddr(token_bucket_waddr0),
    .token_bucket_wdata(token_bucket_wdata0),
    .token_bucket_raddr(token_bucket_raddr0),
    .token_bucket_rdata(token_bucket_rdata0),

    .eir_tb_wr(eir_tb_wr0),
    .eir_tb_waddr(eir_tb_waddr0),
    .eir_tb_wdata(eir_tb_wdata0),
    .eir_tb_raddr(eir_tb_raddr0),
    .eir_tb_rdata(eir_tb_rdata0),

    .event_fifo_wr(event_fifo_wr0),
    .event_fifo_waddr(event_fifo_waddr0),
    .event_fifo_wdata(event_fifo_wdata0),
    .event_fifo_raddr(event_fifo_raddr0),
    .event_fifo_rdata(event_fifo_rdata0),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr00),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr00),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata00),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr00),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata00),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr10),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr10),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata10),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr10),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata10),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr20),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr20),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata20),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr20),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata20),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr30),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr30),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata30),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr30),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata30),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr40),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr40),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata40),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr40),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata40),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr50),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr50),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata50),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr50),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata50),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr60),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr60),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata60),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr60),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata60),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr70),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr70),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata70),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr70),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata70),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr00),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr00),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata00),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr00),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata00),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr10),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr10),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata10),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr10),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata10),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr20),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr20),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata20),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr20),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata20),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr30),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr30),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata30),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr30),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata30),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr40),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr40),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata40),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr40),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata40),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr50),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr50),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata50),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr50),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata50),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr60),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr60),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata60),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr60),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata60),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr70),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr70),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata70),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr70),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata70),

    .event_fifo_count_wr0(event_fifo_count_wr00),   
    .event_fifo_count_waddr0(event_fifo_count_waddr00),
    .event_fifo_count_wdata0(event_fifo_count_wdata00),
    .event_fifo_count_raddr0(event_fifo_count_raddr00),
    .event_fifo_count_rdata0(event_fifo_count_rdata00),

    .event_fifo_count_wr1(event_fifo_count_wr10),   
    .event_fifo_count_waddr1(event_fifo_count_waddr10),
    .event_fifo_count_wdata1(event_fifo_count_wdata10),
    .event_fifo_count_raddr1(event_fifo_count_raddr10),
    .event_fifo_count_rdata1(event_fifo_count_rdata10),

    .event_fifo_count_wr2(event_fifo_count_wr20),   
    .event_fifo_count_waddr2(event_fifo_count_waddr20),
    .event_fifo_count_wdata2(event_fifo_count_wdata20),
    .event_fifo_count_raddr2(event_fifo_count_raddr20),
    .event_fifo_count_rdata2(event_fifo_count_rdata20),

    .event_fifo_count_wr3(event_fifo_count_wr30),   
    .event_fifo_count_waddr3(event_fifo_count_waddr30),
    .event_fifo_count_wdata3(event_fifo_count_wdata30),
    .event_fifo_count_raddr3(event_fifo_count_raddr30),
    .event_fifo_count_rdata3(event_fifo_count_rdata30),

    .event_fifo_count_wr4(event_fifo_count_wr40),   
    .event_fifo_count_waddr4(event_fifo_count_waddr40),
    .event_fifo_count_wdata4(event_fifo_count_wdata40),
    .event_fifo_count_raddr4(event_fifo_count_raddr40),
    .event_fifo_count_rdata4(event_fifo_count_rdata40),

    .event_fifo_count_wr5(event_fifo_count_wr50),   
    .event_fifo_count_waddr5(event_fifo_count_waddr50),
    .event_fifo_count_wdata5(event_fifo_count_wdata50),
    .event_fifo_count_raddr5(event_fifo_count_raddr50),
    .event_fifo_count_rdata5(event_fifo_count_rdata50),

    .event_fifo_count_wr6(event_fifo_count_wr60),   
    .event_fifo_count_waddr6(event_fifo_count_waddr60),
    .event_fifo_count_wdata6(event_fifo_count_wdata60),
    .event_fifo_count_raddr6(event_fifo_count_raddr60),
    .event_fifo_count_rdata6(event_fifo_count_rdata60),

    .event_fifo_count_wr7(event_fifo_count_wr70),   
    .event_fifo_count_waddr7(event_fifo_count_waddr70),
    .event_fifo_count_wdata7(event_fifo_count_wdata70),
    .event_fifo_count_raddr7(event_fifo_count_raddr70),
    .event_fifo_count_rdata7(event_fifo_count_rdata70),

    .event_fifo_count_wr(event_fifo_count_wr0),
    .event_fifo_count_waddr(event_fifo_count_waddr0),
    .event_fifo_count_wdata(event_fifo_count_wdata0),
    .event_fifo_count_raddr(event_fifo_count_raddr0),
    .event_fifo_count_rdata(event_fifo_count_rdata0),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr0), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr0),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata0),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr0),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata0),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr0),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr0),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata0),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr0),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata0),

    .semaphore_wr(semaphore_wr0),   
    .semaphore_waddr(semaphore_waddr0),
    .semaphore_wdata(semaphore_wdata0),
    .semaphore_raddr(semaphore_raddr0),
    .semaphore_rdata(semaphore_rdata0)

);

tm_sch_mem0 u_tm_sch_mem0(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[0]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_queue_profile(reg_ms_queue_profile[0]),
    .reg_ms_wdrr_quantum(reg_ms_wdrr_quantum[0]),
    .reg_ms_shaping_profile_cir(reg_ms_shaping_profile_cir[0]),
    .reg_ms_shaping_profile_eir(reg_ms_shaping_profile_eir[0]),
    .reg_ms_wdrr_sch_ctrl(reg_ms_wdrr_sch_ctrl[0]),
    .reg_ms_fill_tb_dst(reg_ms_fill_tb_dst[0]),

    .queue_profile_rd(queue_profile_rd0), 
    .queue_profile_raddr(queue_profile_raddr0),

    .wdrr_quantum_rd(wdrr_quantum_rd0),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr0),

    .shaping_profile_cir_rd(shaping_profile_cir_rd0),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr0),
	.shaping_profile_cir_wr(shaping_profile_cir_wr0),
	.shaping_profile_cir_waddr(shaping_profile_cir_waddr0),
	.shaping_profile_cir_wdata(shaping_profile_cir_wdata0),

	.shaping_profile_eir_rd(shaping_profile_eir_rd0),
	.shaping_profile_eir_raddr(shaping_profile_eir_raddr0),
	.shaping_profile_eir_wr(shaping_profile_eir_wr0),
	.shaping_profile_eir_waddr(shaping_profile_eir_waddr0),
	.shaping_profile_eir_wdata(shaping_profile_eir_wdata0),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd0),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr0), 
     
    .fill_tb_dst_rd(fill_tb_dst_rd0),  
    .fill_tb_dst_raddr(fill_tb_dst_raddr0), 
    .fill_tb_dst_wr(fill_tb_dst_wr0),
    .fill_tb_dst_waddr(fill_tb_dst_waddr0),
    .fill_tb_dst_wdata(fill_tb_dst_wdata0),
     
    // outputs

    .queue_profile_mem_ack(queue_profile_mem_ack[0]), 
    .queue_profile_mem_rdata(queue_profile_mem_rdata[0]),

    .wdrr_quantum_mem_ack(wdrr_quantum_mem_ack[0]),   
    .wdrr_quantum_mem_rdata(wdrr_quantum_mem_rdata[0]),

    .shaping_profile_cir_mem_ack(shaping_profile_cir_mem_ack[0]),
    .shaping_profile_cir_mem_rdata(shaping_profile_cir_mem_rdata[0]),

    .shaping_profile_eir_mem_ack(shaping_profile_eir_mem_ack[0]),
    .shaping_profile_eir_mem_rdata(shaping_profile_eir_mem_rdata[0]),

    .wdrr_sch_ctrl_mem_ack(wdrr_sch_ctrl_mem_ack[0]),  
    .wdrr_sch_ctrl_mem_rdata(wdrr_sch_ctrl_mem_rdata[0]),

	.fill_tb_dst_mem_ack(fill_tb_dst_mem_ack[0]),  
	.fill_tb_dst_mem_rdata(fill_tb_dst_mem_rdata[0]),

    .queue_profile_ack(queue_profile_ack0), 
    .queue_profile_rdata(queue_profile_rdata0),

    .wdrr_quantum_ack(wdrr_quantum_ack0),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata0),

    .shaping_profile_cir_ack(shaping_profile_cir_ack0),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata0),

    .shaping_profile_eir_ack(shaping_profile_eir_ack0),
    .shaping_profile_eir_rdata(shaping_profile_eir_rdata0),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack0),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata0),

    .fill_tb_dst_ack(fill_tb_dst_ack0),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata0)

);

tm_sch_pri_mem0 u_tm_sch_pri_mem0(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[0]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_pri_sch_ctrl(reg_ms_pri_sch_ctrl[0]),

    .pri_sch_ctrl0_rd(pri_sch_ctrl00_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl00_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl01_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl01_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl02_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl02_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl03_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl03_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl04_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl04_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl05_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl05_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl06_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl06_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl07_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl07_raddr),

    // outputs

    .pri_sch_ctrl_mem_ack(pri_sch_ctrl_mem_ack[0]),   
    .pri_sch_ctrl_mem_rdata(pri_sch_ctrl_mem_rdata[0]),

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr0),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr0),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata0),

    .pri_sch_ctrl0_ack(pri_sch_ctrl00_ack),   
    .pri_sch_ctrl0_rdata(pri_sch_ctrl00_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl01_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl01_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl02_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl02_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl03_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl03_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl04_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl04_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl05_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl05_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl06_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl06_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl07_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl07_rdata)
);

// -------------------- level 1 ------------------------------------
tm_qm_1to3 #(`SECOND_LVL_QUEUE_ID_NBITS) u_tm_qm_1to3_1(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[1]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .alpha(alpha),

    .enq_req(tm_enq_req1),   
    .enq_qid(tm_enq_qid1),   
    .enq_pkt_desc(tm_enq_pkt_desc1),    

    .deq_req(sch_deq_req1),    
    .deq_qid(sch_deq_qid1),

    .next_qm_avail_req(next_qm_avail_req0),             
    .next_qm_avail_req_qid(next_qm_avail_req_qid0), 
            
    .bm_tm_bp(bm_tm_bp),  

    // outputs

    .head_wr(head_wr1),
    .head_raddr(head_raddr1),
    .head_waddr(head_waddr1),
    .head_wdata(head_wdata1),
    .head_rdata(head_rdata1),

    .tail_wr(tail_wr1),
    .tail_raddr(tail_raddr1),
    .tail_waddr(tail_waddr1),
    .tail_wdata(tail_wdata1),
    .tail_rdata(tail_rdata1),

    .depth_wr(depth_wr1),
    .depth_raddr(depth_raddr1),
    .depth_waddr(depth_waddr1),
    .depth_wdata(depth_wdata1),
    .depth_rdata(depth_rdata1),

    .depth1_wr(depth1_wr1),
    .depth1_raddr(depth1_raddr1),
    .depth1_waddr(depth1_waddr1),
    .depth1_wdata(depth1_wdata1),
    .depth1_rdata(depth1_rdata1),

    .ll_wr(ll_wr1),
    .ll_raddr(ll_raddr1),
    .ll_waddr(ll_waddr1),
    .ll_wdata(ll_wdata1),
    .ll_rdata(ll_rdata1),

    .pkt_desc_wr(pkt_desc_wr1),
    .pkt_desc_raddr(pkt_desc_raddr1),
    .pkt_desc_waddr(pkt_desc_waddr1),
    .pkt_desc_wdata(pkt_desc_wdata1),
    .pkt_desc_rdata(pkt_desc_rdata1),

    .next_qm_avail_ack(next_qm_avail_ack0),             
    .next_qm_available(next_qm_available0), 
            
    .src_queue_available(next_qm_enq_src_available0),   
    .dst_queue_available(next_qm_enq_dst_available0),   

    .enq_ack(active_enq_ack1),   
    .enq_ack_qid(active_enq_ack_qid1),    
    .enq_ack_dst_port(active_enq_ack_dst_port1),    
    .enq_to_empty(active_enq_to_empty1),    

    .deq_depth_ack(sch_deq_depth_ack1),
    .deq_depth_from_emptyp2(sch_deq_depth_from_emptyp21),   

    .deq_ack(sch_deq_ack1),
    .deq_ack_qid(sch_deq_ack_qid1),
    .deq_pkt_desc(sch_deq_pkt_desc1)

);


tm_qm_ds1 u_tm_qm_ds1(
    .clk(clk),

    .head_wr(head_wr1),
    .head_raddr(head_raddr1),
    .head_waddr(head_waddr1),
    .head_wdata(head_wdata1),
    .head_rdata(head_rdata1),

    .tail_wr(tail_wr1),
    .tail_raddr(tail_raddr1),
    .tail_waddr(tail_waddr1),
    .tail_wdata(tail_wdata1),
    .tail_rdata(tail_rdata1),

    .depth_wr(depth_wr1),
    .depth_raddr(depth_raddr1),
    .depth_waddr(depth_waddr1),
    .depth_wdata(depth_wdata1),
    .depth_rdata(depth_rdata1),

    .depth1_wr(depth1_wr1),
    .depth1_raddr(depth1_raddr1),
    .depth1_waddr(depth1_waddr1),
    .depth1_wdata(depth1_wdata1),
    .depth1_rdata(depth1_rdata1),

    .ll_wr(ll_wr1),
    .ll_raddr(ll_raddr1),
    .ll_waddr(ll_waddr1),
    .ll_wdata(ll_wdata1),
    .ll_rdata(ll_rdata1),

    .pkt_desc_wr(pkt_desc_wr1),
    .pkt_desc_raddr(pkt_desc_raddr1),
    .pkt_desc_waddr(pkt_desc_waddr1),
    .pkt_desc_wdata(pkt_desc_wdata1),
    .pkt_desc_rdata(pkt_desc_rdata1)

);

tm_sch #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS, `SECOND_LVL_QUEUE_PROFILE_NBITS) u_tm_sch_1(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[1]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif
        
    .qm_enq_ack(active_enq_ack1),   
    .qm_enq_ack_qid(active_enq_ack_qid1), 
    .qm_enq_ack_dst_port(active_enq_ack_dst_port1),    
    .qm_enq_to_empty(active_enq_to_empty1), 

    .sch_deq_depth_ack(sch_deq_depth_ack1),
    .sch_deq_depth_from_emptyp2(sch_deq_depth_from_emptyp21),  

    .sch_deq_ack(sch_deq_ack1),
    .sch_deq_ack_qid(sch_deq_ack_qid1),
    .sch_deq_pkt_desc(sch_deq_pkt_desc1),

    .next_qm_avail_ack(next_qm_avail_ack1),             
    .next_qm_available(next_qm_available1), 
            
    .next_qm_enq_dst_available(next_qm_enq_dst_available1),  

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr1),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr1),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata1),

    .pri_sch_ctrl0_ack(pri_sch_ctrl10_ack), 
    .pri_sch_ctrl0_rdata(pri_sch_ctrl10_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl11_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl11_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl12_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl12_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl13_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl13_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl14_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl14_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl15_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl15_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl16_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl16_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl17_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl17_rdata),

    .queue_profile_ack(queue_profile_ack1), 
    .queue_profile_rdata(queue_profile_rdata1),

    .wdrr_quantum_ack(wdrr_quantum_ack1),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata1),

    .shaping_profile_cir_ack(shaping_profile_cir_ack1),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata1),

    .shaping_profile_eir_ack(shaping_profile_eir_ack1),
    .shaping_profile_eir_rdata(shaping_profile_eir_rdata1),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack1),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata1),

    .fill_tb_dst_ack(fill_tb_dst_ack1),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata1),


    // outputs

    .pri_sch_ctrl0_rd(pri_sch_ctrl10_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl10_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl11_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl11_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl12_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl12_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl13_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl13_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl14_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl14_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl15_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl15_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl16_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl16_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl17_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl17_raddr),

    .queue_profile_rd(queue_profile_rd1), 
    .queue_profile_raddr(queue_profile_raddr1),

    .wdrr_quantum_rd(wdrr_quantum_rd1),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr1),

    .shaping_profile_cir_rd(shaping_profile_cir_rd1),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr1),
    .shaping_profile_cir_wr(shaping_profile_cir_wr1),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr1),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata1),

    .shaping_profile_eir_rd(shaping_profile_eir_rd1),
    .shaping_profile_eir_raddr(shaping_profile_eir_raddr1),
    .shaping_profile_eir_wr(shaping_profile_eir_wr1),
    .shaping_profile_eir_waddr(shaping_profile_eir_waddr1),
    .shaping_profile_eir_wdata(shaping_profile_eir_wdata1),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd1),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr1),
       
    .fill_tb_dst_rd(fill_tb_dst_rd1),  
    .fill_tb_dst_raddr(fill_tb_dst_raddr1),
    .fill_tb_dst_wr(fill_tb_dst_wr1),
    .fill_tb_dst_waddr(fill_tb_dst_waddr1),
    .fill_tb_dst_wdata(fill_tb_dst_wdata1),
       

    .deficit_counter_wr(deficit_counter_wr1),
    .deficit_counter_waddr(deficit_counter_waddr1),
    .deficit_counter_wdata(deficit_counter_wdata1),
    .deficit_counter_raddr(deficit_counter_raddr1),
    .deficit_counter_rdata(deficit_counter_rdata1),

    .token_bucket_wr(token_bucket_wr1),
    .token_bucket_waddr(token_bucket_waddr1),
    .token_bucket_wdata(token_bucket_wdata1),
    .token_bucket_raddr(token_bucket_raddr1),
    .token_bucket_rdata(token_bucket_rdata1),

    .eir_tb_wr(eir_tb_wr1),
    .eir_tb_waddr(eir_tb_waddr1),
    .eir_tb_wdata(eir_tb_wdata1),
    .eir_tb_raddr(eir_tb_raddr1),
    .eir_tb_rdata(eir_tb_rdata1),

    .event_fifo_wr(event_fifo_wr1),
    .event_fifo_waddr(event_fifo_waddr1),
    .event_fifo_wdata(event_fifo_wdata1),
    .event_fifo_raddr(event_fifo_raddr1),
    .event_fifo_rdata(event_fifo_rdata1),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr01),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr01),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata01),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr01),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata01),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr11),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr11),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata11),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr11),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata11),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr21),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr21),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata21),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr21),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata21),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr31),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr31),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata31),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr31),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata31),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr41),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr41),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata41),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr41),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata41),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr51),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr51),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata51),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr51),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata51),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr61),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr61),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata61),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr61),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata61),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr71),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr71),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata71),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr71),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata71),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr01),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr01),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata01),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr01),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata01),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr11),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr11),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata11),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr11),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata11),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr21),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr21),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata21),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr21),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata21),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr31),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr31),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata31),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr31),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata31),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr41),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr41),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata41),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr41),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata41),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr51),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr51),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata51),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr51),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata51),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr61),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr61),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata61),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr61),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata61),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr71),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr71),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata71),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr71),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata71),

    .event_fifo_count_wr0(event_fifo_count_wr01),   
    .event_fifo_count_waddr0(event_fifo_count_waddr01),
    .event_fifo_count_wdata0(event_fifo_count_wdata01),
    .event_fifo_count_raddr0(event_fifo_count_raddr01),
    .event_fifo_count_rdata0(event_fifo_count_rdata01),

    .event_fifo_count_wr1(event_fifo_count_wr11),   
    .event_fifo_count_waddr1(event_fifo_count_waddr11),
    .event_fifo_count_wdata1(event_fifo_count_wdata11),
    .event_fifo_count_raddr1(event_fifo_count_raddr11),
    .event_fifo_count_rdata1(event_fifo_count_rdata11),

    .event_fifo_count_wr2(event_fifo_count_wr21),   
    .event_fifo_count_waddr2(event_fifo_count_waddr21),
    .event_fifo_count_wdata2(event_fifo_count_wdata21),
    .event_fifo_count_raddr2(event_fifo_count_raddr21),
    .event_fifo_count_rdata2(event_fifo_count_rdata21),

    .event_fifo_count_wr3(event_fifo_count_wr31),   
    .event_fifo_count_waddr3(event_fifo_count_waddr31),
    .event_fifo_count_wdata3(event_fifo_count_wdata31),
    .event_fifo_count_raddr3(event_fifo_count_raddr31),
    .event_fifo_count_rdata3(event_fifo_count_rdata31),

    .event_fifo_count_wr4(event_fifo_count_wr41),   
    .event_fifo_count_waddr4(event_fifo_count_waddr41),
    .event_fifo_count_wdata4(event_fifo_count_wdata41),
    .event_fifo_count_raddr4(event_fifo_count_raddr41),
    .event_fifo_count_rdata4(event_fifo_count_rdata41),

    .event_fifo_count_wr5(event_fifo_count_wr51),   
    .event_fifo_count_waddr5(event_fifo_count_waddr51),
    .event_fifo_count_wdata5(event_fifo_count_wdata51),
    .event_fifo_count_raddr5(event_fifo_count_raddr51),
    .event_fifo_count_rdata5(event_fifo_count_rdata51),

    .event_fifo_count_wr6(event_fifo_count_wr61),   
    .event_fifo_count_waddr6(event_fifo_count_waddr61),
    .event_fifo_count_wdata6(event_fifo_count_wdata61),
    .event_fifo_count_raddr6(event_fifo_count_raddr61),
    .event_fifo_count_rdata6(event_fifo_count_rdata61),

    .event_fifo_count_wr7(event_fifo_count_wr71),   
    .event_fifo_count_waddr7(event_fifo_count_waddr71),
    .event_fifo_count_wdata7(event_fifo_count_wdata71),
    .event_fifo_count_raddr7(event_fifo_count_raddr71),
    .event_fifo_count_rdata7(event_fifo_count_rdata71),

    .event_fifo_count_wr(event_fifo_count_wr1),
    .event_fifo_count_waddr(event_fifo_count_waddr1),
    .event_fifo_count_wdata(event_fifo_count_wdata1),
    .event_fifo_count_raddr(event_fifo_count_raddr1),
    .event_fifo_count_rdata(event_fifo_count_rdata1),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr1), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr1),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata1),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr1),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata1),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr1),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr1),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata1),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr1),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata1),

    .semaphore_wr(semaphore_wr1),   
    .semaphore_waddr(semaphore_waddr1),
    .semaphore_wdata(semaphore_wdata1),
    .semaphore_raddr(semaphore_raddr1),
    .semaphore_rdata(semaphore_rdata1),

    .next_qm_avail_req(next_qm_avail_req1),             
    .next_qm_avail_req_qid(next_qm_avail_req_qid1), 
            
    .next_qm_enq_req(tm_enq_req2),   
    .next_qm_enq_qid(tm_enq_qid2),
    .next_qm_enq_pkt_desc(tm_enq_pkt_desc2),

    .sch_deq(sch_deq_req1), 
    .sch_deq_qid(sch_deq_qid1)

);


tm_sch_ds1 u_tm_sch_ds1(
    .clk(clk),

    .deficit_counter_wr(deficit_counter_wr1),
    .deficit_counter_waddr(deficit_counter_waddr1),
    .deficit_counter_wdata(deficit_counter_wdata1),
    .deficit_counter_raddr(deficit_counter_raddr1),
    .deficit_counter_rdata(deficit_counter_rdata1),

    .token_bucket_wr(token_bucket_wr1),
    .token_bucket_waddr(token_bucket_waddr1),
    .token_bucket_wdata(token_bucket_wdata1),
    .token_bucket_raddr(token_bucket_raddr1),
    .token_bucket_rdata(token_bucket_rdata1),

	.eir_tb_wr(eir_tb_wr1),
	.eir_tb_waddr(eir_tb_waddr1),
	.eir_tb_wdata(eir_tb_wdata1),
	.eir_tb_raddr(eir_tb_raddr1),
	.eir_tb_rdata(eir_tb_rdata1),

    .event_fifo_wr(event_fifo_wr1),
    .event_fifo_waddr(event_fifo_waddr1),
    .event_fifo_wdata(event_fifo_wdata1),
    .event_fifo_raddr(event_fifo_raddr1),
    .event_fifo_rdata(event_fifo_rdata1),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr01),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr01),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata01),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr01),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata01),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr11),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr11),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata11),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr11),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata11),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr21),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr21),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata21),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr21),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata21),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr31),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr31),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata31),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr31),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata31),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr41),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr41),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata41),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr41),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata41),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr51),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr51),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata51),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr51),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata51),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr61),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr61),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata61),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr61),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata61),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr71),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr71),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata71),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr71),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata71),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr01),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr01),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata01),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr01),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata01),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr11),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr11),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata11),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr11),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata11),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr21),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr21),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata21),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr21),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata21),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr31),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr31),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata31),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr31),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata31),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr41),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr41),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata41),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr41),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata41),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr51),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr51),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata51),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr51),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata51),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr61),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr61),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata61),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr61),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata61),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr71),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr71),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata71),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr71),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata71),

    .event_fifo_count_wr0(event_fifo_count_wr01),   
    .event_fifo_count_waddr0(event_fifo_count_waddr01),
    .event_fifo_count_wdata0(event_fifo_count_wdata01),
    .event_fifo_count_raddr0(event_fifo_count_raddr01),
    .event_fifo_count_rdata0(event_fifo_count_rdata01),

    .event_fifo_count_wr1(event_fifo_count_wr11),   
    .event_fifo_count_waddr1(event_fifo_count_waddr11),
    .event_fifo_count_wdata1(event_fifo_count_wdata11),
    .event_fifo_count_raddr1(event_fifo_count_raddr11),
    .event_fifo_count_rdata1(event_fifo_count_rdata11),

    .event_fifo_count_wr2(event_fifo_count_wr21),   
    .event_fifo_count_waddr2(event_fifo_count_waddr21),
    .event_fifo_count_wdata2(event_fifo_count_wdata21),
    .event_fifo_count_raddr2(event_fifo_count_raddr21),
    .event_fifo_count_rdata2(event_fifo_count_rdata21),

    .event_fifo_count_wr3(event_fifo_count_wr31),   
    .event_fifo_count_waddr3(event_fifo_count_waddr31),
    .event_fifo_count_wdata3(event_fifo_count_wdata31),
    .event_fifo_count_raddr3(event_fifo_count_raddr31),
    .event_fifo_count_rdata3(event_fifo_count_rdata31),

    .event_fifo_count_wr4(event_fifo_count_wr41),   
    .event_fifo_count_waddr4(event_fifo_count_waddr41),
    .event_fifo_count_wdata4(event_fifo_count_wdata41),
    .event_fifo_count_raddr4(event_fifo_count_raddr41),
    .event_fifo_count_rdata4(event_fifo_count_rdata41),

    .event_fifo_count_wr5(event_fifo_count_wr51),   
    .event_fifo_count_waddr5(event_fifo_count_waddr51),
    .event_fifo_count_wdata5(event_fifo_count_wdata51),
    .event_fifo_count_raddr5(event_fifo_count_raddr51),
    .event_fifo_count_rdata5(event_fifo_count_rdata51),

    .event_fifo_count_wr6(event_fifo_count_wr61),   
    .event_fifo_count_waddr6(event_fifo_count_waddr61),
    .event_fifo_count_wdata6(event_fifo_count_wdata61),
    .event_fifo_count_raddr6(event_fifo_count_raddr61),
    .event_fifo_count_rdata6(event_fifo_count_rdata61),

    .event_fifo_count_wr7(event_fifo_count_wr71),   
    .event_fifo_count_waddr7(event_fifo_count_waddr71),
    .event_fifo_count_wdata7(event_fifo_count_wdata71),
    .event_fifo_count_raddr7(event_fifo_count_raddr71),
    .event_fifo_count_rdata7(event_fifo_count_rdata71),

    .event_fifo_count_wr(event_fifo_count_wr1),
    .event_fifo_count_waddr(event_fifo_count_waddr1),
    .event_fifo_count_wdata(event_fifo_count_wdata1),
    .event_fifo_count_raddr(event_fifo_count_raddr1),
    .event_fifo_count_rdata(event_fifo_count_rdata1),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr1), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr1),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata1),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr1),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata1),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr1),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr1),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata1),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr1),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata1),

    .semaphore_wr(semaphore_wr1),   
    .semaphore_waddr(semaphore_waddr1),
    .semaphore_wdata(semaphore_wdata1),
    .semaphore_raddr(semaphore_raddr1),
    .semaphore_rdata(semaphore_rdata1)

);

tm_sch_mem1 u_tm_sch_mem1(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[1]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_queue_profile(reg_ms_queue_profile[1]),
    .reg_ms_wdrr_quantum(reg_ms_wdrr_quantum[1]),
    .reg_ms_shaping_profile_cir(reg_ms_shaping_profile_cir[1]),
    .reg_ms_shaping_profile_eir(reg_ms_shaping_profile_eir[1]),
    .reg_ms_wdrr_sch_ctrl(reg_ms_wdrr_sch_ctrl[1]),
    .reg_ms_fill_tb_dst(reg_ms_fill_tb_dst[1]),

    .queue_profile_rd(queue_profile_rd1), 
    .queue_profile_raddr(queue_profile_raddr1),

    .wdrr_quantum_rd(wdrr_quantum_rd1),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr1),

    .shaping_profile_cir_rd(shaping_profile_cir_rd1),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr1),
    .shaping_profile_cir_wr(shaping_profile_cir_wr1),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr1),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata1),

	.shaping_profile_eir_rd(shaping_profile_eir_rd1),
	.shaping_profile_eir_raddr(shaping_profile_eir_raddr1),
	.shaping_profile_eir_wr(shaping_profile_eir_wr1),
	.shaping_profile_eir_waddr(shaping_profile_eir_waddr1),
	.shaping_profile_eir_wdata(shaping_profile_eir_wdata1),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd1),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr1), 
     
    .fill_tb_dst_rd(fill_tb_dst_rd1),  
    .fill_tb_dst_raddr(fill_tb_dst_raddr1), 
    .fill_tb_dst_wr(fill_tb_dst_wr1),
    .fill_tb_dst_waddr(fill_tb_dst_waddr1),
    .fill_tb_dst_wdata(fill_tb_dst_wdata1),
     
    // outputs

    .queue_profile_mem_ack(queue_profile_mem_ack[1]), 
    .queue_profile_mem_rdata(queue_profile_mem_rdata[1]),

    .wdrr_quantum_mem_ack(wdrr_quantum_mem_ack[1]),   
    .wdrr_quantum_mem_rdata(wdrr_quantum_mem_rdata[1]),

    .shaping_profile_cir_mem_ack(shaping_profile_cir_mem_ack[1]),
    .shaping_profile_cir_mem_rdata(shaping_profile_cir_mem_rdata[1]),

    .shaping_profile_eir_mem_ack(shaping_profile_eir_mem_ack[1]),
    .shaping_profile_eir_mem_rdata(shaping_profile_eir_mem_rdata[1]),

    .wdrr_sch_ctrl_mem_ack(wdrr_sch_ctrl_mem_ack[1]),  
    .wdrr_sch_ctrl_mem_rdata(wdrr_sch_ctrl_mem_rdata[1]),

	.fill_tb_dst_mem_ack(fill_tb_dst_mem_ack[1]),  
	.fill_tb_dst_mem_rdata(fill_tb_dst_mem_rdata[1]),

    .queue_profile_ack(queue_profile_ack1), 
    .queue_profile_rdata(queue_profile_rdata1),

    .wdrr_quantum_ack(wdrr_quantum_ack1),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata1),

    .shaping_profile_cir_ack(shaping_profile_cir_ack1),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata1),

    .shaping_profile_eir_ack(shaping_profile_eir_ack1),
    .shaping_profile_eir_rdata(shaping_profile_eir_rdata1),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack1),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata1),

    .fill_tb_dst_ack(fill_tb_dst_ack1),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata1)

);

tm_sch_pri_mem1 u_tm_sch_pri_mem1(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[1]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_pri_sch_ctrl(reg_ms_pri_sch_ctrl[1]),

    .pri_sch_ctrl0_rd(pri_sch_ctrl10_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl10_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl11_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl11_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl12_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl12_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl13_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl13_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl14_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl14_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl15_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl15_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl16_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl16_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl17_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl17_raddr),

    // outputs

    .pri_sch_ctrl_mem_ack(pri_sch_ctrl_mem_ack[1]),   
    .pri_sch_ctrl_mem_rdata(pri_sch_ctrl_mem_rdata[1]),

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr1),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr1),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata1),

    .pri_sch_ctrl0_ack(pri_sch_ctrl10_ack),   
    .pri_sch_ctrl0_rdata(pri_sch_ctrl10_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl11_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl11_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl12_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl12_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl13_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl13_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl14_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl14_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl15_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl15_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl16_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl16_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl17_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl17_rdata)
);

// -------------------- level 2 ------------------------------------
tm_qm_1to3 #(`THIRD_LVL_QUEUE_ID_NBITS) u_tm_qm_1to3_2(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[2]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .alpha(alpha),

    .enq_req(tm_enq_req2),   
    .enq_qid(tm_enq_qid2),   
    .enq_pkt_desc(tm_enq_pkt_desc2),    

    .deq_req(sch_deq_req2),    
    .deq_qid(sch_deq_qid2),

    .next_qm_avail_req(next_qm_avail_req1),             
    .next_qm_avail_req_qid(next_qm_avail_req_qid1), 
            
    .bm_tm_bp(bm_tm_bp),  

    // outputs

    .head_wr(head_wr2),
    .head_raddr(head_raddr2),
    .head_waddr(head_waddr2),
    .head_wdata(head_wdata2),
    .head_rdata(head_rdata2),

    .tail_wr(tail_wr2),
    .tail_raddr(tail_raddr2),
    .tail_waddr(tail_waddr2),
    .tail_wdata(tail_wdata2),
    .tail_rdata(tail_rdata2),

    .depth_wr(depth_wr2),
    .depth_raddr(depth_raddr2),
    .depth_waddr(depth_waddr2),
    .depth_wdata(depth_wdata2),
    .depth_rdata(depth_rdata2),

    .depth1_wr(depth1_wr2),
    .depth1_raddr(depth1_raddr2),
    .depth1_waddr(depth1_waddr2),
    .depth1_wdata(depth1_wdata2),
    .depth1_rdata(depth1_rdata2),

    .ll_wr(ll_wr2),
    .ll_raddr(ll_raddr2),
    .ll_waddr(ll_waddr2),
    .ll_wdata(ll_wdata2),
    .ll_rdata(ll_rdata2),

    .pkt_desc_wr(pkt_desc_wr2),
    .pkt_desc_raddr(pkt_desc_raddr2),
    .pkt_desc_waddr(pkt_desc_waddr2),
    .pkt_desc_wdata(pkt_desc_wdata2),
    .pkt_desc_rdata(pkt_desc_rdata2),

    .next_qm_avail_ack(next_qm_avail_ack1),             
    .next_qm_available(next_qm_available1),     

    .src_queue_available(next_qm_enq_src_available1), 
    .dst_queue_available(next_qm_enq_dst_available1), 
      
    .enq_ack(active_enq_ack2),   
    .enq_ack_qid(active_enq_ack_qid2),    
    .enq_ack_dst_port(active_enq_ack_dst_port2),    
    .enq_to_empty(active_enq_to_empty2),    

    .deq_depth_ack(sch_deq_depth_ack2),
    .deq_depth_from_emptyp2(sch_deq_depth_from_emptyp22),   

	.deq_ack(sch_deq_ack2),
	.deq_ack_qid(sch_deq_ack_qid2),
    .deq_pkt_desc(sch_deq_pkt_desc2)

);

tm_qm_ds2 u_tm_qm_ds2(
    .clk(clk),

    .head_wr(head_wr2),
    .head_raddr(head_raddr2),
    .head_waddr(head_waddr2),
    .head_wdata(head_wdata2),
    .head_rdata(head_rdata2),

    .tail_wr(tail_wr2),
    .tail_raddr(tail_raddr2),
    .tail_waddr(tail_waddr2),
    .tail_wdata(tail_wdata2),
    .tail_rdata(tail_rdata2),

    .depth_wr(depth_wr2),
    .depth_raddr(depth_raddr2),
    .depth_waddr(depth_waddr2),
    .depth_wdata(depth_wdata2),
    .depth_rdata(depth_rdata2),

    .depth1_wr(depth1_wr2),
    .depth1_raddr(depth1_raddr2),
    .depth1_waddr(depth1_waddr2),
    .depth1_wdata(depth1_wdata2),
    .depth1_rdata(depth1_rdata2),

    .ll_wr(ll_wr2),
    .ll_raddr(ll_raddr2),
    .ll_waddr(ll_waddr2),
    .ll_wdata(ll_wdata2),
    .ll_rdata(ll_rdata2),

    .pkt_desc_wr(pkt_desc_wr2),
    .pkt_desc_raddr(pkt_desc_raddr2),
    .pkt_desc_waddr(pkt_desc_waddr2),
    .pkt_desc_wdata(pkt_desc_wdata2),
    .pkt_desc_rdata(pkt_desc_rdata2)

);

tm_sch #(`THIRD_LVL_QUEUE_ID_NBITS, `THIRD_LVL_SCH_ID_NBITS, `THIRD_LVL_QUEUE_PROFILE_NBITS) u_tm_sch_2(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[2]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif
        
    .qm_enq_ack(active_enq_ack2),   
    .qm_enq_ack_qid(active_enq_ack_qid2), 
    .qm_enq_ack_dst_port(active_enq_ack_dst_port2),    
    .qm_enq_to_empty(active_enq_to_empty2), 

    .sch_deq_depth_ack(sch_deq_depth_ack2),
    .sch_deq_depth_from_emptyp2(sch_deq_depth_from_emptyp22),  

    .sch_deq_ack(sch_deq_ack2),
    .sch_deq_ack_qid(sch_deq_ack_qid2),
    .sch_deq_pkt_desc(sch_deq_pkt_desc2),

    .next_qm_avail_ack(next_qm_avail_ack2),             
    .next_qm_available(next_qm_available2), 
            
    .next_qm_enq_dst_available(next_qm_enq_dst_available2),  

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr2),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr2),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata2),

    .pri_sch_ctrl0_ack(pri_sch_ctrl20_ack), 
    .pri_sch_ctrl0_rdata(pri_sch_ctrl20_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl21_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl21_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl22_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl22_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl23_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl23_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl24_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl24_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl25_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl25_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl26_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl26_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl27_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl27_rdata),

    .queue_profile_ack(queue_profile_ack2), 
    .queue_profile_rdata(queue_profile_rdata2),

    .wdrr_quantum_ack(wdrr_quantum_ack2),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata2),

    .shaping_profile_cir_ack(shaping_profile_cir_ack2),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata2),

    .shaping_profile_eir_ack(shaping_profile_eir_ack2),
    .shaping_profile_eir_rdata(shaping_profile_eir_rdata2),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack2),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata2),

    .fill_tb_dst_ack(fill_tb_dst_ack2),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata2),

    // outputs

    .pri_sch_ctrl0_rd(pri_sch_ctrl20_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl20_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl21_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl21_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl22_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl22_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl23_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl23_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl24_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl24_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl25_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl25_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl26_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl26_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl27_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl27_raddr),

    .queue_profile_rd(queue_profile_rd2), 
    .queue_profile_raddr(queue_profile_raddr2),

    .wdrr_quantum_rd(wdrr_quantum_rd2),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr2),

    .shaping_profile_cir_rd(shaping_profile_cir_rd2),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr2),
    .shaping_profile_cir_wr(shaping_profile_cir_wr2),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr2),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata2),

    .shaping_profile_eir_rd(shaping_profile_eir_rd2),
    .shaping_profile_eir_raddr(shaping_profile_eir_raddr2),
    .shaping_profile_eir_wr(shaping_profile_eir_wr2),
    .shaping_profile_eir_waddr(shaping_profile_eir_waddr2),
    .shaping_profile_eir_wdata(shaping_profile_eir_wdata2),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd2),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr2),
       
	.fill_tb_dst_rd(fill_tb_dst_rd2),  
	.fill_tb_dst_raddr(fill_tb_dst_raddr2),
    .fill_tb_dst_wr(fill_tb_dst_wr2),
    .fill_tb_dst_waddr(fill_tb_dst_waddr2),
    .fill_tb_dst_wdata(fill_tb_dst_wdata2),


    .deficit_counter_wr(deficit_counter_wr2),
    .deficit_counter_waddr(deficit_counter_waddr2),
    .deficit_counter_wdata(deficit_counter_wdata2),
    .deficit_counter_raddr(deficit_counter_raddr2),
    .deficit_counter_rdata(deficit_counter_rdata2),

    .token_bucket_wr(token_bucket_wr2),
    .token_bucket_waddr(token_bucket_waddr2),
    .token_bucket_wdata(token_bucket_wdata2),
    .token_bucket_raddr(token_bucket_raddr2),
    .token_bucket_rdata(token_bucket_rdata2),

    .eir_tb_wr(eir_tb_wr2),
    .eir_tb_waddr(eir_tb_waddr2),
    .eir_tb_wdata(eir_tb_wdata2),
    .eir_tb_raddr(eir_tb_raddr2),
    .eir_tb_rdata(eir_tb_rdata2),

    .event_fifo_wr(event_fifo_wr2),
    .event_fifo_waddr(event_fifo_waddr2),
    .event_fifo_wdata(event_fifo_wdata2),
    .event_fifo_raddr(event_fifo_raddr2),
    .event_fifo_rdata(event_fifo_rdata2),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr02),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr02),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata02),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr02),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata02),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr12),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr12),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata12),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr12),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata12),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr22),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr22),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata22),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr22),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata22),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr32),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr32),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata32),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr32),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata32),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr42),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr42),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata42),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr42),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata42),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr52),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr52),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata52),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr52),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata52),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr62),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr62),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata62),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr62),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata62),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr72),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr72),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata72),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr72),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata72),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr02),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr02),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata02),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr02),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata02),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr12),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr12),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata12),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr12),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata12),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr22),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr22),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata22),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr22),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata22),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr32),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr32),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata32),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr32),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata32),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr42),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr42),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata42),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr42),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata42),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr52),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr52),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata52),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr52),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata52),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr62),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr62),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata62),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr62),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata62),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr72),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr72),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata72),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr72),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata72),

    .event_fifo_count_wr0(event_fifo_count_wr02),   
    .event_fifo_count_waddr0(event_fifo_count_waddr02),
    .event_fifo_count_wdata0(event_fifo_count_wdata02),
    .event_fifo_count_raddr0(event_fifo_count_raddr02),
    .event_fifo_count_rdata0(event_fifo_count_rdata02),

    .event_fifo_count_wr1(event_fifo_count_wr12),   
    .event_fifo_count_waddr1(event_fifo_count_waddr12),
    .event_fifo_count_wdata1(event_fifo_count_wdata12),
    .event_fifo_count_raddr1(event_fifo_count_raddr12),
    .event_fifo_count_rdata1(event_fifo_count_rdata12),

    .event_fifo_count_wr2(event_fifo_count_wr22),   
    .event_fifo_count_waddr2(event_fifo_count_waddr22),
    .event_fifo_count_wdata2(event_fifo_count_wdata22),
    .event_fifo_count_raddr2(event_fifo_count_raddr22),
    .event_fifo_count_rdata2(event_fifo_count_rdata22),

    .event_fifo_count_wr3(event_fifo_count_wr32),   
    .event_fifo_count_waddr3(event_fifo_count_waddr32),
    .event_fifo_count_wdata3(event_fifo_count_wdata32),
    .event_fifo_count_raddr3(event_fifo_count_raddr32),
    .event_fifo_count_rdata3(event_fifo_count_rdata32),

    .event_fifo_count_wr4(event_fifo_count_wr42),   
    .event_fifo_count_waddr4(event_fifo_count_waddr42),
    .event_fifo_count_wdata4(event_fifo_count_wdata42),
    .event_fifo_count_raddr4(event_fifo_count_raddr42),
    .event_fifo_count_rdata4(event_fifo_count_rdata42),

    .event_fifo_count_wr5(event_fifo_count_wr52),   
    .event_fifo_count_waddr5(event_fifo_count_waddr52),
    .event_fifo_count_wdata5(event_fifo_count_wdata52),
    .event_fifo_count_raddr5(event_fifo_count_raddr52),
    .event_fifo_count_rdata5(event_fifo_count_rdata52),

    .event_fifo_count_wr6(event_fifo_count_wr62),   
    .event_fifo_count_waddr6(event_fifo_count_waddr62),
    .event_fifo_count_wdata6(event_fifo_count_wdata62),
    .event_fifo_count_raddr6(event_fifo_count_raddr62),
    .event_fifo_count_rdata6(event_fifo_count_rdata62),

    .event_fifo_count_wr7(event_fifo_count_wr72),   
    .event_fifo_count_waddr7(event_fifo_count_waddr72),
    .event_fifo_count_wdata7(event_fifo_count_wdata72),
    .event_fifo_count_raddr7(event_fifo_count_raddr72),
    .event_fifo_count_rdata7(event_fifo_count_rdata72),

    .event_fifo_count_wr(event_fifo_count_wr2),
    .event_fifo_count_waddr(event_fifo_count_waddr2),
    .event_fifo_count_wdata(event_fifo_count_wdata2),
    .event_fifo_count_raddr(event_fifo_count_raddr2),
    .event_fifo_count_rdata(event_fifo_count_rdata2),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr2), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr2),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata2),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr2),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata2),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr2),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr2),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata2),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr2),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata2),

    .semaphore_wr(semaphore_wr2),   
    .semaphore_waddr(semaphore_waddr2),
    .semaphore_wdata(semaphore_wdata2),
    .semaphore_raddr(semaphore_raddr2),
    .semaphore_rdata(semaphore_rdata2),

    .next_qm_avail_req(next_qm_avail_req2),             
    .next_qm_avail_req_qid(next_qm_avail_req_qid2), 

    .next_qm_enq_req(tm_enq_req3),   
    .next_qm_enq_qid(tm_enq_qid3),
    .next_qm_enq_pkt_desc(tm_enq_pkt_desc3),

    .sch_deq(sch_deq_req2), 
    .sch_deq_qid(sch_deq_qid2)

);

tm_sch_ds2 u_tm_sch_ds2(
    .clk(clk),

    .deficit_counter_wr(deficit_counter_wr2),
    .deficit_counter_waddr(deficit_counter_waddr2),
    .deficit_counter_wdata(deficit_counter_wdata2),
    .deficit_counter_raddr(deficit_counter_raddr2),
    .deficit_counter_rdata(deficit_counter_rdata2),

    .token_bucket_wr(token_bucket_wr2),
    .token_bucket_waddr(token_bucket_waddr2),
    .token_bucket_wdata(token_bucket_wdata2),
    .token_bucket_raddr(token_bucket_raddr2),
    .token_bucket_rdata(token_bucket_rdata2),

    .eir_tb_wr(eir_tb_wr2),
    .eir_tb_waddr(eir_tb_waddr2),
    .eir_tb_wdata(eir_tb_wdata2),
    .eir_tb_raddr(eir_tb_raddr2),
    .eir_tb_rdata(eir_tb_rdata2),

    .event_fifo_wr(event_fifo_wr2),
    .event_fifo_waddr(event_fifo_waddr2),
    .event_fifo_wdata(event_fifo_wdata2),
    .event_fifo_raddr(event_fifo_raddr2),
    .event_fifo_rdata(event_fifo_rdata2),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr02),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr02),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata02),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr02),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata02),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr12),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr12),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata12),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr12),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata12),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr22),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr22),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata22),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr22),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata22),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr32),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr32),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata32),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr32),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata32),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr42),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr42),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata42),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr42),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata42),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr52),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr52),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata52),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr52),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata52),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr62),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr62),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata62),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr62),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata62),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr72),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr72),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata72),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr72),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata72),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr02),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr02),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata02),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr02),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata02),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr12),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr12),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata12),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr12),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata12),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr22),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr22),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata22),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr22),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata22),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr32),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr32),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata32),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr32),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata32),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr42),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr42),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata42),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr42),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata42),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr52),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr52),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata52),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr52),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata52),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr62),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr62),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata62),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr62),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata62),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr72),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr72),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata72),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr72),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata72),

    .event_fifo_count_wr0(event_fifo_count_wr02),   
    .event_fifo_count_waddr0(event_fifo_count_waddr02),
    .event_fifo_count_wdata0(event_fifo_count_wdata02),
    .event_fifo_count_raddr0(event_fifo_count_raddr02),
    .event_fifo_count_rdata0(event_fifo_count_rdata02),

    .event_fifo_count_wr1(event_fifo_count_wr12),   
    .event_fifo_count_waddr1(event_fifo_count_waddr12),
    .event_fifo_count_wdata1(event_fifo_count_wdata12),
    .event_fifo_count_raddr1(event_fifo_count_raddr12),
    .event_fifo_count_rdata1(event_fifo_count_rdata12),

    .event_fifo_count_wr2(event_fifo_count_wr22),   
    .event_fifo_count_waddr2(event_fifo_count_waddr22),
    .event_fifo_count_wdata2(event_fifo_count_wdata22),
    .event_fifo_count_raddr2(event_fifo_count_raddr22),
    .event_fifo_count_rdata2(event_fifo_count_rdata22),

    .event_fifo_count_wr3(event_fifo_count_wr32),   
    .event_fifo_count_waddr3(event_fifo_count_waddr32),
    .event_fifo_count_wdata3(event_fifo_count_wdata32),
    .event_fifo_count_raddr3(event_fifo_count_raddr32),
    .event_fifo_count_rdata3(event_fifo_count_rdata32),

    .event_fifo_count_wr4(event_fifo_count_wr42),   
    .event_fifo_count_waddr4(event_fifo_count_waddr42),
    .event_fifo_count_wdata4(event_fifo_count_wdata42),
    .event_fifo_count_raddr4(event_fifo_count_raddr42),
    .event_fifo_count_rdata4(event_fifo_count_rdata42),

    .event_fifo_count_wr5(event_fifo_count_wr52),   
    .event_fifo_count_waddr5(event_fifo_count_waddr52),
    .event_fifo_count_wdata5(event_fifo_count_wdata52),
    .event_fifo_count_raddr5(event_fifo_count_raddr52),
    .event_fifo_count_rdata5(event_fifo_count_rdata52),

    .event_fifo_count_wr6(event_fifo_count_wr62),   
    .event_fifo_count_waddr6(event_fifo_count_waddr62),
    .event_fifo_count_wdata6(event_fifo_count_wdata62),
    .event_fifo_count_raddr6(event_fifo_count_raddr62),
    .event_fifo_count_rdata6(event_fifo_count_rdata62),

    .event_fifo_count_wr7(event_fifo_count_wr72),   
    .event_fifo_count_waddr7(event_fifo_count_waddr72),
    .event_fifo_count_wdata7(event_fifo_count_wdata72),
    .event_fifo_count_raddr7(event_fifo_count_raddr72),
    .event_fifo_count_rdata7(event_fifo_count_rdata72),

    .event_fifo_count_wr(event_fifo_count_wr2),
    .event_fifo_count_waddr(event_fifo_count_waddr2),
    .event_fifo_count_wdata(event_fifo_count_wdata2),
    .event_fifo_count_raddr(event_fifo_count_raddr2),
    .event_fifo_count_rdata(event_fifo_count_rdata2),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr2), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr2),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata2),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr2),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata2),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr2),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr2),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata2),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr2),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata2),

	.semaphore_wr(semaphore_wr2),   
	 .semaphore_waddr(semaphore_waddr2),
	 .semaphore_wdata(semaphore_wdata2),
	 .semaphore_raddr(semaphore_raddr2),
	 .semaphore_rdata(semaphore_rdata2)


);

tm_sch_mem2 u_tm_sch_mem2(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[2]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_queue_profile(reg_ms_queue_profile[2]),
    .reg_ms_wdrr_quantum(reg_ms_wdrr_quantum[2]),
    .reg_ms_shaping_profile_cir(reg_ms_shaping_profile_cir[2]),
    .reg_ms_shaping_profile_eir(reg_ms_shaping_profile_eir[2]),
    .reg_ms_wdrr_sch_ctrl(reg_ms_wdrr_sch_ctrl[2]),
    .reg_ms_fill_tb_dst(reg_ms_fill_tb_dst[2]),

    .queue_profile_rd(queue_profile_rd2), 
    .queue_profile_raddr(queue_profile_raddr2),

    .wdrr_quantum_rd(wdrr_quantum_rd2),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr2),

    .shaping_profile_cir_rd(shaping_profile_cir_rd2),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr2),
    .shaping_profile_cir_wr(shaping_profile_cir_wr2),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr2),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata2),

    .shaping_profile_eir_rd(shaping_profile_eir_rd2),
    .shaping_profile_eir_raddr(shaping_profile_eir_raddr2),
    .shaping_profile_eir_wr(shaping_profile_eir_wr2),
    .shaping_profile_eir_waddr(shaping_profile_eir_waddr2),
    .shaping_profile_eir_wdata(shaping_profile_eir_wdata2),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd2),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr2), 
     
    .fill_tb_dst_rd(fill_tb_dst_rd2),  
    .fill_tb_dst_raddr(fill_tb_dst_raddr2), 
    .fill_tb_dst_wr(fill_tb_dst_wr2),
    .fill_tb_dst_waddr(fill_tb_dst_waddr2),
    .fill_tb_dst_wdata(fill_tb_dst_wdata2),
     
    // outputs


    .queue_profile_mem_ack(queue_profile_mem_ack[2]), 
    .queue_profile_mem_rdata(queue_profile_mem_rdata[2]),

    .wdrr_quantum_mem_ack(wdrr_quantum_mem_ack[2]),   
    .wdrr_quantum_mem_rdata(wdrr_quantum_mem_rdata[2]),

    .shaping_profile_cir_mem_ack(shaping_profile_cir_mem_ack[2]),
    .shaping_profile_cir_mem_rdata(shaping_profile_cir_mem_rdata[2]),

    .shaping_profile_eir_mem_ack(shaping_profile_eir_mem_ack[2]),
    .shaping_profile_eir_mem_rdata(shaping_profile_eir_mem_rdata[2]),

    .wdrr_sch_ctrl_mem_ack(wdrr_sch_ctrl_mem_ack[2]),  
    .wdrr_sch_ctrl_mem_rdata(wdrr_sch_ctrl_mem_rdata[2]),

	.fill_tb_dst_mem_ack(fill_tb_dst_mem_ack[2]),  
	.fill_tb_dst_mem_rdata(fill_tb_dst_mem_rdata[2]),

    .queue_profile_ack(queue_profile_ack2), 
    .queue_profile_rdata(queue_profile_rdata2),

    .wdrr_quantum_ack(wdrr_quantum_ack2),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata2),

    .shaping_profile_cir_ack(shaping_profile_cir_ack2),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata2),

	.shaping_profile_eir_ack(shaping_profile_eir_ack2),
	.shaping_profile_eir_rdata(shaping_profile_eir_rdata2),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack2),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata2),

    .fill_tb_dst_ack(fill_tb_dst_ack2),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata2)

);

tm_sch_pri_mem2 u_tm_sch_pri_mem2(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[2]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_pri_sch_ctrl(reg_ms_pri_sch_ctrl[2]),

    .pri_sch_ctrl0_rd(pri_sch_ctrl20_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl20_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl21_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl21_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl22_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl22_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl23_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl23_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl24_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl24_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl25_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl25_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl26_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl26_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl27_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl27_raddr),

    // outputs

    .pri_sch_ctrl_mem_ack(pri_sch_ctrl_mem_ack[2]),   
    .pri_sch_ctrl_mem_rdata(pri_sch_ctrl_mem_rdata[2]),

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr2),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr2),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata2),

    .pri_sch_ctrl0_ack(pri_sch_ctrl20_ack),   
    .pri_sch_ctrl0_rdata(pri_sch_ctrl20_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl21_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl21_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl22_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl22_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl23_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl23_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl24_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl24_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl25_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl25_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl26_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl26_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl27_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl27_rdata)
);


// -------------------- level 3 ------------------------------------
tm_qm_1to3 #(`FOURTH_LVL_QUEUE_ID_NBITS) u_tm_qm_1to3_3(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[3]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .alpha(alpha),

    .enq_req(tm_enq_req3),   
    .enq_qid(tm_enq_qid3),   
    .enq_pkt_desc(tm_enq_pkt_desc3),    

    .deq_req(sch_deq_req3),    
    .deq_qid(sch_deq_qid3),

    .next_qm_avail_req(next_qm_avail_req2),             
    .next_qm_avail_req_qid(next_qm_avail_req_qid2), 
            
    .bm_tm_bp(bm_tm_bp),  

    // outputs

    .head_wr(head_wr3),
    .head_raddr(head_raddr3),
    .head_waddr(head_waddr3),
    .head_wdata(head_wdata3),
    .head_rdata(head_rdata3),

    .tail_wr(tail_wr3),
    .tail_raddr(tail_raddr3),
    .tail_waddr(tail_waddr3),
    .tail_wdata(tail_wdata3),
    .tail_rdata(tail_rdata3),

    .depth_wr(depth_wr3),
    .depth_raddr(depth_raddr3),
    .depth_waddr(depth_waddr3),
    .depth_wdata(depth_wdata3),
    .depth_rdata(depth_rdata3),

    .depth1_wr(depth1_wr3),
    .depth1_raddr(depth1_raddr3),
    .depth1_waddr(depth1_waddr3),
    .depth1_wdata(depth1_wdata3),
    .depth1_rdata(depth1_rdata3),

    .ll_wr(ll_wr3),
    .ll_raddr(ll_raddr3),
    .ll_waddr(ll_waddr3),
    .ll_wdata(ll_wdata3),
    .ll_rdata(ll_rdata3),

    .pkt_desc_wr(pkt_desc_wr3),
    .pkt_desc_raddr(pkt_desc_raddr3),
    .pkt_desc_waddr(pkt_desc_waddr3),
    .pkt_desc_wdata(pkt_desc_wdata3),
    .pkt_desc_rdata(pkt_desc_rdata3),

    .next_qm_avail_ack(next_qm_avail_ack2),             
    .next_qm_available(next_qm_available2),     

    .src_queue_available(next_qm_enq_src_available2), 
    .dst_queue_available(next_qm_enq_dst_available2), 
      
    .enq_ack(active_enq_ack3),   
    .enq_ack_qid(active_enq_ack_qid3),    
    .enq_ack_dst_port(active_enq_ack_dst_port3),    
    .enq_to_empty(active_enq_to_empty3),    

    .deq_depth_ack(sch_deq_depth_ack3),
    .deq_depth_from_emptyp2(sch_deq_depth_from_emptyp23),
	   
    .deq_ack(sch_deq_ack3),
    .deq_ack_qid(sch_deq_ack_qid3),
    .deq_pkt_desc(sch_deq_pkt_desc3)

);

tm_qm_ds3 u_tm_qm_ds3(
    .clk(clk),

    .head_wr(head_wr3),
    .head_raddr(head_raddr3),
    .head_waddr(head_waddr3),
    .head_wdata(head_wdata3),
    .head_rdata(head_rdata3),

    .tail_wr(tail_wr3),
    .tail_raddr(tail_raddr3),
    .tail_waddr(tail_waddr3),
    .tail_wdata(tail_wdata3),
    .tail_rdata(tail_rdata3),

    .depth_wr(depth_wr3),
    .depth_raddr(depth_raddr3),
    .depth_waddr(depth_waddr3),
    .depth_wdata(depth_wdata3),
    .depth_rdata(depth_rdata3),

    .depth1_wr(depth1_wr3),
    .depth1_raddr(depth1_raddr3),
    .depth1_waddr(depth1_waddr3),
    .depth1_wdata(depth1_wdata3),
    .depth1_rdata(depth1_rdata3),

    .ll_wr(ll_wr3),
    .ll_raddr(ll_raddr3),
    .ll_waddr(ll_waddr3),
    .ll_wdata(ll_wdata3),
    .ll_rdata(ll_rdata3),

    .pkt_desc_wr(pkt_desc_wr3),
    .pkt_desc_raddr(pkt_desc_raddr3),
    .pkt_desc_waddr(pkt_desc_waddr3),
    .pkt_desc_wdata(pkt_desc_wdata3),
    .pkt_desc_rdata(pkt_desc_rdata3)

);

tm_sch #(`FOURTH_LVL_QUEUE_ID_NBITS, `FOURTH_LVL_SCH_ID_NBITS, `FOURTH_LVL_QUEUE_PROFILE_NBITS) u_tm_sch_3(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[3]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .qm_enq_ack(active_enq_ack3),   
    .qm_enq_ack_qid(active_enq_ack_qid3), 
    .qm_enq_ack_dst_port(active_enq_ack_dst_port3),    
    .qm_enq_to_empty(active_enq_to_empty3), 

    .sch_deq_depth_ack(sch_deq_depth_ack3),
    .sch_deq_depth_from_emptyp2(sch_deq_depth_from_emptyp23),  

    .sch_deq_ack(sch_deq_ack3),
    .sch_deq_ack_qid(sch_deq_ack_qid3),
    .sch_deq_pkt_desc(sch_deq_pkt_desc3),

    .next_qm_avail_ack(next_qm_avail_req3),               
    .next_qm_available(1'b1),   

    .next_qm_enq_dst_available({(`NUM_OF_PORTS){1'b1}}),  

	.pri_sch_ctrl_wr(pri_sch_ctrl_wr3),
	.pri_sch_ctrl_waddr(pri_sch_ctrl_waddr3),
	.pri_sch_ctrl_wdata(pri_sch_ctrl_wdata3),

    .pri_sch_ctrl0_ack(pri_sch_ctrl30_ack), 
    .pri_sch_ctrl0_rdata(pri_sch_ctrl30_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl31_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl31_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl32_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl32_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl33_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl33_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl34_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl34_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl35_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl35_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl36_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl36_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl37_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl37_rdata),

    .queue_profile_ack(queue_profile_ack3), 
    .queue_profile_rdata(queue_profile_rdata3),

    .wdrr_quantum_ack(wdrr_quantum_ack3),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata3),

    .shaping_profile_cir_ack(shaping_profile_cir_ack3),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata3),

	.shaping_profile_eir_ack(shaping_profile_eir_ack3),
	.shaping_profile_eir_rdata(shaping_profile_eir_rdata3),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack3),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata3),

    .fill_tb_dst_ack(fill_tb_dst_ack3),  
    .fill_tb_dst_rdata(fill_tb_dst_rdata3),

    // outputs

    .pri_sch_ctrl0_rd(pri_sch_ctrl30_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl30_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl31_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl31_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl32_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl32_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl33_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl33_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl34_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl34_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl35_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl35_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl36_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl36_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl37_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl37_raddr),

    .queue_profile_rd(queue_profile_rd3), 
    .queue_profile_raddr(queue_profile_raddr3),

    .wdrr_quantum_rd(wdrr_quantum_rd3),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr3),

    .shaping_profile_cir_rd(shaping_profile_cir_rd3),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr3),
    .shaping_profile_cir_wr(shaping_profile_cir_wr3),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr3),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata3),

    .shaping_profile_eir_rd(shaping_profile_eir_rd3),
    .shaping_profile_eir_raddr(shaping_profile_eir_raddr3),
    .shaping_profile_eir_wr(shaping_profile_eir_wr3),
    .shaping_profile_eir_waddr(shaping_profile_eir_waddr3),
    .shaping_profile_eir_wdata(shaping_profile_eir_wdata3),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd3),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr3),
       
    .fill_tb_dst_rd(fill_tb_dst_rd3),  
    .fill_tb_dst_raddr(fill_tb_dst_raddr3),
    .fill_tb_dst_wr(fill_tb_dst_wr3),
    .fill_tb_dst_waddr(fill_tb_dst_waddr3),
    .fill_tb_dst_wdata(fill_tb_dst_wdata3),
       

    .deficit_counter_wr(deficit_counter_wr3),
    .deficit_counter_waddr(deficit_counter_waddr3),
    .deficit_counter_wdata(deficit_counter_wdata3),
    .deficit_counter_raddr(deficit_counter_raddr3),
    .deficit_counter_rdata(deficit_counter_rdata3),

    .token_bucket_wr(token_bucket_wr3),
    .token_bucket_waddr(token_bucket_waddr3),
    .token_bucket_wdata(token_bucket_wdata3),
    .token_bucket_raddr(token_bucket_raddr3),
    .token_bucket_rdata(token_bucket_rdata3),

    .eir_tb_wr(eir_tb_wr3),
    .eir_tb_waddr(eir_tb_waddr3),
    .eir_tb_wdata(eir_tb_wdata3),
    .eir_tb_raddr(eir_tb_raddr3),
    .eir_tb_rdata(eir_tb_rdata3),

    .event_fifo_wr(event_fifo_wr3),
    .event_fifo_waddr(event_fifo_waddr3),
    .event_fifo_wdata(event_fifo_wdata3),
    .event_fifo_raddr(event_fifo_raddr3),
    .event_fifo_rdata(event_fifo_rdata3),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr03),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr03),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata03),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr03),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata03),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr13),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr13),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata13),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr13),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata13),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr23),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr23),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata23),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr23),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata23),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr33),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr33),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata33),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr33),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata33),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr43),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr43),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata43),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr43),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata43),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr53),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr53),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata53),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr53),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata53),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr63),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr63),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata63),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr63),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata63),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr73),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr73),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata73),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr73),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata73),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr03),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr03),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata03),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr03),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata03),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr13),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr13),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata13),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr13),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata13),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr23),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr23),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata23),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr23),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata23),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr33),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr33),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata33),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr33),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata33),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr43),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr43),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata43),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr43),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata43),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr53),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr53),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata53),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr53),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata53),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr63),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr63),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata63),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr63),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata63),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr73),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr73),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata73),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr73),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata73),

    .event_fifo_count_wr0(event_fifo_count_wr03),   
    .event_fifo_count_waddr0(event_fifo_count_waddr03),
    .event_fifo_count_wdata0(event_fifo_count_wdata03),
    .event_fifo_count_raddr0(event_fifo_count_raddr03),
    .event_fifo_count_rdata0(event_fifo_count_rdata03),

    .event_fifo_count_wr1(event_fifo_count_wr13),   
    .event_fifo_count_waddr1(event_fifo_count_waddr13),
    .event_fifo_count_wdata1(event_fifo_count_wdata13),
    .event_fifo_count_raddr1(event_fifo_count_raddr13),
    .event_fifo_count_rdata1(event_fifo_count_rdata13),

    .event_fifo_count_wr2(event_fifo_count_wr23),   
    .event_fifo_count_waddr2(event_fifo_count_waddr23),
    .event_fifo_count_wdata2(event_fifo_count_wdata23),
    .event_fifo_count_raddr2(event_fifo_count_raddr23),
    .event_fifo_count_rdata2(event_fifo_count_rdata23),

    .event_fifo_count_wr3(event_fifo_count_wr33),   
    .event_fifo_count_waddr3(event_fifo_count_waddr33),
    .event_fifo_count_wdata3(event_fifo_count_wdata33),
    .event_fifo_count_raddr3(event_fifo_count_raddr33),
    .event_fifo_count_rdata3(event_fifo_count_rdata33),

    .event_fifo_count_wr4(event_fifo_count_wr43),   
    .event_fifo_count_waddr4(event_fifo_count_waddr43),
    .event_fifo_count_wdata4(event_fifo_count_wdata43),
    .event_fifo_count_raddr4(event_fifo_count_raddr43),
    .event_fifo_count_rdata4(event_fifo_count_rdata43),

    .event_fifo_count_wr5(event_fifo_count_wr53),   
    .event_fifo_count_waddr5(event_fifo_count_waddr53),
    .event_fifo_count_wdata5(event_fifo_count_wdata53),
    .event_fifo_count_raddr5(event_fifo_count_raddr53),
    .event_fifo_count_rdata5(event_fifo_count_rdata53),

    .event_fifo_count_wr6(event_fifo_count_wr63),   
    .event_fifo_count_waddr6(event_fifo_count_waddr63),
    .event_fifo_count_wdata6(event_fifo_count_wdata63),
    .event_fifo_count_raddr6(event_fifo_count_raddr63),
    .event_fifo_count_rdata6(event_fifo_count_rdata63),

    .event_fifo_count_wr7(event_fifo_count_wr73),   
    .event_fifo_count_waddr7(event_fifo_count_waddr73),
    .event_fifo_count_wdata7(event_fifo_count_wdata73),
    .event_fifo_count_raddr7(event_fifo_count_raddr73),
    .event_fifo_count_rdata7(event_fifo_count_rdata73),

    .event_fifo_count_wr(event_fifo_count_wr3),
    .event_fifo_count_waddr(event_fifo_count_waddr3),
    .event_fifo_count_wdata(event_fifo_count_wdata3),
    .event_fifo_count_raddr(event_fifo_count_raddr3),
    .event_fifo_count_rdata(event_fifo_count_rdata3),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr3), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr3),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata3),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr3),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata3),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr3),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr3),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata3),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr3),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata3),

	.semaphore_wr(semaphore_wr3),   
	 .semaphore_waddr(semaphore_waddr3),
	 .semaphore_wdata(semaphore_wdata3),
	 .semaphore_raddr(semaphore_raddr3),
	 .semaphore_rdata(semaphore_rdata3),


    .next_qm_avail_req(next_qm_avail_req3),               
    .next_qm_avail_req_qid(),   

    .next_qm_enq_req(next_qm_enq_req3),   
    .next_qm_enq_qid(),
    .next_qm_enq_pkt_desc(next_qm_enq_pkt_desc3),

    .sch_deq(sch_deq_req3), 
    .sch_deq_qid(sch_deq_qid3)

);

tm_sch_ds3 u_tm_sch_ds3(
    .clk(clk),

    .deficit_counter_wr(deficit_counter_wr3),
    .deficit_counter_waddr(deficit_counter_waddr3),
    .deficit_counter_wdata(deficit_counter_wdata3),
    .deficit_counter_raddr(deficit_counter_raddr3),
    .deficit_counter_rdata(deficit_counter_rdata3),

    .token_bucket_wr(token_bucket_wr3),
    .token_bucket_waddr(token_bucket_waddr3),
    .token_bucket_wdata(token_bucket_wdata3),
    .token_bucket_raddr(token_bucket_raddr3),
    .token_bucket_rdata(token_bucket_rdata3),

    .eir_tb_wr(eir_tb_wr3),
    .eir_tb_waddr(eir_tb_waddr3),
    .eir_tb_wdata(eir_tb_wdata3),
    .eir_tb_raddr(eir_tb_raddr3),
    .eir_tb_rdata(eir_tb_rdata3),

    .event_fifo_wr(event_fifo_wr3),
    .event_fifo_waddr(event_fifo_waddr3),
    .event_fifo_wdata(event_fifo_wdata3),
    .event_fifo_raddr(event_fifo_raddr3),
    .event_fifo_rdata(event_fifo_rdata3),

    .event_fifo_rd_ptr_wr0(event_fifo_rd_ptr_wr03),   
    .event_fifo_rd_ptr_waddr0(event_fifo_rd_ptr_waddr03),
    .event_fifo_rd_ptr_wdata0(event_fifo_rd_ptr_wdata03),
    .event_fifo_rd_ptr_raddr0(event_fifo_rd_ptr_raddr03),
    .event_fifo_rd_ptr_rdata0(event_fifo_rd_ptr_rdata03),

    .event_fifo_rd_ptr_wr1(event_fifo_rd_ptr_wr13),   
    .event_fifo_rd_ptr_waddr1(event_fifo_rd_ptr_waddr13),
    .event_fifo_rd_ptr_wdata1(event_fifo_rd_ptr_wdata13),
    .event_fifo_rd_ptr_raddr1(event_fifo_rd_ptr_raddr13),
    .event_fifo_rd_ptr_rdata1(event_fifo_rd_ptr_rdata13),

    .event_fifo_rd_ptr_wr2(event_fifo_rd_ptr_wr23),   
    .event_fifo_rd_ptr_waddr2(event_fifo_rd_ptr_waddr23),
    .event_fifo_rd_ptr_wdata2(event_fifo_rd_ptr_wdata23),
    .event_fifo_rd_ptr_raddr2(event_fifo_rd_ptr_raddr23),
    .event_fifo_rd_ptr_rdata2(event_fifo_rd_ptr_rdata23),

    .event_fifo_rd_ptr_wr3(event_fifo_rd_ptr_wr33),   
    .event_fifo_rd_ptr_waddr3(event_fifo_rd_ptr_waddr33),
    .event_fifo_rd_ptr_wdata3(event_fifo_rd_ptr_wdata33),
    .event_fifo_rd_ptr_raddr3(event_fifo_rd_ptr_raddr33),
    .event_fifo_rd_ptr_rdata3(event_fifo_rd_ptr_rdata33),

    .event_fifo_rd_ptr_wr4(event_fifo_rd_ptr_wr43),   
    .event_fifo_rd_ptr_waddr4(event_fifo_rd_ptr_waddr43),
    .event_fifo_rd_ptr_wdata4(event_fifo_rd_ptr_wdata43),
    .event_fifo_rd_ptr_raddr4(event_fifo_rd_ptr_raddr43),
    .event_fifo_rd_ptr_rdata4(event_fifo_rd_ptr_rdata43),

    .event_fifo_rd_ptr_wr5(event_fifo_rd_ptr_wr53),   
    .event_fifo_rd_ptr_waddr5(event_fifo_rd_ptr_waddr53),
    .event_fifo_rd_ptr_wdata5(event_fifo_rd_ptr_wdata53),
    .event_fifo_rd_ptr_raddr5(event_fifo_rd_ptr_raddr53),
    .event_fifo_rd_ptr_rdata5(event_fifo_rd_ptr_rdata53),

    .event_fifo_rd_ptr_wr6(event_fifo_rd_ptr_wr63),   
    .event_fifo_rd_ptr_waddr6(event_fifo_rd_ptr_waddr63),
    .event_fifo_rd_ptr_wdata6(event_fifo_rd_ptr_wdata63),
    .event_fifo_rd_ptr_raddr6(event_fifo_rd_ptr_raddr63),
    .event_fifo_rd_ptr_rdata6(event_fifo_rd_ptr_rdata63),

    .event_fifo_rd_ptr_wr7(event_fifo_rd_ptr_wr73),   
    .event_fifo_rd_ptr_waddr7(event_fifo_rd_ptr_waddr73),
    .event_fifo_rd_ptr_wdata7(event_fifo_rd_ptr_wdata73),
    .event_fifo_rd_ptr_raddr7(event_fifo_rd_ptr_raddr73),
    .event_fifo_rd_ptr_rdata7(event_fifo_rd_ptr_rdata73),

    .event_fifo_wr_ptr_wr0(event_fifo_wr_ptr_wr03),   
    .event_fifo_wr_ptr_waddr0(event_fifo_wr_ptr_waddr03),
    .event_fifo_wr_ptr_wdata0(event_fifo_wr_ptr_wdata03),
    .event_fifo_wr_ptr_raddr0(event_fifo_wr_ptr_raddr03),
    .event_fifo_wr_ptr_rdata0(event_fifo_wr_ptr_rdata03),

    .event_fifo_wr_ptr_wr1(event_fifo_wr_ptr_wr13),   
    .event_fifo_wr_ptr_waddr1(event_fifo_wr_ptr_waddr13),
    .event_fifo_wr_ptr_wdata1(event_fifo_wr_ptr_wdata13),
    .event_fifo_wr_ptr_raddr1(event_fifo_wr_ptr_raddr13),
    .event_fifo_wr_ptr_rdata1(event_fifo_wr_ptr_rdata13),

    .event_fifo_wr_ptr_wr2(event_fifo_wr_ptr_wr23),   
    .event_fifo_wr_ptr_waddr2(event_fifo_wr_ptr_waddr23),
    .event_fifo_wr_ptr_wdata2(event_fifo_wr_ptr_wdata23),
    .event_fifo_wr_ptr_raddr2(event_fifo_wr_ptr_raddr23),
    .event_fifo_wr_ptr_rdata2(event_fifo_wr_ptr_rdata23),

    .event_fifo_wr_ptr_wr3(event_fifo_wr_ptr_wr33),   
    .event_fifo_wr_ptr_waddr3(event_fifo_wr_ptr_waddr33),
    .event_fifo_wr_ptr_wdata3(event_fifo_wr_ptr_wdata33),
    .event_fifo_wr_ptr_raddr3(event_fifo_wr_ptr_raddr33),
    .event_fifo_wr_ptr_rdata3(event_fifo_wr_ptr_rdata33),

    .event_fifo_wr_ptr_wr4(event_fifo_wr_ptr_wr43),   
    .event_fifo_wr_ptr_waddr4(event_fifo_wr_ptr_waddr43),
    .event_fifo_wr_ptr_wdata4(event_fifo_wr_ptr_wdata43),
    .event_fifo_wr_ptr_raddr4(event_fifo_wr_ptr_raddr43),
    .event_fifo_wr_ptr_rdata4(event_fifo_wr_ptr_rdata43),

    .event_fifo_wr_ptr_wr5(event_fifo_wr_ptr_wr53),   
    .event_fifo_wr_ptr_waddr5(event_fifo_wr_ptr_waddr53),
    .event_fifo_wr_ptr_wdata5(event_fifo_wr_ptr_wdata53),
    .event_fifo_wr_ptr_raddr5(event_fifo_wr_ptr_raddr53),
    .event_fifo_wr_ptr_rdata5(event_fifo_wr_ptr_rdata53),

    .event_fifo_wr_ptr_wr6(event_fifo_wr_ptr_wr63),   
    .event_fifo_wr_ptr_waddr6(event_fifo_wr_ptr_waddr63),
    .event_fifo_wr_ptr_wdata6(event_fifo_wr_ptr_wdata63),
    .event_fifo_wr_ptr_raddr6(event_fifo_wr_ptr_raddr63),
    .event_fifo_wr_ptr_rdata6(event_fifo_wr_ptr_rdata63),

    .event_fifo_wr_ptr_wr7(event_fifo_wr_ptr_wr73),   
    .event_fifo_wr_ptr_waddr7(event_fifo_wr_ptr_waddr73),
    .event_fifo_wr_ptr_wdata7(event_fifo_wr_ptr_wdata73),
    .event_fifo_wr_ptr_raddr7(event_fifo_wr_ptr_raddr73),
    .event_fifo_wr_ptr_rdata7(event_fifo_wr_ptr_rdata73),

    .event_fifo_count_wr0(event_fifo_count_wr03),   
    .event_fifo_count_waddr0(event_fifo_count_waddr03),
    .event_fifo_count_wdata0(event_fifo_count_wdata03),
    .event_fifo_count_raddr0(event_fifo_count_raddr03),
    .event_fifo_count_rdata0(event_fifo_count_rdata03),

    .event_fifo_count_wr1(event_fifo_count_wr13),   
    .event_fifo_count_waddr1(event_fifo_count_waddr13),
    .event_fifo_count_wdata1(event_fifo_count_wdata13),
    .event_fifo_count_raddr1(event_fifo_count_raddr13),
    .event_fifo_count_rdata1(event_fifo_count_rdata13),

    .event_fifo_count_wr2(event_fifo_count_wr23),   
    .event_fifo_count_waddr2(event_fifo_count_waddr23),
    .event_fifo_count_wdata2(event_fifo_count_wdata23),
    .event_fifo_count_raddr2(event_fifo_count_raddr23),
    .event_fifo_count_rdata2(event_fifo_count_rdata23),

    .event_fifo_count_wr3(event_fifo_count_wr33),   
    .event_fifo_count_waddr3(event_fifo_count_waddr33),
    .event_fifo_count_wdata3(event_fifo_count_wdata33),
    .event_fifo_count_raddr3(event_fifo_count_raddr33),
    .event_fifo_count_rdata3(event_fifo_count_rdata33),

    .event_fifo_count_wr4(event_fifo_count_wr43),   
    .event_fifo_count_waddr4(event_fifo_count_waddr43),
    .event_fifo_count_wdata4(event_fifo_count_wdata43),
    .event_fifo_count_raddr4(event_fifo_count_raddr43),
    .event_fifo_count_rdata4(event_fifo_count_rdata43),

    .event_fifo_count_wr5(event_fifo_count_wr53),   
    .event_fifo_count_waddr5(event_fifo_count_waddr53),
    .event_fifo_count_wdata5(event_fifo_count_wdata53),
    .event_fifo_count_raddr5(event_fifo_count_raddr53),
    .event_fifo_count_rdata5(event_fifo_count_rdata53),

    .event_fifo_count_wr6(event_fifo_count_wr63),   
    .event_fifo_count_waddr6(event_fifo_count_waddr63),
    .event_fifo_count_wdata6(event_fifo_count_wdata63),
    .event_fifo_count_raddr6(event_fifo_count_raddr63),
    .event_fifo_count_rdata6(event_fifo_count_rdata63),

    .event_fifo_count_wr7(event_fifo_count_wr73),   
    .event_fifo_count_waddr7(event_fifo_count_waddr73),
    .event_fifo_count_wdata7(event_fifo_count_wdata73),
    .event_fifo_count_raddr7(event_fifo_count_raddr73),
    .event_fifo_count_rdata7(event_fifo_count_rdata73),

    .event_fifo_count_wr(event_fifo_count_wr3),
    .event_fifo_count_waddr(event_fifo_count_waddr3),
    .event_fifo_count_wdata(event_fifo_count_wdata3),
    .event_fifo_count_raddr(event_fifo_count_raddr3),
    .event_fifo_count_rdata(event_fifo_count_rdata3),

    .event_fifo_f1_count_wr(event_fifo_f1_count_wr3), 
    .event_fifo_f1_count_waddr(event_fifo_f1_count_waddr3),
    .event_fifo_f1_count_wdata(event_fifo_f1_count_wdata3),
    .event_fifo_f1_count_raddr(event_fifo_f1_count_raddr3),
    .event_fifo_f1_count_rdata(event_fifo_f1_count_rdata3),

    .wdrr_sch_tqna_wr(wdrr_sch_tqna_wr3),   
    .wdrr_sch_tqna_waddr(wdrr_sch_tqna_waddr3),
    .wdrr_sch_tqna_wdata(wdrr_sch_tqna_wdata3),
    .wdrr_sch_tqna_raddr(wdrr_sch_tqna_raddr3),
    .wdrr_sch_tqna_rdata(wdrr_sch_tqna_rdata3),

	.semaphore_wr(semaphore_wr3),   
	  .semaphore_waddr(semaphore_waddr3),
	  .semaphore_wdata(semaphore_wdata3),
	  .semaphore_raddr(semaphore_raddr3),
	  .semaphore_rdata(semaphore_rdata3)


);

tm_sch_mem3 u_tm_sch_mem3(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[3]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_queue_profile(reg_ms_queue_profile[3]),
    .reg_ms_wdrr_quantum(reg_ms_wdrr_quantum[3]),
    .reg_ms_shaping_profile_cir(reg_ms_shaping_profile_cir[3]),
    .reg_ms_shaping_profile_eir(reg_ms_shaping_profile_eir[3]),
    .reg_ms_wdrr_sch_ctrl(reg_ms_wdrr_sch_ctrl[3]),
    .reg_ms_fill_tb_dst(reg_ms_fill_tb_dst[3]),

    .queue_profile_rd(queue_profile_rd3), 
    .queue_profile_raddr(queue_profile_raddr3),

    .wdrr_quantum_rd(wdrr_quantum_rd3),   
    .wdrr_quantum_raddr(wdrr_quantum_raddr3),

    .shaping_profile_cir_rd(shaping_profile_cir_rd3),
    .shaping_profile_cir_raddr(shaping_profile_cir_raddr3),
    .shaping_profile_cir_wr(shaping_profile_cir_wr3),
    .shaping_profile_cir_waddr(shaping_profile_cir_waddr3),
    .shaping_profile_cir_wdata(shaping_profile_cir_wdata3),

	.shaping_profile_eir_rd(shaping_profile_eir_rd3),
	.shaping_profile_eir_raddr(shaping_profile_eir_raddr3),
	.shaping_profile_eir_wr(shaping_profile_eir_wr3),
	.shaping_profile_eir_waddr(shaping_profile_eir_waddr3),
	.shaping_profile_eir_wdata(shaping_profile_eir_wdata3),

    .wdrr_sch_ctrl_rd(wdrr_sch_ctrl_rd3),  
    .wdrr_sch_ctrl_raddr(wdrr_sch_ctrl_raddr3), 
     
	.fill_tb_dst_rd(fill_tb_dst_rd3),  
	.fill_tb_dst_raddr(fill_tb_dst_raddr3), 
    .fill_tb_dst_wr(fill_tb_dst_wr3),
    .fill_tb_dst_waddr(fill_tb_dst_waddr3),
    .fill_tb_dst_wdata(fill_tb_dst_wdata3),

    // outputs


    .queue_profile_mem_ack(queue_profile_mem_ack[3]), 
    .queue_profile_mem_rdata(queue_profile_mem_rdata[3]),

    .wdrr_quantum_mem_ack(wdrr_quantum_mem_ack[3]),   
    .wdrr_quantum_mem_rdata(wdrr_quantum_mem_rdata[3]),

    .shaping_profile_cir_mem_ack(shaping_profile_cir_mem_ack[3]),
    .shaping_profile_cir_mem_rdata(shaping_profile_cir_mem_rdata[3]),

    .shaping_profile_eir_mem_ack(shaping_profile_eir_mem_ack[3]),
    .shaping_profile_eir_mem_rdata(shaping_profile_eir_mem_rdata[3]),

    .wdrr_sch_ctrl_mem_ack(wdrr_sch_ctrl_mem_ack[3]),  
    .wdrr_sch_ctrl_mem_rdata(wdrr_sch_ctrl_mem_rdata[3]),

	.fill_tb_dst_mem_ack(fill_tb_dst_mem_ack[3]),  
	.fill_tb_dst_mem_rdata(fill_tb_dst_mem_rdata[3]),

    .queue_profile_ack(queue_profile_ack3), 
    .queue_profile_rdata(queue_profile_rdata3),

    .wdrr_quantum_ack(wdrr_quantum_ack3),   
    .wdrr_quantum_rdata(wdrr_quantum_rdata3),

    .shaping_profile_cir_ack(shaping_profile_cir_ack3),
    .shaping_profile_cir_rdata(shaping_profile_cir_rdata3),

    .shaping_profile_eir_ack(shaping_profile_eir_ack3),
    .shaping_profile_eir_rdata(shaping_profile_eir_rdata3),

    .wdrr_sch_ctrl_ack(wdrr_sch_ctrl_ack3),  
    .wdrr_sch_ctrl_rdata(wdrr_sch_ctrl_rdata3),

	.fill_tb_dst_ack(fill_tb_dst_ack3),  
	.fill_tb_dst_rdata(fill_tb_dst_rdata3)

);

tm_sch_pri_mem3 u_tm_sch_pri_mem3(

    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[3]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif

    .clk_div(clk_div),

    .reg_addr(reg_addr),
    .reg_din(reg_din),
    .reg_rd(reg_rd),
    .reg_wr(reg_wr),
    .reg_ms_pri_sch_ctrl(reg_ms_pri_sch_ctrl[3]),

    .pri_sch_ctrl0_rd(pri_sch_ctrl30_rd),   
    .pri_sch_ctrl0_raddr(pri_sch_ctrl30_raddr),
    .pri_sch_ctrl1_rd(pri_sch_ctrl31_rd), 
    .pri_sch_ctrl1_raddr(pri_sch_ctrl31_raddr),
    .pri_sch_ctrl2_rd(pri_sch_ctrl32_rd), 
    .pri_sch_ctrl2_raddr(pri_sch_ctrl32_raddr),
    .pri_sch_ctrl3_rd(pri_sch_ctrl33_rd), 
    .pri_sch_ctrl3_raddr(pri_sch_ctrl33_raddr),
    .pri_sch_ctrl4_rd(pri_sch_ctrl34_rd), 
    .pri_sch_ctrl4_raddr(pri_sch_ctrl34_raddr),
    .pri_sch_ctrl5_rd(pri_sch_ctrl35_rd), 
    .pri_sch_ctrl5_raddr(pri_sch_ctrl35_raddr),
    .pri_sch_ctrl6_rd(pri_sch_ctrl36_rd), 
    .pri_sch_ctrl6_raddr(pri_sch_ctrl36_raddr),
    .pri_sch_ctrl7_rd(pri_sch_ctrl37_rd), 
    .pri_sch_ctrl7_raddr(pri_sch_ctrl37_raddr),

    // outputs

    .pri_sch_ctrl_mem_ack(pri_sch_ctrl_mem_ack[3]),
    .pri_sch_ctrl_mem_rdata(pri_sch_ctrl_mem_rdata[3]),

    .pri_sch_ctrl_wr(pri_sch_ctrl_wr3),
    .pri_sch_ctrl_waddr(pri_sch_ctrl_waddr3),
    .pri_sch_ctrl_wdata(pri_sch_ctrl_wdata3),

    .pri_sch_ctrl0_ack(pri_sch_ctrl30_ack),   
    .pri_sch_ctrl0_rdata(pri_sch_ctrl30_rdata),
    .pri_sch_ctrl1_ack(pri_sch_ctrl31_ack), 
    .pri_sch_ctrl1_rdata(pri_sch_ctrl31_rdata),
    .pri_sch_ctrl2_ack(pri_sch_ctrl32_ack), 
    .pri_sch_ctrl2_rdata(pri_sch_ctrl32_rdata),
    .pri_sch_ctrl3_ack(pri_sch_ctrl33_ack), 
    .pri_sch_ctrl3_rdata(pri_sch_ctrl33_rdata),
    .pri_sch_ctrl4_ack(pri_sch_ctrl34_ack), 
    .pri_sch_ctrl4_rdata(pri_sch_ctrl34_rdata),
    .pri_sch_ctrl5_ack(pri_sch_ctrl35_ack), 
    .pri_sch_ctrl5_rdata(pri_sch_ctrl35_rdata),
    .pri_sch_ctrl6_ack(pri_sch_ctrl36_ack), 
    .pri_sch_ctrl6_rdata(pri_sch_ctrl36_rdata),
    .pri_sch_ctrl7_ack(pri_sch_ctrl37_ack), 
    .pri_sch_ctrl7_rdata(pri_sch_ctrl37_rdata)
);

tm_pkt_desc u_tm_pkt_desc(
    .clk(clk),
`ifdef DUPLICATE_RESET
	.`RESET_SIG(`RESET_SIG_DUP[4]),
`else
	.`RESET_SIG(`RESET_SIG),
`endif             

    .rd_pkt_desc_req(next_qm_enq_req3),                 
    .rd_pkt_desc_in(next_qm_enq_pkt_desc3),               

    .wr_pkt_desc_req(asa_tm_enq_req),              
    .wr_pkt_desc_qid(asa_tm_enq_qid),              
    .wr_pkt_desc_conn_id(asa_tm_enq_conn_id),              
    .wr_pkt_desc_conn_group_id(asa_tm_enq_conn_group_id),              
    .wr_pkt_desc_port_queue_id(asa_tm_enq_port_queue_id),              
    .wr_pkt_desc(asa_tm_enq_desc),              

    // outputs

    .rd_pkt_desc_ack(tm_bm_enq_req),                  
    .rd_pkt_desc(tm_bm_enq_pkt_desc),

    .wr_pkt_desc_ack(wr_pkt_desc_ack),              
    .wr_pkt_desc_ack_qid(wr_pkt_desc_ack_qid),              
    .wr_pkt_desc_ack_conn_id(wr_pkt_desc_ack_conn_id),   
    .wr_pkt_desc_ack_conn_group_id(wr_pkt_desc_ack_conn_group_id),   
    .wr_pkt_desc_ack_port_queue_id(wr_pkt_desc_ack_port_queue_id),   
    .wr_pkt_desc_out(wr_pkt_desc_out)  

);

endmodule                           
