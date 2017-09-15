// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module sfifo2f_ram_pf #(
parameter WIDTH = 12,
parameter DEPTH_NBITS = 12,
parameter DEPTH = (16'h1 << DEPTH_NBITS)
) (

input clk,
input `RESET_SIG,

input [(WIDTH - 1):0] din,
input rd, wr,

output reg [DEPTH_NBITS:0] count,
output full, empty,

output [(WIDTH - 1):0] dout

);

/***************************** LOCAL VARIABLES *******************************/

reg fifo_rd_d1;

wire [WIDTH-1:0] prefetch_fifo_dout;
wire prefetch_fifo_full, prefetch_fifo_fullm1;

wire [WIDTH-1:0] fifo_dout;
wire fifo_empty;

/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		count <= 0;
	end else begin
		count <= ~(wr^rd)?count:wr?count+1:count-1;
	end

/***************************** PROGRAM BODY **********************************/

wire prefetch_fifo_wr = fifo_rd_d1;

wire fifo_rd = ~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		fifo_rd_d1 <= 0;
	end else begin
		fifo_rd_d1 <= fifo_rd;
	end
 
/***************************** NEXT STATE ASSIGNMENT **************************/

/***************************** STATE MACHINE *******************************/

/***************************** FIFO ***************************************/


sfifo2f_ram #(WIDTH, DEPTH_NBITS) u_sfifo2f_ram(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(din),				
    .rd(fifo_rd),
    .wr(wr),

	.wptr(), 
	.count(), 
	.full(full),
	.empty(fifo_empty),
    .dout(fifo_dout)       
);

sfifo2f_fo #(WIDTH, 2) u_sfifo2f_fo(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_dout),				
    .rd(rd),
    .wr(prefetch_fifo_wr),

	.ncount(),
	.count(),
	.full(prefetch_fifo_full),
	.empty(empty),
	.fullm1(prefetch_fifo_fullm1),
	.emptyp2(),
    .dout(dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

