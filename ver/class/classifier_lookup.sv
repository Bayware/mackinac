//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module classifier_lookup #(
parameter FLOW_DEPTH_NBITS = `FLOW_HASH_TABLE_DEPTH_NBITS,
parameter FLOW_HASH_NBITS = `FLOW_HASH_TABLE_DEPTH_NBITS,
parameter FLOW_ENTRY_NBITS = `FLOW_HASH_ENTRY_NBITS,
parameter FLOW_BUCKET_NBITS = `FLOW_HASH_BUCKET_NBITS,
parameter FLOW_VALUE_NBITS = `FLOW_VALUE_NBITS,
parameter FLOW_VALUE_DEPTH_NBITS = `FLOW_VALUE_DEPTH_NBITS,
parameter FLOW_KEY_NBITS = `FLOW_KEY_NBITS,
parameter TOPIC_NBITS = `ENCRYPTION_KEY_NBITS,
parameter TOPIC_DEPTH_NBITS = `TOPIC_HASH_TABLE_DEPTH_NBITS,
parameter TOPIC_HASH_NBITS = `TOPIC_HASH_TABLE_DEPTH_NBITS,
parameter TOPIC_ENTRY_NBITS = `TOPIC_HASH_ENTRY_NBITS,
parameter TOPIC_BUCKET_NBITS = `TOPIC_HASH_BUCKET_NBITS,
parameter TOPIC_VALUE_NBITS = `TOPIC_VALUE_NBITS,
parameter TOPIC_VALUE_DEPTH_NBITS = `TOPIC_VALUE_DEPTH_NBITS,
parameter TOPIC_KEY_NBITS = `TOPIC_KEY_NBITS,
parameter TOPIC_SN_NBITS = `SEQUENCE_NUMBER_NBITS,
parameter WR_NBITS = TOPIC_SN_NBITS+`SPI_NBITS
) (

input clk, 
input `RESET_SIG,

input [`REAL_TIME_NBITS-1:0] current_time,
input [`AGING_TIME_NBITS-1:0] aging_time,

input aggr_par_hdr_valid,
input [`DATA_PATH_RANGE] aggr_par_hdr_data,
input aggr_par_meta_type   aggr_par_meta_data,
input aggr_par_sop,
input aggr_par_eop,

input flow_hash_table0_ack, 
input [FLOW_BUCKET_NBITS-1:0] flow_hash_table0_rdata,

input flow_hash_table1_ack, 
input [FLOW_BUCKET_NBITS-1:0] flow_hash_table1_rdata,

input flow_key_ack, 
input [FLOW_KEY_NBITS-1:0] flow_key_rdata,

input flow_etime_ack, 
input [`EXP_TIME_NBITS-1:0] flow_etime_rdata,

input topic_hash_table0_ack, 
input [TOPIC_BUCKET_NBITS-1:0] topic_hash_table0_rdata,

input topic_hash_table1_ack, 
input [TOPIC_BUCKET_NBITS-1:0] topic_hash_table1_rdata,

input topic_key_ack, 
input [TOPIC_KEY_NBITS-1:0] topic_key_rdata,

input topic_etime_ack, 
input [`EXP_TIME_NBITS-1:0] topic_etime_rdata,

output logic cla_supervisor_flow_valid,
output logic [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_flow_hash0,
output logic [`FLOW_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_flow_hash1,
output logic [`FLOW_KEY_NBITS-1:0] cla_supervisor_flow_key,

output logic cla_supervisor_topic_valid,
output logic [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_topic_hash0,
output logic [`TOPIC_HASH_TABLE_DEPTH_NBITS-1:0] cla_supervisor_topic_hash1,
output logic [`TOPIC_KEY_NBITS-1:0] cla_supervisor_topic_key,

output logic cla_irl_valid,
output logic [`DATA_PATH_RANGE] cla_irl_hdr_data,
output cla_irl_meta_type cla_irl_meta_data,
output logic cla_irl_sop,
output logic cla_irl_eop,

output logic flow_hash_table0_rd, 
output logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table0_raddr,

output logic flow_hash_table0_wr, 
output logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table0_waddr,
output logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table0_wdata,

output logic flow_hash_table1_rd, 
output logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table1_raddr,

output logic flow_hash_table1_wr, 
output logic [FLOW_DEPTH_NBITS-1:0] flow_hash_table1_waddr,
output logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table1_wdata,

output logic flow_key_wr, 
output logic [FLOW_VALUE_DEPTH_NBITS-1:0] flow_key_waddr,
output logic [FLOW_KEY_NBITS-1:0] flow_key_wdata,

output logic flow_key_rd, 
output logic [FLOW_VALUE_DEPTH_NBITS-1:0] flow_key_raddr,

output logic flow_etime_rd, 
output logic [FLOW_VALUE_DEPTH_NBITS-1:0] flow_etime_raddr,

output logic topic_hash_table0_rd, 
output logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table0_raddr,

output logic topic_hash_table0_wr, 
output logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table0_waddr,
output logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table0_wdata,

output logic topic_hash_table1_rd, 
output logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table1_raddr,

output logic topic_hash_table1_wr, 
output logic [TOPIC_DEPTH_NBITS-1:0] topic_hash_table1_waddr,
output logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table1_wdata,

output logic topic_key_wr, 
output logic [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_key_waddr,
output logic [TOPIC_KEY_NBITS-1:0] topic_key_wdata,

output logic topic_key_rd, 
output logic [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_key_raddr,

output logic topic_etime_rd, 
output logic [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_etime_raddr

);

/***************************** LOCAL VARIABLES *******************************/
logic [`REAL_TIME_NBITS-1:0] current_time_d1;

logic aggr_par_hdr_valid_d1;
logic [`DATA_PATH_RANGE] aggr_par_hdr_data_d1;
aggr_par_meta_type   aggr_par_meta_data_d1;
logic aggr_par_sop_d1;
logic aggr_par_eop_d1;

logic [9:0] data_cnt;

logic [4:1] flow_hash_table0_ack_d;
logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table0_rdata_sv;

logic flow_hash_table1_ack_d1;
logic [FLOW_BUCKET_NBITS-1:0] flow_hash_table1_rdata_sv;

logic flow_key_ack_d1; 
logic flow_key_ack_d2; 

logic [FLOW_KEY_NBITS-1:0] flow_key_rdata_d1;

logic flow_etime_ack_d1; 
logic [`EXP_TIME_NBITS-1:0] flow_etime_rdata_d1;

logic [4:1] topic_hash_table0_ack_d;
logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table0_rdata_sv;

logic topic_hash_table1_ack_d1;
logic [TOPIC_BUCKET_NBITS-1:0] topic_hash_table1_rdata_sv;

logic topic_key_ack_d1; 
logic topic_key_ack_d2; 

logic [TOPIC_KEY_NBITS-1:0] topic_key_rdata_d1;

logic [`EXP_TIME_NBITS-1:0] topic_etime_rdata_d1; 

logic [`AGING_TIME_NBITS-1:0] aging_ctr;
logic [FLOW_VALUE_DEPTH_NBITS-1:0] aging_fid;
wire aging_en = (aging_ctr==aging_time);
logic aging_fifo_empty;

logic [7:0] in_fifo_traffic_class;
logic [127:0] in_fifo_data;
logic in_fifo_sop;
logic in_fifo_eop;
aggr_par_meta_type  in_fifo_meta_data;
wire in_fifo_discard = in_fifo_meta_data.discard;

logic in_fifo_empty;
logic in_fifo_rd_en;
wire in_fifo_rd = in_fifo_rd_en&~in_fifo_empty;
wire in_fifo_rd_1st = in_fifo_rd&in_fifo_sop;
wire in_fifo_rd_last = in_fifo_rd&in_fifo_eop;

wire lat_fifo2_rd = in_fifo_rd_last;
wire lat_fifo3_rd = lat_fifo2_rd;

logic [FLOW_HASH_NBITS-1:0] flow_hash0;
logic [FLOW_HASH_NBITS-1:0] flow_hash1;
logic [TOPIC_HASH_NBITS-1:0] topic_hash0;
logic [TOPIC_HASH_NBITS-1:0] topic_hash1;

logic [FLOW_HASH_NBITS-1:0] lat_fifo1_flow_hash0;
logic [FLOW_HASH_NBITS-1:0] lat_fifo1_flow_hash1;
logic [TOPIC_HASH_NBITS-1:0] lat_fifo1_topic_hash0;
logic [TOPIC_HASH_NBITS-1:0] lat_fifo1_topic_hash1;

logic lat_fifo_type1;
logic lat_fifo_type3;
logic [FLOW_KEY_NBITS-1:0] lat_fifo_flow_key;
wire [TOPIC_KEY_NBITS-1:0] lat_fifo_topic_key = lat_fifo_flow_key[FLOW_KEY_NBITS-1:FLOW_KEY_NBITS-1-127];

wire flow_hash_compare = lat_fifo_flow_key==flow_key_rdata_d1[`FLOW_VALUE_KEY];
wire topic_hash_compare = lat_fifo_topic_key==topic_key_rdata_d1[`TOPIC_VALUE_KEY];

logic [3:0] flow_compare_valid;
logic [3:0] topic_compare_valid;
logic [3:0] flow_entry_valid;
logic [3:0] topic_entry_valid;

logic type1;
logic type3;
logic lf2_type1;
logic lf2_type3;
logic [3:0] lf2_flow_compare_valid;
logic [3:0] lf2_topic_compare_valid;
logic [3:0] lf2_flow_entry_valid;
logic [3:0] lf2_topic_entry_valid;

wire flow_hash_valid = flow_etime_rdata_d1>current_time_d1[`REAL_TIME_NBITS-1:`REAL_TIME_NBITS-1-`EXP_TIME_NBITS+1];
wire topic_hash_valid = topic_etime_rdata_d1>current_time_d1[`REAL_TIME_NBITS-1:`REAL_TIME_NBITS-1-`EXP_TIME_NBITS+1];

wire [`TID_NBITS-1:0] tid0 = topic_hash_table0_rdata_sv[TOPIC_ENTRY_NBITS*1-1:TOPIC_ENTRY_NBITS*0+TOPIC_HASH_NBITS];
wire [`TID_NBITS-1:0] tid1 = topic_hash_table0_rdata_sv[TOPIC_ENTRY_NBITS*2-1:TOPIC_ENTRY_NBITS*1+TOPIC_HASH_NBITS];
wire [`TID_NBITS-1:0] tid2 = topic_hash_table1_rdata_sv[TOPIC_ENTRY_NBITS*1-1:TOPIC_ENTRY_NBITS*0+TOPIC_HASH_NBITS];
wire [`TID_NBITS-1:0] tid3 = topic_hash_table1_rdata_sv[TOPIC_ENTRY_NBITS*2-1:TOPIC_ENTRY_NBITS*1+TOPIC_HASH_NBITS];

wire [TOPIC_VALUE_DEPTH_NBITS-1:0] n_topic_key_raddr = topic_hash_table0_ack_d[1]?tid0:
							topic_hash_table0_ack_d[2]?tid1:
							topic_hash_table0_ack_d[3]?tid2:tid3;

logic ip_da_ready;
logic ip_da_ready_d1;
logic ip_da_ready_d2;

logic [63:0] data_sv;

logic aggr_par_eop_d2;
wire en_aggr_par_eop_d2 = aggr_par_hdr_valid_d1&(data_cnt>3);

wire in_fifo_wr = (aggr_par_hdr_valid_d1&(aggr_par_eop_d1|(data_cnt>2)))|aggr_par_eop_d2;
wire [127:0] in_fifo_data_in = {data_sv, aggr_par_hdr_data_d1[127:64]};
wire in_fifo_sop_in = (aggr_par_eop_d1&(data_cnt<3))|(data_cnt==3);
wire in_fifo_eop_in = aggr_par_eop_d2|aggr_par_eop_d1&~en_aggr_par_eop_d2;
aggr_par_meta_type  aggr_par_meta_data_d2;
aggr_par_meta_type  in_fifo_meta_data_in;
assign in_fifo_meta_data_in = aggr_par_eop_d2?aggr_par_meta_data_d2:aggr_par_meta_data_d1;

logic [127:0] ip_da;
logic [127:0] ip_sa;
logic [19:0] flow_label;
logic [7:0] traffic_class;

wire [FLOW_KEY_NBITS-1:0] flow_key = {ip_da, ip_sa, flow_label};
wire [TOPIC_KEY_NBITS-1:0] topic_key = ip_da;

wire n_flow_key_rd = |flow_hash_table0_ack_d;
wire n_flow_etime_rd = |flow_hash_table0_ack_d|~aging_fifo_empty;
wire aging_fifo_rd = ~(|flow_hash_table0_ack_d)&~aging_fifo_empty;

wire [`FID_NBITS-1:0] fid0 = flow_hash_table0_rdata_sv[FLOW_ENTRY_NBITS*1-1:FLOW_ENTRY_NBITS*0+FLOW_HASH_NBITS];
wire [`FID_NBITS-1:0] fid1 = flow_hash_table0_rdata_sv[FLOW_ENTRY_NBITS*2-1:FLOW_ENTRY_NBITS*1+FLOW_HASH_NBITS];
wire [`FID_NBITS-1:0] fid2 = flow_hash_table1_rdata_sv[FLOW_ENTRY_NBITS*1-1:FLOW_ENTRY_NBITS*0+FLOW_HASH_NBITS];
wire [`FID_NBITS-1:0] fid3 = flow_hash_table1_rdata_sv[FLOW_ENTRY_NBITS*2-1:FLOW_ENTRY_NBITS*1+FLOW_HASH_NBITS];

logic [FLOW_VALUE_DEPTH_NBITS-1:0] aging_fifo_fid;

wire [FLOW_VALUE_DEPTH_NBITS-1:0] n_flow_key_raddr = flow_hash_table0_ack_d[1]?fid0:
							flow_hash_table0_ack_d[2]?fid1:
							flow_hash_table0_ack_d[3]?fid2:
							flow_hash_table0_ack_d[4]?fid3:aging_fifo_fid;

wire lookup_done = flow_key_ack_d2&~flow_key_ack_d1;
wire lat_fifo_rd = lookup_done;
wire lat_fifo1_rd = lookup_done;

wire en_flow_supervisor = lf2_flow_compare_valid==0&lf2_flow_entry_valid==4'hf&~in_fifo_discard;
wire en_topic_supervisor = lf2_topic_compare_valid==0&lf2_topic_entry_valid==4'hf&~in_fifo_discard;

wire flow_will_wr = lf2_flow_compare_valid==0&lf2_flow_entry_valid!=4'hf;
wire topic_will_wr = lf2_topic_compare_valid==0&lf2_topic_entry_valid!=4'hf;

logic flow_freeb_empty;
logic [`FID_NBITS-1:0] flow_free_entry;
logic topic_freeb_empty;
logic [`TID_NBITS-1:0] topic_free_entry;

logic [`FID_NBITS-1:0] lf2_flow_free_entry;
logic [`TID_NBITS-1:0] lf2_topic_free_entry;

wire mflow_freeb_empty = flow_freeb_empty|in_fifo_discard;
wire mtopic_freeb_empty = topic_freeb_empty|in_fifo_discard;

wire set_en_flow_discard = in_fifo_rd_1st&flow_will_wr&mflow_freeb_empty;
wire set_en_topic_discard = in_fifo_rd_1st&topic_will_wr&mtopic_freeb_empty;

logic en_flow_discard;
logic en_topic_discard;

wire en_discard = set_en_flow_discard|en_flow_discard|set_en_topic_discard|en_topic_discard|~lf2_type1&(lf2_flow_compare_valid==0|lf2_topic_compare_valid==0);

wire en_flow_wr = lf2_type1&~lf2_type3&~mflow_freeb_empty&(~topic_will_wr|~mtopic_freeb_empty);
wire en_flow_key_wr = flow_will_wr&en_flow_wr;
wire en_flow_hash0_wr = lf2_flow_compare_valid==0&lf2_flow_entry_valid[1:0]!=2'h3&en_flow_wr;
wire en_flow_hash1_wr = lf2_flow_compare_valid==0&lf2_flow_entry_valid[3:2]!=2'h3&lf2_flow_entry_valid[1:0]==2'h3&en_flow_wr;

wire en_topic_wr = lf2_type1&~lf2_type3&~mtopic_freeb_empty&(~flow_will_wr|~mflow_freeb_empty);
wire en_topic_key_wr = topic_will_wr&en_topic_wr;
wire en_topic_hash0_wr = lf2_topic_compare_valid==0&lf2_topic_entry_valid[1:0]!=2'h3&en_topic_wr;
wire en_topic_hash1_wr = lf2_topic_compare_valid==0&lf2_topic_entry_valid[3:2]!=2'h3&lf2_topic_entry_valid[1:0]==2'h3&en_topic_wr;

wire [`FID_NBITS-1:0] fid = en_flow_key_wr?lf2_flow_free_entry:lf2_flow_compare_valid[0]?fid0:lf2_flow_compare_valid[1]?fid1:lf2_flow_compare_valid[2]?fid2:fid3;
wire [`TID_NBITS-1:0] tid = en_topic_key_wr?lf2_topic_free_entry:lf2_topic_compare_valid[0]?tid0:lf2_topic_compare_valid[1]?tid1:lf2_topic_compare_valid[2]?tid2:tid3;

logic [FLOW_VALUE_DEPTH_NBITS-1:0] aging_lat_fifo_fid;
logic aging_lat_fifo_sel;

wire flow_rel_buf_valid = flow_etime_ack_d1&~flow_hash_valid&aging_lat_fifo_sel;
wire [FLOW_VALUE_DEPTH_NBITS-1:0] flow_rel_buf_ptr = aging_lat_fifo_fid;

wire topic_rel_buf_valid = flow_etime_ack_d1&~topic_hash_valid&aging_lat_fifo_sel;
wire [TOPIC_VALUE_DEPTH_NBITS-1:0] topic_rel_buf_ptr = aging_lat_fifo_fid[TOPIC_VALUE_DEPTH_NBITS-1:0];

wire flow_key_wr_p1 = in_fifo_rd_1st&en_flow_key_wr;
wire flow_free_buf_rd = flow_key_wr_p1;
wire topic_key_wr_p1 = in_fifo_rd_1st&en_topic_key_wr;
wire topic_free_buf_rd = topic_key_wr_p1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		flow_hash_table0_raddr <= flow_hash0;
		flow_hash_table1_raddr <= flow_hash1;

		flow_hash_table0_waddr <= lat_fifo1_flow_hash0;
		flow_hash_table1_waddr <= lat_fifo1_flow_hash1;

		flow_hash_table0_wdata <= lf2_flow_entry_valid[1]?{flow_free_entry, lat_fifo1_flow_hash1, flow_hash_table0_rdata_sv[FLOW_ENTRY_NBITS-1:0]}:{flow_hash_table0_rdata_sv[FLOW_BUCKET_NBITS-1:FLOW_ENTRY_NBITS], flow_free_entry, lat_fifo1_flow_hash1};
		flow_hash_table1_wdata <= lf2_flow_entry_valid[3]?{flow_free_entry, lat_fifo1_flow_hash0, flow_hash_table1_rdata_sv[FLOW_ENTRY_NBITS-1:0]}:{flow_hash_table1_rdata_sv[FLOW_BUCKET_NBITS-1:FLOW_ENTRY_NBITS], flow_free_entry, lat_fifo1_flow_hash0};

		flow_key_raddr <= n_flow_key_raddr;
		flow_etime_raddr <= n_flow_key_raddr;

		flow_key_waddr <= flow_free_entry;
		flow_key_wdata <= lat_fifo_flow_key;

		topic_hash_table0_raddr <= topic_hash0;
		topic_hash_table1_raddr <= topic_hash1;

		topic_hash_table0_waddr <= lat_fifo1_topic_hash0;
		topic_hash_table1_waddr <= lat_fifo1_topic_hash1;

		topic_hash_table0_wdata <= lf2_topic_entry_valid[1]?{topic_free_entry, lat_fifo1_topic_hash1, topic_hash_table0_rdata_sv[TOPIC_ENTRY_NBITS-1:0]}:{topic_hash_table0_rdata_sv[TOPIC_BUCKET_NBITS-1:TOPIC_ENTRY_NBITS], topic_free_entry, lat_fifo1_topic_hash1};
		topic_hash_table1_wdata <= lf2_topic_entry_valid[3]?{topic_free_entry, lat_fifo1_topic_hash0, topic_hash_table1_rdata_sv[TOPIC_ENTRY_NBITS-1:0]}:{topic_hash_table1_rdata_sv[TOPIC_BUCKET_NBITS-1:TOPIC_ENTRY_NBITS], topic_free_entry, lat_fifo1_topic_hash0};


		topic_key_raddr <= n_topic_key_raddr;
		topic_etime_raddr <= n_topic_key_raddr;

		topic_key_waddr <= topic_free_entry;
		topic_key_wdata <= lat_fifo_topic_key;

		cla_supervisor_flow_key <= lat_fifo_flow_key;
		cla_supervisor_flow_hash0 <= lat_fifo1_flow_hash0;
		cla_supervisor_flow_hash1 <= lat_fifo1_flow_hash1;

		cla_supervisor_topic_key <= lat_fifo_topic_key;
		cla_supervisor_topic_hash0 <= lat_fifo1_topic_hash0;
		cla_supervisor_topic_hash1 <= lat_fifo1_topic_hash1;

		cla_irl_hdr_data <= in_fifo_data;
		cla_irl_sop <= in_fifo_sop|en_discard;
		cla_irl_eop <= in_fifo_eop|en_discard;
		cla_irl_meta_data.traffic_class <= in_fifo_traffic_class;
		cla_irl_meta_data.hdr_len <= in_fifo_meta_data.hdr_len;
		cla_irl_meta_data.buf_ptr <= in_fifo_meta_data.buf_ptr;
		cla_irl_meta_data.len <= in_fifo_meta_data.len;
		cla_irl_meta_data.port <= in_fifo_meta_data.port;
		cla_irl_meta_data.rci <= in_fifo_meta_data.rci;
		cla_irl_meta_data.fid <= fid;
		cla_irl_meta_data.tid <= tid;
		cla_irl_meta_data.type1 <= lf2_type1;
		cla_irl_meta_data.type3 <= lf2_type3|en_discard;
		cla_irl_meta_data.discard <= en_discard;
end


always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		flow_hash_table0_rd <= 1'b0;
		flow_hash_table1_rd <= 1'b0;
		flow_hash_table0_wr <= 1'b0;
		flow_hash_table1_wr <= 1'b0;
		flow_key_rd <= 1'b0;
		flow_key_wr <= 1'b0;
		flow_etime_rd <= 1'b0;
		topic_hash_table0_rd <= 1'b0;
		topic_hash_table1_rd <= 1'b0;
		topic_hash_table0_wr <= 1'b0;
		topic_hash_table1_wr <= 1'b0;
		topic_key_rd <= 1'b0;
		topic_key_wr <= 1'b0;
		topic_etime_rd <= 1'b0;

		cla_supervisor_flow_valid <= 1'b0;
		cla_supervisor_topic_valid <= 1'b0;

		cla_irl_valid <= 1'b0;

	end else begin

		flow_hash_table0_rd <= ip_da_ready_d2;
		flow_hash_table1_rd <= ip_da_ready_d2;
		flow_hash_table0_wr <= in_fifo_rd_1st&en_flow_hash0_wr;
		flow_hash_table1_wr <= in_fifo_rd_1st&en_flow_hash1_wr;
		flow_key_rd <= n_flow_key_rd;
		flow_etime_rd <= n_flow_etime_rd;
		flow_key_wr <= flow_key_wr_p1;
		topic_hash_table0_rd <= ip_da_ready_d2;
		topic_hash_table1_rd <= ip_da_ready_d2;
		topic_hash_table0_wr <= in_fifo_rd_1st&en_topic_hash0_wr;
		topic_hash_table1_wr <= in_fifo_rd_1st&en_topic_hash0_wr;
		topic_key_rd <= n_flow_key_rd;
		topic_etime_rd <= n_flow_etime_rd;
		topic_key_wr <= topic_key_wr_p1;

		cla_supervisor_flow_valid <= in_fifo_rd_1st&en_flow_supervisor;
		cla_supervisor_topic_valid <= in_fifo_rd_1st&en_topic_supervisor;

		cla_irl_valid <= en_discard?in_fifo_rd_last:in_fifo_rd;

	end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin

		current_time_d1 <= current_time;

		aggr_par_hdr_data_d1 <= aggr_par_hdr_data;
		aggr_par_meta_data_d1 <= aggr_par_meta_data;
		aggr_par_meta_data_d2 <= aggr_par_meta_data_d1;
		aggr_par_sop_d1 <= aggr_par_sop;
		aggr_par_eop_d1 <= aggr_par_eop;

		type3 <= aggr_par_hdr_valid_d1&aggr_par_sop_d1?aggr_par_hdr_data_d1[127-48:127-48-8+1]!=253:type3;
		traffic_class <= aggr_par_hdr_valid_d1&aggr_par_sop_d1?aggr_par_hdr_data_d1[127-4:127-4-8+1]:traffic_class;
		flow_label <= aggr_par_hdr_valid_d1&aggr_par_sop_d1?aggr_par_hdr_data_d1[127-12:127-12-20+1]:flow_label;
		ip_sa[127:64] <= aggr_par_hdr_valid_d1&aggr_par_sop_d1?aggr_par_hdr_data_d1[63:0]:ip_sa[127:64];
		{ip_sa[63:0], ip_da[127:64]} <= aggr_par_hdr_valid_d1&(data_cnt==1)?aggr_par_hdr_data_d1:{ip_sa[63:0], ip_da[127:64]};
		ip_da[63:0] <= aggr_par_hdr_valid_d1&(data_cnt==2)?aggr_par_hdr_data_d1[127:64]:ip_da[63:0];
		type1 <= aggr_par_hdr_valid_d1&(data_cnt==2)&~type3?aggr_par_hdr_data_d1[47:44]==4'h1:type1;

		data_sv <= aggr_par_hdr_valid_d1?aggr_par_hdr_data_d1[63:0]:data_sv;

		flow_key_rdata_d1 <= flow_key_rdata;
		flow_etime_rdata_d1 <= flow_etime_rdata;

		topic_key_rdata_d1 <= topic_key_rdata;
		topic_etime_rdata_d1 <= topic_etime_rdata;

		flow_entry_valid <= flow_key_ack_d1?{flow_hash_valid, flow_entry_valid[3:1]}:flow_entry_valid;
		flow_compare_valid <= flow_key_ack_d1?{(flow_hash_valid&flow_hash_compare), flow_compare_valid[3:1]}:flow_compare_valid;
		topic_entry_valid <= flow_key_ack_d1?{topic_hash_valid, topic_entry_valid[3:1]}:topic_entry_valid;
		topic_compare_valid <= flow_key_ack_d1?{(topic_hash_valid&topic_hash_compare), topic_compare_valid[3:1]}:topic_compare_valid;
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		aggr_par_hdr_valid_d1 <= 1'b0;
		aggr_par_eop_d2 <= 1'b0;
		data_cnt <= 0;

		ip_da_ready <= 1'b0;
		ip_da_ready_d1 <= 1'b0;
		ip_da_ready_d2 <= 1'b0;

		in_fifo_rd_en <= 0;

		en_flow_discard <= 1'b0;
		en_topic_discard <= 1'b0;

		flow_hash_table0_ack_d <= 0;
		flow_hash_table1_ack_d1 <= 0;

		flow_key_ack_d1 <= 0;
		flow_key_ack_d2 <= 0;

		flow_etime_ack_d1 <= 0;

		topic_hash_table0_ack_d <= 0;
		topic_hash_table1_ack_d1 <= 0;

		topic_key_ack_d1 <= 0;
		topic_key_ack_d2 <= 0;

		aging_ctr <= 0;
		aging_fid <= 0;

    	end else begin
		aggr_par_hdr_valid_d1 <= aggr_par_hdr_valid;
		aggr_par_eop_d2 <= en_aggr_par_eop_d2&aggr_par_eop_d1;
		data_cnt <= aggr_par_hdr_valid_d1&aggr_par_eop_d1?0:~aggr_par_hdr_valid_d1?data_cnt:data_cnt+1;

		ip_da_ready <= aggr_par_hdr_valid_d1&((aggr_par_eop_d1&data_cnt==0)|(data_cnt==1));
		ip_da_ready_d1 <= ip_da_ready;
		ip_da_ready_d2 <= ip_da_ready_d1;

		in_fifo_rd_en <= lookup_done?1'b1:in_fifo_rd_last?1'b0:in_fifo_rd_en;

		en_flow_discard <= set_en_flow_discard?1'b1:in_fifo_rd_last?1'b0:en_flow_discard;
		en_topic_discard <= set_en_topic_discard?1'b1:in_fifo_rd_last?1'b0:en_topic_discard;

		flow_hash_table0_ack_d <= {flow_hash_table0_ack_d[3:1], flow_hash_table0_ack};
		flow_hash_table1_ack_d1 <= flow_hash_table1_ack;

		flow_key_ack_d1 <= flow_key_ack;
		flow_key_ack_d2 <= flow_key_ack_d1;

		flow_etime_ack_d1 <= flow_etime_ack;

		topic_hash_table0_ack_d <= {topic_hash_table0_ack_d[3:1], topic_hash_table0_ack};
		topic_hash_table1_ack_d1 <= topic_hash_table1_ack;

		topic_key_ack_d1 <= topic_key_ack;
		topic_key_ack_d2 <= topic_key_ack_d1;

		aging_ctr <= aging_en?0:aging_ctr+1;
		aging_fid <= aging_en?aging_fid+1:aging_fid;
    	end

hash #(FLOW_KEY_NBITS, FLOW_HASH_NBITS) u_hash_0(

	.clk(clk), 
	.key(flow_key), 
	.hash_value(flow_hash0) 

);

logic [FLOW_KEY_NBITS-1:0] tp_flow_key;
transpose #(FLOW_KEY_NBITS) u_transpose_0(.in(flow_key), .out(tp_flow_key));

hash #(FLOW_KEY_NBITS, FLOW_HASH_NBITS) u_hash_1(

	.clk(clk), 
	.key(tp_flow_key), 
	.hash_value(flow_hash1) 

);

hash #(TOPIC_KEY_NBITS, TOPIC_HASH_NBITS) u_hash_2(

	.clk(clk), 
	.key(topic_key), 
	.hash_value(topic_hash0) 

);

logic [TOPIC_KEY_NBITS-1:0] tp_topic_key;
transpose #(TOPIC_KEY_NBITS) u_transpose_1(.in(topic_key), .out(tp_topic_key));

hash #(TOPIC_KEY_NBITS, TOPIC_HASH_NBITS) u_hash_3(

	.clk(clk), 
	.key(tp_topic_key), 
	.hash_value(topic_hash1) 

);

sfifo2f_fo #(`DATA_PATH_NBITS+2+8, 4) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({in_fifo_data_in, in_fifo_sop_in, in_fifo_eop_in, traffic_class}),               
        .rd(in_fifo_rd),
        .wr(in_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({in_fifo_data, in_fifo_sop, in_fifo_eop, in_fifo_traffic_class})               
    );

sfifo_aggr_par #(4) u_sfifo_aggr_par(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(in_fifo_meta_data_in),               
        .rd(in_fifo_rd),
        .wr(in_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(in_fifo_meta_data)               
    );

sfifo2f_fo #(2+FLOW_KEY_NBITS, 2) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({type1, type3, flow_key}),
        .rd(lat_fifo_rd),
        .wr(ip_da_ready_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({lat_fifo_type1, lat_fifo_type3, lat_fifo_flow_key})
    );

sfifo2f_fo #(FLOW_HASH_NBITS*2+TOPIC_HASH_NBITS*2, 2) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({flow_hash0, flow_hash1, topic_hash0, topic_hash1}),
        .rd(lat_fifo1_rd),
        .wr(ip_da_ready_d2),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({lat_fifo1_flow_hash0, lat_fifo1_flow_hash1, lat_fifo1_topic_hash0, lat_fifo1_topic_hash1})
    );

sfifo2f1 #(FLOW_BUCKET_NBITS*2+TOPIC_BUCKET_NBITS*2) u_sfifo2f1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({flow_hash_table0_rdata, flow_hash_table1_rdata, topic_hash_table0_rdata, topic_hash_table1_rdata}),
        .rd(lat_fifo3_rd),
        .wr(flow_hash_table0_ack),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({flow_hash_table0_rdata_sv, flow_hash_table1_rdata_sv, topic_hash_table0_rdata_sv, topic_hash_table1_rdata_sv})
    );

sfifo2f_fo #(1+FLOW_VALUE_DEPTH_NBITS, 2) u_sfifo2f_fo_5(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({~aging_fifo_empty, aging_fifo_fid}),
        .rd(flow_etime_ack_d1),
        .wr(n_flow_etime_rd),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({aging_lat_fifo_sel, aging_lat_fifo_fid})
    );

sfifo2f_fo #(2+4+4+4+4+`FID_NBITS+`TID_NBITS, 2) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({lat_fifo_type1, lat_fifo_type3, flow_entry_valid, flow_compare_valid, topic_entry_valid, topic_compare_valid, flow_free_entry, topic_free_entry}),
        .rd(lat_fifo2_rd),
        .wr(lookup_done),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({lf2_type1, lf2_type3, lf2_flow_entry_valid, lf2_flow_compare_valid, lf2_topic_entry_valid, lf2_topic_compare_valid, lf2_flow_free_entry, lf2_topic_free_entry})
    );

sfifo2f_fo #(FLOW_VALUE_DEPTH_NBITS, 4) u_sfifo2f_fo_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({aging_fid}),
        .rd(aging_fifo_rd),
        .wr(aging_en),

        .ncount(),
        .count(),
        .full(),
        .empty(aging_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({aging_fifo_fid})
    );


cla_flow_free_list u_cla_flow_free_list(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .freeb_init(1'b0),

        .rel_buf_valid(flow_rel_buf_valid),
        .rel_buf_ptr(flow_rel_buf_ptr),

        .free_buf_rd(flow_free_buf_rd),

        .inc_freeb_rd_count(),
        .inc_freeb_wr_count(),

        .freeb_init_done(),

        .freeb_empty(flow_freeb_empty),

        .free_buf_ptr(flow_free_entry)
    );

cla_topic_free_list u_cla_topic_free_list(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .freeb_init(1'b0),

        .rel_buf_valid(topic_rel_buf_valid),
        .rel_buf_ptr(topic_rel_buf_ptr),

        .free_buf_rd(topic_free_buf_rd),

        .inc_freeb_rd_count(),
        .inc_freeb_wr_count(),

        .freeb_init_done(),

        .freeb_empty(topic_freeb_empty),

        .free_buf_ptr(topic_free_entry)
    );



/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

