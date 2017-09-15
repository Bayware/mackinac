//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module asa_replicator #(
parameter LEN_NBITS = `PD_CHUNK_DEPTH_NBITS  
)(

input clk, 
input `RESET_SIG, 

input [`REAL_TIME_NBITS-1:0] current_time,			

input asa_rep_enq_req,
input asa_rep_enq_discard,
input asa_rep_enq_allow_mcast,
input [`SCI_VEC_NBITS-1:0] asa_rep_enq_vec,
input [`PRI_NBITS-1:0] asa_rep_enq_pri,
input enq_pkt_desc_type asa_rep_enq_desc,		
input [`TID_NBITS - 1 : 0] asa_rep_enq_tid,		

input int_rep_bp,

input tset_wr,
input [`TID_NBITS+`SCI_NBITS-1:0] tset_waddr,				
input [`SUB_EXP_TIME_NBITS-1:0] tset_wdata,

output logic discard_req,
output discard_info_type discard_info,
output logic [`EM_BUF_PTR_NBITS-1:0] discard_em_buf_ptr,
output logic [LEN_NBITS-1:0] discard_em_len,

output logic rep_enq_req,			
output logic rep_enq_drop,						
output logic rep_enq_ucast,						
output logic rep_enq_last,						
output logic [`PACKET_ID_NBITS-1:0] rep_enq_packet_id,				
output logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] rep_enq_qid,			
output enq_pkt_desc_type rep_enq_desc

);

/***************************** LOCAL VARIABLES *******************************/

localparam IN_FIFO_DEPTH_NBITS = 9;
localparam NEAR_FULL = ((1<<IN_FIFO_DEPTH_NBITS)-4);

logic asa_rep_enq_req_d1;
logic asa_rep_enq_discard_d1;
logic asa_rep_enq_allow_mcast_d1;
logic [`SCI_VEC_NBITS-1:0] asa_rep_enq_vec_d1;
logic [`PRI_NBITS-1:0] asa_rep_enq_pri_d1;
enq_pkt_desc_type asa_rep_enq_desc_d1;		
logic [`TID_NBITS - 1 : 0] asa_rep_enq_tid_d1;		

wire [`SCI_NBITS:0] in_rep_count = bits_sum(asa_rep_enq_vec_d1);
wire in_ucast = in_rep_count==1;
wire discard_en = asa_rep_enq_discard_d1|(in_rep_count==0);

logic in_fifo_full;
logic in_fifo_empty;

wire p_in_fifo_wr = asa_rep_enq_req_d1&in_ucast&~discard_en;
wire in_fifo_wr = asa_rep_enq_req_d1&~in_ucast&~in_fifo_full&~discard_en&asa_rep_enq_allow_mcast_d1;
wire discard_set = asa_rep_enq_req_d1&(discard_en|(~in_ucast&(in_fifo_full|~asa_rep_enq_allow_mcast_d1)));

discard_info_type discard_info_set;
assign discard_info_set.len = asa_rep_enq_desc_d1.ed_cmd.len;
assign discard_info_set.buf_ptr = asa_rep_enq_desc_d1.buf_ptr;
assign discard_info_set.src_port = asa_rep_enq_desc_d1.src_port;
wire [`EM_BUF_PTR_NBITS-1:0] discard_buf_ptr_set = asa_rep_enq_desc_d1.ed_cmd.pd_buf_ptr;
wire [LEN_NBITS-1:0] discard_len_set = asa_rep_enq_desc_d1.ed_cmd.pd_len;

logic p_in_fifo_empty;
logic [`SCI_VEC_NBITS-1:0] p_in_fifo_asa_rep_enq_vec;
logic [`PRI_NBITS-1:0] p_in_fifo_asa_rep_enq_pri;
enq_pkt_desc_type p_in_fifo_asa_rep_enq_desc;		
logic [`TID_NBITS - 1 : 0] p_in_fifo_asa_rep_enq_tid;		

logic [`SCI_VEC_NBITS-1:0] in_fifo_asa_rep_enq_vec;
logic [`PRI_NBITS-1:0] in_fifo_asa_rep_enq_pri;
enq_pkt_desc_type in_fifo_asa_rep_enq_desc;		
logic [`TID_NBITS - 1 : 0] in_fifo_asa_rep_enq_tid;		

logic lat_fifo_full;
logic lat_fifo_empty;

logic [`SCI_VEC_NBITS-1:0] lat_fifo_asa_rep_enq_vec;
logic [`PRI_NBITS-1:0] lat_fifo_asa_rep_enq_pri;
enq_pkt_desc_type lat_fifo_asa_rep_enq_desc;		
logic [`TID_NBITS - 1 : 0] lat_fifo_asa_rep_enq_tid;		

logic [`SCI_NBITS:0] in_fifo_rep_count;

logic [`SCI_VEC_NBITS-1:0] enq_vector;
logic [`SCI_NBITS:0] last_rep_count;
logic [`SCI_NBITS:0] rep_count;
wire [`SCI_NBITS:0] pre_enq_conn = pri_enc(enq_vector);
logic [`SCI_NBITS:0] shift_count;
wire [`SCI_NBITS-1:0] enq_conn = pre_enq_conn+shift_count;

wire out_rep_enq_drop = 1'b0;	// FIXME
wire out_rep_enq_ucast = last_rep_count==1;						
wire out_rep_enq_last = rep_count==(last_rep_count-1);						
wire [`PACKET_ID_NBITS-1:0] out_rep_enq_packet_id = rep_count;				
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] out_rep_enq_qid = {lat_fifo_asa_rep_enq_pri, enq_conn};			
enq_pkt_desc_type out_rep_enq_desc;
assign out_rep_enq_desc.src_port = lat_fifo_asa_rep_enq_desc.src_port;
assign out_rep_enq_desc.dst_port = lat_fifo_asa_rep_enq_desc.dst_port;
assign out_rep_enq_desc.buf_ptr = lat_fifo_asa_rep_enq_desc.buf_ptr;
assign out_rep_enq_desc.ed_cmd.ptr_update = lat_fifo_asa_rep_enq_desc.ed_cmd.ptr_update;
assign out_rep_enq_desc.ed_cmd.cur_ptr = lat_fifo_asa_rep_enq_desc.ed_cmd.cur_ptr;
assign out_rep_enq_desc.ed_cmd.ptr_loc = lat_fifo_asa_rep_enq_desc.ed_cmd.ptr_loc;
assign out_rep_enq_desc.ed_cmd.pd_update = lat_fifo_asa_rep_enq_desc.ed_cmd.pd_update;
assign out_rep_enq_desc.ed_cmd.pd_len = lat_fifo_asa_rep_enq_desc.ed_cmd.pd_len;
assign out_rep_enq_desc.ed_cmd.pd_loc = lat_fifo_asa_rep_enq_desc.ed_cmd.pd_loc;
assign out_rep_enq_desc.ed_cmd.pd_buf_ptr = lat_fifo_asa_rep_enq_desc.ed_cmd.pd_buf_ptr;
assign out_rep_enq_desc.ed_cmd.out_rci = enq_conn;
assign out_rep_enq_desc.ed_cmd.len = lat_fifo_asa_rep_enq_desc.ed_cmd.len;

logic out_fifo_full;
logic out_fifo_empty;

logic p_rep_enq_req;			
logic p_rep_enq_drop;						
logic p_rep_enq_ucast;						
logic p_rep_enq_last;						
logic [`PACKET_ID_NBITS-1:0] p_rep_enq_packet_id;				
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] p_rep_enq_qid;			
enq_pkt_desc_type p_rep_enq_desc;

wire out_fifo_wr = ~lat_fifo_empty&~out_fifo_full;

wire out_fifo_last = out_rep_enq_ucast|out_rep_enq_last;
wire lat_fifo_rd = out_fifo_wr&out_fifo_last;

wire p_in_fifo_rd = ~p_in_fifo_empty&(~lat_fifo_full|lat_fifo_rd);
wire in_fifo_rd = p_in_fifo_empty&~in_fifo_empty&(~lat_fifo_full|lat_fifo_rd);
wire lat_fifo_wr = (~p_in_fifo_empty|~in_fifo_empty)&(~lat_fifo_full|lat_fifo_rd);

wire [`SCI_VEC_NBITS-1:0] lat_fifo_asa_rep_enq_vec_in = p_in_fifo_empty?in_fifo_asa_rep_enq_vec:p_in_fifo_asa_rep_enq_vec;
wire [`PRI_NBITS-1:0] lat_fifo_asa_rep_enq_pri_in = p_in_fifo_empty?in_fifo_asa_rep_enq_pri:p_in_fifo_asa_rep_enq_pri;
enq_pkt_desc_type lat_fifo_asa_rep_enq_desc_in = p_in_fifo_empty?in_fifo_asa_rep_enq_desc:p_in_fifo_asa_rep_enq_desc;		
wire [`TID_NBITS - 1 : 0] lat_fifo_asa_rep_enq_tid_in = p_in_fifo_empty?in_fifo_asa_rep_enq_tid:p_in_fifo_asa_rep_enq_tid;		

logic tset_rd_d1;
wire tset_rd = out_fifo_wr;
wire [`TID_NBITS+`SCI_NBITS-1:0] tset_raddr = {lat_fifo_asa_rep_enq_tid, enq_conn};
logic [`SUB_EXP_TIME_NBITS-1:0] tset_rdata;	

logic tset_fifo_empty;
logic [`SUB_EXP_TIME_NBITS-1:0] tset_fifo_data;	

wire conn_expired = current_time[`SUB_EXP_TIME_NBITS-1:0]>tset_fifo_data;

logic discard_fifo_full;
logic tx_fifo_full;
wire tset_fifo_rd = ~tset_fifo_empty&~tx_fifo_full&~discard_fifo_full;
wire out_fifo_rd = tset_fifo_rd;
wire tx_fifo_wr = tset_fifo_rd&~conn_expired;
logic out_sop;
logic out_drop;

logic tx_fifo_empty;

logic out_fifo_rd_last_d1;

wire discard_fifo_wr = out_fifo_rd_last_d1&out_drop;
discard_info_type discard_fifo_wdata;
assign discard_fifo_wdata.len = p_rep_enq_desc.ed_cmd.len;
assign discard_fifo_wdata.buf_ptr = p_rep_enq_desc.buf_ptr;
assign discard_fifo_wdata.src_port = p_rep_enq_desc.src_port;
wire [`EM_BUF_PTR_NBITS-1:0] discard_fifo_wbuf_ptr = p_rep_enq_desc.ed_cmd.pd_buf_ptr;
wire [LEN_NBITS-1:0] discard_fifo_wlen = p_rep_enq_desc.ed_cmd.pd_len;
logic [`EM_BUF_PTR_NBITS-1:0] discard_fifo_rbuf_ptr;
logic [LEN_NBITS-1:0] discard_fifo_rlen;

logic discard_fifo_empty;
discard_info_type discard_fifo_rdata;

wire discard_fifo_rd = ~discard_set&~discard_fifo_empty;

/***************************** NON REGISTERED OUTPUTS ************************/

assign rep_enq_req = ~tx_fifo_empty&~int_rep_bp;

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		discard_info <= discard_set?discard_info_set:discard_fifo_rdata;
		discard_em_buf_ptr <= discard_set?discard_buf_ptr_set:discard_fifo_rbuf_ptr;
		discard_em_len <= discard_set?discard_len_set:discard_fifo_rlen;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		discard_req <= 1'b0;
	end else begin
		discard_req <= discard_set|~discard_fifo_empty;
	end

/***************************** PROGRAM BODY **********************************/

wire tx_fifo_rd = rep_enq_req;

always @(posedge clk) begin
		asa_rep_enq_discard_d1 <= asa_rep_enq_discard;
		asa_rep_enq_allow_mcast_d1 <= asa_rep_enq_allow_mcast;
		asa_rep_enq_vec_d1 <= asa_rep_enq_vec;
		asa_rep_enq_pri_d1 <= asa_rep_enq_pri;
		asa_rep_enq_desc_d1 <= asa_rep_enq_desc;
		asa_rep_enq_tid_d1 <= asa_rep_enq_tid;

		enq_vector <= in_fifo_rd?lat_fifo_asa_rep_enq_vec:out_fifo_wr?lat_fifo_asa_rep_enq_vec>>(shift_count+1):enq_vector;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		asa_rep_enq_req_d1 <= 0;
		last_rep_count <= 0;
		rep_count <= 0;
		shift_count <= {(`SCI_NBITS+1){1'b1}};
		tset_rd_d1 <= 1'b0;
		out_sop <= 1'b1;
		out_drop <= 1'b0;
		out_fifo_rd_last_d1 <= 1'b0;
	end else begin
		asa_rep_enq_req_d1 <= asa_rep_enq_req;
		last_rep_count <= in_fifo_rd?in_fifo_rep_count:last_rep_count;
		rep_count <= in_fifo_rd?0:out_fifo_wr?rep_count+1:rep_count;
		shift_count <= in_fifo_rd?{(`SCI_NBITS+1){1'b1}}:out_fifo_wr?shift_count+pre_enq_conn:shift_count;
		tset_rd_d1 <= tset_rd;
		out_sop <= ~out_fifo_rd?out_sop:out_rep_enq_last;
		out_drop <= ~out_fifo_rd?out_drop:out_sop?conn_expired:~conn_expired?1'b0:out_drop;
		out_fifo_rd_last_d1 <= out_fifo_rd&p_rep_enq_last;
	end

/***************************** FIFO ***************************************/

sfifo2f_ram_pf #(`SCI_VEC_NBITS+`PRI_NBITS+`TID_NBITS, IN_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({asa_rep_enq_vec_d1, asa_rep_enq_pri_d1, asa_rep_enq_tid_d1}),				
		.rd(p_in_fifo_rd),
		.wr(p_in_fifo_wr),

		.count(),
		.full(),
		.empty(p_in_fifo_empty),
		.dout({p_in_fifo_asa_rep_enq_vec, p_in_fifo_asa_rep_enq_pri, p_in_fifo_asa_rep_enq_tid}));				

sfifo_ram_pf_enq_pkt_desc #(IN_FIFO_DEPTH_NBITS) u_sfifo_ram_pf_enq_pkt_desc_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(asa_rep_enq_desc_d1),				
		.rd(p_in_fifo_rd),
		.wr(p_in_fifo_wr),

		.count(),
		.full(),
		.empty(),
		.dout(p_in_fifo_asa_rep_enq_desc));				

sfifo2f_fo #(LEN_NBITS+`EM_BUF_PTR_NBITS, 4) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({discard_fifo_wbuf_ptr, discard_fifo_wlen}),				
		.rd(discard_fifo_rd),
		.wr(discard_fifo_wr),

		.ncount(),
		.count(),
		.full(discard_fifo_full),
		.empty(discard_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({discard_fifo_rbuf_ptr, discard_fifo_rlen}));				

sfifo_discard_info #(4) u_sfifo_discard_info(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(discard_fifo_wdata),				
		.rd(discard_fifo_rd),
		.wr(discard_fifo_wr),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(discard_fifo_rdata));				

sfifo2f_ram_pf #(`SCI_NBITS+1+`SCI_VEC_NBITS+`PRI_NBITS+`TID_NBITS, IN_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({in_rep_count, asa_rep_enq_vec_d1, asa_rep_enq_pri_d1, asa_rep_enq_tid_d1}),				
		.rd(in_fifo_rd),
		.wr(asa_rep_enq_req_d1&~in_ucast),

		.count(),
		.full(),
		.empty(in_fifo_empty),
		.dout({in_fifo_rep_count, in_fifo_asa_rep_enq_vec, in_fifo_asa_rep_enq_pri, in_fifo_asa_rep_enq_tid}));				

sfifo_ram_pf_enq_pkt_desc #(IN_FIFO_DEPTH_NBITS) u_sfifo_ram_pf_enq_pkt_desc_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(asa_rep_enq_desc_d1),				
		.rd(in_fifo_rd),
		.wr(asa_rep_enq_req_d1&~in_ucast),

		.count(),
		.full(),
		.empty(in_fifo_empty),
		.dout(in_fifo_asa_rep_enq_desc));				

sfifo1f #(`SCI_VEC_NBITS+`PRI_NBITS+`TID_NBITS) u_sfifo1f(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_asa_rep_enq_vec_in, lat_fifo_asa_rep_enq_pri_in, lat_fifo_asa_rep_enq_tid_in}),				
		.rd(lat_fifo_rd),
		.wr(lat_fifo_wr),

		.full(),
		.empty(lat_fifo_empty),
		.dout({lat_fifo_asa_rep_enq_vec, lat_fifo_asa_rep_enq_pri, lat_fifo_asa_rep_enq_tid}));				

always @(posedge clk) lat_fifo_asa_rep_enq_desc <= lat_fifo_wr?lat_fifo_asa_rep_enq_desc_in:lat_fifo_asa_rep_enq_desc;

sfifo2f1 #(2+`PACKET_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS+1) u_sfifo2f1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({out_rep_enq_ucast, out_rep_enq_last,
			 out_rep_enq_packet_id, out_rep_enq_qid,
			 out_rep_enq_drop}),				
		.rd(out_fifo_rd),
		.wr(out_fifo_wr),

		.count(),
		.full(out_fifo_full),
		.empty(out_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({p_rep_enq_ucast, p_rep_enq_last,
			 p_rep_enq_packet_id, p_rep_enq_qid,
			 p_rep_enq_drop}));

sfifo_enq_pkt_desc #(1) u_sfifo_enq_pkt_desc_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(out_rep_enq_desc),				
		.rd(out_fifo_rd),
		.wr(out_fifo_wr),

		.ncount(),
		.count(),
		.full(out_fifo_full),
		.empty(out_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout(p_rep_enq_desc));

sfifo2f1 #(`SUB_EXP_TIME_NBITS) u_sfifo2f1_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({tset_rdata}),
		.rd(tset_fifo_rd),
		.wr(tset_rd_d1),

		.count(),
		.full(),
		.empty(tset_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({tset_fifo_data}));

sfifo2f_fo #(2+`PACKET_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS+1, 2) u_sfifo2f_fo_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({p_rep_enq_ucast, out_rep_enq_last,
			 p_rep_enq_packet_id, out_rep_enq_qid,
			 p_rep_enq_drop}),				
		.rd(tx_fifo_rd),
		.wr(tx_fifo_wr),

		.ncount(),
		.count(),
		.full(tx_fifo_full),
		.empty(tx_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({rep_enq_ucast, rep_enq_last,
			 rep_enq_packet_id, rep_enq_qid,
			 rep_enq_drop}));

sfifo_enq_pkt_desc #(2) u_sfifo_enq_pkt_desc_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(out_rep_enq_desc),				
		.rd(tx_fifo_rd),
		.wr(tx_fifo_wr),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(rep_enq_desc));

/***************************** MEMORY ***************************************/

ram_1r1w #(`SUB_EXP_TIME_NBITS, `TID_NBITS+`SCI_NBITS) u_ram_1r1w_3(
			.clk(clk),
			.wr(tset_wr),
			.raddr(tset_raddr),
			.waddr(tset_waddr),
			.din(tset_wdata),

			.dout(tset_rdata));

/***************************** FUNCTION ***************************************/

function [`SCI_NBITS:0] pri_enc;
input[`SCI_VEC_NBITS-1:0] din;
reg [`SCI_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = pri_enc_2(din[`SCI_VEC_NBITS-1:`SCI_VEC_NBITS/2]);
	pe2_1 = pri_enc_2(din[`SCI_VEC_NBITS/2-1:0]);
	pri_enc = pe2_1!=0?pe2_1:pe2_0+(`SCI_VEC_NBITS/2);
end
endfunction

function [`SCI_NBITS:0] pri_enc_2;
input[`SCI_VEC_NBITS/2-1:0] din;
reg [`SCI_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = pri_enc_4(din[`SCI_VEC_NBITS/2-1:`SCI_VEC_NBITS/4]);
	pe2_1 = pri_enc_4(din[`SCI_VEC_NBITS/4-1:0]);
	pri_enc_2 = pe2_1!=0?pe2_1:pe2_0+(`SCI_VEC_NBITS/4);
end
endfunction

function [`SCI_NBITS:0] pri_enc_4;
input[`SCI_VEC_NBITS/4-1:0] din;
reg [`SCI_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = pri_enc_8(din[`SCI_VEC_NBITS/4-1:`SCI_VEC_NBITS/8]);
	pe2_1 = pri_enc_8(din[`SCI_VEC_NBITS/8-1:0]);
	pri_enc_4 = pe2_1!=0?pe2_1:pe2_0+(`SCI_VEC_NBITS/8);
end
endfunction

function [`SCI_NBITS:0] pri_enc_8;
input[`SCI_VEC_NBITS/8-1:0] din;
reg [`SCI_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = pri_enc_16(din[`SCI_VEC_NBITS/8-1:`SCI_VEC_NBITS/16]);
	pe2_1 = pri_enc_16(din[`SCI_VEC_NBITS/16-1:0]);
	pri_enc_8 = pe2_1!=0?pe2_1:pe2_0+(`SCI_VEC_NBITS/16);
end
endfunction

function [`SCI_NBITS:0] pri_enc_16;
input[`SCI_VEC_NBITS/16-1:0] din;
reg [`SCI_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = pri_enc_32(din[`SCI_VEC_NBITS/16-1:`SCI_VEC_NBITS/32]);
	pe2_1 = pri_enc_32(din[`SCI_VEC_NBITS/32-1:0]);
	pri_enc_16 = pe2_1!=0?pe2_1:pe2_0+(`SCI_VEC_NBITS/32);
end
endfunction

function [`SCI_NBITS:0] pri_enc_32;
input[`SCI_VEC_NBITS/32-1:0] din;
reg [`SCI_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = din[`SCI_VEC_NBITS/32-1:`SCI_VEC_NBITS/64];
	pe2_1 = din[`SCI_VEC_NBITS/64-1:0];
	pri_enc_32 = pe2_1!=0?pe2_1:pe2_0+(`SCI_VEC_NBITS/64);
end
endfunction

function [`SCI_NBITS:0] bits_sum;
input[`SCI_VEC_NBITS-1:0] din;
begin
	bits_sum = bits_sum_2(din[`SCI_VEC_NBITS-1:`SCI_VEC_NBITS/2]) + bits_sum_2(din[`SCI_VEC_NBITS/2-1:0]);
end
endfunction

function [`SCI_NBITS:0] bits_sum_2;
input[`SCI_VEC_NBITS/2-1:0] din;
begin
	bits_sum_2 = bits_sum_4(din[`SCI_VEC_NBITS/2-1:`SCI_VEC_NBITS/4]) + bits_sum_4(din[`SCI_VEC_NBITS/4-1:0]);
end
endfunction

function [`SCI_NBITS:0] bits_sum_4;
input[`SCI_VEC_NBITS/4-1:0] din;
begin
	bits_sum_4 = bits_sum_8(din[`SCI_VEC_NBITS/4-1:`SCI_VEC_NBITS/8]) + bits_sum_8(din[`SCI_VEC_NBITS/8-1:0]);
end
endfunction

function [`SCI_NBITS:0] bits_sum_8;
input[`SCI_VEC_NBITS/8-1:0] din;
begin
	bits_sum_8 = bits_sum_16(din[`SCI_VEC_NBITS/8-1:`SCI_VEC_NBITS/16]) + bits_sum_16(din[`SCI_VEC_NBITS/16-1:0]);
end
endfunction

function [`SCI_NBITS:0] bits_sum_16;
input[`SCI_VEC_NBITS/16-1:0] din;
begin
	bits_sum_16 = bits_sum_32(din[`SCI_VEC_NBITS/16-1:`SCI_VEC_NBITS/32]) + bits_sum_32(din[`SCI_VEC_NBITS/32-1:0]);
end
endfunction

function [`SCI_NBITS:0] bits_sum_32;
input[`SCI_VEC_NBITS/32-1:0] din;
begin
	bits_sum_32 = din[`SCI_VEC_NBITS/32-1:`SCI_VEC_NBITS/64] + din[`SCI_VEC_NBITS/64-1:0];
end
endfunction


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

