//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : synchronous FIFO based on RAM
//===========================================================================

`include "defines.vh"

import meta_package::*;

module sfifo_ram_enq_pkt_desc (

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

parameter DEPTH_NBITS = 12;
parameter DEPTH = (16'h1 << DEPTH_NBITS);


input clk;
input `RESET_SIG;

input enq_pkt_desc_type din;
input rd, wr;

output [DEPTH_NBITS-1:0] wptr;
output [DEPTH_NBITS:0] count;
output full, empty;

output enq_pkt_desc_type dout;

/*****************************************************************************/

wire ren = rd;
wire wen = wr;
wire ren1 = ren;//&~empty;
wire wen1 = wen;//&~full;

wire [(DEPTH_NBITS - 1):0] rptr;
wire [DEPTH_NBITS:0] ncount;


//sfifo_ctrl #(DEPTH_NBITS, DEPTH, DEPTH-1, 1) sfifo_ctrl_inst(
sfifo_ctrl #(DEPTH_NBITS, DEPTH, DEPTH-1, 0) u_sfifo_ctrl(

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

(* ram_style = "block" *)
enq_pkt_desc_type mem_d[DEPTH-1:0];

always @(posedge clk) 
	if(wen1) mem_d[wptr] <= din;

always @(posedge clk)
	dout <= mem_d[rptr];

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
// synopsys translate_on

endmodule

