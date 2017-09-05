//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION :
//===========================================================================

`include "defines.vh"

module flop #(
parameter WIDTH = 64,
parameter RESET_VALUE = 0
)
             ( input clk, input [WIDTH-1:0] din, output logic [WIDTH-1:0] dout);

always @(posedge clk) 
	dout <= din;

endmodule            
