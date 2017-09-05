//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

module pu_rf
             ( clk, wr, raddr0, raddr1, waddr, din, dout0, dout1);

parameter WIDTH = 64,
	      DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  [WIDTH-1:0] dout0, dout1;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr0, raddr1, waddr;
input   [WIDTH-1:0] din;

ram_1r1w #(WIDTH, DEPTH_NBITS) u_ram_1r1w_0(.clk(clk), .wr(wr), .raddr(raddr0), .waddr(waddr), .din(din), .dout(dout0));
ram_1r1w #(WIDTH, DEPTH_NBITS) u_ram_1r1w_1(.clk(clk), .wr(wr), .raddr(raddr1), .waddr(waddr), .din(din), .dout(dout1));

endmodule            
