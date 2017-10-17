//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

`include "defines.vh"

import meta_package::ext_pkt_desc_type;

module ram_1r1w_bram_ext_pkt_desc
             ( clk, wr, raddr, waddr, din, dout);

parameter DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  ext_pkt_desc_type dout;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr, waddr;
input   ext_pkt_desc_type din;

localparam WIDTH = `SECOND_LVL_QUEUE_ID_NBITS+`THIRD_LVL_QUEUE_ID_NBITS+`FOURTH_LVL_QUEUE_ID_NBITS+`ENQ_PKT_DESC_NBITS;

(* ram_style = "block" *)
logic [WIDTH-1:0] mem_d[DEPTH-1:0];

logic [WIDTH-1:0] dout0;

wire [WIDTH-1:0] din0 = {din.conn_id, 
			din.conn_group_id, 
			din.port_queue_id,
			din.enq_pkt_desc.src_port, 
			din.enq_pkt_desc.dst_port, 
			din.enq_pkt_desc.buf_ptr, 
			din.enq_pkt_desc.ed_cmd.ptr_update, 
			din.enq_pkt_desc.ed_cmd.cur_ptr, 
			din.enq_pkt_desc.ed_cmd.ptr_loc, 
			din.enq_pkt_desc.ed_cmd.pd_update, 
			din.enq_pkt_desc.ed_cmd.pd_len, 
			din.enq_pkt_desc.ed_cmd.pd_loc, 
			din.enq_pkt_desc.ed_cmd.pd_buf_ptr, 
			din.enq_pkt_desc.ed_cmd.out_rci, 
			din.enq_pkt_desc.ed_cmd.len}; 

assign 	{dout.conn_id, 
	dout.conn_group_id, 
	dout.port_queue_id,
	dout.enq_pkt_desc.src_port, 
	dout.enq_pkt_desc.dst_port, 
	dout.enq_pkt_desc.buf_ptr, 
	dout.enq_pkt_desc.ed_cmd.ptr_update, 
	dout.enq_pkt_desc.ed_cmd.cur_ptr, 
	dout.enq_pkt_desc.ed_cmd.ptr_loc, 
	dout.enq_pkt_desc.ed_cmd.pd_update, 
	dout.enq_pkt_desc.ed_cmd.pd_len, 
	dout.enq_pkt_desc.ed_cmd.pd_loc, 
	dout.enq_pkt_desc.ed_cmd.pd_buf_ptr, 
	dout.enq_pkt_desc.ed_cmd.out_rci, 
	dout.enq_pkt_desc.ed_cmd.len} = dout0; 


always @(posedge clk) begin
	if(wr) mem_d[waddr] <= din0;
end


always @(posedge clk) begin
	dout0 <= mem_d[raddr];
end

endmodule            
