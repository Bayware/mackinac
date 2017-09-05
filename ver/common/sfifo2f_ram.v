//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : synchronous FIFO based on RAM
//===========================================================================

`include "defines.vh"

module sfifo2f_ram (

	// inputs

	clk,
	`RESET_SIG,

	din,
	rd,
	wr,

	//outputs

	wptr,
	count,
	full,
	empty,
	dout 

	);

parameter WIDTH = 12;
parameter DEPTH_BITS = 12;
parameter DEPTH = (16'h1 << DEPTH_BITS);


input clk;
input `RESET_SIG;

input [(WIDTH - 1):0] din;
input rd, wr;

output [DEPTH_BITS-1:0] wptr;
output [DEPTH_BITS:0] count;
output full, empty;

output [(WIDTH - 1):0] dout;

/*****************************************************************************/

wire ren = rd;
wire wen = wr;
wire ren1 = ren;//&~empty;
wire wen1 = wen;//&~full;

wire [(DEPTH_BITS - 1):0] rptr;
wire [DEPTH_BITS:0] ncount;


//sfifo_ctrl #(DEPTH_BITS, DEPTH, DEPTH-1, 1) sfifo_ctrl_inst(
sfifo_ctrl #(DEPTH_BITS, DEPTH, DEPTH-1, 0) u_sfifo_ctrl(

                // inputs

                .clk                    (clk),
                .`RESET_SIG                (`RESET_SIG),

                .rd                     (ren1),
                .wr                     (wen1),

                //outputs

                .pfull                  (full),
                .pempty                 (),
                .ncount                 (ncount),
                .count                  (count),
                .full                   (),
                .empty                  (empty),
                .fullm1                 (),
                .emptyp1                (),
                .emptyp2                (),
                .nrptr                  (),
                .rptr                   (rptr),
                .wptr                   (wptr)
);

ram_1r1w_bram #(WIDTH, DEPTH_BITS) u_ram_1r1w_bram(
        .clk(clk),
        .wr(wen1),
        .raddr(rptr),
        .waddr(wptr),
        .din(din),
        .dout(dout));

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
// synopsys translate_on

endmodule

