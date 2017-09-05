//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : depth/width parameterized synchronous FIFO (depth=2**n)
//		implemented with flops; with flop outputs
//===========================================================================

`include "defines.vh"

module sfifo2f_fo (

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

reg empty;
reg [DEPTH_BITS:0] count;

reg [(WIDTH - 1):0] dout;

wire ff_full, ff_empty, ff_fullm1, ff_emptyp1, ff_emptyp2;
wire [(WIDTH - 1):0] ff_dout;
wire [(DEPTH_BITS - 1):0] ff_ncount;

wire nempty = ~(wr^rd)?empty:~wr&rd&ff_empty;

/***************************** NON REGISTERED OUTPUTS ***********************/

assign ncount = ff_ncount+(nempty?1'b0:1'b1);

/***************************** REGISTERED OUTPUTS ***************************/

assign full = ff_full;
assign fullm1 = ff_fullm1;
assign emptyp2 = ff_emptyp1;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		empty <= 1'b1;
		count <= 1'b0;
	end else begin
		empty <= nempty;
		count <= ncount;
	end

always @(posedge clk) dout <= ~((wr&empty)|rd)?dout:rd&~ff_empty?ff_dout:din;

/***************************** PROGRAM BODY ********************************/

/**************************** INSTANTIATION ********************************/

sfifof #(WIDTH, DEPTH_BITS, DEPTH-1) u_sfifof(

		// inputs

		.clk			(clk),
		.`RESET_SIG		(`RESET_SIG),

		.din			(din),
		.rd			(rd&~ff_empty),
		.wr			(wr&~(empty|(ff_empty&rd))),

		//outputs

		.ncount			(ff_ncount),
		.count			(),
		.full			(ff_full),
		.empty			(ff_empty),
		.fullm1			(ff_fullm1),
		.emptyp1		(ff_emptyp1),
		.emptyp2		(ff_emptyp2),
		.dout			(ff_dout) 
);
	
/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
always @(posedge clk) begin
	if (`INACTIVE_RESET & wr & full) $display("ERROR: %d %m write when FIFO full", $time);
	if (`INACTIVE_RESET & rd & empty) $display("ERROR: %d %m read when FIFO empty", $time);
end
// synopsys translate_on

endmodule

