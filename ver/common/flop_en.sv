//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION :
//===========================================================================

`include "defines.vh"

module flop_en #(
parameter WIDTH = 64
)
             ( input clk, input en, input [WIDTH-1:0] din, output logic [WIDTH-1:0] dout);

always @(posedge clk) 
	dout <= en?din:dout;

endmodule            
