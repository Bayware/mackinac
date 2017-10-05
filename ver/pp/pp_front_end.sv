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
   input pp_pu_hop_eop,
   input pp_pu_hop_type3,

   input pu_pp_buf_fifo_rd,
   input [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count,

   output     pp_ecdsa_ready,

   output pp_valid0,
   output [`DATA_PATH_RANGE] pp_data0,
   output pp_sop0,
   output pp_eop0,
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

logic sel_lh;

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
logic set_discard_st;
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
assign in_meta_data.type3 = in_type3|set_discard_st;
assign in_meta_data.discard = in_discard|set_discard_st;

wire [`CHUNK_LEN_NBITS-1:0] in_auth_len = sel_lh?0:ecdsa_pp_auth_len_d1+2;
logic [`CHUNK_LEN_NBITS-1:0] in_auth_len_d1;
wire [`HEADER_LENGTH_NBITS-1:0] in_hdr_len = sel_lh?(lh_pp_meta_fifo_data.hdr_len<<4):(ecdsa_pp_meta_data_d1.hdr_len<<4)-(ecdsa_pp_auth_len_d1+2);

logic [`CHUNK_LEN_NBITS-1:0] pp_len;
logic [31:0] creation_time;
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

wire [9:0] inst_pd_chunk_len = in_hdr_len-pp_chunk_len;

wire discard_en1 = (in_meta_data.type1|~in_type3)&(pp_chunk_len>buf_fifo_count);
wire discard_en2 = (in_meta_data.type1|~in_type3)&(inst_pd_chunk_len>(INST_BUF_FIFO_FULL_COUNT-(pu_pp_inst_buf_fifo_count+6)));
wire reset_discard_st = in_valid_d1&in_eop_d1;
assign set_discard_st = in_valid_d1&in_sop_d1&(discard_en1|discard_en2);
logic discard_st;
wire discard_mode = set_discard_st|discard_st;

logic in_discard_d1;

wire dec_buf_fifo_count0 = in_valid_d1&in_sop_d1&~set_discard_st&~in_meta_data_d1.type3;
wire dec_buf_fifo_count1 = ~pp_pu_hop_type3&pp_pu_hop_valid;
wire inc_buf_fifo_count0 = ~pp_pu_hop_type3&pp_pu_hop_valid&pp_pu_hop_eop;
wire inc_buf_fifo_count1 = pu_pp_buf_fifo_rd_d1;

always @(*)
	case ({dec_buf_fifo_count0, dec_buf_fifo_count1, inc_buf_fifo_count0, inc_buf_fifo_count1})
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
wire set_disable_pp_st = pp_valid0_last;
logic disable_pp;

wire set_enable_inst = pp_valid0_last;
logic enable_inst;

wire inst_valid = in_valid_d2&enable_inst;
logic inst_sop;
wire inst_eop = inst_data_cnt==(inst_chunk_last_byte_loc>>4);
wire inst_valid_1st = inst_valid&inst_sop;
wire inst_valid_last = inst_valid&inst_eop;
logic inst_valid_last_d1;
logic [`DATA_PATH_RANGE] rot_in_data_sv;
logic [9:0] inst_chunk_last_byte_loc_p1;
assign inst_chunk_last_byte_loc_p1 = rot_in_data_sv[15-4:15-4-11];
wire [`DATA_PATH_VB_RANGE] inst_valid_bytes = inst_eop?(inst_sop?inst_chunk_last_byte_loc_p1[3:0]:inst_chunk_last_byte_loc[3:0]+1):0;

wire [2:0] rot_cnt = inst_chunk_first_byte_loc[3:1];
wire [`DATA_PATH_RANGE] rot_in_data = rot(pp_data0, rot_cnt);
wire [`DATA_PATH_RANGE] mask = mask_gen(rot_cnt);

logic [`DATA_PATH_RANGE] mask_d1;

wire [`DATA_PATH_RANGE] inst_pp_pu_data_p1 = rot_in_data_sv&mask_d1|rot_in_data&~mask_d1;
logic [`DATA_PATH_RANGE] inst_data;

wire set_enable_pd = inst_valid_last_d1|~inst_valid_1st&inst_valid_last;
logic enable_pd;

wire pd_valid = in_valid_d4&enable_pd;
logic pd_sop;
wire pd_valid_1st = pd_valid&pd_sop;
wire pd_eop = pd_data_cnt==(pd_chunk_last_byte_loc>>4);
wire pd_valid_last = pd_valid&pd_eop;
logic [9:0] pd_chunk_last_byte_loc_p1;
logic [`DATA_PATH_RANGE] rot_inst_data_sv;
assign pd_chunk_last_byte_loc_p1 = rot_inst_data_sv[15-4:15-4-11];
wire [`DATA_PATH_VB_RANGE] pd_valid_bytes = pd_eop?(pd_sop?pd_chunk_last_byte_loc_p1[3:0]:pd_chunk_last_byte_loc[3:0]+1):0;

wire [2:0] pd_rot_cnt = pd_chunk_first_byte_loc[3:1];
wire [`DATA_PATH_RANGE] rot_inst_data = rot(inst_data, pd_rot_cnt);
wire [`DATA_PATH_RANGE] pd_mask = mask_gen(pd_rot_cnt);

logic [`DATA_PATH_RANGE] pd_mask_d1;

wire [`DATA_PATH_RANGE] pd_pp_pu_data_p1 = rot_inst_data_sv&pd_mask_d1|rot_inst_data&~pd_mask_d1;

wire [9:0] pd_chunk_first_byte_loc_p1 = rot_in_data_sv[15-4:15-4-11]+2;

/***************************** NON REGISTERED OUTPUTS ************************/

assign pp_valid0 = in_valid_d1&~disable_pp&~discard_mode&~in_discard_d1&~in_meta_data_d1.type3;
assign pp_data0 = {in_data_sv, in_data[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-6*8+1]};
assign pp_sop0 = in_sop_d1;
assign pp_eop0 = pp_data_cnt==(pp_chunk_last_byte_loc>>4);
assign pp_meta_valid0 = in_valid_d1&in_sop_d1;
assign pp_meta_rci0 = in_meta_data_d1.rci;
assign pp_meta_data = in_meta_data_d1;
assign pp_creation_time = creation_time;
assign pp_loc = 40+2+in_auth_len_d1+2+4;

assign pp_ecdsa_ready = ~sel_lh;

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	    pp_pu_sop <= inst_sop|pd_sop;
	    pp_pu_eop <= inst_eop|pd_eop;
	    pp_pu_data <= inst_valid?inst_pp_pu_data_p1:pd_pp_pu_data_p1;
	    pp_pu_valid_bytes <= inst_valid?inst_valid_bytes:pd_valid_bytes;

	    pp_pu_inst_pd <= enable_inst;
	    pp_pu_pd_loc <= 40+in_auth_len_d1+pp_len+2+(inst_valid_1st?pd_chunk_first_byte_loc_p1+2:pd_chunk_first_byte_loc+2);
	    pp_pu_pd_len <= pd_valid&~pd_sop?pd_chunk_last_byte_loc+1:pd_chunk_last_byte_loc_p1;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	    pp_pu_valid <= 1'b0;
    end else begin
	    pp_pu_valid <= inst_valid|pd_valid;
    end

/***************************** PROGRAM BODY **********************************/ 
always @(posedge clk) begin

    ecdsa_pp_valid_d1 <= ecdsa_pp_valid;
    ecdsa_pp_sop_d1 <= ecdsa_pp_sop;
    ecdsa_pp_eop_d1 <= ecdsa_pp_eop;
    ecdsa_pp_data_d1 <= ecdsa_pp_data;
    ecdsa_pp_meta_data_d1 <= ecdsa_pp_meta_data;
    ecdsa_pp_auth_len_d1 <= ecdsa_pp_auth_len;

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

    rot_in_data_sv <= in_valid_d1?rot_in_data:rot_in_data_sv;
    mask_d1 <= mask;

    inst_data <= inst_pp_pu_data_p1;
    
    rot_inst_data_sv <= in_valid_d2?rot_inst_data:rot_inst_data_sv;
    pd_mask_d1 <= pd_mask;

    inst_sop <= set_enable_inst?1'b1:inst_valid?1'b0:inst_sop;
    pd_sop <= set_enable_pd?1'b1:pd_valid?1'b0:pd_sop;

    inst_valid_last_d1 <= inst_valid_last;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	buf_fifo_count <= BUF_FIFO_FULL_COUNT;

	pu_pp_buf_fifo_rd_d1 <= 1'b0;
	pu_pp_inst_buf_fifo_count_d1 <= 0;

	discard_st <= 1'b0;
	pp_ecdsa_ready_d1 <= 1'b0;
	sel_lh <= 1'b1;
	in_valid_d1 <= 0;
	in_valid_d2 <= 0;
	in_valid_d3 <= 0;
	in_valid_d4 <= 0;
	pp_data_cnt <= 0;
	inst_data_cnt <= 0;
	pd_data_cnt <= 0;
	disable_pp <= 0;
	enable_inst <= 0;
	enable_pd <= 0;

    	pp_chunk_last_byte_loc <= 0;
    	inst_chunk_first_byte_loc <= 0;
    	inst_chunk_last_byte_loc <= 0;
    	pd_chunk_first_byte_loc <= 0;
    	pd_chunk_last_byte_loc <= 0;

    end else begin
	buf_fifo_count <= buf_fifo_count_p1;

	pu_pp_buf_fifo_rd_d1 <= pu_pp_buf_fifo_rd;
	pu_pp_inst_buf_fifo_count_d1 <= pu_pp_inst_buf_fifo_count;

	discard_st <= reset_discard_st?1'b0:set_discard_st?1'b1:discard_st;
	pp_ecdsa_ready_d1 <= pp_ecdsa_ready;
	sel_lh <= toggle_sel_lh?~sel_lh:sel_lh;
	in_valid_d1 <= in_valid;
	in_valid_d2 <= in_valid_d1;
	in_valid_d3 <= in_valid_d2;
	in_valid_d4 <= in_valid_d3;
	pp_data_cnt <= pp_valid0_last?0:~pp_valid0?pp_data_cnt:pp_data_cnt+1;
	inst_data_cnt <= inst_valid_last?0:~inst_valid?inst_data_cnt:inst_data_cnt+1;
	pd_data_cnt <= pd_valid_last?0:~pd_valid?pd_data_cnt:pd_data_cnt+1;
	disable_pp <= set_disable_pp_st?1'b1:in_valid_d1&in_eop_d1?1'b0:disable_pp;
	enable_inst <= set_enable_inst?1'b1:inst_valid_last?1'b0:enable_inst;
	enable_pd <= set_enable_pd?1'b1:pd_valid_last?1'b0:enable_pd;

    	pp_chunk_last_byte_loc <= in_valid_1st?in_data[127-4:127-4-11]+2-1:pp_chunk_last_byte_loc;
    	inst_chunk_first_byte_loc <= in_valid_1st?in_data[127-4:127-4-11]+2-6+2:inst_chunk_first_byte_loc;
    	inst_chunk_last_byte_loc <= inst_valid_1st?inst_chunk_last_byte_loc_p1-1:inst_chunk_last_byte_loc;
    	pd_chunk_first_byte_loc <= inst_valid_1st?pd_chunk_first_byte_loc_p1:pd_chunk_first_byte_loc;
    	pd_chunk_last_byte_loc <= pd_valid_1st?pd_chunk_last_byte_loc_p1-1:pd_chunk_last_byte_loc;

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

sfifo2f_fo #(1+1+`DATA_PATH_NBITS, `PP_PU_FIFO_DEPTH_NBITS) u_sfifo2f_fo0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({lh_pp_sop_d1, lh_pp_eop_d1, lh_pp_hdr_data_d1}),              
        .rd(lh_pp_fifo_rd),
        .wr(lh_pp_valid_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(lh_pp_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({lh_pp_fifo_sop, lh_pp_fifo_eop, lh_pp_fifo_data})       
);

sfifo2f_fo #(`HEADER_LENGTH_NBITS, 4) u_sfifo2f_fo1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_chunk_len}),              
        .rd(inc_buf_fifo_count0),
        .wr(dec_buf_fifo_count0),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({len_fifo_data})       
);


function [`DATA_PATH_NBITS-1:0] rot;
input[`DATA_PATH_NBITS-1:0] din;
input[2:0] rot_cnt;

reg[`DATA_PATH_NBITS-1:0] din0, din1;

begin
    din0 = rot_cnt[2]?{din[`DATA_PATH_NBITS-1-64:0], din[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-63]}:din;
    din1 = rot_cnt[1]?{din0[`DATA_PATH_NBITS-1-32:0], din0[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-31]}:din0;
    rot = rot_cnt[0]?{din1[`DATA_PATH_NBITS-1-16:0], din1[`DATA_PATH_NBITS-1:`DATA_PATH_NBITS-1-15]}:din1;
end
endfunction


function [`DATA_PATH_NBITS-1:0] mask_gen;
input[2:0] rot_cnt;

reg[`DATA_PATH_NBITS-1:0] din0, din1;

begin
    din0 = rot_cnt[2]?{{(`DATA_PATH_NBITS-64){1'b1}}, 64'b0}:{(`DATA_PATH_NBITS){1'b1}};
    din1 = rot_cnt[1]?{din0[`DATA_PATH_NBITS-1-32:0], 32'b0}:din0;
    mask_gen = rot_cnt[0]?{din1[`DATA_PATH_NBITS-1-16:0], 16'b0}:din1;
end
endfunction



/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule 
