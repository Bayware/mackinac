//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 2-deep DEPTH/WIDTH parameterized synchronous FIFO
//		implemented with flops
//===========================================================================

`include "defines.vh"

module sfifo2f1_flop (

	// inputs

	clk,
	reset,

	din,
	rd,
	wr,

	//outputs

	count,
	full,
	empty,
	empty_rep,
	fullm1,
	emptyp2,
	dout 

	);

parameter WIDTH = 32;
parameter DEPTH_BITS = 1;
parameter DEPTH = 2;
parameter MAXM1 = (16'h1<<DEPTH_BITS)-1;


input clk;
input reset;

input [(WIDTH - 1):0] din;
input rd, wr;

output [DEPTH_BITS:0] count;
output full, empty, empty_rep, fullm1, emptyp2;

output [(WIDTH - 1):0] dout;


/***************************** LOCAL VARIABLES *******************************/

reg [(WIDTH - 1):0] reg0;
reg [(WIDTH - 1):0] reg1;

reg full, empty, empty_rep, fullm1, emptyp2;

reg rptr_rep, rptr, wptr;

wire nrptr = rptr + rd;
wire nwptr = wptr + wr;

wire ncount0 = nwptr - nrptr;

reg count0;

wire nfull = ~empty & (nwptr == rptr) & ~rd;
wire [DEPTH_BITS:0] ncount = {nfull, ncount0};

/***************************** NON REGISTERED OUTPUTS ***********************/

assign dout[15:0] = rptr?reg1[15:0]:reg0[15:0];
assign dout[(WIDTH - 1):16] = rptr_rep?reg1[(WIDTH - 1):16]:reg0[(WIDTH - 1):16];

/***************************** REGISTERED OUTPUTS ***************************/

assign count = {full, count0};

always @(`CLK_RST) 
    if (reset) begin
		full <= 1'b0;
		empty <= 1'b1;
		empty_rep <= 1'b1;
		fullm1 <= 1'b0;
		emptyp2 <= 1'b0;
	end else begin
		full <= nfull;
		empty <= ~full & (nrptr == wptr) & ~wr;
		empty_rep <= ~full & (nrptr == wptr) & ~wr;
		fullm1 <= (ncount==MAXM1);
		emptyp2 <= (ncount==2'd2);
	end


/***************************** PROGRAM BODY *******************************/

always @(posedge clk) begin
		reg0 <= wr&~wptr?din:reg0;
		reg1 <= wr&wptr?din:reg1;
end

always @(`CLK_RST) 
	if (reset) begin
		rptr_rep <= 1'b0;
		rptr <= 1'b0;
		wptr <= 1'b0;
		count0 <= 1'b0;
	end else begin
		rptr_rep <= nrptr;
		rptr <= nrptr;
		wptr <= nwptr;
		count0 <= ncount0;
	end

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
always @(posedge clk) begin
	if (~reset & wr & full) $display("ERROR: %d %m write when FIFO full", $time);
	if (~reset & rd & empty) $display("ERROR: %d %m read when FIFO empty", $time);
end
// synopsys translate_on

endmodule

