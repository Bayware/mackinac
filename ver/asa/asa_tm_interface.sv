//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module asa_tm_interface #(
parameter LEN_NBITS = `PD_CHUNK_DEPTH_NBITS  
)(

input clk, `RESET_SIG,

input discard_req,		
input [`PACKET_LENGTH_NBITS-1:0] discard_packet_length,
input [`PORT_ID_NBITS-1:0] discard_src_port,
input [`BUF_PTR_NBITS-1:0] discard_buf_ptr,
input [`EM_BUF_PTR_NBITS-1:0] discard_em_buf_ptr,
input [LEN_NBITS-1:0] discard_em_len,

input rep_enq_req,			
input rep_enq_drop,						
input rep_enq_ucast,						
input rep_enq_last,						
input [`PACKET_ID_NBITS-1:0] rep_enq_packet_id,				
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] rep_enq_qid,			
input enq_pkt_desc_type rep_enq_desc,		

input tm_asa_poll_ack,
input tm_asa_poll_drop,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id,
input [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id,

output logic int_rep_bp,

output logic asa_tm_poll_req,		
output logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_poll_qid,				
output logic [`PORT_ID_NBITS-1:0] asa_tm_poll_src_port,				

output logic asa_tm_enq_req,					
output logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_qid,				
output logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_id,
output logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_conn_group_id,
output logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] asa_tm_enq_port_queue_id,
output enq_pkt_desc_type asa_tm_enq_desc,				

output logic asa_em_read_count_valid,
output logic [`READ_COUNT_NBITS-1:0] asa_em_read_count,
output logic [`PD_CHUNK_DEPTH_NBITS-1:0] asa_em_pd_length,
output logic [`PORT_ID_NBITS-1:0] asa_em_rc_port_id,
output logic [`EM_BUF_PTR_NBITS-1:0] asa_em_buf_ptr,

output logic asa_bm_read_count_valid,
output logic [`READ_COUNT_NBITS-1:0] asa_bm_read_count,
output logic [`PACKET_LENGTH_NBITS-1:0] asa_bm_packet_length,
output logic [`PORT_ID_NBITS-1:0] asa_bm_rc_port_id,
output logic [`BUF_PTR_NBITS-1:0] asa_bm_buf_ptr

);

/***************************** LOCAL VARIABLES *******************************/
localparam LAT_FIFO_DEPTH_BITS = 7;

localparam [1:0]	 INIT_IDLE = 0,
		 INIT_CTR = 1,
		 INIT_DONE = 2;

logic [1:0] init_st, nxt_init_st;
logic [`PACKET_ID_NBITS-1:0] init_count;
logic init_wr;


logic tm_asa_poll_ack_d1;
logic tm_asa_poll_drop_d1;

logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id_d1;
logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id_d2;
logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_id_d3;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id_d1;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id_d2;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_conn_group_id_d3;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id_d1;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id_d2;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] tm_asa_poll_port_queue_id_d3;
logic [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id_d1;
logic [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id_d2;
logic [`PORT_ID_NBITS-1:0] tm_asa_poll_port_id_d3;

logic discard_req_d1;														
logic [`PACKET_LENGTH_NBITS-1:0] discard_packet_length_d1;
logic [`PORT_ID_NBITS-1:0] discard_src_port_d1;
logic [`BUF_PTR_NBITS-1:0] discard_buf_ptr_d1;
logic [`EM_BUF_PTR_NBITS-1:0] discard_em_buf_ptr_d1;
logic [LEN_NBITS-1:0] discard_em_len_d1;

logic rep_enq_req1_d1;				
logic rep_enq_req_d1;				
logic rep_enq_drop_d1;						
logic rep_enq_ucast_d1;						
logic rep_enq_last_d1;						
logic [`PACKET_ID_NBITS-1:0] rep_enq_packet_id_d1;				
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] rep_enq_qid_d1;			

enq_pkt_desc_type rep_enq_desc_d1;

logic tm_drop_d1;
logic tm_drop_d2;
logic tm_drop1_d2;

logic final_copy_d1;
logic final_copy_d2;

logic [`READ_COUNT_NBITS-1:0] rc_ctr_rdata_d1;

logic [`PORT_ID_NBITS-1:0] src_port_id_d1;
logic [`PORT_ID_NBITS-1:0] src_port_id_d2;

logic [`BUF_PTR_NBITS-1:0] buf_ptr_d1;
logic [`BUF_PTR_NBITS-1:0] buf_ptr_d2;

logic [`PACKET_LENGTH_NBITS-1:0] packet_length_d1;
logic [`PACKET_LENGTH_NBITS-1:0] packet_length_d2;

logic [`EM_BUF_PTR_NBITS-1:0] em_buf_ptr_d1;
logic [`EM_BUF_PTR_NBITS-1:0] em_buf_ptr_d2;

logic [LEN_NBITS-1:0] em_len_d1;
logic [LEN_NBITS-1:0] em_len_d2;

logic lat_fifo_rd0_d1;
logic lat_fifo_rd0_d2;
logic lat_fifo_rd01_d2;
logic lat_fifo_rd02_d2;

logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_rep_enq_qid_d1;			
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_rep_enq_qid_d2;			
enq_pkt_desc_type lat_fifo_rep_enq_desc_d1;	
enq_pkt_desc_type lat_fifo_rep_enq_desc_d2;	
logic [`PACKET_ID_NBITS-1:0] lat_fifo_rep_enq_packet_id_d1;
logic [`PACKET_ID_NBITS-1:0] lat_fifo_rep_enq_packet_id_d2;
logic lat_fifo_rep_enq_ucast_d1;
logic lat_fifo_rep_enq_ucast_d2;
logic lat_fifo_rep_enq_ucast1_d2;

logic [`READ_COUNT_NBITS-1:0] enq_read_count0;
logic [`READ_COUNT_NBITS-1:0] enq_read_count1;

logic rc_ctr_wr;
logic rc_ctr_wr_d1;
logic rc_ctr_wr_d2;

logic [`PACKET_ID_NBITS-1:0] rc_ctr_waddr;
logic [`PACKET_ID_NBITS-1:0] rc_ctr_waddr_d1;
logic [`PACKET_ID_NBITS-1:0] rc_ctr_waddr_d2;

logic [`READ_COUNT_NBITS-1:0] rc_ctr_wdata;
logic [`READ_COUNT_NBITS-1:0] rc_ctr_wdata_d1;
logic [`READ_COUNT_NBITS-1:0] rc_ctr_wdata_d2;

logic [`READ_COUNT_NBITS-1:0] mrc_ctr_rdata;
logic same_addr21;
logic same_addr0;

logic [1:0] ctr4;
logic [2:0] policer;

logic buf_fifo_rd0_d1;
logic buf_fifo_rd01_d1;
logic buf_fifo_rd1_d1;

logic intf_fifo_rep_enq_drop;						
logic intf_fifo_rep_enq_ucast;						
logic intf_fifo_rep_enq_last;						
logic [`PACKET_ID_NBITS-1:0] intf_fifo_rep_enq_packet_id;				
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] intf_fifo_rep_enq_qid;			
enq_pkt_desc_type intf_fifo_rep_enq_desc;
	
logic [4:0] intf_fifo_count;
logic intf_fifo_empty;
logic intf_fifo_empty1;

logic [LAT_FIFO_DEPTH_BITS:0] lat_fifo_count;

logic lat_fifo_rep_enq_drop;						
logic lat_fifo_rep_enq_ucast;						
logic lat_fifo_rep_enq_last;						
logic [`PACKET_ID_NBITS-1:0] lat_fifo_rep_enq_packet_id;				
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_rep_enq_qid;			
enq_pkt_desc_type lat_fifo_rep_enq_desc;	

wire en_intf_rd = 1 /*~policer[2]*/;
wire intf_fifo_rd = ~intf_fifo_empty&en_intf_rd;
wire intf_fifo_rd1 = ~intf_fifo_empty1&en_intf_rd;
wire lat_fifo_wr0 = intf_fifo_rd;

wire [`PORT_ID_NBITS-1:0] src_port_id = lat_fifo_rep_enq_desc.src_port;
wire [`BUF_PTR_NBITS-1:0] buf_ptr = lat_fifo_rep_enq_desc.buf_ptr;
wire [`PACKET_LENGTH_NBITS-1:0] packet_length = lat_fifo_rep_enq_desc.ed_cmd.len;
wire [`EM_BUF_PTR_NBITS-1:0] em_buf_ptr = lat_fifo_rep_enq_desc.ed_cmd.pd_buf_ptr;
wire [LEN_NBITS-1:0] em_len = lat_fifo_rep_enq_desc.ed_cmd.pd_len;

logic lat_fifo_empty0;
wire lat_fifo_rd0 = tm_asa_poll_ack_d1;

logic [`READ_COUNT_NBITS-1:0] lat_fifo_final_read_count;
logic [`PORT_ID_NBITS-1:0] lat_fifo_src_port_id;
logic [`BUF_PTR_NBITS-1:0] lat_fifo_buf_ptr;
logic [`PACKET_LENGTH_NBITS-1:0] lat_fifo_packet_length;
logic [`EM_BUF_PTR_NBITS-1:0] lat_fifo_em_buf_ptr;
logic [LEN_NBITS-1:0] lat_fifo_em_len;
logic [`PACKET_ID_NBITS-1:0] lat_fifo_packet_id;				
logic lat_fifo_ucast;
logic lat_fifo_empty3;

wire lat_fifo_rd3 = ~discard_req_d1&~lat_fifo_empty3;

logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] buf_tm_asa_poll_conn_id0;
logic [`SECOND_LVL_QUEUE_ID_NBITS-1:0] buf_tm_asa_poll_conn_id1;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] buf_tm_asa_poll_conn_group_id0;
logic [`THIRD_LVL_QUEUE_ID_NBITS-1:0] buf_tm_asa_poll_conn_group_id1;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] buf_tm_asa_poll_port_queue_id0;
logic [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] buf_tm_asa_poll_port_queue_id1;
logic [`PACKET_ID_NBITS-1:0] buf_rep_enq_packet_id0;
logic [`PACKET_ID_NBITS-1:0] buf_rep_enq_packet_id1;
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] buf_rep_enq_qid0;			
logic [`FIRST_LVL_QUEUE_ID_NBITS-1:0] buf_rep_enq_qid1;			
enq_pkt_desc_type buf_rep_enq_desc0;	
enq_pkt_desc_type buf_rep_enq_desc1;	
	
wire [`PORT_ID_NBITS-1:0] enq_src_port_id = intf_fifo_rep_enq_desc.src_port;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		asa_em_read_count <= discard_req_d1?0:lat_fifo_final_read_count;
		asa_em_pd_length <= discard_req_d1?discard_em_len_d1:lat_fifo_em_len;
		asa_em_rc_port_id <= discard_req_d1?0:lat_fifo_src_port_id;
		asa_em_buf_ptr <= discard_req_d1?discard_em_buf_ptr_d1:lat_fifo_em_buf_ptr;

		asa_bm_read_count <= discard_req_d1?0:lat_fifo_final_read_count;
		asa_bm_packet_length <= discard_req_d1?discard_packet_length:lat_fifo_packet_length;
		asa_bm_rc_port_id <= discard_req_d1?discard_src_port_d1:lat_fifo_src_port_id;
		asa_bm_buf_ptr <= discard_req_d1?discard_buf_ptr_d1:lat_fifo_buf_ptr;

		asa_tm_poll_qid <= intf_fifo_rep_enq_qid;
		asa_tm_poll_src_port <= intf_fifo_rep_enq_desc.src_port;

		asa_tm_enq_qid <= buf_fifo_rd01_d1?buf_rep_enq_qid0:buf_rep_enq_qid1;
		asa_tm_enq_conn_id <= buf_fifo_rd01_d1?buf_tm_asa_poll_conn_id0:buf_tm_asa_poll_conn_id1;
		asa_tm_enq_conn_group_id <= buf_fifo_rd01_d1?buf_tm_asa_poll_conn_group_id0:buf_tm_asa_poll_conn_group_id1;
		asa_tm_enq_port_queue_id <= buf_fifo_rd01_d1?buf_tm_asa_poll_port_queue_id0:buf_tm_asa_poll_port_queue_id1;
		asa_tm_enq_desc <= buf_fifo_rd01_d1?buf_rep_enq_desc0:buf_rep_enq_desc1;
					
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		asa_em_read_count_valid <= 0;
		asa_bm_read_count_valid <= 0;
		asa_tm_poll_req <= 0;
		asa_tm_enq_req <= 0;
		int_rep_bp <= 0;
	end else begin
		asa_em_read_count_valid <= discard_req_d1|~lat_fifo_empty3;
		asa_bm_read_count_valid <= discard_req_d1|~lat_fifo_empty3;
		asa_tm_poll_req <= intf_fifo_rd;
		asa_tm_enq_req <= buf_fifo_rd0_d1|buf_fifo_rd1_d1;
		int_rep_bp <= intf_fifo_count>10?1:intf_fifo_count<6?0:int_rep_bp;
	end

/***************************** PROGRAM BODY **********************************/

wire final_copy = lat_fifo_rep_enq_ucast|lat_fifo_rep_enq_last;

wire tm_drop0 = tm_asa_poll_drop_d1|lat_fifo_rep_enq_drop;

wire [`READ_COUNT_NBITS-1:0] rc_ctr_rdata /* synthesis keep = 1 */;

wire [`PACKET_ID_NBITS-1:0] rc_ctr_raddr = lat_fifo_rep_enq_packet_id;
wire [`PACKET_ID_NBITS-1:0] rc_ctr_waddr_p1 = lat_fifo_rep_enq_packet_id_d1;

wire rc_ctr_wr_p1 = lat_fifo_rd0_d2&~tm_drop_d2;
wire rc_ctr_wr1_p1 = lat_fifo_rd01_d2&~tm_drop1_d2;

logic [2:0] same_addr_p1;
assign same_addr_p1[0] = (rc_ctr_waddr_p1==rc_ctr_waddr_p1)&rc_ctr_wr_p1;
assign same_addr_p1[1] = (rc_ctr_waddr_p1==rc_ctr_waddr)&rc_ctr_wr;
assign same_addr_p1[2] = (rc_ctr_waddr_p1==rc_ctr_waddr_d1)&rc_ctr_wr_d1;

wire [`READ_COUNT_NBITS-1:0] mrc_ctr_rdata_p1 = same_addr_p1[1]?rc_ctr_wdata:rc_ctr_wdata_d1;

wire [`READ_COUNT_NBITS-1:0] mrc_ctr_rdata_d1 = same_addr0?rc_ctr_wdata:same_addr21?mrc_ctr_rdata:rc_ctr_rdata_d1;

wire [`READ_COUNT_NBITS-1:0] final_read_count = mrc_ctr_rdata_d1+(tm_drop_d2?0:1);
wire [`READ_COUNT_NBITS-1:0] rc_ctr_wdata_p1 = final_copy_d2?0:mrc_ctr_rdata_d1+1;

wire lat_fifo_wr3 = lat_fifo_rd02_d2&final_copy_d2;

wire buf_fifo_wr0 = rc_ctr_wr_p1&lat_fifo_rep_enq_ucast_d2;
wire buf_fifo_wr1 = rc_ctr_wr1_p1&~lat_fifo_rep_enq_ucast1_d2;

wire save_fifo_wr0 = lat_fifo_rd3&(lat_fifo_final_read_count!=0)&lat_fifo_ucast;
logic [`READ_COUNT_NBITS-1:0] save_fifo_final_read_count0;
logic save_fifo_empty0;
logic [`PACKET_ID_NBITS-1:0] save_fifo_packet_id0;

wire save_fifo_wr1 = lat_fifo_rd3&(lat_fifo_final_read_count!=0)&~lat_fifo_ucast;
logic [`READ_COUNT_NBITS-1:0] save_fifo_final_read_count1;
logic save_fifo_empty1;
logic [`PACKET_ID_NBITS-1:0] save_fifo_packet_id1;

logic buf_fifo_empty0;
logic buf_fifo_empty1;

wire same_packet_id0 = (save_fifo_packet_id0==buf_rep_enq_packet_id0);
wire en_rd0 = ~buf_fifo_empty0&~save_fifo_empty0&same_packet_id0;
wire buf_fifo_rd0 = en_rd0;

wire same_packet_id1 = (save_fifo_packet_id1==buf_rep_enq_packet_id1);
wire buf_fifo_rd1 = ~en_rd0&~buf_fifo_empty1&~save_fifo_empty1&same_packet_id1;

wire final_enq0 = enq_read_count0==save_fifo_final_read_count0;
wire save_fifo_rd0 = buf_fifo_rd0&final_enq0;

wire final_enq1 = enq_read_count1==save_fifo_final_read_count1;
wire save_fifo_rd1 = buf_fifo_rd1&final_enq1;

always @(posedge clk) begin
		discard_buf_ptr_d1 <= discard_buf_ptr;
		discard_src_port_d1 <= discard_src_port;

		rep_enq_drop_d1 <= rep_enq_drop;
		rep_enq_ucast_d1 <= rep_enq_ucast;
		rep_enq_last_d1 <= rep_enq_last;
		rep_enq_packet_id_d1 <= rep_enq_packet_id;
		rep_enq_qid_d1 <= rep_enq_qid;
		rep_enq_desc_d1 <= rep_enq_desc;

		tm_asa_poll_drop_d1 <= tm_asa_poll_drop;
		tm_asa_poll_conn_id_d1 <= tm_asa_poll_conn_id;
		tm_asa_poll_conn_id_d2 <= tm_asa_poll_conn_id_d1;
		tm_asa_poll_conn_id_d3 <= tm_asa_poll_conn_id_d2;
		tm_asa_poll_conn_group_id_d1 <= tm_asa_poll_conn_group_id;
		tm_asa_poll_conn_group_id_d2 <= tm_asa_poll_conn_group_id_d1;
		tm_asa_poll_conn_group_id_d3 <= tm_asa_poll_conn_group_id_d2;
		tm_asa_poll_port_queue_id_d1 <= tm_asa_poll_port_queue_id;
		tm_asa_poll_port_queue_id_d2 <= tm_asa_poll_port_queue_id_d1;
		tm_asa_poll_port_queue_id_d3 <= tm_asa_poll_port_queue_id_d2;
		tm_asa_poll_port_id_d1 <= tm_asa_poll_port_id;
		tm_asa_poll_port_id_d2 <= tm_asa_poll_port_id_d1;
		tm_asa_poll_port_id_d3 <= tm_asa_poll_port_id_d2;

		rc_ctr_rdata_d1 <= rc_ctr_rdata;

		rc_ctr_wr <= rc_ctr_wr_p1;
		rc_ctr_wr_d1 <= rc_ctr_wr;
		rc_ctr_wr_d2 <= rc_ctr_wr_d1;

		rc_ctr_waddr <= rc_ctr_waddr_p1;
		rc_ctr_waddr_d1 <= rc_ctr_waddr;
		rc_ctr_waddr_d2 <= rc_ctr_waddr_d1;

		rc_ctr_wdata <= rc_ctr_wdata_p1;
		rc_ctr_wdata_d1 <= rc_ctr_wdata;
		rc_ctr_wdata_d2 <= rc_ctr_wdata_d1;

		same_addr21 <= |same_addr_p1[2:1];
		same_addr0 <= same_addr_p1[0];
		mrc_ctr_rdata <= mrc_ctr_rdata_p1;

		tm_drop_d1 <= tm_drop0;
		tm_drop_d2 <= tm_drop_d1;
		tm_drop1_d2 <= tm_drop_d1;

		final_copy_d1 <= final_copy;
		final_copy_d2 <= final_copy_d1;

		src_port_id_d1 <= src_port_id;
		src_port_id_d2 <= src_port_id_d1;
		buf_ptr_d1 <= buf_ptr;
		buf_ptr_d2 <= buf_ptr_d1;
		packet_length_d1 <= packet_length;
		packet_length_d2 <= packet_length_d1;
		em_len_d1 <= em_len;
		em_len_d2 <= em_len_d1;

		lat_fifo_rep_enq_qid_d1 <= lat_fifo_rep_enq_qid;			
		lat_fifo_rep_enq_qid_d2 <= lat_fifo_rep_enq_qid_d1;			
		lat_fifo_rep_enq_desc_d1 <= lat_fifo_rep_enq_desc;	
		lat_fifo_rep_enq_desc_d2 <= lat_fifo_rep_enq_desc_d1;	
		lat_fifo_rep_enq_packet_id_d1 <= lat_fifo_rep_enq_packet_id;	
		lat_fifo_rep_enq_packet_id_d2 <= lat_fifo_rep_enq_packet_id_d1;	
		lat_fifo_rep_enq_ucast_d1 <= lat_fifo_rep_enq_ucast;	
		lat_fifo_rep_enq_ucast_d2 <= lat_fifo_rep_enq_ucast_d1;	
		lat_fifo_rep_enq_ucast1_d2 <= lat_fifo_rep_enq_ucast_d1;	
end

wire fill_policer = ctr4!=3;

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		ctr4 <= 0;
		policer <= 0;
		init_count <= 0;
		init_wr <= 0;
		discard_req_d1 <= 0;
		rep_enq_req1_d1 <= 0;
		rep_enq_req_d1 <= 0;
		tm_asa_poll_ack_d1 <= 0;
		lat_fifo_rd0_d1 <= 0;
		lat_fifo_rd0_d2 <= 0;
		lat_fifo_rd01_d2 <= 0;
		lat_fifo_rd02_d2 <= 0;
		enq_read_count0 <= 1;	
		enq_read_count1 <= 1;	
		buf_fifo_rd0_d1 <= 0;	
		buf_fifo_rd01_d1 <= 0;	
		buf_fifo_rd1_d1 <= 0;	
	end else begin
		ctr4 <= ctr4+1;
		policer <= ~(fill_policer^intf_fifo_rd)?policer:intf_fifo_rd?policer-1:policer==3?3:policer+1;
		init_count <= init_count+init_wr;
		init_wr <= nxt_init_st==INIT_CTR;
		discard_req_d1 <= discard_req;
		rep_enq_req1_d1 <= rep_enq_req;
		rep_enq_req_d1 <= rep_enq_req;
		tm_asa_poll_ack_d1 <= tm_asa_poll_ack;
		lat_fifo_rd0_d1 <= lat_fifo_rd0;
		lat_fifo_rd0_d2 <= lat_fifo_rd0_d1;
		lat_fifo_rd01_d2 <= lat_fifo_rd0_d1;
		lat_fifo_rd02_d2 <= lat_fifo_rd0_d1;
		enq_read_count0 <= buf_fifo_rd0?(final_enq0?1:enq_read_count0+1):enq_read_count0;	
		enq_read_count1 <= buf_fifo_rd1?(final_enq1?1:enq_read_count1+1):enq_read_count1;	
		buf_fifo_rd0_d1 <= buf_fifo_rd0;	
		buf_fifo_rd01_d1 <= buf_fifo_rd0;	
		buf_fifo_rd1_d1 <= buf_fifo_rd1;	
	end

/***************************** NEXT STATE ASSIGNMENT **************************/
always @(init_st or init_count)  begin
	nxt_init_st = init_st;
	case (init_st)		
		INIT_IDLE: nxt_init_st = INIT_CTR;
		INIT_CTR: if (&init_count) nxt_init_st = INIT_DONE;
		INIT_DONE: nxt_init_st = INIT_DONE;
		default: nxt_init_st = INIT_IDLE;
	endcase
end

/***************************** STATE MACHINE *******************************/

always @(`CLK_RST) 
	if (`ACTIVE_RESET)
		init_st <= INIT_IDLE;
	else 
		init_st <= nxt_init_st;

/***************************** FIFO ***************************************/

sfifo2f_fo #(2+`PACKET_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS+1, 4) u_sfifo2f_fo_010(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({rep_enq_ucast_d1, rep_enq_last_d1,
			 rep_enq_packet_id_d1, rep_enq_qid_d1, 
			 rep_enq_drop_d1}),				
		.rd(intf_fifo_rd),
		.wr(rep_enq_req_d1),

		.ncount(),
		.count(intf_fifo_count),
		.full(),
		.empty(intf_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({intf_fifo_rep_enq_ucast, intf_fifo_rep_enq_last,
			 intf_fifo_rep_enq_packet_id, intf_fifo_rep_enq_qid, 
			 intf_fifo_rep_enq_drop}));

sfifo_enq_pkt_desc #(4) u_sfifo_enq_pkt_desc_010(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(rep_enq_desc_d1),				
		.rd(intf_fifo_rd),
		.wr(rep_enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(intf_fifo_rep_enq_desc));


sfifo2f_fo #(2+`PACKET_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS+1, 5) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({intf_fifo_rep_enq_ucast, intf_fifo_rep_enq_last,
			 intf_fifo_rep_enq_packet_id, intf_fifo_rep_enq_qid,
			 intf_fifo_rep_enq_drop}),				
		.rd(lat_fifo_rd0),
		.wr(lat_fifo_wr0),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty0),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_rep_enq_ucast, lat_fifo_rep_enq_last,
			 lat_fifo_rep_enq_packet_id, lat_fifo_rep_enq_qid,
			 lat_fifo_rep_enq_drop}));

sfifo_enq_pkt_desc #(5) u_sfifo_enq_pkt_desc_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(intf_fifo_rep_enq_desc),				
		.rd(lat_fifo_rd0),
		.wr(lat_fifo_wr0),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_rep_enq_desc));


enq_pkt_desc_type mlat_fifo_rep_enq_desc_d2;
assign mlat_fifo_rep_enq_desc_d2.src_port = lat_fifo_rep_enq_desc_d2.src_port;
assign mlat_fifo_rep_enq_desc_d2.dst_port = tm_asa_poll_port_id_d3;
assign mlat_fifo_rep_enq_desc_d2.ed_cmd = lat_fifo_rep_enq_desc_d2.ed_cmd;
assign mlat_fifo_rep_enq_desc_d2.buf_ptr = lat_fifo_rep_enq_desc_d2.buf_ptr;

sfifo2f_fo #(`PACKET_ID_NBITS, 5) u_sfifo2f_fo_100(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_rep_enq_packet_id_d2}),				
		.rd(buf_fifo_rd0),
		.wr(buf_fifo_wr0),

		.ncount(),
		.count(),
		.full(),
		.empty(buf_fifo_empty0),
		.fullm1(),
		.emptyp2(),
		.dout({buf_rep_enq_packet_id0}));

sfifo2f_fo #(`SECOND_LVL_QUEUE_ID_NBITS+`THIRD_LVL_QUEUE_ID_NBITS+`FOURTH_LVL_QUEUE_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS, 5) u_sfifo2f_fo_101(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({tm_asa_poll_conn_id_d3, tm_asa_poll_conn_group_id_d3, tm_asa_poll_port_queue_id_d3, 
			 lat_fifo_rep_enq_qid_d2}),				
		.rd(buf_fifo_rd0_d1),
		.wr(buf_fifo_wr0),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({buf_tm_asa_poll_conn_id0, buf_tm_asa_poll_conn_group_id0, buf_tm_asa_poll_port_queue_id0, 
			 buf_rep_enq_qid0}));

sfifo_enq_pkt_desc #(5) u_sfifo_enq_pkt_desc_101(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(mlat_fifo_rep_enq_desc_d2),				
		.rd(buf_fifo_rd0_d1),
		.wr(buf_fifo_wr0),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(buf_rep_enq_desc0));


sfifo2f_fo #(`PACKET_ID_NBITS, 5) u_sfifo2f_fo_110(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_rep_enq_packet_id_d2}),				
		.rd(buf_fifo_rd1),
		.wr(buf_fifo_wr1),

		.ncount(),
		.count(),
		.full(),
		.empty(buf_fifo_empty1),
		.fullm1(),
		.emptyp2(),
		.dout({buf_rep_enq_packet_id1}));

sfifo2f_fo #(`SECOND_LVL_QUEUE_ID_NBITS+`THIRD_LVL_QUEUE_ID_NBITS+`FOURTH_LVL_QUEUE_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS, 5) u_sfifo2f_fo_111(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({tm_asa_poll_conn_id_d3, tm_asa_poll_conn_group_id_d3, tm_asa_poll_port_queue_id_d3,
			 lat_fifo_rep_enq_qid_d2}),				
		.rd(buf_fifo_rd1_d1),
		.wr(buf_fifo_wr1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({buf_tm_asa_poll_conn_id1, buf_tm_asa_poll_conn_group_id1, buf_tm_asa_poll_port_queue_id1, 
			 buf_rep_enq_qid1}));

sfifo_enq_pkt_desc #(5) u_sfifo_enq_pkt_desc_111(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(mlat_fifo_rep_enq_desc_d2),				
		.rd(buf_fifo_rd1_d1),
		.wr(buf_fifo_wr1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(buf_rep_enq_desc1));


sfifo2f_fo #(`READ_COUNT_NBITS+`PACKET_ID_NBITS, 5) u_sfifo2f_fo_20(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_final_read_count, lat_fifo_packet_id}),				
		.rd(save_fifo_rd0),
		.wr(save_fifo_wr0),

		.ncount(),
		.count(),
		.full(),
		.empty(save_fifo_empty0),
		.fullm1(),
		.emptyp2(),
		.dout({save_fifo_final_read_count0, save_fifo_packet_id0}));


sfifo2f_fo #(`READ_COUNT_NBITS+`PACKET_ID_NBITS, 5) u_sfifo2f_fo_21(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_final_read_count, lat_fifo_packet_id}),				
		.rd(save_fifo_rd1),
		.wr(save_fifo_wr1),

		.ncount(),
		.count(),
		.full(),
		.empty(save_fifo_empty1),
		.fullm1(),
		.emptyp2(),
		.dout({save_fifo_final_read_count1, save_fifo_packet_id1}));


sfifo2f_fo #(1+`PACKET_ID_NBITS+`PORT_ID_NBITS+`READ_COUNT_NBITS+`BUF_PTR_NBITS+`PACKET_LENGTH_NBITS+`EM_BUF_PTR_NBITS+LEN_NBITS, LAT_FIFO_DEPTH_BITS) u_sfifo2f_fo_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_rep_enq_ucast_d2, lat_fifo_rep_enq_packet_id_d2, src_port_id_d2, final_read_count, buf_ptr_d2, packet_length_d2, em_buf_ptr_d2, em_len_d2}),				
		.rd(lat_fifo_rd3),
		.wr(lat_fifo_wr3),

		.ncount(),
		.count(lat_fifo_count),
		.full(),
		.empty(lat_fifo_empty3),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_ucast, lat_fifo_packet_id, lat_fifo_src_port_id, lat_fifo_final_read_count, lat_fifo_buf_ptr, lat_fifo_packet_length, lat_fifo_em_buf_ptr, lat_fifo_em_len}));

/***************************** MEMORY ***************************************/

ram_1r1w #(`READ_COUNT_NBITS, `PACKET_ID_NBITS) u_ram_1r1w_0(
			.clk(clk),
			.wr(init_wr|rc_ctr_wr),
			.raddr(rc_ctr_raddr),
			.waddr(init_wr?init_count:rc_ctr_waddr),
			.din(init_wr?5'b0:rc_ctr_wdata),

			.dout(rc_ctr_rdata));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

