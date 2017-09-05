//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module ecdsa_process (

input clk,
input `RESET_SIG,

input [`REAL_TIME_NBITS-1:0] current_time,
input [`REAL_TIME_NBITS-1:0] default_exp_time,

input lh_ecdsa_hash_valid,
input [`LOGIC_HASH_NBITS-1:0] lh_ecdsa_hash_data,

input lh_ecdsa_valid,
input [`DATA_PATH_RANGE] lh_ecdsa_hdr_data,
input lh_ecdsa_meta_type   lh_ecdsa_meta_data,
input lh_ecdsa_sop,
input lh_ecdsa_eop,

input pp_ecdsa_ready,

input topic_policy_ack,
input [`TOPIC_POLICY_NBITS-1:0] topic_policy_rdata,

output logic topic_policy_rd,
output logic [`TID_NBITS-1:0] topic_policy_raddr,

output logic      ecdsa_pp_valid,
output logic      ecdsa_pp_sop,
output logic      ecdsa_pp_eop,
output logic [`DATA_PATH_RANGE] ecdsa_pp_data,
output ecdsa_pp_meta_type ecdsa_pp_meta_data,
output logic [`CHUNK_LEN_NBITS-1:0] ecdsa_pp_auth_len,

output logic ecdsa_lh_ready,

output logic ecdsa_classifier_flow_valid,
output logic [`FID_NBITS-1:0] ecdsa_classifier_fid,
output logic [`EXP_TIME_NBITS-1:0] ecdsa_classifier_flow_etime,

output logic ecdsa_classifier_topic_valid,
output logic [`TID_NBITS-1:0] ecdsa_classifier_tid,
output logic [`EXP_TIME_NBITS-1:0] ecdsa_classifier_topic_etime,

output logic ecdsa_irl_fill_tb_src_wr, 
output logic [`FLOW_VALUE_DEPTH_NBITS-1:0] ecdsa_irl_fill_tb_src_waddr,
output logic [`FILL_TB_NBITS-1:0] ecdsa_irl_fill_tb_src_wdata,

output logic ecdsa_lh_wr,
output logic [`FID_NBITS-1:0] ecdsa_lh_waddr,
output logic [`LOGIC_HASH_NBITS-1:0] ecdsa_lh_wdata,
output logic [`SERIAL_NUM_NBITS-1:0]   ecdsa_lh_sn_wdata,
output logic [`PPL_NBITS-1:0]   ecdsa_lh_ppl_wdata,

output logic ecdsa_piarb_wr,
output logic [`FID_NBITS-1:0] ecdsa_piarb_waddr,
output logic [`FLOW_PU_NBITS-1:0] ecdsa_piarb_wdata,

output logic ecdsa_asa_fp_wr,
output logic [`FID_NBITS-1:0] ecdsa_asa_fp_waddr,				
output logic [`FLOW_POLICY2_NBITS-1:0] ecdsa_asa_fp_wdata		

);

/***************************** LOCAL VARIABLES *******************************/

localparam PDATA_FIFO_DEPTH_NBITS = 12;
localparam PMETA_FIFO_DEPTH_NBITS = PDATA_FIFO_DEPTH_NBITS-3;
localparam DATA_FIFO_DEPTH_NBITS = 6;
localparam DATA_XON = ((1<<PDATA_FIFO_DEPTH_NBITS)-256);
localparam DATA_XOFF = ((1<<PDATA_FIFO_DEPTH_NBITS)-64);
localparam META_XON = ((1<<PMETA_FIFO_DEPTH_NBITS)-8);
localparam META_XOFF = ((1<<PMETA_FIFO_DEPTH_NBITS)-4);
localparam OUT_DATA_FIFO_DEPTH_NBITS = 7;
localparam OUT_META_FIFO_DEPTH_NBITS = 2;
localparam AUTH_LEN = 92;

logic lh_ecdsa_hash_valid_d1;
logic [`LOGIC_HASH_NBITS-1:0] lh_ecdsa_hash_data_d1;

logic lh_ecdsa_valid_d1;
logic [`DATA_PATH_RANGE] lh_ecdsa_hdr_data_d1;
lh_ecdsa_meta_type   lh_ecdsa_meta_data_d1;
logic lh_ecdsa_sop_d1;
logic lh_ecdsa_eop_d1;

logic lh_fifo_empty;
logic [`LOGIC_HASH_NBITS-1:0] lh_fifo_data;
logic lh_fifo_rd = ecdsa_lh_wr;

logic pmeta_fifo_empty;
logic [PMETA_FIFO_DEPTH_NBITS:0] pmeta_fifo_count;
lh_ecdsa_meta_type pmeta_fifo_data;
logic [`CHUNK_LEN_NBITS-1:0] pmeta_fifo_auth_len;

logic meta_fifo_full;
logic meta_fifo_empty;
lh_ecdsa_meta_type meta_fifo_data;
logic [`CHUNK_LEN_NBITS-1:0] meta_fifo_auth_len;

logic [`LH_ECDSA_META_FID_RANGE] fid = meta_fifo_data.fid;
logic [`LH_ECDSA_META_TID_RANGE] tid = meta_fifo_data.tid;

logic pdata_fifo_empty;
logic [PDATA_FIFO_DEPTH_NBITS:0] pdata_fifo_count;
logic [`DATA_PATH_RANGE] pdata_fifo_data;
logic pdata_fifo_sop;
logic pdata_fifo_eop;

logic data_fifo_full;
logic data_fifo_empty;
logic [`DATA_PATH_RANGE] data_fifo_data;
logic data_fifo_sop;
logic data_fifo_eop;
logic data_fifo_eop_d1;

logic ecdsa_ip_ready;
logic pdata_fifo_rd;
logic set_pdata_fifo_rd_en = ~pdata_fifo_empty&~pmeta_fifo_empty&pdata_fifo_sop&ecdsa_ip_ready;
logic reset_pdata_fifo_rd_en = pdata_fifo_rd&pdata_fifo_eop;
logic pdata_fifo_rd_en;
assign pdata_fifo_rd = ~pdata_fifo_empty&~data_fifo_full&pdata_fifo_rd_en&(~pdata_fifo_eop|~meta_fifo_full);
logic pdata_fifo_rd_1st = pdata_fifo_rd&pdata_fifo_sop;
logic pdata_fifo_rd_last = pdata_fifo_rd&pdata_fifo_eop;

logic data_fifo_wr = pdata_fifo_rd;

logic pmeta_fifo_rd = pdata_fifo_rd_last;
logic meta_fifo_wr = pmeta_fifo_rd;

logic signature_valid;
logic signature_verified;
	
logic [9:0] data_cnt;
logic [31:0] data_sv;

logic topic_fifo_empty;
logic [`TOPIC_POLICY_NBITS-1:0] topic_fifo_data;

logic out_data_fifo_full;
logic [`DATA_PATH_RANGE] out_data_fifo_data;
logic out_data_fifo_sop;
logic out_data_fifo_eop;

logic signature_fifo_empty;
logic signature_fifo_data;

logic out_meta_fifo_full;

logic data_fifo_rd;
logic data_fifo_rd_d1;
logic set_data_fifo_rd_en = ~data_fifo_empty&~meta_fifo_empty&data_fifo_sop&~signature_fifo_empty;
logic reset_data_fifo_rd_en = data_fifo_rd&data_fifo_eop;
logic data_fifo_rd_en;
assign data_fifo_rd = ~data_fifo_empty&data_fifo_rd_en&~out_data_fifo_full&(~data_fifo_eop|~out_meta_fifo_full);
logic data_fifo_rd_last = data_fifo_rd&data_fifo_eop;

lh_ecdsa_meta_type mpmeta_fifo_data;
assign mpmeta_fifo_data.traffic_class = pmeta_fifo_data.traffic_class;
assign mpmeta_fifo_data.hdr_len = pmeta_fifo_data.hdr_len;
assign mpmeta_fifo_data.buf_ptr = pmeta_fifo_data.buf_ptr;
assign mpmeta_fifo_data.len = pmeta_fifo_data.len;
assign mpmeta_fifo_data.port = pmeta_fifo_data.port;
assign mpmeta_fifo_data.rci = pmeta_fifo_data.rci;
assign mpmeta_fifo_data.fid = pmeta_fifo_data.fid;
assign mpmeta_fifo_data.tid = pmeta_fifo_data.tid;
assign mpmeta_fifo_data.type1 = pmeta_fifo_data.type1;
assign mpmeta_fifo_data.type3 = pmeta_fifo_data.type3;
assign mpmeta_fifo_data.discard = pmeta_fifo_data.discard|~signature_fifo_data;

logic out_data_fifo_wr = signature_fifo_data?(data_fifo_rd&(data_cnt>5))|(data_fifo_rd_d1&data_fifo_eop_d1):data_fifo_rd_last;
logic out_data_fifo_sop_in = (data_cnt==6);
logic [`DATA_PATH_RANGE] out_data_fifo_data_in = {data_sv, data_fifo_data[`DATA_PATH_NBITS-1:32]};
logic out_data_fifo_eop_in = ~signature_fifo_data|data_fifo_eop_d1;

logic meta_fifo_rd = data_fifo_rd_last;
logic out_meta_fifo_wr = meta_fifo_rd;
logic signature_fifo_rd = meta_fifo_rd;

lh_ecdsa_meta_type out_meta_fifo_data;
logic [`DOMAIN_ID_NBITS-1:0] out_meta_fifo_domain_id;
logic [`CHUNK_LEN_NBITS-1:0] out_meta_fifo_auth_len;

logic out_data_fifo_rd = ecdsa_pp_valid&pp_ecdsa_ready;
logic out_meta_fifo_rd = out_data_fifo_rd&out_data_fifo_eop;

logic [`PPL_NBITS-1:0] ppl;
logic [`ISSUER_ID_NBITS-1:0] issuer_id;
logic [`SERIAL_NUM_NBITS-1:0] serial_num;
logic [`NOTAFTER_NBITS-1:0] notafter;
logic [`DOMAIN_ID_NBITS-1:0] domain_id;
logic [`TOPIC_ROLE_NBITS-1:0] topic_role;
logic [`MASKON_NBITS-1:0] maskon;
logic [`BA_NBITS-1:0] ba;
logic [`EA_NBITS-1:0] ea;
logic [`FSPDA_NBITS-1:0] fspda;
logic [`TSPDA_NBITS-1:0] tspda;

logic ppl_valid;
logic ba_valid;

logic [`REAL_TIME_NBITS-1:0] current_time_d1;		

logic [`REAL_TIME_NBITS-1:0] target_exp_time = current_time_d1+default_exp_time;		

logic out_data_fifo_empty;
logic out_meta_fifo_empty;

logic [11:0] topic_maskon;
logic [3:0] topic_role_compare;
assign topic_role_compare[0] = topic_role==topic_fifo_data[7:0];
assign topic_role_compare[1] = topic_role==topic_fifo_data[24*1+7:24*0+0];
assign topic_role_compare[2] = topic_role==topic_fifo_data[24*2+7:24*1+0];
assign topic_role_compare[3] = topic_role==topic_fifo_data[24*3+7:24*2+0];
always @*
	case (1'b1)
		topic_role_compare[0]: topic_maskon = topic_fifo_data[24*1-1:24*0+8];
		topic_role_compare[1]: topic_maskon = topic_fifo_data[24*2-1:24*1+8];
		topic_role_compare[2]: topic_maskon = topic_fifo_data[24*3-1:24*2+8];
		topic_role_compare[3]: topic_maskon = topic_fifo_data[24*4-1:24*3+8];
		default: topic_maskon = maskon;
	endcase

logic topic_fifo_rd = ~topic_fifo_empty&ba_valid;

/***************************** NON REGISTERED OUTPUTS ************************/

assign ecdsa_pp_valid = ~out_data_fifo_empty&~out_meta_fifo_empty;

assign topic_policy_rd = pdata_fifo_rd_1st;

/***************************** REGISTERED OUTPUTS ****************************/

assign topic_policy_raddr = tid;

assign ecdsa_pp_sop = out_data_fifo_sop;
assign ecdsa_pp_eop = out_data_fifo_eop;
assign ecdsa_pp_data = out_data_fifo_data;

assign ecdsa_pp_meta_data.domain_id = out_meta_fifo_domain_id;
assign ecdsa_pp_meta_data.hdr_len = out_meta_fifo_data.hdr_len;
assign ecdsa_pp_meta_data.buf_ptr = out_meta_fifo_data.buf_ptr;
assign ecdsa_pp_meta_data.len = out_meta_fifo_data.len;
assign ecdsa_pp_meta_data.port = out_meta_fifo_data.port;
assign ecdsa_pp_meta_data.rci = out_meta_fifo_data.rci;
assign ecdsa_pp_meta_data.fid = out_meta_fifo_data.fid;
assign ecdsa_pp_meta_data.tid = out_meta_fifo_data.tid;
assign ecdsa_pp_meta_data.type1 = out_meta_fifo_data.type1;
assign ecdsa_pp_meta_data.type3 = out_meta_fifo_data.type3;
assign ecdsa_pp_meta_data.discard = out_meta_fifo_data.discard;

assign ecdsa_pp_auth_len = out_meta_fifo_auth_len;

always @(posedge clk) begin

		ecdsa_lh_waddr <= fid;
		ecdsa_lh_wdata <= lh_fifo_data;
		ecdsa_lh_sn_wdata <= serial_num;
		ecdsa_lh_ppl_wdata <= ppl;

		ecdsa_irl_fill_tb_src_waddr <= meta_fifo_data.port;
		ecdsa_irl_fill_tb_src_wdata <= {fid, ba};

		ecdsa_classifier_fid <= fid;
		ecdsa_classifier_flow_etime <= target_exp_time[`REAL_TIME_NBITS-1:`REAL_TIME_NBITS-`NOTAFTER_NBITS];

		ecdsa_classifier_tid <= tid;
		ecdsa_classifier_topic_etime <= target_exp_time[`REAL_TIME_NBITS-1:`REAL_TIME_NBITS-`NOTAFTER_NBITS];

		ecdsa_piarb_waddr <= fid;
		ecdsa_piarb_wdata <= {tspda, fspda, ea, topic_maskon[1:0]};

		ecdsa_asa_fp_waddr <= fid;
		ecdsa_asa_fp_wdata <= {topic_maskon[11:2], domain_id, meta_fifo_data.traffic_class};

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		ecdsa_lh_ready <= 1'b1;

		ecdsa_lh_wr <= 1'b0;
		ecdsa_irl_fill_tb_src_wr <= 1'b0;
		ecdsa_classifier_flow_valid <= 1'b0;
		ecdsa_classifier_topic_valid <= 1'b0;
		ecdsa_piarb_wr <= 1'b0;
		ecdsa_asa_fp_wr <= 1'b0;

    end else begin

		ecdsa_lh_ready <= (pdata_fifo_count>DATA_XOFF)|(pmeta_fifo_count>META_XOFF)?1'b0:(pdata_fifo_count<DATA_XON)&(pmeta_fifo_count<META_XON)?1'b1:ecdsa_lh_ready;
		ecdsa_lh_wr <= ppl_valid&signature_fifo_data&~lh_fifo_empty;
		ecdsa_irl_fill_tb_src_wr <= ba_valid&signature_fifo_data;
		ecdsa_classifier_flow_valid <= ba_valid&signature_fifo_data;
		ecdsa_classifier_topic_valid <= ba_valid&signature_fifo_data;
		ecdsa_piarb_wr <= ba_valid&signature_fifo_data;
		ecdsa_asa_fp_wr <= ba_valid&signature_fifo_data;
    end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin

		current_time_d1 <= current_time;

		lh_ecdsa_hash_data_d1 <= lh_ecdsa_hash_data;

		lh_ecdsa_meta_data_d1 <= lh_ecdsa_meta_data;
		lh_ecdsa_hdr_data_d1 <= lh_ecdsa_hdr_data;
		lh_ecdsa_sop_d1 <= lh_ecdsa_sop;
		lh_ecdsa_eop_d1 <= lh_ecdsa_eop;

		data_sv <= data_fifo_rd?data_fifo_data[31:0]:data_sv;
		data_fifo_eop_d1 <= data_fifo_rd?data_fifo_eop:data_fifo_eop_d1;

		ppl <= data_fifo_rd&(data_cnt==`PPL_LOC)?data_fifo_data[`PPL]:ppl;
		issuer_id <= data_fifo_rd&(data_cnt==`ISSUER_ID_LOC)?data_fifo_data[`ISSUER_ID]:issuer_id;
		serial_num <= data_fifo_rd&(data_cnt==`SERIAL_NUM_LOC)?data_fifo_data[`SERIAL_NUM]:serial_num;
		notafter <= data_fifo_rd&(data_cnt==`NOTAFTER_LOC)?data_fifo_data[`NOTAFTER]:notafter;
		domain_id <= data_fifo_rd&(data_cnt==`DOMAIN_ID_LOC)?data_fifo_data[`DOMAIN_ID]:domain_id;
		topic_role <= data_fifo_rd&(data_cnt==`TOPIC_ROLE_LOC)?data_fifo_data[`TOPIC_ROLE]:topic_role;
		maskon <= data_fifo_rd&(data_cnt==`MASKON_LOC)?data_fifo_data[`MASKON]:maskon;
		ba <= data_fifo_rd&(data_cnt==`BA_LOC)?data_fifo_data[`BA]:ba;
		ea <= data_fifo_rd&(data_cnt==`EA_LOC)?data_fifo_data[`EA]:ea;
		fspda <= data_fifo_rd&(data_cnt==`FSPDA_LOC)?data_fifo_data[`FSPDA]:fspda;
		tspda <= data_fifo_rd&(data_cnt==`TSPDA_LOC)?data_fifo_data[`TSPDA]:tspda;

		ppl_valid <= data_fifo_rd&(data_cnt==`PPL_LOC);
		ba_valid <= data_fifo_rd&(data_cnt==`BA_LOC);
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		lh_ecdsa_valid_d1 <= 1'b0;
		lh_ecdsa_hash_valid_d1 <= 1'b0;

		pdata_fifo_rd_en <= 1'b0;
		ecdsa_ip_ready <= 1'b1;

		data_cnt <= 0;

		data_fifo_rd_en <= 1'b0;
		data_fifo_rd_d1 <= 1'b0;

    end else begin

		lh_ecdsa_valid_d1 <= lh_ecdsa_valid;
		lh_ecdsa_hash_valid_d1 <= lh_ecdsa_hash_valid;

		pdata_fifo_rd_en <= set_pdata_fifo_rd_en?1'b1:reset_pdata_fifo_rd_en?1'b0:pdata_fifo_rd_en;
		ecdsa_ip_ready <= pdata_fifo_rd_1st?1'b0:signature_valid?1'b1:ecdsa_ip_ready;

		data_cnt <= pdata_fifo_rd_last?0:~pdata_fifo_rd?data_cnt:data_cnt+1;

		data_fifo_rd_en <= set_data_fifo_rd_en?1'b1:reset_data_fifo_rd_en?1'b0:data_fifo_rd_en;
		data_fifo_rd_d1 <= data_fifo_rd;
    end

sfifo2f_ram_pf #(`DATA_PATH_NBITS+2, PDATA_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lh_ecdsa_hdr_data_d1, lh_ecdsa_sop_d1, lh_ecdsa_eop_d1}),				
		.rd(pdata_fifo_rd),
		.wr(lh_ecdsa_valid_d1),

		.count(pdata_fifo_count),
		.full(),
		.empty(pdata_fifo_empty),
		.dout({pdata_fifo_data, pdata_fifo_sop, pdata_fifo_eop}));				

sfifo2f_ram_pf #(`DATA_PATH_NBITS+2, DATA_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pdata_fifo_data, pdata_fifo_sop, pdata_fifo_eop}),
		.rd(data_fifo_rd),
		.wr(data_fifo_wr),

		.count(),
		.full(data_fifo_full),
		.empty(data_fifo_empty),
		.dout({data_fifo_data, data_fifo_sop, data_fifo_eop}));				


sfifo2f_ram_pf #(`CHUNK_LEN_NBITS, PMETA_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lh_ecdsa_hdr_data_d1[127-`CHUNK_TYPE_NBITS:127-`CHUNK_TYPE_NBITS-`CHUNK_LEN_NBITS+1]}),				
		.rd(pmeta_fifo_rd),
		.wr(lh_ecdsa_valid_d1&lh_ecdsa_sop_d1),

		.count(pmeta_fifo_count),
		.full(),
		.empty(pmeta_fifo_empty),
		.dout({pmeta_fifo_auth_len})
);				

sfifo_ram_pf_lh_ecdsa #(PMETA_FIFO_DEPTH_NBITS) u_sfifo_ram_pf_lh_ecdsa_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(lh_ecdsa_meta_data_d1),				
		.rd(pmeta_fifo_rd),
		.wr(lh_ecdsa_valid_d1&lh_ecdsa_sop_d1),

		.count(),
		.full(),
		.empty(),
		.dout(pmeta_fifo_data)
);				

sfifo2f_ram_pf #(`LOGIC_HASH_NBITS, PMETA_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lh_ecdsa_hash_data_d1}),				
		.rd(lh_fifo_rd),
		.wr(lh_ecdsa_hash_valid_d1),

		.count(),
		.full(),
		.empty(lh_fifo_empty),
		.dout({lh_fifo_data})
);				

sfifo2f1 #(`CHUNK_LEN_NBITS) u_sfifo2f1_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pmeta_fifo_auth_len}),				
		.rd(meta_fifo_rd),
		.wr(meta_fifo_wr),

		.count(),
		.full(),
		.empty(meta_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({meta_fifo_auth_len}));			

sfifo_lh_ecdsa #(1) u_sfifo_lh_ecdsa_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(mpmeta_fifo_data),				
		.rd(meta_fifo_rd),
		.wr(meta_fifo_wr),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(meta_fifo_data));			

sfifo2f1 #(1) u_sfifo2f1_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({signature_verified}),				
		.rd(signature_fifo_rd),
		.wr(signature_valid),

		.count(),
		.full(),
		.empty(signature_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({signature_fifo_data}));			

sfifo2f_ram_pf #(`DATA_PATH_NBITS+2, OUT_DATA_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({out_data_fifo_data_in, out_data_fifo_sop_in, out_data_fifo_eop_in}),
		.rd(out_data_fifo_rd),
		.wr(out_data_fifo_wr),

		.count(),
		.full(),
		.empty(out_data_fifo_empty),
		.dout({out_data_fifo_data, out_data_fifo_sop, out_data_fifo_eop}));				

sfifo2f_ram_pf #(`DOMAIN_ID_NBITS+`CHUNK_LEN_NBITS, OUT_META_FIFO_DEPTH_NBITS) u_sfifo2f_ram_pf_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({domain_id, meta_fifo_auth_len}),				
		.rd(out_meta_fifo_rd),
		.wr(out_meta_fifo_wr),

		.count(),
		.full(out_meta_fifo_full),
		.empty(out_meta_fifo_empty),
		.dout({out_meta_fifo_domain_id, out_meta_fifo_auth_len})
);				

sfifo_ram_pf_lh_ecdsa #(OUT_META_FIFO_DEPTH_NBITS) u_sfifo_ram_pf_lh_ecdsa_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(meta_fifo_data),				
		.rd(out_meta_fifo_rd),
		.wr(out_meta_fifo_wr),

		.count(),
		.full(),
		.empty(),
		.dout(out_meta_fifo_data)
);				

sfifo2f1 #(`TOPIC_POLICY_NBITS) u_sfifo2f1_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({topic_policy_rdata}),				
		.rd(topic_fifo_rd),
		.wr(topic_policy_ack),

		.count(),
		.full(),
		.empty(topic_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({topic_fifo_data}));			

ecdsa_ip_core u_ecdsa_ip_core(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),
		.in_valid(lh_ecdsa_valid_d1),
		.in_hdr_data(lh_ecdsa_hdr_data_d1),
		.in_meta_data(lh_ecdsa_meta_data_d1),
		.in_sop(lh_ecdsa_sop_d1),
		.in_eop(lh_ecdsa_eop_d1),

		.signature_valid(signature_valid),
		.signature_verified(signature_verified)
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

