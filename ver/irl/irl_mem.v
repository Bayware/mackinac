//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module irl_mem #(
parameter DEPTH_NBITS = `FLOW_VALUE_DEPTH_NBITS,
parameter BUCKET_NBITS = `CIR_NBITS+2+`EIR_NBITS+2,
parameter EIR_TB_NBITS = `EIR_NBITS+2
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_limiting_profile_cir,
input reg_ms_limiting_profile_eir,

output limiting_profile_cir_mem_ack,
output [`PIO_RANGE] limiting_profile_cir_mem_rdata,

output limiting_profile_eir_mem_ack,
output [`PIO_RANGE] limiting_profile_eir_mem_rdata,

input ecdsa_irl_fill_tb_src_wr, 
input [DEPTH_NBITS-1:0] ecdsa_irl_fill_tb_src_waddr,
input [`FILL_TB_NBITS-1:0] ecdsa_irl_fill_tb_src_wdata,

input limiting_profile_cir_rd, 
input [`LIMITER_NBITS-1:0] limiting_profile_cir_raddr,

input limiting_profile_cir_wr, 
input [`LIMITER_NBITS-1:0] limiting_profile_cir_waddr,
input [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_wdata,

input limiting_profile_eir_rd, 
input [`LIMITER_NBITS-1:0] limiting_profile_eir_raddr,

input limiting_profile_eir_wr, 
input [`LIMITER_NBITS-1:0] limiting_profile_eir_waddr,
input [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_wdata,

input fill_tb_src_rd, 
input [DEPTH_NBITS-1:0] fill_tb_src_raddr,

input fill_tb_src_wr, 
input [DEPTH_NBITS-1:0] fill_tb_src_waddr,
input [`FILL_TB_NBITS-1:0] fill_tb_src_wdata,

input eir_tb_rd, 
input [`PORT_ID_NBITS-1:0] eir_tb_raddr,

input eir_tb_wr, 
input [`PORT_ID_NBITS-1:0] eir_tb_waddr,
input [EIR_TB_NBITS-1:0] eir_tb_wdata,

input token_bucket_rd, 
input [DEPTH_NBITS-1:0] token_bucket_raddr,

input token_bucket_wr, 
input [DEPTH_NBITS-1:0] token_bucket_waddr,
input [BUCKET_NBITS-1:0] token_bucket_wdata,

output reg limiting_profile_cir_ack, 
output [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_rdata  /* synthesis keep = 1 */,

output reg limiting_profile_eir_ack, 
output [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_rdata  /* synthesis keep = 1 */,

output reg fill_tb_src_ack, 
output [`FILL_TB_NBITS-1:0] fill_tb_src_rdata  /* synthesis keep = 1 */,

output reg eir_tb_ack, 
output [EIR_TB_NBITS-1:0] eir_tb_rdata  /* synthesis keep = 1 */,

output reg token_bucket_ack, 
output [BUCKET_NBITS-1:0] token_bucket_rdata  /* synthesis keep = 1 */

);

/***************************** LOCAL VARIABLES *******************************/

reg ecdsa_irl_fill_tb_src_wr_d1; 
reg [DEPTH_NBITS-1:0] ecdsa_irl_fill_tb_src_waddr_d1;
reg [`FILL_TB_NBITS-1:0] ecdsa_irl_fill_tb_src_wdata_d1;

wire fill_wr = ecdsa_irl_fill_tb_src_wr_d1|fill_tb_src_wr;
wire [DEPTH_NBITS-1:0] fill_waddr = ecdsa_irl_fill_tb_src_wr_d1?ecdsa_irl_fill_tb_src_waddr_d1:fill_tb_src_waddr;
wire [`FILL_TB_NBITS-1:0] fill_wdata = ecdsa_irl_fill_tb_src_wr_d1?ecdsa_irl_fill_tb_src_wdata_d1:fill_tb_src_wdata;


/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
	        fill_tb_src_ack <= 1'b0;
	        token_bucket_ack <= 1'b0;
	        eir_tb_ack <= 1'b0;
	end else begin
	        fill_tb_src_ack <= fill_tb_src_rd;
	        token_bucket_ack <= token_bucket_rd;
	        eir_tb_ack <= eir_tb_rd;
	end


/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
	        ecdsa_irl_fill_tb_src_waddr_d1 <= ecdsa_irl_fill_tb_src_waddr;
	        ecdsa_irl_fill_tb_src_wdata_d1 <= ecdsa_irl_fill_tb_src_wdata;
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
	        ecdsa_irl_fill_tb_src_wr_d1 <= 1'b0;
	end else begin
	        ecdsa_irl_fill_tb_src_wr_d1 <= ecdsa_irl_fill_tb_src_wr;
	end


pio_rw_mem #(`LIMITING_PROFILE_NBITS, `LIMITER_NBITS) u_pio_rw_mem0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_limiting_profile_cir),

		.app_mem_rd(limiting_profile_cir_rd),
		.app_mem_raddr(limiting_profile_cir_raddr),

		.app_mem_wr(limiting_profile_cir_wr),
		.app_mem_waddr(limiting_profile_cir_waddr),
		.app_mem_wdata(limiting_profile_cir_wdata),

        	.mem_ack(limiting_profile_cir_mem_ack),
        	.mem_rdata(limiting_profile_cir_mem_rdata),

		.app_mem_ack(limiting_profile_cir_ack),
		.app_mem_rdata(limiting_profile_cir_rdata)
);

pio_rw_mem #(`LIMITING_PROFILE_NBITS, `LIMITER_NBITS) u_pio_rw_mem1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_limiting_profile_eir),

		.app_mem_rd(limiting_profile_eir_rd),
		.app_mem_raddr(limiting_profile_eir_raddr),

		.app_mem_wr(limiting_profile_eir_wr),
		.app_mem_waddr(limiting_profile_eir_waddr),
		.app_mem_wdata(limiting_profile_eir_wdata),

        	.mem_ack(limiting_profile_eir_mem_ack),
        	.mem_rdata(limiting_profile_eir_mem_rdata),

		.app_mem_ack(limiting_profile_eir_ack),
		.app_mem_rdata(limiting_profile_eir_rdata)
);


ram_1r1w #(`FILL_TB_NBITS, DEPTH_NBITS) u_ram_1r1w_0(
		.clk(clk),
		.wr(fill_wr),
		.raddr(fill_tb_src_raddr),
		.waddr(fill_waddr),
		.din(fill_wdata),

		.dout(fill_tb_src_rdata));


ram_1r1w #(EIR_TB_NBITS, `PORT_ID_NBITS) u_ram_1r1w_1(
		.clk(clk),
		.wr(eir_tb_wr),
		.raddr(eir_tb_raddr),
		.waddr(eir_tb_waddr),
		.din(eir_tb_wdata),

		.dout(eir_tb_rdata));


ram_1r1w #(BUCKET_NBITS, DEPTH_NBITS) u_ram_1r1w_2(
		.clk(clk),
		.wr(token_bucket_wr),
		.raddr(token_bucket_raddr),
		.waddr(token_bucket_waddr),
		.din(token_bucket_wdata),

		.dout(token_bucket_rdata));


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

