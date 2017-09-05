//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 2-deep DEPTH/WIDTH parameterized synchronous FIFO
//		implemented with flops
//===========================================================================

`include "defines.vh"

module sfifo2f1 (

	// inputs

	clk,
	`RESET_SIG,

	din,
	rd,
	wr,

	//outputs

	count,
	full,
	empty,
	fullm1,
	emptyp2,
	dout 

	);

parameter WIDTH = 16;
parameter DEPTH_NBITS = 1;
parameter DEPTH = 2;
parameter MAXM1 = (16'h1<<DEPTH_NBITS)-1;


input clk;
input `RESET_SIG;

input [(WIDTH - 1):0] din;
input rd, wr;

output [DEPTH_NBITS:0] count;
output full, empty, fullm1, emptyp2;

output [(WIDTH - 1):0] dout;


/***************************** LOCAL VARIABLES *******************************/

reg full, empty, fullm1, emptyp2;

reg [DEPTH_NBITS-1:0] rptr /* synthesis maxfan = 16 preserve */;
reg [DEPTH_NBITS-1:0] wptr /* synthesis maxfan = 16 preserve */;

wire [DEPTH_NBITS-1:0] nrptr = rptr + rd;
wire [DEPTH_NBITS-1:0] nwptr = wptr + wr;

wire ncount0 = nwptr - nrptr;

reg count0;

wire nfull = ~empty & (nwptr == rptr) & ~rd;
wire [DEPTH_NBITS:0] ncount = {nfull, ncount0};

/***************************** NON REGISTERED OUTPUTS ***********************/

fifo_data #(WIDTH, DEPTH_NBITS) u_fifo_data(

                // inputs

                .clk                    (clk),

                .rptr                   (rptr),
                .wptr                   (wptr),
                .wr                     (wr),
                .din                    (din),

                //outputs

                .dout                   (dout)
);

/***************************** REGISTERED OUTPUTS ***************************/

assign count = {full, count0};

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		full <= 1'b0;
		empty <= 1'b1;
		fullm1 <= 1'b0;
		emptyp2 <= 1'b0;
	end else begin
		full <= nfull;
		empty <= ~full & (nrptr == wptr) & ~wr;
		fullm1 <= (ncount==MAXM1);
		emptyp2 <= (ncount==2'd2);
	end


/***************************** PROGRAM BODY *******************************/

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		rptr <= 1'b0;
		wptr <= 1'b0;
		count0 <= 1'b0;
	end else begin
		rptr <= nrptr;
		wptr <= nwptr;
		count0 <= ncount0;
	end

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
always @(posedge clk) begin
	if (`INACTIVE_RESET & wr & full) $display("ERROR: %d %m write when FIFO full", $time);
	if (`INACTIVE_RESET & rd & empty) $display("ERROR: %d %m read when FIFO empty", $time);
end
// synopsys translate_on

endmodule

