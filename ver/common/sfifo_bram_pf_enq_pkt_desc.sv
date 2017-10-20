// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::enq_pkt_desc_type;

module sfifo_bram_pf_enq_pkt_desc #(
parameter DEPTH_NBITS = 12,
parameter DEPTH = (16'h1 << DEPTH_NBITS)
) (

input clk,
input `RESET_SIG,

input enq_pkt_desc_type din,
input rd, wr,

output logic [DEPTH_NBITS:0] count,
output full, empty,

output enq_pkt_desc_type dout

);

/***************************** LOCAL VARIABLES *******************************/

logic fifo_rd_d1;

enq_pkt_desc_type prefetch_fifo_dout;
logic prefetch_fifo_full, prefetch_fifo_fullm1;

enq_pkt_desc_type fifo_dout;
logic fifo_empty;

/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		count <= 0;
	end else begin
		count <= ~(wr^rd)?count:wr?count+1:count-1;
	end

/***************************** PROGRAM BODY **********************************/

wire prefetch_fifo_wr = fifo_rd_d1;

wire fifo_rd = ~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		fifo_rd_d1 <= 0;
	end else begin
		fifo_rd_d1 <= fifo_rd;
	end
 
/***************************** NEXT STATE ASSIGNMENT **************************/

/***************************** STATE MACHINE *******************************/

/***************************** FIFO ***************************************/


sfifo_bram_enq_pkt_desc #(DEPTH_NBITS) u_sfifo_bram_enq_pkt_desc(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(din),				
    .rd(fifo_rd),
    .wr(wr),

	.wptr(), 
	.count(), 
	.full(full),
	.empty(fifo_empty),
    .dout(fifo_dout)       
);

sfifo_enq_pkt_desc #(2) u_sfifo_enq_pkt_desc(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_dout),				
    .rd(rd),
    .wr(prefetch_fifo_wr),

	.ncount(),
	.count(),
	.full(prefetch_fifo_full),
	.empty(empty),
	.fullm1(prefetch_fifo_fullm1),
	.emptyp2(),
    .dout(dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

