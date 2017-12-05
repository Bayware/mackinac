//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : PIO accessable memory
//===========================================================================

`include "defines.vh"

module pio_rw_dmem_bram #(
  parameter WIDTH = 32,
  parameter DEPTH_NBITS = 10,
  parameter REG_WR_EN = 1'b1
)(

input clk, 
input `RESET_SIG, 

input clk_div, 

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms,

input   [3:0] wea,
input   [DEPTH_NBITS-1:0] addra,
input   [WIDTH-1:0] dina,

output  [WIDTH-1:0] douta,

input app_mem_rd, 

input   [3:0] web,
input   [DEPTH_NBITS-1:0] addrb,
input   [WIDTH-1:0] dinb,

(* keep = "true" *) output [WIDTH-1:0] doutb ,

output     reg   mem_ack,
output reg [`PIO_RANGE] mem_rdata

);
/***************************** LOCAL VARIABLES *******************************/

reg n_mem_ack;

reg ram_rd_save;
reg ram_wr_save;
reg ram_rd_mem_ack_d1;

wire mreg_wr = reg_wr&(reg_addr[`PU_MEM_CYCLE_DEPTH_MSB:`PU_MEM_META_DEPTH_LSB]==`REGISTERS_BASE);
wire reg_ram_wr = reg_ms&mreg_wr;
wire ram_rd = reg_ms&reg_rd;

wire app_mem_wr = |web;

wire ram_rd_mem_ack = ~app_mem_rd&(ram_rd|ram_rd_save);
wire ram_wr_mem_ack = ~app_mem_wr&(reg_ram_wr|ram_wr_save);

wire [DEPTH_NBITS-1:0] app_mem_raddr = addrb;

wire [DEPTH_NBITS-1:0] app_mem_waddr = addrb;
wire [WIDTH-1:0] app_mem_wdata = dinb;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
        mem_rdata <= ram_rd_mem_ack_d1?{{(`PIO_NBITS-WIDTH){1'b0}}, doutb}:doutb;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	mem_ack <= 0;
    end else begin
	mem_ack <= clk_div?n_mem_ack:mem_ack;
    end

/***************************** PROGRAM BODY **********************************/

wire [`PIO_ADDR_MSB-2:0] reg_addr_dw = reg_addr[`PIO_ADDR_MSB:2];

wire [DEPTH_NBITS-1:0] ram_raddr = app_mem_rd?app_mem_raddr:reg_addr_dw[DEPTH_NBITS-1:0];
wire ram_wr = app_mem_wr|(REG_WR_EN&ram_wr_mem_ack);
wire [DEPTH_NBITS-1:0] ram_waddr = app_mem_wr?app_mem_waddr:reg_addr_dw[DEPTH_NBITS-1:0];
wire [WIDTH-1:0] ram_wdata = app_mem_wr?app_mem_wdata:reg_din[WIDTH-1:0];

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	        n_mem_ack <= 0;
		ram_rd_save <= 0;
                ram_rd_mem_ack_d1 <= 1'b0;
		ram_wr_save <= 0;
	end else begin
		n_mem_ack <= ram_wr_mem_ack|ram_rd_mem_ack_d1?1'b1:clk_div?1'b0:n_mem_ack;
		ram_rd_save <= app_mem_rd&ram_rd?1'b1:ram_rd_mem_ack?1'b0:ram_rd_save;
                ram_rd_mem_ack_d1 <= ram_rd_mem_ack;
		ram_wr_save <= app_mem_wr&reg_ram_wr?1'b1:ram_wr_mem_ack?1'b0:ram_wr_save;
	end

/***************************** MEMORY ***************************************/
ram_dual_we_bram #(WIDTH/4, DEPTH_NBITS) u_ram_dual_we_bram(
	.clka(clk), 
	.wea(wea), 
	.addra(addra),
	.dina(dina), 
	.douta(douta), 
	.clkb(clk), 
	.web({(4){ram_wr}}), 
	.addrb(~ram_wr?ram_raddr:ram_waddr), 
	.dinb(ram_wdata), 
	.doutb(doutb));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

