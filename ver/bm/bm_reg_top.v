//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : bm registers
//===========================================================================

`include "defines.vh"

module bm_reg_top (

input clk, 
input `RESET_SIG, 

input         pio_start,
input         pio_rw,
input [`PIO_RANGE] pio_addr_wdata,

input   	  freeb_init_done,

input         inc_freeb_rd_count,
input         inc_freeb_wr_count,

input         inc_ll_rd_count,
input         inc_ll_wr_count,

output pio_ack,
output pio_rvalid,
output [`PIO_RANGE] pio_rdata,

output        freeb_init,
output [3:0]  dt_alpha

);

/***************************** LOCAL VARIABLES *******************************/

wire reg_selected;
wire reg_rd;
wire reg_wr;
wire [`PIO_RANGE] reg_addr;
wire [`PIO_RANGE] reg_rdata;
wire reg_bs;
wire [`PIO_RANGE] reg_din;

/***************************** PROGRAM BODY **********************************/
pio2reg_bus #(
  BLOCK_ADDR_LSB = `BM_BLOCK_ADDR_LSB;
  BLOCK_ADDR = `BM_BLOCK_ADDR;
) u_pio2reg_bus (

clk, 
`RESET_SIG, 

pio_start,
pio_rw,
pio_addr_wdata,

reg_addr,
reg_din,
reg_rd,
reg_wr,
reg_bs

);

bm_reg u_bm_reg(

clk, 
`RESET_SIG, 

reg_bs,
reg_wr,
reg_addr,
reg_din,

freeb_init_done,

inc_freeb_rd_count,
inc_freeb_wr_count,

inc_ll_rd_count,
inc_ll_wr_count,

reg_selected,
reg_rdata,

freeb_init,
dt_alpha

);

reg2pio_data u_reg2pio_data (

clk, 
`RESET_SIG, 

reg_bs,
reg_rd,
reg_wr

reg_selected,
reg_rdata,

pio_ack,
pio_rvalid,
pio_rdata

);

endmodule

