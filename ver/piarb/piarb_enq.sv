//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_enq #(
parameter DATA_NBITS = `HOP_INFO_NBITS,
parameter BPTR_NBITS = `PIARB_BUF_PTR_NBITS,
parameter INST_DATA_NBITS = `DATA_PATH_NBITS,
parameter INST_BPTR_NBITS = `PIARB_INST_BUF_PTR_NBITS,
parameter ID_NBITS = `PU_ID_NBITS,
parameter QUEUE_DEPTH = `NUM_OF_PU,
parameter DESC_NBITS = `PU_QUEUE_PAYLOAD_NBITS
) (

input clk, 
input `RESET_SIG,

input pp_pu_hop_valid,
input [DATA_NBITS-1:0] pp_pu_hop_data,
input pp_pu_hop_sop,
input pp_pu_hop_eop,
input pp_piarb_meta_type pp_pu_meta_data,    
input [`CHUNK_LEN_NBITS-1:0] pp_pu_pp_loc,


input  pp_pu_valid,
input  pp_pu_sop,
input  pp_pu_eop,
input  [`DATA_PATH_RANGE] pp_pu_data,
input  [`DATA_PATH_VB_RANGE] pp_pu_valid_bytes,
input [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_loc,
input  pp_pu_inst_pd,


input inst_free_buf_valid,        
input [INST_BPTR_NBITS-1:0] inst_free_buf_ptr,   
input inst_free_buf_available,    

input free_buf_valid,        
input [BPTR_NBITS-1:0] free_buf_ptr,   
input free_buf_available,    

input fid_lookup_ack,
input [1:0] fid_lookup_fid_valid[QUEUE_DEPTH-1:0],
input [1:0] fid_lookup_fid_hit[QUEUE_DEPTH-1:0],

output logic         piarb_asa_valid,
output logic         piarb_asa_type3,
output logic [`PU_ID_NBITS-1:0] piarb_asa_pu_id,				
output piarb_asa_meta_type piarb_asa_meta_data,				

output logic inst_free_buf_req,
output logic free_buf_req,

output logic pu_pp_buf_fifo_rd,
output logic [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count,

output logic fid_lookup_req,
output logic [`FID_NBITS-1:0] fid_lookup_fid,

output logic wr_fid_req,
output logic [`FID_NBITS-1:0] wr_fid,
output logic [QUEUE_DEPTH-1:0] wr_fid_sel_id,
output logic wr_fid_sel,

output logic enq_req, 
output logic [ID_NBITS-1:0] enq_qid,
output pu_queue_payload_type enq_desc,
output logic enq_fid_sel,

output logic inst_write_data_valid,
output logic [`DATA_PATH_NBITS-1:0] inst_write_data,
output logic [INST_BPTR_NBITS-1:0] inst_write_buf_ptr,    
output logic [ID_NBITS-1:0] inst_write_port_id,
output logic inst_write_sop,

output logic write_data_valid,
output logic [DATA_NBITS-1:0] write_data,
output logic [BPTR_NBITS-1:0] write_buf_ptr,    
output logic [ID_NBITS-1:0] write_port_id,
output logic write_sop

);

/***************************** LOCAL VARIABLES *******************************/

localparam INST_PREFETCH_FIFO_DEPTH_NBITS = 4;
localparam INST_PREFETCH_FIFO_NEAR_FULL = (1<<INST_PREFETCH_FIFO_DEPTH_NBITS)-2;
localparam PREFETCH_FIFO_DEPTH_NBITS = 4;
localparam PREFETCH_FIFO_NEAR_FULL = (1<<PREFETCH_FIFO_DEPTH_NBITS)-2;
localparam INST_BUF_FIFO_DEPTH_NBITS = `PIARB_INST_BUF_FIFO_DEPTH_NBITS;
localparam BUF_FIFO_DEPTH_NBITS = `PIARB_BUF_FIFO_DEPTH_NBITS;

localparam IDLE = 0,
	   BOTH_BUF_RD_ST = 1,
	   BUF_RD_ST = 2,
	   INST_BUF_RD_ST = 3;

logic pp_pu_hop_valid_d1;
logic [DATA_NBITS-1:0] pp_pu_hop_data_d1;
logic pp_pu_hop_sop_d1;
logic pp_pu_hop_eop_d1;
pp_piarb_meta_type pp_pu_meta_data_d1;    
logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pp_loc_d1;

logic  pp_pu_valid_d1;
logic  pp_pu_sop_d1;
logic  pp_pu_eop_d1;
logic  [`DATA_PATH_RANGE] pp_pu_data_d1;
logic  [`DATA_PATH_VB_RANGE] pp_pu_valid_bytes_d1;
logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_loc_d1;
logic  pp_pu_inst_pd_d1;

logic enq_req_p1;

logic inst_free_buf_valid_d1;       
logic [INST_BPTR_NBITS-1:0] inst_free_buf_ptr_d1;  
logic inst_free_buf_available_d1;   

logic free_buf_valid_d1;       
logic [BPTR_NBITS-1:0] free_buf_ptr_d1;  
logic free_buf_available_d1;   

logic [ID_NBITS-1:0] fid_hit_sel_id0;
logic [ID_NBITS-1:0] fid_hit_sel_id1;
logic [ID_NBITS-1:0] fid_idle_sel_id0;
logic [ID_NBITS-1:0] fid_idle_sel_id1;
logic [ID_NBITS-1:0] fid_miss_sel_id0;
logic [ID_NBITS-1:0] fid_miss_sel_id1;
logic [ID_NBITS-1:0] fid_sel_id;
logic fid_sel;
logic stall;

logic [`INST_CHUNK_NBITS-1:0] inst_len;
logic [`INST_CHUNK_NBITS-1:0] pd_len;

logic [`HOP_ID_NBITS-1:0] len;

logic fid_lookup_req_d1;

integer i;

logic [INST_PREFETCH_FIFO_DEPTH_NBITS:0] inst_prefetch_fifo_count;
logic [PREFETCH_FIFO_DEPTH_NBITS:0] prefetch_fifo_count;
wire inst_free_buf_req_p1 = inst_prefetch_fifo_count<INST_PREFETCH_FIFO_NEAR_FULL;
wire free_buf_req_p1 = prefetch_fifo_count<PREFETCH_FIFO_NEAR_FULL;

logic  inst_buf_fifo_empty;
logic  inst_buf_fifo_sop;
logic  inst_buf_fifo_eop;
logic [INST_BUF_FIFO_DEPTH_NBITS:0] inst_buf_fifo_ncount;
logic [INST_DATA_NBITS-1:0] inst_buf_fifo_data;
logic inst_buf_fifo_inst_pd;
logic [4:0] inst_buf_fifo_valid_bytes;

logic [`CHUNK_LEN_NBITS-1:0] inst_meta_fifo_pd_loc;

logic  buf_fifo_empty;
logic  buf_fifo_sop;
logic  buf_fifo_eop;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_ncount;
logic [DATA_NBITS-1:0] buf_fifo_data;

wire  meta_fifo_wr = pp_pu_hop_valid&pp_pu_hop_eop;
logic  meta_fifo_empty;
logic  meta_fifo_full;
logic [BUF_FIFO_DEPTH_NBITS/2:0] meta_fifo_count;
logic  meta_fifo_sop;
logic  meta_fifo_eop;
pp_piarb_meta_type meta_fifo_data;
logic [`CHUNK_LEN_NBITS-1:0] meta_fifo_pp_loc;

logic  inst_buf_ptr_fifo_empty;
logic  inst_buf_ptr_fifo_sop;
logic  inst_buf_ptr_fifo_eop;
logic [INST_BPTR_NBITS-1:0] inst_buf_ptr_fifo_data;
logic [INST_BPTR_NBITS-1:0] inst_buf_ptr_fifo_data_d1;

logic  buf_ptr_fifo_empty;
logic  buf_ptr_fifo_sop;
logic  buf_ptr_fifo_eop;
logic [BPTR_NBITS-1:0] buf_ptr_fifo_data;
logic [BPTR_NBITS-1:0] buf_ptr_fifo_data_d1;

logic inst_prefetch_fifo_empty;
logic [INST_BPTR_NBITS-1:0] inst_prefetch_fifo_buf_ptr;

logic prefetch_fifo_empty;
logic [BPTR_NBITS-1:0] prefetch_fifo_buf_ptr;

logic  fid_fifo_empty;
logic  fid_fifo_full;
logic  [2:0] fid_fifo_count;
pp_piarb_meta_type fid_fifo_meta_data;
logic [ID_NBITS-1:0] fid_fifo_fid_sel_id;
logic fid_fifo_fid_sel;
logic fid_fifo_fid_hit;

pp_piarb_meta_type fid_fifo_meta_data_d1;
logic [ID_NBITS-1:0] fid_fifo_fid_sel_id_d1;
logic fid_fifo_fid_sel_d1;

wire in_discard = fid_fifo_meta_data.discard;
wire type3 = fid_fifo_meta_data.type3;

logic [1:0] pfid_hit;

logic [1:0] buf_rd_st;

wire inst_buf_fifo_rd_en = (buf_rd_st==BOTH_BUF_RD_ST)|(buf_rd_st==INST_BUF_RD_ST);
wire inst_buf_fifo_rd = ~inst_buf_fifo_empty&inst_buf_fifo_rd_en&(in_discard|~inst_prefetch_fifo_empty);
wire inst_buf_fifo_rd_last = inst_buf_fifo_rd_en&inst_buf_fifo_eop;

wire inst_write_data_valid_p1 = ~in_discard&~type3&inst_buf_fifo_rd;
wire inst_prefetch_fifo_rd = inst_write_data_valid_p1;
wire inst_write_eop_p1 = inst_buf_fifo_eop&~inst_buf_fifo_inst_pd;
wire [ID_NBITS-1:0] inst_write_port_id_p1 = fid_sel_id;

wire inst_write_sop_p1 = inst_buf_fifo_sop;
wire inst_buf_ptr_fifo_wr = inst_write_data_valid_p1&inst_write_sop_p1;
wire [INST_BPTR_NBITS-1:0] inst_write_buf_ptr_p1 = inst_prefetch_fifo_buf_ptr;
wire [INST_BPTR_NBITS-1:0] inst_buf_ptr_fifo_wdata = inst_write_buf_ptr_p1;

wire buf_fifo_rd_en = (buf_rd_st==BOTH_BUF_RD_ST)|(buf_rd_st==BUF_RD_ST);
wire buf_fifo_rd = ~buf_fifo_empty&buf_fifo_rd_en&(in_discard|~prefetch_fifo_empty);
wire buf_fifo_rd_last = buf_fifo_rd_en&buf_fifo_eop;

wire write_data_valid_p1 = ~in_discard&~type3&buf_fifo_rd;
wire prefetch_fifo_rd = write_data_valid_p1;
wire write_eop_p1 = buf_fifo_eop;
wire [ID_NBITS-1:0] write_port_id_p1 = fid_sel_id;

wire write_sop_p1 = buf_fifo_sop;
wire buf_ptr_fifo_wr = write_data_valid_p1&write_sop_p1;
wire [BPTR_NBITS-1:0] write_buf_ptr_p1 = prefetch_fifo_buf_ptr;
wire [BPTR_NBITS-1:0] buf_ptr_fifo_wdata = write_buf_ptr_p1;

wire fid_fifo_wr = fid_lookup_ack&~stall;

wire meta_fifo_rd = fid_fifo_wr;

wire inst_meta_fifo_rd = meta_fifo_rd;

wire fid_fifo_rd = (buf_rd_st==BOTH_BUF_RD_ST)?inst_buf_fifo_rd_last&buf_fifo_rd_last:
			(buf_rd_st==INST_BUF_RD_ST)?inst_buf_fifo_rd_last:
			(buf_rd_st==BUF_RD_ST)?buf_fifo_rd_last:1'b0;

wire inst_buf_ptr_fifo_rd = fid_fifo_rd;
wire buf_ptr_fifo_rd = fid_fifo_rd;

wire en_rd = ~buf_fifo_empty&~fid_fifo_empty;

wire fid_fifo_av = fid_lookup_req_d1|fid_lookup_req?fid_fifo_count<3:~fid_fifo_full;
wire meta_fifo_av = fid_lookup_req_d1|fid_lookup_req?meta_fifo_count>1:~meta_fifo_empty;
wire fid_lookup_req_p1 = meta_fifo_av&fid_fifo_av&~fid_lookup_req;

piarb_asa_meta_type piarb_asa_meta_data_p1;

assign piarb_asa_meta_data_p1.ptr_loc = meta_fifo_pp_loc;
assign piarb_asa_meta_data_p1.pd_loc = inst_meta_fifo_pd_loc;
assign piarb_asa_meta_data_p1.domain_id = fid_fifo_meta_data.domain_id;
assign piarb_asa_meta_data_p1.hdr_len = fid_fifo_meta_data.hdr_len;
assign piarb_asa_meta_data_p1.buf_ptr = fid_fifo_meta_data.buf_ptr;
assign piarb_asa_meta_data_p1.len = fid_fifo_meta_data.len;
assign piarb_asa_meta_data_p1.port = fid_fifo_meta_data.port;
assign piarb_asa_meta_data_p1.rci = fid_fifo_meta_data.rci;
assign piarb_asa_meta_data_p1.fid_sel = fid_fifo_fid_sel;
assign piarb_asa_meta_data_p1.fid = fid_fifo_meta_data.fid;
assign piarb_asa_meta_data_p1.tid = fid_fifo_meta_data.tid;
assign piarb_asa_meta_data_p1.type1 = fid_fifo_meta_data.type1;
assign piarb_asa_meta_data_p1.type3 = fid_fifo_meta_data.type3;
assign piarb_asa_meta_data_p1.creation_time = fid_fifo_meta_data.creation_time;
assign piarb_asa_meta_data_p1.discard = fid_fifo_meta_data.discard;

pu_queue_payload_type enq_desc_p1;
assign enq_desc_p1.len = len;
assign enq_desc_p1.pd_len = pd_len;
assign enq_desc_p1.inst_len = inst_len<`DATA_PATH_NBYTES?`DATA_PATH_NBYTES:inst_len;
assign enq_desc_p1.buf_ptr = buf_ptr_fifo_data_d1;
assign enq_desc_p1.inst_buf_ptr = inst_buf_ptr_fifo_data_d1;
assign enq_desc_p1.pp_piarb_meta = fid_fifo_meta_data_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	fid_lookup_fid <= meta_fifo_data.fid;
        inst_write_port_id <= inst_write_buf_ptr_p1;
        inst_write_sop <= inst_write_sop_p1;
        inst_write_data <= inst_buf_fifo_data;
        inst_write_buf_ptr <= inst_write_buf_ptr_p1;
        write_port_id <= write_buf_ptr_p1;
        write_sop <= write_sop_p1;
        write_data <= buf_fifo_data;
        write_buf_ptr <= write_buf_ptr_p1;
        enq_qid <= fid_fifo_fid_sel_id_d1;
        enq_desc <= enq_desc_p1;
        enq_fid_sel <= fid_fifo_fid_sel_d1;
	wr_fid <= fid_fifo_meta_data.fid;
	wr_fid_sel_id <= fid_fifo_fid_sel_id;
	wr_fid_sel <= fid_fifo_fid_sel;
	piarb_asa_type3 <= type3;
	piarb_asa_pu_id <= fid_fifo_fid_sel_id;				
	piarb_asa_meta_data <= piarb_asa_meta_data_p1;		
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        inst_free_buf_req <= 0;
        free_buf_req <= 0;
	fid_lookup_req <= 1'b0;
        inst_write_data_valid <= 0;
        write_data_valid <= 0;
        enq_req <= 0;
        wr_fid_req <= 0;
        pu_pp_buf_fifo_rd <= 1'b1;
        pu_pp_inst_buf_fifo_count <= 0;
        piarb_asa_valid <= 1'b0;
    end else begin
        inst_free_buf_req <= inst_free_buf_req_p1;
        free_buf_req <= free_buf_req_p1;
	fid_lookup_req <= fid_lookup_req_p1;
        inst_write_data_valid <= inst_write_data_valid_p1;
        write_data_valid <= write_data_valid_p1;
        enq_req <= enq_req_p1;
        wr_fid_req <= fid_fifo_rd&~fid_fifo_fid_hit&~in_discard&~type3;
        pu_pp_buf_fifo_rd <= buf_fifo_rd;
        pu_pp_inst_buf_fifo_count <= inst_buf_fifo_ncount;
        piarb_asa_valid <= fid_fifo_rd;
    end

/***************************** PROGRAM BODY **********************************/

always @(*) begin

	fid_hit_sel_id0 = QUEUE_DEPTH;
	fid_hit_sel_id1 = QUEUE_DEPTH;
	fid_miss_sel_id0 = QUEUE_DEPTH;
	fid_miss_sel_id1 = QUEUE_DEPTH;
	fid_idle_sel_id0 = QUEUE_DEPTH;
	fid_idle_sel_id1 = QUEUE_DEPTH;
	for(i=0; i<QUEUE_DEPTH; i=i+1) begin
		if (fid_lookup_fid_hit[i][0]==1'b1) fid_hit_sel_id0 = i;
		if (fid_lookup_fid_hit[i][1]==1'b1) fid_hit_sel_id1 = i;
		if (fid_lookup_fid_valid[i][0]==1'b1) fid_miss_sel_id0 = i;
		if (fid_lookup_fid_valid[i][1]==1'b1) fid_miss_sel_id1 = i;
		if (fid_lookup_fid_valid[i][0]==1'b0) fid_idle_sel_id0 = i;
		if (fid_lookup_fid_valid[i][1]==1'b0) fid_idle_sel_id1 = i;
	end
end

always @(*) begin

	stall = 1'b1;
	fid_sel_id = QUEUE_DEPTH;
	fid_sel = 1'b0;
	for(i=0; i<QUEUE_DEPTH; i=i+1) begin
		pfid_hit[0] = pfid_hit[0]|fid_lookup_fid_hit[i][0];
		pfid_hit[1] = pfid_hit[1]|fid_lookup_fid_hit[i][1];
	end
	if (|pfid_hit) begin
		fid_sel_id = pfid_hit[0]?fid_hit_sel_id0:fid_hit_sel_id1;
		fid_sel = pfid_hit[0]?1'b0:1'b1;
		stall = 1'b0;
	end else if ((fid_idle_sel_id0!=QUEUE_DEPTH)||(fid_idle_sel_id1!=QUEUE_DEPTH)) begin
		fid_sel_id = (fid_idle_sel_id0!=QUEUE_DEPTH)?fid_idle_sel_id0:fid_idle_sel_id1;
		fid_sel = (fid_idle_sel_id0!=QUEUE_DEPTH)?1'b0:1'b1;
		stall = 1'b0;
	end else if ((fid_miss_sel_id0!=QUEUE_DEPTH)||(fid_miss_sel_id1!=QUEUE_DEPTH)) begin
		fid_sel_id = (fid_miss_sel_id0!=QUEUE_DEPTH)?fid_miss_sel_id0:fid_miss_sel_id1;
		fid_sel = (fid_miss_sel_id0!=QUEUE_DEPTH)?1'b0:1'b1;
		stall = 1'b0;
	end

end

always @(posedge clk) begin

	pp_pu_hop_sop_d1 <= pp_pu_hop_sop;
	pp_pu_hop_eop_d1 <= pp_pu_hop_eop;
	pp_pu_hop_data_d1 <= pp_pu_hop_data;
	pp_pu_meta_data_d1 <= pp_pu_meta_data;
	pp_pu_pp_loc_d1 <= pp_pu_pp_loc;

	pp_pu_sop_d1 <= pp_pu_sop;
	pp_pu_eop_d1 <= pp_pu_eop;
	pp_pu_inst_pd_d1 <= pp_pu_inst_pd;
	pp_pu_data_d1 <= pp_pu_data;
	pp_pu_valid_bytes_d1 <= pp_pu_valid_bytes;
	pp_pu_pd_loc_d1 <= pp_pu_pd_loc;

        inst_free_buf_ptr_d1 <= inst_free_buf_ptr;
        inst_free_buf_available_d1 <= inst_free_buf_available;

        free_buf_ptr_d1 <= free_buf_ptr;
        free_buf_available_d1 <= free_buf_available;

	fid_fifo_meta_data_d1 <= fid_fifo_meta_data;
	fid_fifo_fid_sel_id_d1 <= fid_fifo_fid_sel_id;
	fid_fifo_fid_sel_d1 <= fid_fifo_fid_sel;

	inst_buf_ptr_fifo_data_d1 <= inst_buf_ptr_fifo_data;
	buf_ptr_fifo_data_d1 <= buf_ptr_fifo_data;

end

wire inst_inc_prefetch_fifo = inst_free_buf_req_p1;
wire inst_dec_prefetch_fifo = inst_free_buf_valid_d1&~inst_free_buf_available_d1;

wire inc_prefetch_fifo = free_buf_req_p1;
wire dec_prefetch_fifo = free_buf_valid_d1&~free_buf_available_d1;

always @(`CLK_RST) 
  
    if (`ACTIVE_RESET) begin

	pp_pu_hop_valid_d1 <= 1'b0;
	pp_pu_valid_d1 <= 1'b0;

	buf_rd_st <= IDLE;
	
        enq_req_p1 <= 1'b0;

        inst_len <= 0;
        pd_len <= 0;
        len <= 0;
        inst_free_buf_valid_d1 <= 0;
        free_buf_valid_d1 <= 0;
        inst_prefetch_fifo_count <= 0;
        prefetch_fifo_count <= 0;
        fid_lookup_req_d1 <= 0;

    end else begin

	pp_pu_hop_valid_d1 <= pp_pu_hop_valid;
	pp_pu_valid_d1 <= pp_pu_valid;

	case (buf_rd_st)
		IDLE: 
			if(en_rd)
				buf_rd_st <= BOTH_BUF_RD_ST;
			else 
				buf_rd_st <= IDLE;
		INST_BUF_RD_ST: 
			if(inst_buf_fifo_rd_last)
				buf_rd_st <= IDLE;
			else 
				buf_rd_st <= INST_BUF_RD_ST;
		BUF_RD_ST: 
			if(buf_fifo_rd_last)
				buf_rd_st <= IDLE;
			else 
				buf_rd_st <= BUF_RD_ST;
		BOTH_BUF_RD_ST: 
			if(buf_fifo_rd_last&inst_buf_fifo_rd_last)
				buf_rd_st <= IDLE;
			else if(buf_fifo_rd_last)
				buf_rd_st <= INST_BUF_RD_ST;
			else if(inst_buf_fifo_rd_last)
				buf_rd_st <= BUF_RD_ST;
			else 
				buf_rd_st <= BOTH_BUF_RD_ST;
	endcase

        enq_req_p1 <= fid_fifo_rd&~type3&~in_discard;

        inst_len <= inst_write_data_valid_p1&inst_buf_fifo_inst_pd?(inst_buf_fifo_sop&inst_buf_fifo_inst_pd?inst_buf_fifo_valid_bytes:inst_len+inst_buf_fifo_valid_bytes):inst_len;
        pd_len <= inst_write_data_valid_p1&~inst_buf_fifo_inst_pd?(inst_buf_fifo_sop&~inst_buf_fifo_inst_pd?inst_buf_fifo_valid_bytes:pd_len+inst_buf_fifo_valid_bytes):pd_len;
        len <= write_data_valid_p1?(write_sop_p1?1:len+1):len;
        inst_free_buf_valid_d1 <= inst_free_buf_valid;
        free_buf_valid_d1 <= free_buf_valid;

	case ({inst_inc_prefetch_fifo, inst_dec_prefetch_fifo, inst_prefetch_fifo_rd})
		3'b000: inst_prefetch_fifo_count <= inst_prefetch_fifo_count;
		3'b001: inst_prefetch_fifo_count <= inst_prefetch_fifo_count-1;
		3'b010: inst_prefetch_fifo_count <= inst_prefetch_fifo_count-1;
		3'b011: inst_prefetch_fifo_count <= inst_prefetch_fifo_count-2;
		3'b100: inst_prefetch_fifo_count <= inst_prefetch_fifo_count+1;
		3'b101: inst_prefetch_fifo_count <= inst_prefetch_fifo_count;
		3'b110: inst_prefetch_fifo_count <= inst_prefetch_fifo_count;
		default: inst_prefetch_fifo_count <= inst_prefetch_fifo_count-1;
	endcase
	case ({inc_prefetch_fifo, dec_prefetch_fifo, prefetch_fifo_rd})
		3'b000: prefetch_fifo_count <= prefetch_fifo_count;
		3'b001: prefetch_fifo_count <= prefetch_fifo_count-1;
		3'b010: prefetch_fifo_count <= prefetch_fifo_count-1;
		3'b011: prefetch_fifo_count <= prefetch_fifo_count-2;
		3'b100: prefetch_fifo_count <= prefetch_fifo_count+1;
		3'b101: prefetch_fifo_count <= prefetch_fifo_count;
		3'b110: prefetch_fifo_count <= prefetch_fifo_count;
		default: prefetch_fifo_count <= prefetch_fifo_count-1;
	endcase

        fid_lookup_req_d1 <= fid_lookup_req;
    end

/***************************** FIFO ***************************************/

sfifo2f_2f1 #(DATA_NBITS+2, BUF_FIFO_DEPTH_NBITS) u_sfifo2f_2f1_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_pu_hop_data_d1, pp_pu_hop_sop_d1, pp_pu_hop_eop_d1}),             
        .rd(buf_fifo_rd),
        .wr(pp_pu_hop_valid_d1),

        .ncount(buf_fifo_ncount),
        .count(),
        .full(),
        .empty(buf_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({buf_fifo_data, buf_fifo_sop, buf_fifo_eop})       
    );

sfifo2f_fo #(INST_DATA_NBITS+2+`DATA_PATH_VB_NBITS+1+1, INST_BUF_FIFO_DEPTH_NBITS) u_sfifo2f_fo_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_pu_data_d1, pp_pu_sop_d1, pp_pu_eop_d1, {(~|pp_pu_valid_bytes_d1), pp_pu_valid_bytes_d1}, pp_pu_inst_pd_d1}),             
        .rd(inst_buf_fifo_rd),
        .wr(pp_pu_valid_d1),

        .ncount(inst_buf_fifo_ncount),
        .count(),
        .full(),
        .empty(inst_buf_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({inst_buf_fifo_data, inst_buf_fifo_sop, inst_buf_fifo_eop, inst_buf_fifo_valid_bytes, inst_buf_fifo_inst_pd})       
    );

sfifo2f_fo #(`CHUNK_LEN_NBITS, INST_BUF_FIFO_DEPTH_NBITS/2) u_sfifo2f_fo_41(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_pu_pd_loc_d1}),             
        .rd(inst_meta_fifo_rd),
        .wr(pp_pu_valid_d1&pp_pu_sop_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({inst_meta_fifo_pd_loc})       
    );

sfifo2f_fo #(`CHUNK_LEN_NBITS, BUF_FIFO_DEPTH_NBITS/2) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_pu_pp_loc}),             
        .rd(meta_fifo_rd),
        .wr(pp_pu_hop_valid_d1&pp_pu_hop_sop_d1),

        .ncount(),
        .count(meta_fifo_count),
        .full(meta_fifo_full),
        .empty(meta_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({meta_fifo_pp_loc})       
    );

sfifo_pp_piarb #(BUF_FIFO_DEPTH_NBITS/2) u_sfifo_pp_piarb_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(pp_pu_meta_data_d1),             
        .rd(meta_fifo_rd),
        .wr(pp_pu_hop_valid_d1&pp_pu_hop_sop_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(meta_fifo_data)       
    );

sfifo2f_fo #(BPTR_NBITS, BUF_FIFO_DEPTH_NBITS/2) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({buf_ptr_fifo_wdata}),             
        .rd(buf_ptr_fifo_rd),
        .wr(buf_ptr_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({buf_ptr_fifo_data})       
    );

sfifo2f_fo #(INST_BPTR_NBITS, BUF_FIFO_DEPTH_NBITS/2) u_sfifo2f_fo_31(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({inst_buf_ptr_fifo_wdata}),             
        .rd(inst_buf_ptr_fifo_rd),
        .wr(inst_buf_ptr_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({inst_buf_ptr_fifo_data})       
    );

sfifo2f_fo #(ID_NBITS+1+1, 2) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({fid_sel_id, fid_sel, (~stall&(|pfid_hit))}),             
        .rd(fid_fifo_rd),
        .wr(fid_fifo_wr),

        .ncount(),
        .count(fid_fifo_count),
        .full(fid_fifo_full),
        .empty(fid_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({fid_fifo_fid_sel_id, fid_fifo_fid_sel, fid_fifo_fid_hit})             
    );

sfifo_pp_piarb #(`PP_PIARB_META_NBITS+ID_NBITS+1+1, 2) u_sfifo_pp_piarb_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(meta_fifo_data),             
        .rd(fid_fifo_rd),
        .wr(fid_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(fid_fifo_meta_data)             
    );

sfifo2f_fo #(BPTR_NBITS, PREFETCH_FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(free_buf_ptr_d1),               
        .rd(prefetch_fifo_rd),
        .wr(free_buf_valid_d1&free_buf_available_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(prefetch_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(prefetch_fifo_buf_ptr)       
    );

sfifo2f_fo #(INST_BPTR_NBITS, INST_PREFETCH_FIFO_DEPTH_NBITS) u_sfifo2f_fo_11(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(inst_free_buf_ptr_d1),               
        .rd(inst_prefetch_fifo_rd),
        .wr(inst_free_buf_valid_d1&inst_free_buf_available_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(inst_prefetch_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(inst_prefetch_fifo_buf_ptr)       
    );

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

