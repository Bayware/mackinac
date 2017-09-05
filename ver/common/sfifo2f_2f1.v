//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : depth/width parameterized synchronous FIFO (depth=2**n)
//		sfifo_2f_fo + sfifo2f1
//===========================================================================

`include "defines.vh"

module sfifo2f_2f1 (

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
	emptyp2,
	dout 

	);

parameter WIDTH = 16;
parameter DEPTH_BITS = 3;
parameter DEPTH = (16'h1  << DEPTH_BITS);


input clk;
input `RESET_SIG;

input [(WIDTH - 1):0] din;
input rd, wr;

output [DEPTH_BITS:0] ncount, count;
output full, empty, fullm1, emptyp2;

output [(WIDTH - 1):0] dout;


/***************************** LOCAL VARIABLES *******************************/



/***************************** NON REGISTERED OUTPUTS ***********************/

/***************************** REGISTERED OUTPUTS ***************************/

/***************************** PROGRAM BODY ********************************/

wire [(WIDTH - 1):0] ff_dout;

wire ff_empty, ff_full;

wire fifo_rd = ~ff_empty&~ff_full;

sfifo2f_fo #(WIDTH, DEPTH_BITS) u_sfifo2f_fo(

		// inputs

		.clk			(clk),
		.`RESET_SIG		(`RESET_SIG),

		.din			(din),
		.rd			(fifo_rd),
		.wr			(wr),

		//outputs

		.ncount			(ncount),
		.count			(count),
		.full			(full),
		.empty			(ff_empty),
		.fullm1			(fullm1),
		.emptyp2		(),
		.dout			(ff_dout) 
);
	
sfifo2f1 #(WIDTH) u_sfifo2f1(

		// inputs

		.clk			(clk),
		.`RESET_SIG		(`RESET_SIG),

		.din			(ff_dout),
		.rd			(rd),
		.wr			(fifo_rd),

		//outputs

		.count			(),
		.full			(ff_full),
		.empty			(empty),
		.fullm1			(),
		.emptyp2		(emptyp2),
		.dout			(dout) 
);

	
endmodule

