//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module classifier #(
parameter FLOW_BUCKET_NBITS = `FLOW_HASH_BUCKET_NBITS,
parameter FLOW_DEPTH_NBITS = `FLOW_HASH_TABLE_DEPTH_NBITS,
parameter FLOW_VALUE_DEPTH_NBITS = `FLOW_VALUE_DEPTH_NBITS,
parameter FLOW_KEY_NBITS = `FLOW_KEY_NBITS,
parameter TOPIC_BUCKET_NBITS = `TOPIC_HASH_BUCKET_NBITS,
parameter TOPIC_DEPTH_NBITS = `TOPIC_HASH_TABLE_DEPTH_NBITS,
parameter TOPIC_VALUE_DEPTH_NBITS = `TOPIC_VALUE_DEPTH_NBITS,
parameter TOPIC_KEY_NBITS = `TOPIC_KEY_NBITS
) (

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

input aggr_par_hdr_valid,
input [`DATA_PATH_RANGE] aggr_par_hdr_data,
aggr_par_meta_type   aggr_par_meta_data,
input aggr_par_sop,
input aggr_par_eop,

input asa_classifier_valid,
input [`FID_NBITS-1:0] asa_classifier_fid,

input ecdsa_classifier_flow_valid,
input [`FID_NBITS-1:0] ecdsa_classifier_fid,
input [`EXP_TIME_NBITS-1:0] ecdsa_classifier_flow_etime,

input ecdsa_classifier_topic_valid,
input [`TID_NBITS-1:0] ecdsa_classifier_tid,
input [`EXP_TIME_NBITS-1:0] ecdsa_classifier_topic_etime,


output logic cla_supervisor_flow_valid,
output logic [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_flow_hash0,
output logic [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_flow_hash1,
output logic [`FLOW_KEY_NBITS-1:0] cla_supervisor_flow_key,

output logic cla_supervisor_topic_valid,
output logic [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_topic_hash0,
output logic [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_topic_hash1,
output logic [`TOPIC_KEY_NBITS-1:0] cla_supervisor_topic_key,

output logic cla_irl_valid,
output logic [`DATA_PATH_RANGE] cla_irl_hdr_data,
output cla_irl_meta_type   cla_irl_meta_data,
output logic cla_irl_sop,
output logic cla_irl_eop

);

/***************************** LOCAL VARIABLES *******************************/
logic flow_hash_table0_ack; 
logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table0_rdata  /* synthesis keep = 1 */;

logic flow_hash_table1_ack; 
logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table1_rdata  /* synthesis keep = 1 */;

logic flow_key_ack; 
logic [`FLOW_KEY_NBITS-1:0] flow_key_rdata; /* synthesis keep = 1 */

logic flow_etime_ack; 
logic [`EXP_TIME_NBITS-1:0] flow_etime_rdata; /* synthesis keep = 1 */

logic topic_hash_table0_ack; 
logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table0_rdata  /* synthesis keep = 1 */;

logic topic_hash_table1_ack; 
logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table1_rdata  /* synthesis keep = 1 */;

logic topic_key_ack; 
logic [`TOPIC_KEY_NBITS-1:0] topic_key_rdata; /* synthesis keep = 1 */

logic topic_etime_ack; 
logic [`EXP_TIME_NBITS-1:0] topic_etime_rdata; /* synthesis keep = 1 */

logic flow_hash_table0_rd; 
logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table0_raddr;

logic flow_hash_table0_wr; 
logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table0_waddr;
logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table0_wdata;

logic flow_hash_table1_rd; 
logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table1_raddr;

logic flow_hash_table1_wr; 
logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table1_waddr;
logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table1_wdata;

logic flow_key_wr; 
logic [FLOW_VALUE_DEPTH_NBITS-1:0] flow_key_waddr;
logic [`FLOW_KEY_NBITS-1:0] flow_key_wdata;

logic flow_key_rd; 
logic [FLOW_VALUE_DEPTH_NBITS-1:0] flow_key_raddr;

logic flow_etime_rd; 
logic [FLOW_VALUE_DEPTH_NBITS-1:0] flow_etime_raddr;

logic topic_hash_table0_rd; 
logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table0_raddr;

logic topic_hash_table0_wr; 
logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table0_waddr;
logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table0_wdata;

logic topic_hash_table1_rd; 
logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table1_raddr;

logic topic_hash_table1_wr; 
logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table1_waddr;
logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table1_wdata;

logic topic_key_wr; 
logic [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_key_waddr;
logic [TOPIC_KEY_NBITS-1:0] topic_key_wdata;

logic topic_key_rd; 
logic [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_key_raddr;

logic topic_etime_rd; 
logic [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_etime_raddr;

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

logic flow_hash_table_mem_ack;
logic [`PIO_RANGE] flow_hash_table_mem_rdata;

logic topic_hash_table_mem_ack;
logic [`PIO_RANGE] topic_hash_table_mem_rdata;

logic reg_ms_flow_hash_table;
logic reg_ms_topic_hash_table;

logic [`AGING_TIME_NBITS-1:0] aging_time;

/***************************** NON REGISTERED OUTPUTS ************************/

assign pio_ack = pio_ack0|pio_ack1;
assign pio_rvalid = pio_rvalid0|pio_rvalid1;
assign pio_rdata = pio_rvalid0?pio_rdata0:pio_rdata1;

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/


classifier_lookup u_classifier_lookup(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .current_time(current_time),
        .aging_time(aging_time),
	
	.aggr_par_hdr_valid(aggr_par_hdr_valid),
	.aggr_par_hdr_data(aggr_par_hdr_data),
	.aggr_par_meta_data(aggr_par_meta_data),
	.aggr_par_sop(aggr_par_sop),
	.aggr_par_eop(aggr_par_eop),

        .flow_hash_table0_ack(flow_hash_table0_ack),
        .flow_hash_table0_rdata(flow_hash_table0_rdata),

        .flow_hash_table1_ack(flow_hash_table1_ack),
        .flow_hash_table1_rdata(flow_hash_table1_rdata),

        .flow_key_ack(flow_key_ack),
        .flow_key_rdata(flow_key_rdata),

        .flow_etime_ack(flow_etime_ack),
        .flow_etime_rdata(flow_etime_rdata),

        .topic_hash_table0_ack(topic_hash_table0_ack),
        .topic_hash_table0_rdata(topic_hash_table0_rdata),

        .topic_hash_table1_ack(topic_hash_table1_ack),
        .topic_hash_table1_rdata(topic_hash_table1_rdata),

        .topic_key_ack(topic_key_ack),
        .topic_key_rdata(topic_key_rdata),

        .topic_etime_ack(topic_etime_ack),
        .topic_etime_rdata(topic_etime_rdata),


        .cla_supervisor_flow_valid(cla_supervisor_flow_valid),
        .cla_supervisor_flow_hash0(cla_supervisor_flow_hash0),
        .cla_supervisor_flow_hash1(cla_supervisor_flow_hash1),
        .cla_supervisor_flow_key(cla_supervisor_flow_key),

        .cla_supervisor_topic_valid(cla_supervisor_topic_valid),
        .cla_supervisor_topic_hash0(cla_supervisor_topic_hash0),
        .cla_supervisor_topic_hash1(cla_supervisor_topic_hash1),
        .cla_supervisor_topic_key(cla_supervisor_topic_key),

	.cla_irl_valid(cla_irl_valid),
	.cla_irl_hdr_data(cla_irl_hdr_data),
	.cla_irl_meta_data(cla_irl_meta_data),
	.cla_irl_sop(cla_irl_sop),
	.cla_irl_eop(cla_irl_eop),

        .flow_hash_table0_rd(flow_hash_table0_rd),
        .flow_hash_table0_raddr(flow_hash_table0_raddr),

        .flow_hash_table0_wr(flow_hash_table0_wr),
        .flow_hash_table0_waddr(flow_hash_table0_waddr),
        .flow_hash_table0_wdata(flow_hash_table0_wdata),

        .flow_hash_table1_rd(flow_hash_table1_rd),
        .flow_hash_table1_raddr(flow_hash_table1_raddr),

        .flow_hash_table1_wr(flow_hash_table1_wr),
        .flow_hash_table1_waddr(flow_hash_table1_waddr),
        .flow_hash_table1_wdata(flow_hash_table1_wdata),

        .flow_key_rd(flow_key_rd),
        .flow_key_raddr(flow_key_raddr),

        .flow_key_wr(flow_key_wr),
        .flow_key_waddr(flow_key_waddr),
        .flow_key_wdata(flow_key_wdata),

        .flow_etime_rd(flow_etime_rd),
        .flow_etime_raddr(flow_etime_raddr),

        .topic_hash_table0_rd(topic_hash_table0_rd),
        .topic_hash_table0_raddr(topic_hash_table0_raddr),

        .topic_hash_table0_wr(topic_hash_table0_wr),
        .topic_hash_table0_waddr(topic_hash_table0_waddr),
        .topic_hash_table0_wdata(topic_hash_table0_wdata),

        .topic_hash_table1_rd(topic_hash_table1_rd),
        .topic_hash_table1_raddr(topic_hash_table1_raddr),

        .topic_hash_table1_wr(topic_hash_table1_wr),
        .topic_hash_table1_waddr(topic_hash_table1_waddr),
        .topic_hash_table1_wdata(topic_hash_table1_wdata),

        .topic_key_rd(topic_key_rd),
        .topic_key_raddr(topic_key_raddr),

        .topic_key_wr(topic_key_wr),
        .topic_key_waddr(topic_key_waddr),
        .topic_key_wdata(topic_key_wdata),

        .topic_etime_rd(topic_etime_rd),
        .topic_etime_raddr(topic_etime_raddr)
    );

classifier_mem_flow u_classifier_mem_flow(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .clk_div(clk_div),

        .reg_addr(reg_addr),
        .reg_din(reg_din),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_ms_flow_hash_table(reg_ms_flow_hash_table),

        .flow_hash_table_mem_ack(flow_hash_table_mem_ack),
        .flow_hash_table_mem_rdata(flow_hash_table_mem_rdata),

        .ecdsa_classifier_flow_valid(ecdsa_classifier_flow_valid),
        .ecdsa_classifier_fid(ecdsa_classifier_fid),
        .ecdsa_classifier_flow_etime(ecdsa_classifier_flow_etime),

        .current_time(current_time),
        .asa_classifier_valid(asa_classifier_valid),
        .asa_classifier_fid(asa_classifier_fid),

        .flow_hash_table0_rd(flow_hash_table0_rd),
        .flow_hash_table0_raddr(flow_hash_table0_raddr),

        .flow_hash_table0_wr(flow_hash_table0_wr),
        .flow_hash_table0_waddr(flow_hash_table0_waddr),
        .flow_hash_table0_wdata(flow_hash_table0_wdata),

        .flow_hash_table1_rd(flow_hash_table1_rd),
        .flow_hash_table1_raddr(flow_hash_table1_raddr),

        .flow_hash_table1_wr(flow_hash_table1_wr),
        .flow_hash_table1_waddr(flow_hash_table1_waddr),
        .flow_hash_table1_wdata(flow_hash_table1_wdata),

        .flow_key_rd(flow_key_rd),
        .flow_key_raddr(flow_key_raddr),

        .flow_key_wr(flow_key_wr),
        .flow_key_waddr(flow_key_waddr),
        .flow_key_wdata(flow_key_wdata),

        .flow_etime_rd(flow_etime_rd),
        .flow_etime_raddr(flow_etime_raddr),

        .flow_hash_table0_ack(flow_hash_table0_ack),
        .flow_hash_table0_rdata(flow_hash_table0_rdata),

        .flow_hash_table1_ack(flow_hash_table1_ack),
        .flow_hash_table1_rdata(flow_hash_table1_rdata),

        .flow_key_ack(flow_key_ack),
        .flow_key_rdata(flow_key_rdata),

        .flow_etime_ack(flow_etime_ack),
        .flow_etime_rdata(flow_etime_rdata)

    );

classifier_mem_topic u_classifier_mem_topic(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .clk_div(clk_div),

        .reg_addr(reg_addr),
        .reg_din(reg_din),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_ms_topic_hash_table(reg_ms_topic_hash_table),

        .topic_hash_table_mem_ack(topic_hash_table_mem_ack),
        .topic_hash_table_mem_rdata(topic_hash_table_mem_rdata),

        .ecdsa_classifier_topic_valid(ecdsa_classifier_topic_valid),
        .ecdsa_classifier_tid(ecdsa_classifier_tid),
        .ecdsa_classifier_topic_etime(ecdsa_classifier_topic_etime),

        .topic_hash_table0_rd(topic_hash_table0_rd),
        .topic_hash_table0_raddr(topic_hash_table0_raddr),

        .topic_hash_table0_wr(topic_hash_table0_wr),
        .topic_hash_table0_waddr(topic_hash_table0_waddr),
        .topic_hash_table0_wdata(topic_hash_table0_wdata),

        .topic_hash_table1_rd(topic_hash_table1_rd),
        .topic_hash_table1_raddr(topic_hash_table1_raddr),

        .topic_hash_table1_wr(topic_hash_table1_wr),
        .topic_hash_table1_waddr(topic_hash_table1_waddr),
        .topic_hash_table1_wdata(topic_hash_table1_wdata),

        .topic_key_rd(topic_key_rd),
        .topic_key_raddr(topic_key_raddr),

        .topic_key_wr(topic_key_wr),
        .topic_key_waddr(topic_key_waddr),
        .topic_key_wdata(topic_key_wdata),

        .topic_etime_rd(topic_etime_rd),
        .topic_etime_raddr(topic_etime_raddr),

        .topic_hash_table0_ack(topic_hash_table0_ack),
        .topic_hash_table0_rdata(topic_hash_table0_rdata),

        .topic_hash_table1_ack(topic_hash_table1_ack),
        .topic_hash_table1_rdata(topic_hash_table1_rdata),

        .topic_key_ack(topic_key_ack),
        .topic_key_rdata(topic_key_rdata),

        .topic_etime_ack(topic_etime_ack),
        .topic_etime_rdata(topic_etime_rdata)

);


pio2reg_bus #(
  .BLOCK_ADDR_LSB(`CLASSIFIER_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`CLASSIFIER_BLOCK_ADDR),
  .REG_BLOCK_ADDR_LSB(`CLASSIFIER_REG_BLOCK_ADDR_LSB),
  .REG_BLOCK_ADDR(`CLASSIFIER_REG_BLOCK_ADDR)
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

classifier_pio u_classifier_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .flow_hash_table_mem_ack(flow_hash_table_mem_ack),
    .flow_hash_table_mem_rdata(flow_hash_table_mem_rdata),

    .topic_hash_table_mem_ack(topic_hash_table_mem_ack),
    .topic_hash_table_mem_rdata(topic_hash_table_mem_rdata),

    .reg_ms_flow_hash_table(reg_ms_flow_hash_table),
    .reg_ms_topic_hash_table(reg_ms_topic_hash_table),

    .pio_ack(pio_ack0),
    .pio_rvalid(pio_rvalid0),
    .pio_rdata(pio_rdata0)

);

classifier_reg u_classifier_reg(

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

    .aging_time(aging_time)

);


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

