//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module asa_process #(
parameter RAS_WIDTH = (`RAS_FLAG_NBITS+(1+`SCI_NBITS)*9)
) (


input clk, 
input `RESET_SIG, 

input [`REAL_TIME_NBITS-1:0] current_time,				
input [`SUB_EXP_TIME_NBITS-1:0] default_sub_exp_time,				

input [`SCI_NBITS-1:0] supervisor_sci,				
input [15:0] class2pri,				

input ecdsa_asa_fp_wr,
input [`FID_NBITS-1:0] ecdsa_asa_fp_waddr,				
input [`FLOW_POLICY2_NBITS-1:0] ecdsa_asa_fp_wdata,				

input asa_proc_valid,
input asa_proc_type3,
input asa_proc_meta_type asa_proc_meta,
input [RAS_WIDTH-1:0] asa_proc_ras,

output logic asa_classifier_valid,
output logic [`FID_NBITS-1:0] asa_classifier_fid,

output logic tset_wr,
output logic [`TID_NBITS+`SCI_NBITS-1:0] tset_waddr,				
output logic [`SUB_EXP_TIME_NBITS-1:0] tset_wdata,

output logic asa_rep_enq_req,
output logic asa_rep_enq_discard,
output logic asa_rep_enq_allow_mcast,
output logic [`SCI_VEC_NBITS-1:0] asa_rep_enq_vec,
output logic [`PRI_NBITS-1:0] asa_rep_enq_pri,
output enq_pkt_desc_type asa_rep_enq_desc,		
output logic [`TID_NBITS - 1 : 0] asa_rep_enq_tid		

);

/***************************** LOCAL VARIABLES *******************************/

localparam IN_FIFO_DEPTH_NBITS = 9;

logic [`REAL_TIME_NBITS-1:0] current_time_d1;				

logic asa_proc_valid_d1;
logic asa_proc_type3_d1;
asa_proc_meta_type asa_proc_meta_d1;
logic [RAS_WIDTH-1:0] asa_proc_ras_d1;

logic asa_proc_valid_d2;
logic asa_proc_type3_d2;
asa_proc_meta_type asa_proc_meta_d2;
logic [RAS_WIDTH-1:0] asa_proc_ras_d2;

logic ecdsa_asa_fp_wr_d1;
logic [`FID_NBITS-1:0] ecdsa_asa_fp_waddr_d1;				
logic [`FLOW_POLICY2_NBITS-1:0] ecdsa_asa_fp_wdata_d1;				

wire [`TID_NBITS-1:0] tid = asa_proc_meta.tid;
wire [`TID_NBITS-1:0] tid_d2 = asa_proc_meta_d2.tid;
wire [`FID_NBITS-1:0] fid = asa_proc_meta.fid;
wire [`FID_NBITS-1:0] fid_d2 = asa_proc_meta_d2.fid;

wire fp_rd = asa_proc_valid;
wire [`FID_NBITS-1:0] fp_raddr = fid;				
(* dont_touch = "true" *) logic [`FLOW_POLICY2_NBITS-1:0] fp_rdata ;				
logic [`FLOW_POLICY2_NBITS-1:0] fp_rdata_d1;				

wire fa_rd = fp_rd;
wire [`FID_NBITS-1:0] fa_raddr = fp_raddr;				
(* dont_touch = "true" *) logic [`FLOW_ACTION_NBITS-1:0] fa_rdata ;				
logic [`FLOW_ACTION_NBITS-1:0] fa_rdata_d1;				

wire ta_rd = fp_rd;
wire [`TID_NBITS-1:0] ta_raddr = tid;				
(* dont_touch = "true" *) logic [`SCI_VEC_NBITS-1:0] ta_rdata ;				
logic [`SCI_VEC_NBITS-1:0] ta_rdata_d1;				

wire [`SCI_VEC_NBITS-1:0] in_rci_bit_vec_p1 = bit_vec_gen({1'b0, asa_proc_meta_d1.rci[`SCI_NBITS-1:0]});
logic [`SCI_VEC_NBITS-1:0] in_rci_mask;

wire [`SCI_VEC_NBITS-1:0] flow_bit_vec0 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*1+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*0+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec1 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*2+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*1+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec2 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*3+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*2+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec3 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*4+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*3+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec4 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*5+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*4+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec5 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*6+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*5+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec6 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*7+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*6+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] flow_bit_vec7 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*8+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*7+`RAS_FLAG_NBITS]);
wire [`SCI_VEC_NBITS-1:0] topic_bit_vec_p1 = bit_vec_gen(asa_proc_ras_d1[(1+`SCI_NBITS)*9+`RAS_FLAG_NBITS-1:(1+`SCI_NBITS)*8+`RAS_FLAG_NBITS]);
logic [`SCI_VEC_NBITS-1:0] topic_bit_vec;

wire [`SCI_VEC_NBITS-1:0] flow_bit_vec_p1 = flow_bit_vec0|
						flow_bit_vec1|
						flow_bit_vec2|
						flow_bit_vec3|
						flow_bit_vec4|
						flow_bit_vec5|
						flow_bit_vec6|
						flow_bit_vec7;

logic [`SCI_VEC_NBITS-1:0] flow_bit_vec;

logic [7:0] flow_vec_valid_p1;

assign flow_vec_valid_p1[0] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*1+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[1] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*2+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[2] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*3+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[3] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*4+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[4] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*5+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[5] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*6+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[6] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*7+`RAS_FLAG_NBITS-1];
assign flow_vec_valid_p1[7] = ~asa_proc_ras_d1[(1+`SCI_NBITS)*8+`RAS_FLAG_NBITS-1];

logic [7:0] flow_vec_valid;

wire topic_vec_valid_p1 = ~asa_proc_ras_d1[(1+`SCI_NBITS)*9+`RAS_FLAG_NBITS-1];
logic topic_vec_valid;

wire [`RAS_FLAG_NBITS-1:0] ras_flag = asa_proc_ras_d2[`RAS_FLAG_NBITS-1:0];

wire [`RAS_FLAG_EAST_RANGE] ras_east = ras_flag[`RAS_FLAG_EAST];
wire [`RAS_FLAG_UFDAST_RANGE] ras_ufdast = ras_flag[`RAS_FLAG_UFDAST];
wire [`RAS_FLAG_UPPP_RANGE] ras_uppp = ras_flag[`RAS_FLAG_UPPP];
wire [`RAS_FLAG_UPPD_RANGE] ras_uppd = ras_flag[`RAS_FLAG_UPPD];
wire [`RAS_FLAG_NFASCF_RANGE] ras_nfascf = ras_flag[`RAS_FLAG_NFASCF];

wire terminate_flow = ~ras_east[2];
wire discard_packet = ras_east[1:0]==2'b00;
wire execute_topic = ras_east[0]==1'b1;
wire execute_flow = ras_east[1]==1'b1;

wire allow_update = ras_nfascf[5:2]==4'b1101|ras_nfascf[5:2]==4'b1111;
wire allow_forward = ras_nfascf[5:4]==2'b00|ras_nfascf[5:2]==4'b1001|ras_nfascf[5:2]==4'b1101|ras_nfascf[5:2]==4'b1111;

wire update_default_type = ras_ufdast[2];

wire [`FLOW_POLICY2_MASKON_RANGE] flow_maskon = fp_rdata_d1[`FLOW_POLICY2_MASKON];

wire domain_discard = asa_proc_meta_d2.type1&(asa_proc_meta_d2.domain_id!=0)&(asa_proc_meta_d2.domain_id!=fp_rdata_d1[`FLOW_POLICY2_DOMAIN_ID]);
wire in_discard = asa_proc_meta_d2.discard;

wire fmo_allow_update_ppd = flow_maskon[2-2];
wire fmo_allow_update_fas = flow_maskon[3-2];
wire fmo_allow_update_tas = flow_maskon[4-2];
wire fmo_allow_execute_forward = flow_maskon[5-2];
wire fmo_allow_fsas_forward = flow_maskon[6-2];
wire fmo_allow_tsas_forward = flow_maskon[7-2];
wire fmo_allow_multicast = flow_maskon[8-2];
wire fmo_allow_forward_supervisor = flow_maskon[9-2];

wire fa_vec_wr = ~in_discard&~domain_discard&~terminate_flow&execute_flow&allow_update&(|flow_vec_valid)&fmo_allow_update_fas&asa_proc_valid_d2&~asa_proc_type3_d2;
wire fa_default_type_wr = ~in_discard&~domain_discard&~terminate_flow&ras_ufdast[2]&fmo_allow_update_fas&asa_proc_valid_d2&~asa_proc_type3_d2;
wire fa_wr = fa_vec_wr|fa_default_type_wr;
wire [`ACTION_SET_TYPE_NBITS-1:0] fa_default_type_rd = fa_rdata_d1[`FLOW_ACTION_NBITS-1:`SCI_VEC_NBITS];
wire [`ACTION_SET_TYPE_NBITS-1:0] fa_default_type = /*~fa_default_type_wr?fa_default_type_rd:*/ras_ufdast[1:0];				
wire [`SCI_VEC_NBITS-1:0] fa_action_set_rd = fa_rdata_d1[`SCI_VEC_NBITS-1:0];
wire [`SCI_VEC_NBITS-1:0] fa_action_set = ~fa_vec_wr?fa_action_set_rd:flow_bit_vec;
wire [`FLOW_ACTION_NBITS-1:0] fa_wdata = {fa_default_type, fa_action_set};				
wire [`FID_NBITS-1:0] fa_waddr = fid_d2;				

wire ta_wr = ~in_discard&~domain_discard&~terminate_flow&execute_topic&topic_vec_valid&fmo_allow_update_tas&asa_proc_valid_d2&~asa_proc_type3_d2;
wire [`SCI_VEC_NBITS-1:0] ta_wdata = ta_rdata_d1|topic_bit_vec;				
wire [`TID_NBITS-1:0] ta_waddr = tid_d2;				

wire type_use_etopic = execute_topic&fmo_allow_execute_forward;
wire type_use_eflow = allow_forward&execute_flow&fmo_allow_execute_forward;

wire type_use_stopic = execute_topic&fmo_allow_tsas_forward;
wire type_use_sflow = ~type_use_eflow&fmo_allow_fsas_forward;

wire type3_discard = fa_default_type_rd==2'b00;
wire type3_use_topic = (fa_default_type_rd[0]==1'b1)&fmo_allow_tsas_forward;
wire type3_use_flow = (fa_default_type_rd[1]==1'b1)&fmo_allow_fsas_forward;

wire [`SCI_VEC_NBITS-1:0] supervisor_bit_vec = bit_vec_gen({1'b0, supervisor_sci});
wire [`SCI_VEC_NBITS-1:0] supervisor_mask = fmo_allow_forward_supervisor?{(`SCI_VEC_NBITS){1'b1}}:~supervisor_bit_vec;

wire [`SCI_VEC_NBITS-1:0] type3_topic_forward_enable = type3_use_topic?ta_rdata_d1:{(`SCI_VEC_NBITS){1'b0}};
wire [`SCI_VEC_NBITS-1:0] type3_flow_forward_enable = type3_use_flow?fa_action_set_rd:{(`SCI_VEC_NBITS){1'b0}};

wire [`SCI_VEC_NBITS-1:0] type_stopic_forward_enable = type_use_stopic?ta_rdata_d1:{(`SCI_VEC_NBITS){1'b0}};
wire [`SCI_VEC_NBITS-1:0] type_sflow_forward_enable = type_use_sflow?fa_rdata_d1:{(`SCI_VEC_NBITS){1'b0}};

wire [`SCI_VEC_NBITS-1:0] type_etopic_forward_enable = type_use_etopic?topic_bit_vec:{(`SCI_VEC_NBITS){1'b0}};
wire [`SCI_VEC_NBITS-1:0] type_eflow_forward_enable = type_use_eflow?flow_bit_vec:{(`SCI_VEC_NBITS){1'b0}};

wire [`FLOW_POLICY2_TCLASS_RANGE] traffic_class = fp_rdata_d1[`FLOW_POLICY2_TCLASS];

wire asa_rep_enq_discard_p1 = in_discard|domain_discard|(asa_proc_type3_d2?type3_discard:discard_packet);
wire asa_rep_enq_req_p1 = asa_proc_valid_d2;

wire [`SCI_VEC_NBITS-1:0] asa_rep_enq_vec_p1 = asa_proc_type3_d2?in_rci_mask&supervisor_mask&(type3_topic_forward_enable|type3_flow_forward_enable):in_rci_mask&supervisor_mask&(type_stopic_forward_enable|type_sflow_forward_enable|type_etopic_forward_enable|type_eflow_forward_enable);

wire [`PRI_NBITS-1:0] asa_rep_enq_pri_p1 = pri_gen(class2pri, traffic_class[2:0]);

enq_pkt_desc_type asa_rep_enq_desc_p1;

assign asa_rep_enq_desc_p1.src_port = asa_proc_meta_d2.src_port;
assign asa_rep_enq_desc_p1.dst_port = asa_proc_meta_d2.dst_port;
assign asa_rep_enq_desc_p1.buf_ptr = asa_proc_meta_d2.buf_ptr;

assign asa_rep_enq_desc_p1.ed_cmd.ptr_update = ~asa_proc_type3_d2&ras_uppp;
assign asa_rep_enq_desc_p1.ed_cmd.cur_ptr = asa_proc_meta_d2.ed_cmd.cur_ptr;
assign asa_rep_enq_desc_p1.ed_cmd.ptr_loc = asa_proc_meta_d2.ed_cmd.ptr_loc;
assign asa_rep_enq_desc_p1.ed_cmd.pd_update = ~asa_proc_type3_d2&fmo_allow_update_ppd&ras_uppd;
assign asa_rep_enq_desc_p1.ed_cmd.pd_len = asa_proc_meta_d2.ed_cmd.pd_len;
assign asa_rep_enq_desc_p1.ed_cmd.pd_loc = asa_proc_meta_d2.ed_cmd.pd_loc;
assign asa_rep_enq_desc_p1.ed_cmd.pd_buf_ptr = asa_proc_meta_d2.ed_cmd.pd_buf_ptr;
assign asa_rep_enq_desc_p1.ed_cmd.len = asa_proc_meta_d2.ed_cmd.len;
assign asa_rep_enq_desc_p1.ed_cmd.out_rci = asa_proc_meta_d2.ed_cmd.out_rci;

wire [`TID_NBITS - 1 : 0] asa_rep_enq_tid_p1 = asa_proc_meta_d2.tid;

wire [`SCI_NBITS-1:0] topic_sci = asa_proc_ras_d2[(1+`SCI_NBITS)*9+`RAS_FLAG_NBITS-1-1:(1+`SCI_NBITS)*8+`RAS_FLAG_NBITS];

wire [`REAL_TIME_NBITS-1:0] target_exp_time = current_time_d1+{default_sub_exp_time, {(`REAL_TIME_NBITS-`SUB_EXP_TIME_NBITS){1'b0}}};				

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		asa_classifier_fid <= asa_proc_meta_d1.tid;
		tset_waddr <= {tid_d2, topic_sci};
		tset_wdata <= target_exp_time[`REAL_TIME_NBITS-1:`SUB_EXP_TIME_NBITS];
		asa_rep_enq_desc <= asa_rep_enq_desc_p1;
		asa_rep_enq_pri <= asa_rep_enq_pri_p1;
		asa_rep_enq_tid <= asa_rep_enq_tid_p1;
		asa_rep_enq_vec <= asa_rep_enq_vec_p1;
		asa_rep_enq_discard <= asa_rep_enq_discard_p1;
		asa_rep_enq_allow_mcast <= fmo_allow_multicast;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		asa_classifier_valid <= 1'b0;
		tset_wr <= 1'b0;
		asa_rep_enq_req <= 1'b0;
	end else begin
		asa_classifier_valid <= asa_proc_valid_d1&terminate_flow;
		tset_wr <= ta_wr;
		asa_rep_enq_req <= asa_rep_enq_req_p1;
	end



/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
		ecdsa_asa_fp_waddr_d1 <= ecdsa_asa_fp_waddr;
		ecdsa_asa_fp_wdata_d1 <= ecdsa_asa_fp_wdata;
		current_time_d1 <= current_time;
		asa_proc_type3_d1 <= asa_proc_type3;
		asa_proc_meta_d1 <= asa_proc_meta;
		asa_proc_ras_d1 <= asa_proc_ras;
		asa_proc_type3_d2 <= asa_proc_type3_d1;
		asa_proc_meta_d2 <= asa_proc_meta_d1;
		asa_proc_ras_d2 <= asa_proc_ras_d1;
		fp_rdata_d1 <= fp_rdata;
		fa_rdata_d1 <= fa_rdata;
		ta_rdata_d1 <= ta_rdata;
		flow_bit_vec <= flow_bit_vec_p1;
		topic_bit_vec <= topic_bit_vec_p1;
		in_rci_mask <= ~in_rci_bit_vec_p1;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		ecdsa_asa_fp_wr_d1 <= 1'b0;
		asa_proc_valid_d1 <= 1'b0;
		asa_proc_valid_d2 <= 1'b0;
		flow_vec_valid <= 0;
		topic_vec_valid <= 0;
	end else begin
		ecdsa_asa_fp_wr_d1 <= ecdsa_asa_fp_wr;
		asa_proc_valid_d1 <= asa_proc_valid;
		asa_proc_valid_d2 <= asa_proc_valid_d1;
		flow_vec_valid <= flow_vec_valid_p1;
		topic_vec_valid <= topic_vec_valid_p1;
	end

/***************************** MEMORY ***************************************/

ram_1r1w_ultra #(`FLOW_POLICY2_NBITS, `FID_NBITS) u_ram_1r1w_ultra_0(
			.clk(clk),
			.wr(ecdsa_asa_fp_wr_d1),
			.raddr(fp_raddr),
			.waddr(ecdsa_asa_fp_waddr_d1),
			.din(ecdsa_asa_fp_wdata_d1),

			.dout(fp_rdata));

ram_1r1w_ultra #(`FLOW_ACTION_NBITS, `FID_NBITS) u_ram_1r1w_ultra_1(
			.clk(clk),
			.wr(fa_wr),
			.raddr(fa_raddr),
			.waddr(fa_waddr),
			.din(fa_wdata),

			.dout(fa_rdata));

ram_1r1w_ultra #(`SCI_VEC_NBITS, `TID_NBITS) u_ram_1r1w_ultra_2(
			.clk(clk),
			.wr(ta_wr),
			.raddr(ta_raddr),
			.waddr(ta_waddr),
			.din(ta_wdata),

			.dout(ta_rdata));

/***************************** FUNCTION ***************************************/

function [`SCI_VEC_NBITS-1:0] bit_vec_gen;
input [1+`SCI_NBITS-1:0] din;

integer i;
begin
	if (din[`SCI_NBITS])
		bit_vec_gen = {(`SCI_VEC_NBITS){1'b0}};
	else
		for (i=0; i<(1<<`SCI_NBITS); i++)
			bit_vec_gen[i] = din[`SCI_NBITS-1:0]==i;
end
endfunction

function [1:0] pri_gen;
input [15:0] din0;
input [2:0] din1;
begin
	case(din1)
		3'd0: pri_gen = din0[1:0];
		3'd1: pri_gen = din0[3:2];
		3'd2: pri_gen = din0[5:4];
		3'd3: pri_gen = din0[7:6];
		3'd4: pri_gen = din0[9:8];
		3'd5: pri_gen = din0[11:10];
		3'd6: pri_gen = din0[13:12];
		default: pri_gen = din0[15:14];
	endcase
end
endfunction

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

