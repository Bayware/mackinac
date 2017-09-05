//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================


`include "defines.vh"

module tm_sch_event_fifo #(
	
parameter WIDTH = `FIRST_LVL_SCH_ID_NBITS,
parameter DEPTH_NBITS = `FIRST_LVL_SCH_ID_NBITS
) (

input clk, `RESET_SIG,

input push,
input [WIDTH-1:0] push_data,

input pop,

output [WIDTH-1:0] pop_data,
output sch_fifo_empty,
output reg [DEPTH_NBITS:0] fifo_count

);

/***************************** LOCAL VARIABLES *******************************/

reg fifo_rd_d1;

wire [WIDTH-1:0] prefetch_fifo_dout;
wire prefetch_fifo_full, prefetch_fifo_fullm1;
wire prefetch_fifo_empty;

wire [WIDTH-1:0] fifo_dout;
wire fifo_empty, fifo_full;

wire fifo_wr = push;

/***************************** NON REGISTERED OUTPUTS ************************/

assign pop_data = prefetch_fifo_dout;

/***************************** REGISTERED OUTPUTS ****************************/

assign sch_fifo_empty = prefetch_fifo_empty;

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		fifo_count <= 0;
	end else begin
		fifo_count <= ~(push^pop)?fifo_count:fifo_wr?fifo_count+1:fifo_count-1;
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
 

sfifo2f_ram #(WIDTH, DEPTH_NBITS) u_sfifo2f_ram(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(push_data),				
    .rd(fifo_rd),
    .wr(push),

	.wptr(), 
	.count(), 
	.full(fifo_full),
	.empty(fifo_empty),
    .dout(fifo_dout)       
);

// free queue prefetch FIFO to hide memory based FIFO latency
sfifo2f1 #(WIDTH) u_sfifo2f1(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_dout),				
    .rd(pop),
    .wr(prefetch_fifo_wr),

	.count(),
	.full(prefetch_fifo_full),
	.empty(prefetch_fifo_empty),
	.fullm1(prefetch_fifo_fullm1),
	.emptyp2(),
    .dout(prefetch_fifo_dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

