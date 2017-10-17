//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

`include "defines.vh"

import meta_package::sch_pkt_desc_type;

module ram_1r1w_bram_sch_pkt_desc
             ( clk, wr, raddr, waddr, din, dout);

parameter DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  sch_pkt_desc_type dout;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr, waddr;
input   sch_pkt_desc_type din;

localparam WIDTH = `SCH_PKT_DESC_NBITS;
(* ram_style = "block" *)
logic [WIDTH-1:0] mem_d[DEPTH-1:0];

logic [WIDTH-1:0] dout0;

wire [WIDTH-1:0] din0 = {
			din.src_port, 
			din.dst_port, 
			din.len,
			din.idx 
			}; 

assign {
			dout.src_port, 
			dout.dst_port, 
			dout.len,
			dout.idx 
			} = dout0; 

always @(posedge clk) begin
	if(wr) mem_d[waddr] <= din0;
end

always @(posedge clk) begin
	dout0 <= mem_d[raddr];
end

endmodule            
