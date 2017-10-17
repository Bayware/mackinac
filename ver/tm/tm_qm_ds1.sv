//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm_qm_ds1 #(
parameter QUEUE_ID_NBITS = `SECOND_LVL_QUEUE_ID_NBITS,
parameter QUEUE_ENTRIES_NBITS = `SECOND_LVL_QUEUE_ID_NBITS
) (

input clk, 

input head_wr,
input [QUEUE_ID_NBITS-1:0] head_raddr,
input [QUEUE_ID_NBITS-1:0] head_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] head_wdata,
output [QUEUE_ENTRIES_NBITS-1:0] head_rdata  /* synthesis DONT_TOUCH */,

input tail_wr,
input [QUEUE_ID_NBITS-1:0] tail_raddr,
input [QUEUE_ID_NBITS-1:0] tail_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] tail_wdata,
output [QUEUE_ENTRIES_NBITS-1:0] tail_rdata  /* synthesis DONT_TOUCH */,

input depth_wr,
input [QUEUE_ID_NBITS-1:0] depth_raddr,
input [QUEUE_ID_NBITS-1:0] depth_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] depth_wdata,
output [QUEUE_ENTRIES_NBITS-1:0] depth_rdata  /* synthesis DONT_TOUCH */,

input depth1_wr,
input [QUEUE_ID_NBITS-1:0] depth1_raddr,
input [QUEUE_ID_NBITS-1:0] depth1_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] depth1_wdata,
output [QUEUE_ENTRIES_NBITS-1:0] depth1_rdata  /* synthesis DONT_TOUCH */,

input ll_wr,
input [QUEUE_ENTRIES_NBITS-1:0] ll_raddr,
input [QUEUE_ENTRIES_NBITS-1:0] ll_waddr,
input [QUEUE_ENTRIES_NBITS-1:0] ll_wdata,
output [QUEUE_ENTRIES_NBITS-1:0] ll_rdata  /* synthesis DONT_TOUCH */,

input pkt_desc_wr,
input [QUEUE_ENTRIES_NBITS-1:0] pkt_desc_raddr,
input [QUEUE_ENTRIES_NBITS-1:0] pkt_desc_waddr,
input sch_pkt_desc_type pkt_desc_wdata,
output sch_pkt_desc_type pkt_desc_rdata  /* synthesis DONT_TOUCH */
);

/***************************** MEMORY ***************************************/
// head memory
ram_1r1w_bram #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS) u_ram_1r1w_bram_0(
			.clk(clk),
			.wr(head_wr),
			.raddr(head_raddr),
			.waddr(head_waddr),
			.din(head_wdata),

			.dout(head_rdata));

// tail memory
ram_1r1w_bram #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS) u_ram_1r1w_bram_1(
        .clk(clk),
        .wr(tail_wr),
        .raddr(tail_raddr),
		.waddr(tail_waddr),
        .din(tail_wdata),

        .dout(tail_rdata));

// depth memory
ram_1r1w_bram #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS) u_ram_1r1w_bram_2(
        .clk(clk),
        .wr(depth_wr),
        .raddr(depth_raddr),
		.waddr(depth_waddr),
        .din(depth_wdata),

        .dout(depth_rdata));

// depth1 memory
ram_1r1w_bram #(QUEUE_ENTRIES_NBITS, QUEUE_ID_NBITS) u_ram_1r1w_bram_21(
        .clk(clk),
        .wr(depth1_wr),
        .raddr(depth1_raddr),
		.waddr(depth1_waddr),
        .din(depth1_wdata),

        .dout(depth1_rdata));

// linked list memory
ram_1r1w_bram #(QUEUE_ENTRIES_NBITS, QUEUE_ENTRIES_NBITS) u_ram_1r1w_bram_3(
		.clk(clk),
		.wr(ll_wr),
		.raddr(ll_raddr),
		.waddr(ll_waddr),
		.din(ll_wdata),

		.dout(ll_rdata));

// packet descriptor memory
ram_1r1w_bram_sch_pkt_desc #(QUEUE_ENTRIES_NBITS) u_ram_1r1w_bram__bram_sch_pkt_desc(
		.clk(clk),
		.wr(pkt_desc_wr),
		.raddr(pkt_desc_raddr),
		.waddr(pkt_desc_waddr),
		.din(pkt_desc_wdata),

		.dout(pkt_desc_rdata));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

