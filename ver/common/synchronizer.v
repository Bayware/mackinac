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

(* ASYNC_REG = "TRUE" *) reg din_d1;
(* ASYNC_REG = "TRUE" *) reg dout;

always @(posedge clk) begin
	din_d1 <= din;
	dout <= din_d1;
end

endmodule            
