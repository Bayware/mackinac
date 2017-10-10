//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : PIO accessable memory
//===========================================================================

`include "defines.vh"

module pio_mem_bram_f #(
  parameter WIDTH = 20,
  parameter DEPTH_NBITS = 10
)(

input clk, 
input `RESET_SIG, 

input clk_div, 

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms,

input app_mem_rd, 
input [DEPTH_NBITS-1:0] app_mem_raddr,

output reg   mem_ack,
output reg [`PIO_RANGE] mem_rdata,

output reg app_mem_ack, 
output [WIDTH-1:0] app_mem_rdata

);
/***************************** LOCAL VARIABLES *******************************/

reg n_mem_ack;

reg ram_rd_save;
reg ram_rd_mem_ack_d1;

wire ram_wr = reg_ms&reg_wr;
wire ram_rd = reg_ms&reg_rd;

wire [WIDTH-1:0] ram_rdata /* synthesis keep = 1 */;

wire ram_rd_mem_ack = ~app_mem_rd&(ram_rd|ram_rd_save);

/***************************** NON REGISTERED OUTPUTS ************************/

assign app_mem_rdata = ram_rdata;

/***************************** REGISTERED OUTPUTS ****************************/


always @(posedge clk) begin
        mem_rdata <= ram_rd_mem_ack_d1?{{(`PIO_NBITS-WIDTH){1'b0}}, ram_rdata}:mem_rdata;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	app_mem_ack <= 0;
	mem_ack <= 0;
    end else begin
	app_mem_ack <= app_mem_rd;
	mem_ack <= clk_div?n_mem_ack:mem_ack;
    end

/***************************** PROGRAM BODY **********************************/

wire [`PIO_ADDR_MSB-2:0] reg_addr_dw = reg_addr[`PIO_ADDR_MSB:2];

wire [DEPTH_NBITS-1:0] ram_raddr = app_mem_rd?app_mem_raddr:reg_addr_dw[DEPTH_NBITS-1:0];
wire [DEPTH_NBITS-1:0] ram_waddr = reg_addr_dw[DEPTH_NBITS-1:0];
wire [WIDTH-1:0] ram_wdata = reg_din[WIDTH-1:0];

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		n_mem_ack <= 0;
		ram_rd_save <= 0;
                ram_rd_mem_ack_d1 <= 1'b0;
	end else begin
		n_mem_ack <= ram_wr|ram_rd_mem_ack_d1?1'b1:clk_div?1'b0:n_mem_ack;
		ram_rd_save <= app_mem_rd&ram_rd?1'b1:mem_ack?1'b0:ram_rd_save;
                ram_rd_mem_ack_d1 <= ram_rd_mem_ack;
	end

/***************************** MEMORY ***************************************/
ram_1r1w_bram #(WIDTH, DEPTH_NBITS) u_ram_1r1w_bram(
		.clk(clk),
		.wr(ram_wr),
		.raddr(ram_raddr),
		.waddr(ram_waddr),
		.din(ram_wdata),

		.dout(ram_rdata)
);

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

