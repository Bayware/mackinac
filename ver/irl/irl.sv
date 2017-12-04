//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module irl #(
parameter DEPTH_NBITS = `FLOW_VALUE_DEPTH_NBITS,
parameter BUCKET_NBITS = `CIR_NBITS+2+`EIR_NBITS+2,
parameter EIR_TB_NBITS = `EIR_NBITS+2
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

input ecdsa_irl_fill_tb_src_wr, 
input [DEPTH_NBITS-1:0] ecdsa_irl_fill_tb_src_waddr,
input [`FILL_TB_NBITS-1:0] ecdsa_irl_fill_tb_src_wdata,

input cla_irl_valid,
input [`DATA_PATH_RANGE] cla_irl_hdr_data,
input cla_irl_meta_type   cla_irl_meta_data,
input cla_irl_sop,
input cla_irl_eop,


    // outputs
  
output logic irl_lh_valid,
output logic [`DATA_PATH_RANGE] irl_lh_hdr_data,
output irl_lh_meta_type irl_lh_meta_data,
output logic irl_lh_sop,
output logic irl_lh_eop

);


/***************************** LOCAL VARIABLES *******************************/

logic limiting_profile_cir_ack; 
(* dont_touch = "true" *) wire [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_rdata  ;

logic limiting_profile_eir_ack; 
(* dont_touch = "true" *) wire [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_rdata  ;

logic fill_tb_src_ack; 
(* dont_touch = "true" *) wire [`FILL_TB_NBITS-1:0] fill_tb_src_rdata  ;

logic eir_tb_ack; 
(* dont_touch = "true" *) wire [`EIR_NBITS+2-1:0] eir_tb_rdata  ;

logic token_bucket_ack; 
(* dont_touch = "true" *) wire [BUCKET_NBITS-1:0] token_bucket_rdata  ;

logic limiting_profile_cir_rd; 
logic [`LIMITER_NBITS-1:0] limiting_profile_cir_raddr;

logic limiting_profile_cir_wr; 
logic [`LIMITER_NBITS-1:0] limiting_profile_cir_waddr;
logic [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_wdata;

logic limiting_profile_eir_rd; 
logic [`LIMITER_NBITS-1:0] limiting_profile_eir_raddr;

logic limiting_profile_eir_wr; 
logic [`LIMITER_NBITS-1:0] limiting_profile_eir_waddr;
logic [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_wdata;

logic fill_tb_src_rd; 
logic [DEPTH_NBITS-1:0] fill_tb_src_raddr;

logic fill_tb_src_wr; 
logic [DEPTH_NBITS-1:0] fill_tb_src_waddr;
logic [`FILL_TB_NBITS-1:0] fill_tb_src_wdata;

logic eir_tb_rd; 
logic [`PORT_ID_NBITS-1:0] eir_tb_raddr;

logic eir_tb_wr; 
logic [`PORT_ID_NBITS-1:0] eir_tb_waddr;
logic [`EIR_NBITS+2-1:0] eir_tb_wdata;

logic token_bucket_rd; 
logic [DEPTH_NBITS-1:0] token_bucket_raddr;

logic token_bucket_wr; 
logic [DEPTH_NBITS-1:0] token_bucket_waddr;
logic [BUCKET_NBITS-1:0] token_bucket_wdata;

logic         reg_bs;
logic         reg_wr;
logic         reg_rd;
logic [`PIO_RANGE] reg_addr;
logic [`PIO_RANGE] reg_din;

logic limiting_profile_cir_mem_ack;
logic [`PIO_RANGE] limiting_profile_cir_mem_rdata;

logic limiting_profile_eir_mem_ack;
logic [`PIO_RANGE] limiting_profile_eir_mem_rdata;

logic reg_ms_limiting_profile_cir;
logic reg_ms_limiting_profile_eir;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

/***************************** PROGRAM BODY **********************************/

irl_process u_irl_process(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .cla_irl_valid(cla_irl_valid),
        .cla_irl_hdr_data(cla_irl_hdr_data),
        .cla_irl_meta_data(cla_irl_meta_data),
        .cla_irl_sop(cla_irl_sop),
        .cla_irl_eop(cla_irl_eop),

        .limiting_profile_cir_ack(limiting_profile_cir_ack),
        .limiting_profile_cir_rdata(limiting_profile_cir_rdata),

        .limiting_profile_eir_ack(limiting_profile_eir_ack),
        .limiting_profile_eir_rdata(limiting_profile_eir_rdata),

        .fill_tb_src_ack(fill_tb_src_ack),
        .fill_tb_src_rdata(fill_tb_src_rdata),

        .eir_tb_ack(eir_tb_ack),
        .eir_tb_rdata(eir_tb_rdata),

        .token_bucket_ack(token_bucket_ack),
        .token_bucket_rdata(token_bucket_rdata),

        .irl_lh_valid(irl_lh_valid),
        .irl_lh_hdr_data(irl_lh_hdr_data),
        .irl_lh_meta_data(irl_lh_meta_data),
        .irl_lh_sop(irl_lh_sop),
        .irl_lh_eop(irl_lh_eop),

        .limiting_profile_cir_rd(limiting_profile_cir_rd),
        .limiting_profile_cir_raddr(limiting_profile_cir_raddr),

        .limiting_profile_cir_wr(limiting_profile_cir_wr),
        .limiting_profile_cir_waddr(limiting_profile_cir_waddr),
        .limiting_profile_cir_wdata(limiting_profile_cir_wdata),

        .limiting_profile_eir_rd(limiting_profile_eir_rd),
        .limiting_profile_eir_raddr(limiting_profile_eir_raddr),

        .limiting_profile_eir_wr(limiting_profile_eir_wr),
        .limiting_profile_eir_waddr(limiting_profile_eir_waddr),
        .limiting_profile_eir_wdata(limiting_profile_eir_wdata),

        .fill_tb_src_rd(fill_tb_src_rd),
        .fill_tb_src_raddr(fill_tb_src_raddr),

        .fill_tb_src_wr(fill_tb_src_wr),
        .fill_tb_src_waddr(fill_tb_src_waddr),
        .fill_tb_src_wdata(fill_tb_src_wdata),

        .eir_tb_rd(eir_tb_rd),
        .eir_tb_raddr(eir_tb_raddr),

        .eir_tb_wr(eir_tb_wr),
        .eir_tb_waddr(eir_tb_waddr),
        .eir_tb_wdata(eir_tb_wdata),

        .token_bucket_rd(token_bucket_rd),
        .token_bucket_raddr(token_bucket_raddr),

        .token_bucket_wr(token_bucket_wr),
        .token_bucket_waddr(token_bucket_waddr),
        .token_bucket_wdata(token_bucket_wdata)

);


irl_mem u_irl_mem(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .clk_div(clk_div),

        .reg_addr(reg_addr),
        .reg_din(reg_din),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
	.reg_ms_limiting_profile_cir(reg_ms_limiting_profile_cir),
        .reg_ms_limiting_profile_eir(reg_ms_limiting_profile_eir),

        .limiting_profile_cir_mem_ack(limiting_profile_cir_mem_ack),
        .limiting_profile_cir_mem_rdata(limiting_profile_cir_mem_rdata),

        .limiting_profile_eir_mem_ack(limiting_profile_eir_mem_ack),
        .limiting_profile_eir_mem_rdata(limiting_profile_eir_mem_rdata),

	.ecdsa_irl_fill_tb_src_wr(ecdsa_irl_fill_tb_src_wr), 
	.ecdsa_irl_fill_tb_src_waddr(ecdsa_irl_fill_tb_src_waddr),
	.ecdsa_irl_fill_tb_src_wdata(ecdsa_irl_fill_tb_src_wdata),


        .limiting_profile_cir_rd(limiting_profile_cir_rd),
        .limiting_profile_cir_raddr(limiting_profile_cir_raddr),

        .limiting_profile_cir_wr(limiting_profile_cir_wr),
        .limiting_profile_cir_waddr(limiting_profile_cir_waddr),
        .limiting_profile_cir_wdata(limiting_profile_cir_wdata),

        .limiting_profile_eir_rd(limiting_profile_eir_rd),
        .limiting_profile_eir_raddr(limiting_profile_eir_raddr),

        .limiting_profile_eir_wr(limiting_profile_eir_wr),
        .limiting_profile_eir_waddr(limiting_profile_eir_waddr),
        .limiting_profile_eir_wdata(limiting_profile_eir_wdata),

        .fill_tb_src_rd(fill_tb_src_rd),
        .fill_tb_src_raddr(fill_tb_src_raddr),

        .fill_tb_src_wr(fill_tb_src_wr),
        .fill_tb_src_waddr(fill_tb_src_waddr),
        .fill_tb_src_wdata(fill_tb_src_wdata),

        .eir_tb_rd(eir_tb_rd),
        .eir_tb_raddr(eir_tb_raddr),

        .eir_tb_wr(eir_tb_wr),
        .eir_tb_waddr(eir_tb_waddr),
        .eir_tb_wdata(eir_tb_wdata),

        .token_bucket_rd(token_bucket_rd),
        .token_bucket_raddr(token_bucket_raddr),

        .token_bucket_wr(token_bucket_wr),
        .token_bucket_waddr(token_bucket_waddr),
        .token_bucket_wdata(token_bucket_wdata),

        .limiting_profile_cir_ack(limiting_profile_cir_ack),
        .limiting_profile_cir_rdata(limiting_profile_cir_rdata),

        .limiting_profile_eir_ack(limiting_profile_eir_ack),
        .limiting_profile_eir_rdata(limiting_profile_eir_rdata),

        .fill_tb_src_ack(fill_tb_src_ack),
        .fill_tb_src_rdata(fill_tb_src_rdata),

        .eir_tb_ack(eir_tb_ack),
        .eir_tb_rdata(eir_tb_rdata),

        .token_bucket_ack(token_bucket_ack),
        .token_bucket_rdata(token_bucket_rdata)

);

pio2reg_bus #(
  .BLOCK_ADDR_LSB(`IRL_BLOCK_ADDR_LSB),
  .BLOCK_ADDR(`IRL_BLOCK_ADDR),
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

irl_pio u_irl_pio(

    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_div(clk_div),

    .reg_bs(mem_bs),
    .reg_wr(reg_wr),
    .reg_rd(reg_rd),
    .reg_addr(reg_addr),
    .reg_din(reg_din),

    .limiting_profile_cir_mem_ack(limiting_profile_cir_mem_ack),
    .limiting_profile_cir_mem_rdata(limiting_profile_cir_mem_rdata),

    .limiting_profile_eir_mem_ack(limiting_profile_eir_mem_ack),
    .limiting_profile_eir_mem_rdata(limiting_profile_eir_mem_rdata),

    .reg_ms_limiting_profile_cir(reg_ms_limiting_profile_cir),
    .reg_ms_limiting_profile_eir(reg_ms_limiting_profile_eir),

    .pio_ack(pio_ack),
    .pio_rvalid(pio_rvalid),
    .pio_rdata(pio_rdata)

);



/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

