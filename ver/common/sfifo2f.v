//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : depth/width parameterized synchronous FIFO (depth=2**n)
//		implemented with flops
//===========================================================================

`include "defines.vh"

module sfifo2f (

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
parameter DEPTH_BITS = 3;

input clk;
input `RESET_SIG;

input [(WIDTH - 1):0] din;
input rd, wr;

output [DEPTH_BITS:0] count;
output full, empty, fullm1, emptyp2;

output [(WIDTH - 1):0] dout;


/*****************************************************************************/

wire [(DEPTH_BITS - 1):0] rptr, wptr;

sfifo_ctrl #(DEPTH_BITS) u_sfifo_ctrl(

                // inputs

                .clk                    (clk),
                .`RESET_SIG                (`RESET_SIG),

                .rd                     (rd),
                .wr                     (wr),

                //outputs

                .pfull                  (),
                .pempty                 (),
                .ncount                 (),
                .count                  (count),
                .full                   (full),
                .empty                  (empty),
                .fullm1                 (fullm1),
                .emptyp1                (),
                .emptyp2                (emptyp2),
                .nrptr                  (),
                .rptr                   (rptr),
                .wptr                   (wptr)
);

fifo_data #(WIDTH, DEPTH_BITS) u_fifo_data(

                // inputs

                .clk                    (clk),

                .rptr                   (rptr),
                .wptr                   (wptr),
                .wr                     (wr),
                .din                    (din),

                //outputs

                .dout                   (dout)
);

endmodule

