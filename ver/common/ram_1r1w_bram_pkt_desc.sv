//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

import meta_package::pkt_desc_type;

module ram_1r1w_bram_pkt_desc
             ( clk, wr, raddr, waddr, din, dout);

parameter DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  pkt_desc_type dout;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr, waddr;
input   pkt_desc_type din;

(* ram_style = "block" *)
pkt_desc_type mem_d[DEPTH-1:0];


always @(posedge clk) begin
	if(wr) mem_d[waddr] <= din;
end


always @(posedge clk) begin
	dout <= mem_d[raddr];
end

endmodule            
