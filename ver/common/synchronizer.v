//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

module synchronizer
             ( clk, din, dout);

output  dout;

input    clk; 
input   din;

reg din_d1;
reg dout;

always @(posedge clk) begin
	din_d1 <= din;
	dout <= din_d1;
end

endmodule            
