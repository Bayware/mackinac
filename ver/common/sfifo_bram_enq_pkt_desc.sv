//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : synchronous FIFO based on RAM
//===========================================================================

`include "defines.vh"

import meta_package::*;

module sfifo_bram_enq_pkt_desc (

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

localparam WIDTH = `ENQ_PKT_DESC_NBITS;

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
logic [WIDTH-1:0] mem_d[DEPTH-1:0];

logic [WIDTH-1:0] dout0;

wire [WIDTH-1:0] din0 = {
			din.src_port, 
			din.dst_port, 
			din.buf_ptr, 
			din.ed_cmd.ptr_update, 
			din.ed_cmd.cur_ptr, 
			din.ed_cmd.ptr_loc, 
			din.ed_cmd.pd_update, 
			din.ed_cmd.pd_len, 
			din.ed_cmd.pd_loc, 
			din.ed_cmd.pd_buf_ptr, 
			din.ed_cmd.out_rci, 
			din.ed_cmd.len}; 

assign 	{
	dout.src_port, 
	dout.dst_port, 
	dout.buf_ptr, 
	dout.ed_cmd.ptr_update, 
	dout.ed_cmd.cur_ptr, 
	dout.ed_cmd.ptr_loc, 
	dout.ed_cmd.pd_update, 
	dout.ed_cmd.pd_len, 
	dout.ed_cmd.pd_loc, 
	dout.ed_cmd.pd_buf_ptr, 
	dout.ed_cmd.out_rci, 
	dout.ed_cmd.len} = dout0; 

always @(posedge clk) 
	if(wen1) mem_d[wptr] <= din0;

always @(posedge clk)
	dout0 <= mem_d[rptr];

/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
// synopsys translate_on

endmodule

