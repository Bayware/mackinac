//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module ecdsa(

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

input lh_ecdsa_hash_valid,
input [`LOGIC_HASH_NBITS-1:0] lh_ecdsa_hash_data,

input lh_ecdsa_valid,
input [`DATA_PATH_RANGE] lh_ecdsa_hdr_data,
input lh_ecdsa_meta_type   lh_ecdsa_meta_data,
input lh_ecdsa_sop,
input lh_ecdsa_eop,

input pp_ecdsa_ready,

output logic      ecdsa_pp_valid,
output logic      ecdsa_pp_sop,
output logic      ecdsa_pp_eop,
output logic [`DATA_PATH_RANGE] ecdsa_pp_data,
output ecdsa_pp_meta_type ecdsa_pp_meta_data,
output logic [`CHUNK_LEN_NBITS-1:0] ecdsa_pp_auth_len,

output logic ecdsa_lh_ready,

output logic ecdsa_classifier_flow_valid,
output logic [`FID_NBITS-1:0] ecdsa_classifier_fid,
output logic [`EXP_TIME_NBITS-1:0] ecdsa_classifier_flow_etime,

output logic ecdsa_classifier_topic_valid,
output logic [`TID_NBITS-1:0] ecdsa_classifier_tid,
output logic [`EXP_TIME_NBITS-1:0] ecdsa_classifier_topic_etime,

output logic ecdsa_irl_fill_tb_src_wr, 
output logic [`FLOW_VALUE_DEPTH_NBITS-1:0] ecdsa_irl_fill_tb_src_waddr,
output logic [`FILL_TB_NBITS-1:0] ecdsa_irl_fill_tb_src_wdata,

output logic ecdsa_lh_wr,
output logic [`FID_NBITS-1:0] ecdsa_lh_waddr,
output logic [`LOGIC_HASH_NBITS-1:0] ecdsa_lh_wdata,
output logic [`SERIAL_NUM_NBITS-1:0]   ecdsa_lh_sn_wdata,
output logic [`PPL_NBITS-1:0]   ecdsa_lh_ppl_wdata,

output logic ecdsa_piarb_wr,
output logic [`FID_NBITS-1:0] ecdsa_piarb_waddr,
output logic [`FLOW_PU_NBITS-1:0] ecdsa_piarb_wdata,

output logic         ecdsa_asa_fp_wr,
output logic [`FID_NBITS-1:0] ecdsa_asa_fp_waddr,				
output logic [`FLOW_POLICY2_NBITS-1:0] ecdsa_asa_fp_wdata		

);

/***************************** LOCAL VARIABLES *******************************/

logic [`REAL_TIME_NBITS-1:0] default_exp_time;

logic topic_policy_ack;
logic [`TOPIC_POLICY_NBITS-1:0] topic_policy_rdata;

logic topic_policy_rd;
logic [`TID_NBITS-1:0] topic_policy_raddr;

logic pio_ack0;
logic pio_rvalid0;
logic [`PIO_RANGE] pio_rdata0;

logic pio_ack1;
logic pio_rvalid1;
logic [`PIO_RANGE] pio_rdata1;

logic         reg_bs;
logic         reg_wr;
logic         reg_rd;
logic [`PIO_RANGE] reg_addr;
logic [`PIO_RANGE] reg_din;

logic topic_policy_mem_ack;
logic [`PIO_RANGE] topic_policy_mem_rdata;

logic reg_ms_topic_policy;

/***************************** NON REGISTERED OUTPUTS ************************/

assign pio_ack = pio_ack0|pio_ack1;
assign pio_rvalid = pio_ack0?pio_rvalid0:pio_rvalid1;
assign pio_rdata = pio_ack0?pio_rdata0:pio_rdata1;

/***************************** REGISTERED OUTPUTS ****************************/

/***************************** PROGRAM BODY **********************************/


ecdsa_process u_ecdsa_process(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

        .current_time(current_time),
        .default_exp_time(default_exp_time),

        .lh_ecdsa_hash_valid(lh_ecdsa_hash_valid),
        .lh_ecdsa_hash_data(lh_ecdsa_hash_data),

        .lh_ecdsa_valid(lh_ecdsa_valid),
        .lh_ecdsa_hdr_data(lh_ecdsa_hdr_data),
        .lh_ecdsa_meta_data(lh_ecdsa_meta_data),
        .lh_ecdsa_sop(lh_ecdsa_sop),
        .lh_ecdsa_eop(lh_ecdsa_eop),

        .pp_ecdsa_ready(pp_ecdsa_ready),

        .topic_policy_rd(topic_policy_rd),
        .topic_policy_raddr(topic_policy_raddr),

        .topic_policy_ack(topic_policy_ack),
        .topic_policy_rdata(topic_policy_rdata),

        .ecdsa_pp_valid(ecdsa_pp_valid),
        .ecdsa_pp_sop(ecdsa_pp_sop),
        .ecdsa_pp_eop(ecdsa_pp_eop),
        .ecdsa_pp_data(ecdsa_pp_data),
        .ecdsa_pp_meta_data(ecdsa_pp_meta_data),
        .ecdsa_pp_auth_len(ecdsa_pp_auth_len),

        .ecdsa_lh_ready(ecdsa_lh_ready),

        .ecdsa_classifier_flow_valid(ecdsa_classifier_flow_valid),
        .ecdsa_classifier_fid(ecdsa_classifier_fid),
        .ecdsa_classifier_flow_etime(ecdsa_classifier_flow_etime),

        .ecdsa_classifier_topic_valid(ecdsa_classifier_topic_valid),
        .ecdsa_classifier_tid(ecdsa_classifier_tid),
        .ecdsa_classifier_topic_etime(ecdsa_classifier_topic_etime),

        .ecdsa_irl_fill_tb_src_wr(ecdsa_irl_fill_tb_src_wr),
        .ecdsa_irl_fill_tb_src_waddr(ecdsa_irl_fill_tb_src_waddr),
        .ecdsa_irl_fill_tb_src_wdata(ecdsa_irl_fill_tb_src_wdata),

        .ecdsa_lh_wr(ecdsa_lh_wr),
        .ecdsa_lh_waddr(ecdsa_lh_waddr),
        .ecdsa_lh_wdata(ecdsa_lh_wdata),
        .ecdsa_lh_sn_wdata(ecdsa_lh_sn_wdata),
        .ecdsa_lh_ppl_wdata(ecdsa_lh_ppl_wdata),

        .ecdsa_piarb_wr(ecdsa_piarb_wr),
        .ecdsa_piarb_waddr(ecdsa_piarb_waddr),
        .ecdsa_piarb_wdata(ecdsa_piarb_wdata),

        .ecdsa_asa_fp_wr(ecdsa_asa_fp_wr),
        .ecdsa_asa_fp_waddr(ecdsa_asa_fp_waddr),
        .ecdsa_asa_fp_wdata(ecdsa_asa_fp_wdata)

);

ecdsa_mem u_ecdsa_mem(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .clk_div(clk_div),

        .reg_addr(reg_addr),
        .reg_din(reg_din),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_ms_topic_policy(reg_ms_topic_policy),

        .topic_policy_mem_ack(topic_policy_mem_ack),
        .topic_policy_mem_rdata(topic_policy_mem_rdata),

        .topic_policy_rd(topic_policy_rd),
        .topic_policy_raddr(topic_policy_raddr),

        .topic_policy_ack(topic_policy_ack),
        .topic_policy_rdata(topic_policy_rdata)

);



pio2reg_bus #(
  .BLOCK_ADDR_LSB(0),
  .BLOCK_ADDR(0),
  .REG_BLOCK_ADDR_LSB(`ECDSA_REG_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`ECDSA_REG_BLOCK_ADDR)
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

ecdsa_pio u_ecdsa_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .topic_policy_mem_ack(topic_policy_mem_ack),
    .topic_policy_mem_rdata(topic_policy_mem_rdata),

    .reg_ms_topic_policy(reg_ms_topic_policy),

    .pio_ack(pio_ack0),
    .pio_rvalid(pio_rvalid0),
    .pio_rdata(pio_rdata0)

);


ecdsa_reg u_ecdsa_reg(

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

    .default_exp_time(default_exp_time)

);


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

