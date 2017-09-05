//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

module register_file
             ( clk, wr, raddr, waddr, din, dout);

parameter WIDTH = 64,
	      DEPTH_BITS = 4,
	      DEPTH = 16'h1<<DEPTH_BITS;

output  [WIDTH-1:0] dout;

input    clk, wr;  
input   [DEPTH_BITS-1:0] raddr, waddr;
input   [WIDTH-1:0] din;

reg [WIDTH-1:0] dout;
reg [WIDTH-1:0] mem_d[DEPTH-1:0]; /* synthesis ramstyle = "MLAB" */


always @(posedge clk) begin
	if(wr)
        mem_d[waddr] <= din;
	dout <= mem_d[raddr];
end

endmodule            
