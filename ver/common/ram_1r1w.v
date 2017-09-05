//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

module ram_1r1w
             ( clk, wr, raddr, waddr, din, dout);

parameter WIDTH = 64,
	      DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  [WIDTH-1:0] dout;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr, waddr;
input   [WIDTH-1:0] din;

reg [WIDTH-1:0] dout;
(* ram_style = "distributed" *)
reg [WIDTH-1:0] mem_d[DEPTH-1:0];


always @(posedge clk) begin
	if(wr) mem_d[waddr] <= din;
	dout <= mem_d[raddr]; 
end

endmodule            
