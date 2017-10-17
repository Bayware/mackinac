//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : PIO accessable wide memory
//===========================================================================

`include "defines.vh"

module pio_rw_wmem #(
  parameter WIDTH = 40,
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

input app_mem_rd, 
input [DEPTH_NBITS-1:0] app_mem_raddr,

input app_mem_wr, 
input [DEPTH_NBITS-1:0] app_mem_waddr,
input [WIDTH-1:0] app_mem_wdata,

output reg   mem_ack,
output reg [`PIO_RANGE] mem_rdata,

output reg app_mem_ack, 
output reg [WIDTH-1:0] app_mem_rdata

);
/***************************** LOCAL VARIABLES *******************************/

reg n_mem_ack;

reg app_mem_rd_d1; 
reg app_mem_rd_d2; 
reg [DEPTH_NBITS-1:0] app_mem_raddr_d1;
reg app_mem_wr_d1; 
reg app_mem_wr_d2; 
reg [DEPTH_NBITS-1:0] app_mem_waddr_d1;
reg [WIDTH-1:0] app_mem_wdata_d1;
reg [`PIO_RANGE] ram_wdata_lsb;
reg [WIDTH-1:-`PIO_NBITS] ram_rdata_d1;
reg ram_rd_save;
reg ram_wr_save;
reg ram_rd_mem_ack_lsb_d1;
reg ram_wr_mem_ack_msb_d1;

wire [`PIO_ADDR_MSB-2:0] reg_addr_dw = reg_addr[`PIO_ADDR_MSB:2];

wire ram_wr_lsb = reg_ms&reg_wr&~reg_addr_dw[0];
wire ram_wr_msb = reg_ms&reg_wr&reg_addr_dw[0];
wire ram_rd_lsb = reg_ms&reg_rd&~reg_addr_dw[0];
wire ram_rd_msb = reg_ms&reg_rd&reg_addr_dw[0];

wire [WIDTH-1:0] ram_rdata /* synthesis DONT_TOUCH */;

wire ram_rd_mem_ack_lsb = ~app_mem_rd_d1&(ram_rd_lsb|ram_rd_save);
wire ram_wr_mem_ack_msb = ~app_mem_wr_d1&(ram_wr_msb|ram_wr_save);

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	app_mem_rdata <= ram_rdata;
        mem_rdata <= ram_rd_mem_ack_lsb_d1?ram_rdata[`PIO_RANGE]:ram_rd_msb?ram_rdata_d1:mem_rdata;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	app_mem_ack <= 0;
	mem_ack <= 0;
    end else begin
	app_mem_ack <= app_mem_rd_d2;
	mem_ack <= clk_div?n_mem_ack:mem_ack;
    end

/***************************** PROGRAM BODY **********************************/

wire [`PIO_ADDR_MSB-3:0] reg_addr_qw = reg_addr[`PIO_ADDR_MSB:3];

wire [DEPTH_NBITS-1:0] ram_raddr = app_mem_rd_d1?app_mem_raddr_d1:reg_addr_qw[DEPTH_NBITS-1:0];
wire ram_wr = app_mem_wr_d1|(REG_WR_EN&ram_wr_mem_ack_msb);
wire [DEPTH_NBITS-1:0] ram_waddr = app_mem_wr_d1?app_mem_waddr_d1:reg_addr_qw[DEPTH_NBITS-1:0];
wire [WIDTH-1:0] ram_wdata = app_mem_wr_d1?app_mem_wdata_d1:{reg_din[WIDTH-1-`PIO_NBITS:0], ram_wdata_lsb};

always @(posedge clk) begin
	app_mem_raddr_d1 <= app_mem_raddr;
        app_mem_waddr_d1 <= app_mem_waddr;
	app_mem_wdata_d1 <= app_mem_wdata;
	ram_wdata_lsb <= ram_wr_lsb?reg_din:ram_wdata_lsb;
	ram_rdata_d1 <= ram_rd_mem_ack_lsb_d1?ram_rdata[WIDTH-1:`PIO_NBITS]:ram_rdata_d1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	        n_mem_ack <= 1'b0;
		app_mem_rd_d1 <= 0;
		app_mem_rd_d2 <= 0;
                app_mem_wr_d1 <= 0;
		app_mem_wr_d2 <= 0;
		ram_rd_save <= 0;
                ram_rd_mem_ack_lsb_d1 <= 1'b0;
                ram_wr_mem_ack_msb_d1 <= 1'b0;
		ram_wr_save <= 0;
	end else begin
	        n_mem_ack <= ram_rd_msb|ram_rd_mem_ack_lsb_d1|ram_wr_lsb|ram_wr_mem_ack_msb_d1?1'b1:clk_div?1'b0:n_mem_ack;
		app_mem_rd_d1 <= app_mem_rd;
		app_mem_rd_d2 <= app_mem_rd_d1;
                app_mem_wr_d1 <= app_mem_wr;
		app_mem_wr_d2 <= app_mem_wr_d1;
		ram_rd_save <= app_mem_rd_d1&ram_rd_lsb?1'b1:ram_rd_mem_ack_lsb?1'b0:ram_rd_save;
                ram_rd_mem_ack_lsb_d1 <= ram_rd_mem_ack_lsb;
                ram_wr_mem_ack_msb_d1 <= ram_wr_mem_ack_msb;
		ram_wr_save <= app_mem_wr_d1&ram_wr_msb?1'b1:ram_wr_mem_ack_msb?1'b0:ram_wr_save;
	end

/***************************** MEMORY ***************************************/
ram_1r1w #(WIDTH, DEPTH_NBITS) u_ram_1r1w(
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

