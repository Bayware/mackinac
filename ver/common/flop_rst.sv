//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION :
//===========================================================================

`include "defines.vh"

module flop_rst #(
parameter WIDTH = 64,
parameter RESET_VALUE = 0
)
             ( input clk, input `RESET_SIG, input [WIDTH-1:0] din, output logic [WIDTH-1:0] dout);

always @(`CLK_RST) 
	if(`ACTIVE_RESET)
        	dout <= RESET_VALUE;
	else 
		dout <= din;

endmodule            
