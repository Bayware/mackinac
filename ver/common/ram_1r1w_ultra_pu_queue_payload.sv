//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 1 read port, 1 write port memory model
//===========================================================================

`include "defines.vh"

import meta_package::pu_queue_payload_type;

module ram_1r1w_ultra_pu_queue_payload
             ( clk, wr, raddr, waddr, din, dout);

parameter DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  pu_queue_payload_type dout;

input    clk, wr;  
input   [DEPTH_NBITS-1:0] raddr, waddr;
input   pu_queue_payload_type din;

localparam WIDTH = `PU_QUEUE_PAYLOAD_NBITS;

(* ram_style = "ultra" *)
logic [WIDTH-1:0] mem_d[DEPTH-1:0];

logic [WIDTH-1:0] dout0;

wire [WIDTH-1:0] din0 = {
			din.len,
			din.pd_len,
			din.inst_len,
			din.buf_ptr,
			din.inst_buf_ptr,
			din.pp_piarb_meta.ptr_loc,
			din.pp_piarb_meta.pd_loc,
			din.pp_piarb_meta.domain_id,
			din.pp_piarb_meta.hdr_len,
			din.pp_piarb_meta.buf_ptr,
			din.pp_piarb_meta.len,
			din.pp_piarb_meta.port,
			din.pp_piarb_meta.rci,
			din.pp_piarb_meta.fid_sel,
			din.pp_piarb_meta.fid,
			din.pp_piarb_meta.tid,
			din.pp_piarb_meta.type1,
			din.pp_piarb_meta.type3,
			din.pp_piarb_meta.creation_time,
			din.pp_piarb_meta.discard};

assign {
			dout.len,
			dout.pd_len,
			dout.inst_len,
			dout.buf_ptr,
			dout.inst_buf_ptr,
			dout.pp_piarb_meta.ptr_loc,
			dout.pp_piarb_meta.pd_loc,
			dout.pp_piarb_meta.domain_id,
			dout.pp_piarb_meta.hdr_len,
			dout.pp_piarb_meta.buf_ptr,
			dout.pp_piarb_meta.len,
			dout.pp_piarb_meta.port,
			dout.pp_piarb_meta.rci,
			dout.pp_piarb_meta.fid_sel,
			dout.pp_piarb_meta.fid,
			dout.pp_piarb_meta.tid,
			dout.pp_piarb_meta.type1,
			dout.pp_piarb_meta.type3,
			dout.pp_piarb_meta.creation_time,
			dout.pp_piarb_meta.discard} = dout0;

always @(posedge clk) begin
	if(wr) mem_d[waddr] <= din0;
end


always @(posedge clk) begin
	dout0 <= mem_d[raddr];
end

endmodule            
