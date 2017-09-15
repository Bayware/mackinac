//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION :
//===========================================================================

`include "defines.vh"

module pio2reg_bus #(
  parameter BLOCK_ADDR_LSB = 20,
  parameter BLOCK_ADDR = 20,
  parameter REG_BLOCK_ADDR_LSB = 20,
  parameter REG_BLOCK_ADDR = 20
) (

input clk, 
input `RESET_SIG, 

input         pio_start,
input         pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

output reg clk_div, 

output reg [`PIO_RANGE] reg_addr,
output [`PIO_RANGE] reg_din,
output reg reg_rd,
output reg reg_wr,
output mem_bs,
output reg_bs

);

/***************************** LOCAL VARIABLES *******************************/

reg [1:0] cnt;

reg pio_start_d1;
reg pio_start_d2;
reg pio_rw_d1;
reg [`PIO_RANGE] pio_addr_wdata_d1;

wire start_pulse = pio_start_d1&~pio_start_d2;

/***************************** NON REGISTERED OUTPUTS ************************/

assign mem_bs = reg_addr[`PIO_ADDR_MSB:BLOCK_ADDR_LSB]==BLOCK_ADDR;
assign reg_bs = reg_addr[`PIO_ADDR_MSB:REG_BLOCK_ADDR_LSB]==REG_BLOCK_ADDR;

/***************************** REGISTERED OUTPUTS ****************************/

assign reg_din = pio_addr_wdata_d1;

always @(posedge clk) begin
  reg_addr <= start_pulse?pio_addr_wdata_d1:reg_addr;
end

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
	  clk_div <= 1'b0;
	  reg_wr <= 1'b0;
	  reg_rd <= 1'b0;
	end else begin
	  clk_div <= &cnt;
	  reg_wr <= start_pulse&pio_rw_d1;
	  reg_rd <= start_pulse&~pio_rw_d1;
	end
end

/***************************** PROGRAM BODY **********************************/
always @(posedge clk) begin
	pio_addr_wdata_d1 <= pio_addr_wdata;
	pio_start_d1 <= pio_start;
	pio_start_d2 <= pio_start_d1;
	pio_rw_d1 <= pio_rw;
end

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
	  cnt <= 2'b0;
	end else begin
	  cnt <= cnt+2'b1;
	end
end

endmodule

