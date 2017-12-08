/*
 * Path Parser
 */

`include "defines.vh"

import meta_package::*;

module pp_front_end
  (
   input      ecdsa_pp_valid,
   input      ecdsa_pp_sop,
   input      ecdsa_pp_eop,
   input [`DATA_PATH_RANGE] ecdsa_pp_data,
   input ecdsa_pp_meta_type ecdsa_pp_meta_data,
   input [`CHUNK_LEN_NBITS-1:0] ecdsa_pp_auth_len,

   input      lh_pp_valid,
   input      lh_pp_sop,
   input      lh_pp_eop,
   input [`DATA_PATH_RANGE] lh_pp_hdr_data,
   input lh_pp_meta_type lh_pp_meta_data,

   input pp_pu_hop_valid,
   input pp_pu_hop_sop,
   input pp_pu_hop_eop,
   input pp_pu_hop_error,
   input pp_pu_hop_type3,

   input pu_pp_buf_fifo_rd,
   input [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count,


   output     pp_ecdsa_ready,

   output pp_valid0,
   output [`DATA_PATH_RANGE] pp_data0,
   output pp_sop0,
   output pp_eop0,
   output [`CHUNK_LEN_NBITS-1:0] pp_len0,
   output pp_meta_valid0,
   output [`PP_META_RCI_RANGE] pp_meta_rci0,
   output pp_meta_type pp_meta_data,
   output [31:0] pp_creation_time,
   output [`CHUNK_LEN_NBITS-1:0] pp_loc,

   output logic pp_pu_valid,
   output logic pp_pu_sop,
   output logic pp_pu_eop,
   output logic [`DATA_PATH_RANGE] pp_pu_data,
   output logic [`DATA_PATH_VB_RANGE] pp_pu_valid_bytes,
   output logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_loc,
   output logic [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_len,
   output logic pp_pu_inst_pd,

   input      clk,
   input      `RESET_SIG
   );

/***************************** LOCAL VARIABLES *******************************/

localparam BUF_FIFO_DEPTH_NBITS   = `PIARB_BUF_FIFO_DEPTH_NBITS;
localparam BUF_FIFO_FULL_COUNT   = (1<<BUF_FIFO_DEPTH_NBITS);
localparam INST_BUF_FIFO_DEPTH_NBITS   = `PIARB_INST_BUF_FIFO_DEPTH_NBITS;
localparam INST_BUF_FIFO_FULL_COUNT   = (1<<INST_BUF_FIFO_DEPTH_NBITS);

logic pu_pp_buf_fifo_rd_d1;
logic [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count_d1;

logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_count;
logic [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_count_p1;

logic     pp_ecdsa_ready_d1;

logic      ecdsa_pp_valid_d1;
logic      ecdsa_pp_sop_d1;
logic      ecdsa_pp_eop_d1;
logic [`DATA_PATH_RANGE] ecdsa_pp_data_d1;
ecdsa_pp_meta_type ecdsa_pp_meta_data_d1;
logic [`CHUNK_LEN_NBITS-1:0] ecdsa_pp_auth_len_d1;

logic      lh_pp_valid_d1;
logic      lh_pp_sop_d1;
logic      lh_pp_eop_d1;
logic [`DATA_PATH_RANGE] lh_pp_hdr_data_d1;
lh_pp_meta_type lh_pp_meta_data_d1;

/* (* keep = "true", max_fanout = 100 *) */ logic sel_lh;

logic [9:0] pp_data_cnt;
logic [9:0] inst_data_cnt;
logic [9:0] pd_data_cnt;
logic [9:0] pp_chunk_last_byte_loc;
logic [9:0] inst_chunk_first_byte_loc;
logic [9:0] inst_chunk_last_byte_loc;
logic [9:0] inst_chunk_first_byte_loc_d1;
logic [9:0] pd_chunk_first_byte_loc;
logic [9:0] pd_chunk_last_byte_loc;

wire lh_pp_meta_valid = lh_pp_valid_d1&lh_pp_sop_d1;

logic lh_pp_fifo_empty;
logic lh_pp_fifo_sop;
logic lh_pp_fifo_eop;
logic [`DATA_PATH_RANGE] lh_pp_fifo_data;
logic lh_pp_meta_fifo_empty;
lh_pp_meta_type lh_pp_meta_fifo_data;
wire type3 = lh_pp_meta_fifo_data.type3;
wire lh_discard = lh_pp_meta_fifo_data.discard;
wire ecdsa_discard = ecdsa_pp_meta_data_d1.discard;

wire lh_pp_fifo_rd = sel_lh&~lh_pp_fifo_empty;
wire lh_pp_meta_fifo_rd = lh_pp_fifo_rd&lh_pp_fifo_eop;

wire toggle_sel_lh = sel_lh?(lh_pp_meta_fifo_rd|lh_pp_meta_fifo_empty)&ecdsa_pp_valid_d1:(~ecdsa_pp_valid_d1|ecdsa_pp_eop_d1)&~lh_pp_meta_fifo_empty;

wire in_valid = sel_lh?~lh_pp_fifo_empty:ecdsa_pp_valid_d1&pp_ecdsa_ready_d1;
wire in_sop = sel_lh?lh_pp_fifo_sop:ecdsa_pp_sop_d1;
wire in_eop = sel_lh?lh_pp_fifo_eop:ecdsa_pp_eop_d1;
wire [`DATA_PATH_RANGE] in_data = sel_lh?lh_pp_fifo_data:ecdsa_pp_data_d1;
pp_meta_type in_meta_data;
pp_meta_type in_meta_data_d1;
assign in_meta_data.domain_id = sel_lh?{(`DOMAIN_ID_NBITS){1'b0}}:ecdsa_pp_meta_data_d1.domain_id;
assign in_meta_data.hdr_len = sel_lh?lh_pp_meta_fifo_data.hdr_len:ecdsa_pp_meta_data_d1.hdr_len;
assign in_meta_data.buf_ptr = sel_lh?lh_pp_meta_fifo_data.buf_ptr:ecdsa_pp_meta_data_d1.buf_ptr;
assign in_meta_data.len = sel_lh?lh_pp_meta_fifo_data.len:ecdsa_pp_meta_data_d1.len;
assign in_meta_data.port = sel_lh?lh_pp_meta_fifo_data.port:ecdsa_pp_meta_data_d1.port;
assign in_meta_data.rci = sel_lh?lh_pp_meta_fifo_data.rci:ecdsa_pp_meta_data_d1.rci;
assign in_meta_data.fid_sel = 1'b0;
assign in_meta_data.fid = sel_lh?lh_pp_meta_fifo_data.fid:ecdsa_pp_meta_data_d1.fid;
assign in_meta_data.tid = sel_lh?lh_pp_meta_fifo_data.tid:ecdsa_pp_meta_data_d1.tid;
assign in_meta_data.type1 = sel_lh?lh_pp_meta_fifo_data.type1:ecdsa_pp_meta_data_d1.type1;
assign in_discard = sel_lh?lh_pp_meta_fifo_data.discard:ecdsa_pp_meta_data_d1.discard;
wire in_type3 = (sel_lh?lh_pp_meta_fifo_data.type3:ecdsa_pp_meta_data_d1.type3)|in_discard;
assign in_meta_data.type3 = in_type3;
assign in_meta_data.discard = in_discard;

wire [`CHUNK_LEN_NBITS-1:0] in_auth_len = sel_lh&~lh_pp_meta_fifo_data.type1?0:ecdsa_pp_auth_len_d1+2;
logic [`CHUNK_LEN_NBITS-1:0] in_auth_len_d1;
wire [`HEADER_LENGTH_NBITS-1:0] in_hdr_len = sel_lh?(lh_pp_meta_fifo_data.hdr_len<<4):(ecdsa_pp_meta_data_d1.hdr_len<<4)-(ecdsa_pp_auth_len_d1+2);

logic [`CHUNK_LEN_NBITS-1:0] pp_len;
logic [31:0] creation_time;
wire [9:0] pp_chunk_last_byte_loc_p1 = in_data[127-4:127-4-11]+2-1;
wire [`HEADER_LENGTH_NBITS-1:0] pp_chunk_len_p1 = pp_chunk_last_byte_loc_p1+1;
wire [`HEADER_LENGTH_NBITS-1:0] pp_chunk_len = pp_chunk_last_byte_loc+1;
logic [`HEADER_LENGTH_NBITS-1:0] len_fifo_data;

wire in_valid_1st = in_valid&in_sop;
wire in_valid_last = in_valid&in_eop;

logic [`DATA_PATH_NBITS-1-6*8:0] in_data_sv;
logic in_sop_d1;
logic in_eop_d1;

logic in_valid_d1;
logic in_valid_d2;
logic in_valid_d3;
logic in_valid_d4;
logic in_valid_d5;
logic in_valid_d6;

wire [9:0] inst_pd_chunk_len = in_hdr_len-pp_chunk_len_p1;

logic discard_en1_d1, discard_en2_d1;
wire discard_en1 = (in_meta_data.type1|~in_type3)&(pp_chunk_len_p1>buf_fifo_count);
wire discard_en2 = (in_meta_data.type1|~in_type3)&(inst_pd_chunk_len>(INST_BUF_FIFO_FULL_COUNT-(pu_pp_inst_buf_fifo_count+6)));

logic in_discard_d1;

pp_meta_type min_meta_data_d1;
always @* begin
	min_meta_data_d1 = in_meta_data_d1;
	min_meta_data_d1.type1 = in_meta_data_d1.type1&~(discard_en1_d1|discard_en2_d1);
	min_meta_data_d1.type3 = in_meta_data_d1.type3|discard_en1_d1|discard_en2_d1;
end

logic dec_buf_fifo_count0_d1;
wire dec_buf_fifo_count0 = in_valid_1st&~(in_type3|in_discard|discard_en1|discard_en2);
wire dec_buf_fifo_count1 = ~pp_pu_hop_type3&pp_pu_hop_valid;
wire inc_buf_fifo_count0 = (pp_pu_hop_error|~pp_pu_hop_type3)&pp_pu_hop_valid&pp_pu_hop_eop;
wire inc_buf_fifo_count1 = pu_pp_buf_fifo_rd_d1;

always @(*)
	case ({dec_buf_fifo_count0_d1, dec_buf_fifo_count1, inc_buf_fifo_count0, inc_buf_fifo_count1})
		4'b0000: buf_fifo_count_p1 = buf_fifo_count;
		4'b0001: buf_fifo_count_p1 = buf_fifo_count+1;
		4'b0010: buf_fifo_count_p1 = buf_fifo_count+len_fifo_data;
		4'b0011: buf_fifo_count_p1 = buf_fifo_count+len_fifo_data+1;
		4'b0100: buf_fifo_count_p1 = buf_fifo_count-1;
		4'b0101: buf_fifo_count_p1 = buf_fifo_count;
		4'b0110: buf_fifo_count_p1 = buf_fifo_count-1+len_fifo_data;
		4'b0111: buf_fifo_count_p1 = buf_fifo_count+len_fifo_data;
		4'b1000: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len;
		4'b1001: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len+1;
		4'b1010: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len+len_fifo_data;
		4'b1011: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len+len_fifo_data+1;
		4'b1100: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len-1;
		4'b1101: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len-1+1;
		4'b1110: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len-1+len_fifo_data;
		4'b1111: buf_fifo_count_p1 = buf_fifo_count-pp_chunk_len+len_fifo_data;
	endcase	

wire pp_valid0_last = pp_valid0&pp_eop0;
logic pp_valid0_last_d1;
wire set_disable_pp_st = pp_valid0_last;
logic disable_pp;

logic [9:0] inst_chunk_last_byte_loc_p1;

wire [3:0] rot_cnt = inst_chunk_first_byte_loc[3:0];
wire delay_inst = rot_cnt==1|rot_cnt==2;
logic delay_inst_d1;
logic delay_inst_d2;
logic delay_inst_sv;

wire set_enable_inst = delay_inst_d1&pp_valid0_last_d1|~delay_inst&pp_valid0_last;
logic enable_inst;

wire inst_valid = (delay_inst_d2&in_valid_d3|~delay_inst_d1&in_valid_d2)&enable_inst;
logic inst_sop;
wire inst_eop = inst_data_cnt==(inst_chunk_last_byte_loc>>4);
wire inst_valid_1st = inst_valid&inst_sop;
wire inst_valid_last = inst_valid&inst_eop;
logic inst_valid_last_d1;
logic inst_valid_last_d2;
logic [`DATA_PATH_RANGE] rot_in_data_d1;
logic [`DATA_PATH_RANGE] rot_in_data_d2;
wire [9:0] pd_chunk_first_byte_loc_p1 = inst_chunk_last_byte_loc_p1+2;
wire [`DATA_PATH_VB_RANGE] inst_sop_valid_bytes_p1 = inst_chunk_last_byte_loc_p1[3:0];
logic [`DATA_PATH_VB_RANGE] inst_sop_valid_bytes;
wire [`DATA_PATH_VB_RANGE] inst_valid_bytes = inst_eop?(inst_sop?inst_sop_valid_bytes_p1:inst_chunk_last_byte_loc[3:0]+1):0;

wire [`DATA_PATH_RANGE] rot_in_data = rot(pp_data0, rot_cnt);
wire rot_cnt_b4 = ~|rot_cnt;
wire [`DATA_PATH_RANGE] mask = mask_gen(rot_cnt);

logic [`DATA_PATH_RANGE] mask_d1;
logic [`DATA_PATH_RANGE] mask_d2;

wire [`DATA_PATH_RANGE] inst_pp_pu_data_p1 = rot_in_data_d1&mask_d1|rot_in_data&~mask_d1;
logic [`DATA_PATH_RANGE] inst_data;
assign inst_chunk_last_byte_loc_p1 = inst_pp_pu_data_p1[15-4:15-4-11];

wire [3:0] pd_rot_cnt = pd_chunk_first_byte_loc[3:0];
wire delay_pd = pd_rot_cnt==1|pd_rot_cnt==2;
reg delay_pd_d1;
reg delay_pd_d2;

wire set_enable_pd = delay_pd?inst_valid_last_d2:inst_valid_last_d1/*|~inst_valid_1st&inst_valid_last*/;
logic enable_pd;

wire pd_valid = (delay_inst_sv&delay_pd_d2?in_valid_d6:delay_inst_sv|delay_pd_d1?in_valid_d5:in_valid_d4)&enable_pd;
logic pd_sop;
wire pd_valid_1st = pd_valid&pd_sop;
logic [9:0] pd_chunk_last_byte_loc_p1;
wire pd_eop = pd_data_cnt==(pd_chunk_last_byte_loc>>4);
wire pd_valid_last = pd_valid&pd_eop;
logic [`DATA_PATH_RANGE] rot_inst_data_d1;
logic [`DATA_PATH_RANGE] rot_inst_data_d2;
wire [`DATA_PATH_VB_RANGE] pd_sop_valid_bytes_p1 = pd_chunk_last_byte_loc_p1[3:0];
logic [`DATA_PATH_VB_RANGE] pd_sop_valid_bytes;
wire [`DATA_PATH_VB_RANGE] pd_valid_bytes = pd_eop?pd_chunk_last_byte_loc[3:0]+1:0;

wire [`DATA_PATH_RANGE] rot_inst_data = rot(inst_data, pd_rot_cnt);
wire pd_rot_cnt_b4 = ~|pd_rot_cnt;
wire [`DATA_PATH_RANGE] pd_mask = mask_gen(pd_rot_cnt);

logic [`DATA_PATH_RANGE] pd_mask_d1;
logic [`DATA_PATH_RANGE] pd_mask_d2;

wire [`DATA_PATH_RANGE] pd_pp_pu_data_p1 = rot_inst_data_d1&pd_mask_d1|rot_inst_data&~pd_mask_d1;
assign pd_chunk_last_byte_loc_p1 = pd_pp_pu_data_p1[15-4:15-4-11];

logic [`CHUNK_LEN_NBITS-1:0] p_pp_pu_pd_loc1_d1;
wire [`CHUNK_LEN_NBITS-1:0] p_pp_pu_pd_loc1 = 40+in_auth_len_d1+pp_len+2+2;
wire [`CHUNK_LEN_NBITS-1:0] p_pp_pu_pd_loc = p_pp_pu_pd_loc1_d1+(inst_valid_1st?pd_chunk_first_byte_loc_p1:pd_chunk_first_byte_loc);
wire [`CHUNK_LEN_NBITS-1:0] p_pp_pu_pd_len = pd_chunk_last_byte_loc+1;

wire en_inst_pd = pp_pu_hop_valid&pp_pu_hop_sop;

logic enable_fifo;
logic enable_fifo_error;

logic pp_pu_fifo_empty;
wire pp_pu_fifo_rd = ~pp_pu_fifo_empty&enable_fifo;

/***************************** NON REGISTERED OUTPUTS ************************/

assign pp_valid0 = in_valid_d1&~disable_pp&~in_discard_d1&~min_meta_data_d1.type3;
assign pp_data0 = {in_data_sv, in_data[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-6*8+1]};
assign pp_sop0 = in_sop_d1;
assign pp_eop0 = pp_data_cnt==((pp_chunk_last_byte_loc-6)>>4);
assign pp_len0 = pp_chunk_last_byte_loc-5;
assign pp_meta_valid0 = in_valid_d1&in_sop_d1;
assign pp_meta_rci0 = in_meta_data_d1.rci;
assign pp_meta_data = min_meta_data_d1;
assign pp_creation_time = creation_time;
assign pp_loc = 40+2+in_auth_len_d1+2+4;

assign pp_ecdsa_ready = ~sel_lh;

assign pp_pu_valid = pp_pu_fifo_rd&~enable_fifo_error;

/***************************** REGISTERED OUTPUTS ****************************/

/***************************** PROGRAM BODY **********************************/ 
always @(posedge clk) begin

    ecdsa_pp_valid_d1 <= ecdsa_pp_valid;
    ecdsa_pp_sop_d1 <= ecdsa_pp_sop;
    ecdsa_pp_eop_d1 <= ecdsa_pp_eop;
    ecdsa_pp_data_d1 <= ecdsa_pp_data;
    ecdsa_pp_meta_data_d1 <= ecdsa_pp_meta_data;
    ecdsa_pp_auth_len_d1 <= ecdsa_pp_valid?ecdsa_pp_auth_len:ecdsa_pp_auth_len_d1;

    lh_pp_valid_d1 <= lh_pp_valid;
    lh_pp_sop_d1 <= lh_pp_sop;
    lh_pp_eop_d1 <= lh_pp_eop;
    lh_pp_hdr_data_d1 <= lh_pp_hdr_data;
    lh_pp_meta_data_d1 <= lh_pp_meta_data;

    in_meta_data_d1 <= in_meta_data;

    creation_time <= in_valid_1st?in_data[`DATA_PATH_NBITS-1-2*8:`DATA_PATH_NBITS-1-2*8-31]:creation_time;
    pp_len <= in_valid_1st?in_data[`DATA_PATH_NBITS-1-`CHUNK_TYPE_NBITS:`DATA_PATH_NBITS-1-`CHUNK_TYPE_NBITS-`CHUNK_LEN_NBITS+1]+2:pp_len;
    in_auth_len_d1 <= in_valid_1st?in_auth_len:in_auth_len_d1;
    in_data_sv <= in_valid?in_data[`DATA_PATH_NBITS-1-6*8:0]:in_data_sv;
    in_sop_d1 <= in_valid?in_sop:in_sop_d1;
    in_eop_d1 <= in_valid?in_eop:in_eop_d1;
    in_discard_d1 <= in_valid?in_discard:in_discard_d1;

    rot_in_data_d1 <= in_valid_d1?rot_in_data:rot_in_data_d1;
    rot_in_data_d2 <= in_valid_d1?rot_in_data_d1:rot_in_data_d2;
    mask_d1 <= rot_cnt_b4?0:mask;
    mask_d2 <= mask_d1;

    inst_data <= inst_pp_pu_data_p1;
    inst_sop_valid_bytes <= inst_chunk_last_byte_loc_p1[3:0];
    pd_sop_valid_bytes <= pd_chunk_last_byte_loc_p1[3:0];
    
    rot_inst_data_d1 <= in_valid_d2?rot_inst_data:rot_inst_data_d1;
    rot_inst_data_d2 <= in_valid_d2?rot_inst_data_d1:rot_inst_data_d2;
    pd_mask_d1 <= pd_rot_cnt_b4?0:pd_mask;
    pd_mask_d2 <= pd_mask_d1;

    inst_sop <= set_enable_inst?1'b1:inst_valid?1'b0:inst_sop;
    pd_sop <= set_enable_pd?1'b1:pd_valid?1'b0:pd_sop;

    inst_valid_last_d1 <= inst_valid_last;
    inst_valid_last_d2 <= inst_valid_last_d1;

    p_pp_pu_pd_loc1_d1 <= p_pp_pu_pd_loc1;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	dec_buf_fifo_count0_d1 <= 1'b0;
	buf_fifo_count <= BUF_FIFO_FULL_COUNT;

	pu_pp_buf_fifo_rd_d1 <= 1'b0;
	pu_pp_inst_buf_fifo_count_d1 <= 0;

	pp_ecdsa_ready_d1 <= 1'b0;
	sel_lh <= 1'b1;
	in_valid_d1 <= 0;
	in_valid_d2 <= 0;
	in_valid_d3 <= 0;
	in_valid_d4 <= 0;
	in_valid_d5 <= 0;
	in_valid_d6 <= 0;
	pp_data_cnt <= 0;
	inst_data_cnt <= 0;
	pd_data_cnt <= 0;
	disable_pp <= 0;
	pp_valid0_last_d1 <= 0;
	delay_inst_d1 <= 0;
	delay_inst_d2 <= 0;
	delay_inst_sv <= 0;
	delay_pd_d1 <= 0;
	delay_pd_d2 <= 0;
	enable_inst <= 0;
	enable_pd <= 0;

	discard_en1_d1 <= 1'b0;
	discard_en2_d1 <= 1'b0;

    	pp_chunk_last_byte_loc <= 0;
    	inst_chunk_first_byte_loc <= 0;
    	inst_chunk_last_byte_loc <= 0;
    	pd_chunk_first_byte_loc <= 0;
    	pd_chunk_last_byte_loc <= 0;

	enable_fifo <= 1'b0;
	enable_fifo_error <= 1'b0;

    end else begin
	dec_buf_fifo_count0_d1 <= dec_buf_fifo_count0;
	buf_fifo_count <= buf_fifo_count_p1;

	pu_pp_buf_fifo_rd_d1 <= pu_pp_buf_fifo_rd;
	pu_pp_inst_buf_fifo_count_d1 <= pu_pp_inst_buf_fifo_count;

	pp_ecdsa_ready_d1 <= pp_ecdsa_ready;
	sel_lh <= toggle_sel_lh?~sel_lh:sel_lh;
	in_valid_d1 <= in_valid;
	in_valid_d2 <= in_valid_d1;
	in_valid_d3 <= in_valid_d2;
	in_valid_d4 <= in_valid_d3;
	in_valid_d5 <= in_valid_d4;
	in_valid_d6 <= in_valid_d5;
	pp_data_cnt <= pp_valid0_last?0:~pp_valid0?pp_data_cnt:pp_data_cnt+1;
	inst_data_cnt <= inst_valid_last?0:~inst_valid?inst_data_cnt:inst_data_cnt+1;
	pd_data_cnt <= pd_valid_last?0:~pd_valid?pd_data_cnt:pd_data_cnt+1;
	disable_pp <= set_disable_pp_st?1'b1:in_valid_d1&in_eop_d1?1'b0:disable_pp;
	pp_valid0_last_d1 <= pp_valid0_last;
	delay_inst_d1 <= in_valid_d1?delay_inst:delay_inst_d1;
	delay_inst_d2 <= in_valid_d2?delay_inst_d1:delay_inst_d2;
	delay_inst_sv <= inst_valid_last?delay_inst_d2:delay_inst_sv;
	delay_pd_d1 <= in_valid_d4?delay_pd:delay_pd_d1;
	delay_pd_d2 <= in_valid_d5?delay_pd_d1:delay_pd_d2;
	enable_inst <= set_enable_inst?1'b1:inst_valid_last?1'b0:enable_inst;
	enable_pd <= set_enable_pd?1'b1:pd_valid_last?1'b0:enable_pd;

	discard_en1_d1 <= in_valid_1st?discard_en1:discard_en1_d1;
	discard_en2_d1 <= in_valid_1st?discard_en2:discard_en2_d1;

    	pp_chunk_last_byte_loc <= in_valid_1st?in_data[127-4:127-4-11]+2-1:pp_chunk_last_byte_loc;
    	inst_chunk_first_byte_loc <= in_valid_1st?in_data[127-4:127-4-11]+2-6+2:inst_chunk_first_byte_loc;
    	inst_chunk_last_byte_loc <= set_enable_inst?inst_chunk_last_byte_loc_p1-1:inst_chunk_last_byte_loc;
    	pd_chunk_first_byte_loc <= set_enable_inst?pd_chunk_first_byte_loc_p1:pd_chunk_first_byte_loc;
    	pd_chunk_last_byte_loc <= set_enable_pd?pd_chunk_last_byte_loc_p1-1:pd_chunk_last_byte_loc;

	enable_fifo <= en_inst_pd?1'b1:pp_pu_fifo_rd&pp_pu_eop&~pp_pu_inst_pd?1'b0:enable_fifo;
	enable_fifo_error <= en_inst_pd?pp_pu_hop_error:pp_pu_fifo_rd&pp_pu_eop&~pp_pu_inst_pd?1'b0:enable_fifo_error;

    end

sfifo_lh_pp #(1) u_sfifo_lh_pp(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(lh_pp_meta_data_d1),              
        .rd(lh_pp_meta_fifo_rd),
        .wr(lh_pp_meta_valid),

        .ncount(),
        .count(),
        .full(),
        .empty(lh_pp_meta_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(lh_pp_meta_fifo_data)       
    );

sfifo2f_bram_pf #(1+1+`DATA_PATH_NBITS, `PP_PU_FIFO_DEPTH_NBITS) u_sfifo2f_bram_pf_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({lh_pp_sop_d1, lh_pp_eop_d1, lh_pp_hdr_data_d1}),              
        .rd(lh_pp_fifo_rd),
        .wr(lh_pp_valid_d1),

        .count(),
        .full(),
        .empty(lh_pp_fifo_empty),
        .dout({lh_pp_fifo_sop, lh_pp_fifo_eop, lh_pp_fifo_data})       
);

sfifo2f_fo #(`HEADER_LENGTH_NBITS, 4) u_sfifo2f_fo1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_chunk_len}),              
        .rd(inc_buf_fifo_count0),
        .wr(dec_buf_fifo_count0_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({len_fifo_data})       
);

sfifo2f_bram_pf #(1+1+`DATA_PATH_NBITS+`DATA_PATH_VB_NBITS+1+`CHUNK_LEN_NBITS*2, `PP_PU_FIFO_DEPTH_NBITS+2) u_sfifo2f_bram_pf_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({(inst_valid?inst_sop:pd_sop), (inst_valid?inst_eop:pd_eop), (inst_valid?inst_pp_pu_data_p1:pd_pp_pu_data_p1), (inst_valid?inst_valid_bytes:pd_valid_bytes), enable_inst, p_pp_pu_pd_loc, p_pp_pu_pd_len}),
        .rd(pp_pu_fifo_rd),
        .wr(inst_valid|pd_valid),

        .count(),
        .full(),
        .empty(pp_pu_fifo_empty),
        .dout({pp_pu_sop, pp_pu_eop, pp_pu_data, pp_pu_valid_bytes, pp_pu_inst_pd, pp_pu_pd_loc, pp_pu_pd_len})
);

function [`DATA_PATH_NBITS-1:0] rot;
input[`DATA_PATH_NBITS-1:0] din;
input[3:0] rot_cnt;

reg[`DATA_PATH_NBITS-1:0] din0, din1, din2;

begin
    din0 = rot_cnt[3]?{din[`DATA_PATH_NBITS-1-64:0], din[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-63]}:din;
    din1 = rot_cnt[2]?{din0[`DATA_PATH_NBITS-1-32:0], din0[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-31]}:din0;
    din2 = rot_cnt[1]?{din1[`DATA_PATH_NBITS-1-16:0], din1[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-15]}:din1;
    rot = rot_cnt[0]?{din2[`DATA_PATH_NBITS-1-8:0], din2[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-7]}:din2;
end
endfunction


function [`DATA_PATH_NBITS-1:0] mask_gen;
input[3:0] rot_cnt;

reg[`DATA_PATH_NBITS-1:0] din0, din1, din2;

begin
    din0 = rot_cnt[3]?{{(`DATA_PATH_NBITS-64){1'b1}}, 64'b0}:{(`DATA_PATH_NBITS){1'b1}};
    din1 = rot_cnt[2]?{din0[`DATA_PATH_NBITS-1-32:0], 32'b0}:din0;
    din2 = rot_cnt[1]?{din1[`DATA_PATH_NBITS-1-16:0], 16'b0}:din1;
    mask_gen = rot_cnt[0]?{din2[`DATA_PATH_NBITS-1-8:0], 8'b0}:din2;
end
endfunction



/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule 
