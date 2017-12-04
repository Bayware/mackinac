//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_sch_mem0 #(
parameter QUEUE_NBITS = `FIRST_LVL_QUEUE_ID_NBITS,
parameter SCH_NBITS = `FIRST_LVL_SCH_ID_NBITS,
parameter QUEUE_PROFILE_NBITS = `FIRST_LVL_QUEUE_PROFILE_NBITS
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_queue_profile,
input reg_ms_wdrr_quantum,
input reg_ms_shaping_profile_cir,
input reg_ms_shaping_profile_eir,
input reg_ms_wdrr_sch_ctrl,
input reg_ms_fill_tb_dst,

input queue_profile_rd, 
input [QUEUE_NBITS-1:0] queue_profile_raddr,

input wdrr_quantum_rd, 
input [QUEUE_NBITS-1:0] wdrr_quantum_raddr,

input shaping_profile_cir_rd, 
input [QUEUE_NBITS-1:0] shaping_profile_cir_raddr,
input shaping_profile_cir_wr, 
input [QUEUE_NBITS-1:0] shaping_profile_cir_waddr,
input [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_wdata,

input shaping_profile_eir_rd, 
input [QUEUE_NBITS-1:0] shaping_profile_eir_raddr,
input shaping_profile_eir_wr, 
input [QUEUE_NBITS-1:0] shaping_profile_eir_waddr,
input [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_wdata,

input wdrr_sch_ctrl_rd, 
input [SCH_NBITS-1:0] wdrr_sch_ctrl_raddr,

input fill_tb_dst_rd, 
input [QUEUE_NBITS-1:0] fill_tb_dst_raddr,
input fill_tb_dst_wr, 
input [QUEUE_NBITS-1:0] fill_tb_dst_waddr,
input [`PORT_ID_NBITS-1:0] fill_tb_dst_wdata,

output queue_profile_mem_ack,
output [`PIO_RANGE] queue_profile_mem_rdata,

output wdrr_quantum_mem_ack,
output [`PIO_RANGE] wdrr_quantum_mem_rdata,

output shaping_profile_cir_mem_ack,
output [`PIO_RANGE] shaping_profile_cir_mem_rdata,

output shaping_profile_eir_mem_ack,
output [`PIO_RANGE] shaping_profile_eir_mem_rdata,

output fill_tb_dst_mem_ack,
output [`PIO_RANGE] fill_tb_dst_mem_rdata,

output wdrr_sch_ctrl_mem_ack,
(* dont_touch = "true" *) output [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata  ,

output queue_profile_ack, 
(* dont_touch = "true" *) output [QUEUE_PROFILE_NBITS-1:0] queue_profile_rdata  ,

output wdrr_quantum_ack, 
(* dont_touch = "true" *) output [`WDRR_QUANTUM_NBITS-1:0] wdrr_quantum_rdata  ,

output shaping_profile_cir_ack, 
(* dont_touch = "true" *) output [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_cir_rdata  ,

output shaping_profile_eir_ack, 
(* dont_touch = "true" *) output [`SHAPING_PROFILE_NBITS-1:0] shaping_profile_eir_rdata  ,

output wdrr_sch_ctrl_ack, 
(* dont_touch = "true" *) output [`WDRR_N_NBITS-1:0] wdrr_sch_ctrl_rdata  ,

output fill_tb_dst_ack, 
(* dont_touch = "true" *) output [`PORT_ID_NBITS-1:0] fill_tb_dst_rdata  

);

/***************************** LOCAL VARIABLES *******************************/


/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

pio_mem_bram_f #(QUEUE_PROFILE_NBITS, QUEUE_NBITS) u_pio_mem_bram_f0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_queue_profile),

		.app_mem_rd(queue_profile_rd),
		.app_mem_raddr(queue_profile_raddr),

        	.mem_ack(queue_profile_mem_ack),
        	.mem_rdata(queue_profile_mem_rdata),

		.app_mem_ack(queue_profile_ack),
		.app_mem_rdata(queue_profile_rdata)
);

pio_mem_bram_f #(`WDRR_QUANTUM_NBITS, QUEUE_NBITS) u_pio_mem_bram_f1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_wdrr_quantum),

		.app_mem_rd(wdrr_quantum_rd),
		.app_mem_raddr(wdrr_quantum_raddr),

        	.mem_ack(wdrr_quantum_mem_ack),
        	.mem_rdata(wdrr_quantum_mem_rdata),

		.app_mem_ack(wdrr_quantum_ack),
		.app_mem_rdata(wdrr_quantum_rdata)
);

pio_rw_mem_bram_f #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_rw_mem_bram_f0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_shaping_profile_cir),

		.app_mem_rd(shaping_profile_cir_rd),
		.app_mem_raddr(shaping_profile_cir_raddr),

		.app_mem_wr(shaping_profile_cir_wr),
		.app_mem_waddr(shaping_profile_cir_waddr),
		.app_mem_wdata(shaping_profile_cir_wdata),

        	.mem_ack(shaping_profile_cir_mem_ack),
        	.mem_rdata(shaping_profile_cir_mem_rdata),

		.app_mem_ack(shaping_profile_cir_ack),
		.app_mem_rdata(shaping_profile_cir_rdata)
);

pio_rw_mem_bram_f #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_rw_mem_bram_f1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_shaping_profile_eir),

		.app_mem_rd(shaping_profile_eir_rd),
		.app_mem_raddr(shaping_profile_eir_raddr),

		.app_mem_wr(shaping_profile_eir_wr),
		.app_mem_waddr(shaping_profile_eir_waddr),
		.app_mem_wdata(shaping_profile_eir_wdata),

        	.mem_ack(shaping_profile_eir_mem_ack),
        	.mem_rdata(shaping_profile_eir_mem_rdata),

		.app_mem_ack(shaping_profile_eir_ack),
		.app_mem_rdata(shaping_profile_eir_rdata)
);

pio_mem_bram_f #(`WDRR_N_NBITS, SCH_NBITS) u_pio_mem_bram_f2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_wdrr_sch_ctrl),

		.app_mem_rd(wdrr_sch_ctrl_rd),
		.app_mem_raddr(wdrr_sch_ctrl_raddr),

        	.mem_ack(wdrr_sch_ctrl_mem_ack),
        	.mem_rdata(wdrr_sch_ctrl_mem_rdata),

		.app_mem_ack(wdrr_sch_ctrl_ack),
		.app_mem_rdata(wdrr_sch_ctrl_rdata)
);

pio_rw_mem_bram_f #(`PORT_ID_NBITS, QUEUE_NBITS) u_pio_rw_mem_bram_f2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_fill_tb_dst),

		.app_mem_rd(fill_tb_dst_rd),
		.app_mem_raddr(fill_tb_dst_raddr),

		.app_mem_wr(fill_tb_dst_wr),
		.app_mem_waddr(fill_tb_dst_waddr),
		.app_mem_wdata(fill_tb_dst_wdata),

        	.mem_ack(fill_tb_dst_mem_ack),
        	.mem_rdata(fill_tb_dst_mem_rdata),

		.app_mem_ack(fill_tb_dst_ack),
		.app_mem_rdata(fill_tb_dst_rdata)
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

