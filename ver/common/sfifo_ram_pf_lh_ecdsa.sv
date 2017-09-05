// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::lh_ecdsa_meta_type;

module sfifo_ram_pf_lh_ecdsa #(
parameter DEPTH_NBITS = 12,
parameter DEPTH = (16'h1 << DEPTH_NBITS)
) (

input clk,
input `RESET_SIG,

input lh_ecdsa_meta_type din,
input rd, wr,

output logic [DEPTH_NBITS:0] count,
output full, empty,

output lh_ecdsa_meta_type dout

);

/***************************** LOCAL VARIABLES *******************************/

logic fifo_rd_d1;

lh_ecdsa_meta_type prefetch_fifo_dout;
logic prefetch_fifo_full, prefetch_fifo_fullm1;

lh_ecdsa_meta_type fifo_dout;
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

logic prefetch_fifo_wr = fifo_rd_d1;

logic fifo_rd = ~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		fifo_rd_d1 <= 0;
	end else begin
		fifo_rd_d1 <= fifo_rd;
	end
 
/***************************** NEXT STATE ASSIGNMENT **************************/

/***************************** STATE MACHINE *******************************/

/***************************** FIFO ***************************************/


sfifo_ram_lh_ecdsa #(DEPTH_NBITS) u_sfifo_ram_lh_ecdsa(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(din),				
    .rd(fifo_rd),
    .wr(wr),

	.wptr(), 
	.count(), 
	.full(),
	.empty(fifo_empty),
    .dout(fifo_dout)       
);

sfifo_lh_ecdsa #(2) u_sfifo_lh_ecdsa(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_dout),				
    .rd(rd),
    .wr(prefetch_fifo_wr),

	.ncount(),
	.count(),
	.full(prefetch_fifo_full),
	.empty(),
	.fullm1(prefetch_fifo_fullm1),
	.emptyp2(),
    .dout(dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

