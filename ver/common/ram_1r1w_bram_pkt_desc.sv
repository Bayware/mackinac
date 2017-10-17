//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

`include "defines.vh"

import meta_package::pkt_desc_type;

module ram_1r1w_bram_pkt_desc
             ( clk, wr, raddr, waddr, din, dout);

parameter DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  pkt_desc_type dout;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr, waddr;
input   pkt_desc_type din;

localparam WIDTH = `PKT_DESC_NBITS;
(* ram_style = "block" *)
logic [WIDTH-1:0] mem_d[DEPTH-1:0];

logic [WIDTH-1:0] dout0;

wire [WIDTH-1:0] din0 = {
			din.q_id, 
			din.conn_id, 
			din.conn_group_id, 
			din.port_queue_id,
			din.sch_pkt_desc.src_port, 
			din.sch_pkt_desc.dst_port, 
			din.sch_pkt_desc.len, 
			din.sch_pkt_desc.idx
			};

assign 	{
	dout.q_id, 
	dout.conn_id, 
	dout.conn_group_id, 
	dout.port_queue_id,
	dout.sch_pkt_desc.src_port, 
	dout.sch_pkt_desc.dst_port, 
	dout.sch_pkt_desc.len, 
	dout.sch_pkt_desc.idx
	} = dout0; 


always @(posedge clk) begin
	if(wr) mem_d[waddr] <= din0;
end


always @(posedge clk) begin
	dout0 <= mem_d[raddr];
end

endmodule            
