//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

`include "defines.vh"

import meta_package::piarb_asa_meta_type;

module register_file_piarb_asa
             ( clk, wr, raddr, waddr, din, dout);

parameter DEPTH_BITS = 4,
	      DEPTH = 16'h1<<DEPTH_BITS;

output  piarb_asa_meta_type dout;

input    clk, wr;  
input   [DEPTH_BITS-1:0] raddr, waddr;
input   piarb_asa_meta_type din;

piarb_asa_meta_type mem_d[DEPTH-1:0]; /* synthesis ramstyle = "MLAB" */


always @(posedge clk) begin
	if(wr)
        mem_d[waddr] <= din;
	dout <= mem_d[raddr];
end

endmodule            
