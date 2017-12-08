//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_qm_ds #(
parameter QUEUE_ID_NBITS = 5, // log2(`NUM_OF_PU);
parameter QUEUE_ENTRIES_NBITS = `PU_QUEUE_ENTRIES_NBITS,
parameter QUEUE_DEPTH = `NUM_OF_PU,
parameter QUEUE_PAYLOAD_NBITS = `PU_QUEUE_PAYLOAD_NBITS
) (

input clk, 

input head_wr,
input [QUEUE_ID_NBITS-1:0] head_raddr,
input [QUEUE_ID_NBITS-1:0] head_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] head_wdata,
(* keep = "true" *) output [QUEUE_ENTRIES_NBITS-1:0] head_rdata  ,

input tail_wr,
input [QUEUE_ID_NBITS-1:0] tail_raddr,
input [QUEUE_ID_NBITS-1:0] tail_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] tail_wdata,
(* keep = "true" *) output [QUEUE_ENTRIES_NBITS-1:0] tail_rdata  ,

input depth_wr,
input [QUEUE_ID_NBITS-1:0] depth_raddr,
input [QUEUE_ID_NBITS-1:0] depth_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] depth_wdata,
(* keep = "true" *) output [QUEUE_ENTRIES_NBITS-1:0] depth_rdata  ,

input depth_fid0_wr,
input [QUEUE_ID_NBITS-1:0] depth_fid0_raddr,
input [QUEUE_ID_NBITS-1:0] depth_fid0_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_wdata,
(* keep = "true" *) output [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_rdata  ,

input depth_fid1_wr,
input [QUEUE_ID_NBITS-1:0] depth_fid1_raddr,
input [QUEUE_ID_NBITS-1:0] depth_fid1_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_wdata,
(* keep = "true" *) output [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_rdata  ,

input ll_wr,
input [QUEUE_ENTRIES_NBITS-1:0] ll_raddr,
input [QUEUE_ENTRIES_NBITS-1:0] ll_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] ll_wdata,
(* keep = "true" *) output [QUEUE_ENTRIES_NBITS-1:0] ll_rdata  ,

input desc_wr,
input [QUEUE_ENTRIES_NBITS-1:0] desc_raddr,
input [QUEUE_ENTRIES_NBITS-1:0] desc_waddr,
input pu_queue_payload_type desc_wdata,
(* keep = "true" *) output pu_queue_payload_type desc_rdata  
);

/***************************** MEMORY ***************************************/
// head memory
ram_1r1w_ultra #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS, QUEUE_DEPTH) u_ram_1r1w_ultra_0(
			.clk(clk),
			.wr(head_wr),
			.raddr(head_raddr),
			.waddr(head_waddr),
			.din(head_wdata),

			.dout(head_rdata));

// tail memory
ram_1r1w_ultra #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS, QUEUE_DEPTH) u_ram_1r1w_ultra_1(
        .clk(clk),
        .wr(tail_wr),
        .raddr(tail_raddr),
		.waddr(tail_waddr),
        .din(tail_wdata),

        .dout(tail_rdata));

// depth memory
ram_1r1w_ultra #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS, QUEUE_DEPTH) u_ram_1r1w_ultra_2(
        .clk(clk),
        .wr(depth_wr),
        .raddr(depth_raddr),
		.waddr(depth_waddr),
        .din(depth_wdata),

        .dout(depth_rdata));

// depth_fid0 memory
ram_1r1w_ultra #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS, QUEUE_DEPTH) u_ram_1r1w_ultra_21(
        .clk(clk),
        .wr(depth_fid0_wr),
        .raddr(depth_fid0_raddr),
		.waddr(depth_fid0_waddr),
        .din(depth_fid0_wdata),

        .dout(depth_fid0_rdata));

// depth_fid0 memory
ram_1r1w_ultra #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS, QUEUE_DEPTH) u_ram_1r1w_ultra_22(
        .clk(clk),
        .wr(depth_fid1_wr),
        .raddr(depth_fid1_raddr),
		.waddr(depth_fid1_waddr),
        .din(depth_fid1_wdata),

        .dout(depth_fid1_rdata));

// linked list memory
ram_1r1w_ultra #(QUEUE_ENTRIES_NBITS, QUEUE_ENTRIES_NBITS) u_ram_1r1w_ultra_3(
		.clk(clk),
		.wr(ll_wr),
		.raddr(ll_raddr),
		.waddr(ll_waddr),
		.din(ll_wdata),

		.dout(ll_rdata));

// packet descriptor memory
ram_1r1w_ultra_pu_queue_payload #(QUEUE_ENTRIES_NBITS) u_ram_1r1w_ultra_4(
		.clk(clk),
		.wr(desc_wr),
		.raddr(desc_raddr),
		.waddr(desc_waddr),
		.din(desc_wdata),

		.dout(desc_rdata));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

