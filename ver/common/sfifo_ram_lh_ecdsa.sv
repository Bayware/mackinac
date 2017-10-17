//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : synchronous FIFO based on RAM
//===========================================================================

`include "defines.vh"

import meta_package::lh_ecdsa_meta_type;

module sfifo_ram_lh_ecdsa (

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

input lh_ecdsa_meta_type din;
input rd, wr;

output [DEPTH_NBITS-1:0] wptr;
output [DEPTH_NBITS:0] count;
output full, empty;

output lh_ecdsa_meta_type dout;

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

localparam WIDTH = `LH_ECDSA_META_NBITS;
(* ram_style = "ultra" *)
logic [WIDTH-1:0] mem_d[DEPTH-1:0];

logic [WIDTH-1:0] dout0;

wire [WIDTH-1:0] din0 = {
			din.traffic_class, 
			din.hdr_len, 
			din.buf_ptr, 
			din.len,
			din.port, 
			din.rci, 
			din.fid, 
			din.tid, 
			din.type1, 
			din.type3, 
			din.discard
			}; 

assign {
			dout.traffic_class, 
			dout.hdr_len, 
			dout.buf_ptr, 
			dout.len,
			dout.port, 
			dout.rci, 
			dout.fid, 
			dout.tid, 
			dout.type1, 
			dout.type3, 
			dout.discard
			} = dout0; 

always @(posedge clk) 
	if(wen1) mem_d[wptr] <= din0;

always @(posedge clk)
	dout0 <= mem_d[rptr];

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
// synopsys translate_on

endmodule

