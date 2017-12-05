//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1-deep width parameterized synchronous FIFO
//		implemented with flops
//===========================================================================

`include "defines.vh"


module sfifo1f (

	// inputs

	clk,
	`RESET_SIG,

	din,
	rd,
	wr,

	//outputs

	full,
	empty,
	dout 

	);

parameter WIDTH = 16;
parameter DEPTH_BITS = 1;
parameter DEPTH = 1;

input clk;
input `RESET_SIG;

input [(WIDTH - 1):0] din;
input rd;
/* (* keep = "true", max_fanout = 50 *) */ input wr;

output full, empty;

/* (* keep = "true", max_fanout = 50 *) */ output [(WIDTH - 1):0] dout;


/***************************** LOCAL VARIABLES *******************************/

reg full, empty;

reg [(WIDTH - 1):0] fifod;

/***************************** NON REGISTERED OUTPUTS ***********************/

/***************************** REGISTERED OUTPUTS ***************************/

assign dout = fifod;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		full <= 1'b0;
		empty <= 1'b1;
	end else begin
		full <= ~(wr^rd)?full:wr;
		empty <= ~(wr^rd)?empty:rd;
	end

/***************************** PROGRAM BODY *******************************/

// synopsys dc_script_begin
// synopsys dc_script_end

always @(posedge clk) if (wr) fifod <= din;
	
/***************************** DIAGNOSTICS *********************************/

// synopsys translate_off 
always @(posedge clk) begin
	if (`INACTIVE_RESET & wr & full & ~rd) $display("ERROR: %d %m write when FIFO full", $time);
	if (`INACTIVE_RESET & rd & empty & ~wr) $display("ERROR: %d %m read when FIFO empty", $time);
end
// synopsys translate_on

endmodule

