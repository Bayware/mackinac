//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : depth/width parameterized synchronous FIFO (DEPTH=n)
//		implemented with flops
//===========================================================================

`include "defines.vh"

module sfifof (

	// inputs

	clk,
	`RESET_SIG,

	din,
	rd,
	wr,

	//outputs

	ncount,
	count,
	full,
	empty,
	fullm1,
	emptyp1,
	emptyp2,
	dout 

	);

parameter WIDTH = 16;
parameter DEPTH_BITS = 3;
parameter DEPTH = 7;


input clk;
input `RESET_SIG;

input [(WIDTH - 1):0] din;
input rd, wr;

output [(DEPTH_BITS-1):0] ncount, count;
output full, empty, fullm1, emptyp1, emptyp2;

output [(WIDTH - 1):0] dout;


/*****************************************************************************/

/* (* keep = "true", max_fanout = 100 *) */ wire [(DEPTH_BITS - 1):0] rptr;
wire [(DEPTH_BITS - 1):0] wptr;

wire unused0, unused1;

sfifo_ctrl #(DEPTH_BITS, DEPTH) u_sfifo_ctrl(

                // inputs

                .clk                    (clk),
                .`RESET_SIG                (`RESET_SIG),

                .rd                     (rd),
                .wr                     (wr),

                //outputs

                .pfull                  (),
                .pempty                 (),
                .ncount                 ({unused0, ncount[DEPTH_BITS-1:0]}),
                .count                  ({unused1, count[DEPTH_BITS-1:0]}),
                .full                   (full),
                .empty                  (empty),
                .fullm1                 (fullm1),
                .emptyp1                (emptyp1),
                .emptyp2                (emptyp2),
                .nrptr                  (),
                .rptr                   (rptr),
                .wptr                   (wptr)
);

fifo_data #(WIDTH, DEPTH_BITS, DEPTH) u_fifo_data(

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

