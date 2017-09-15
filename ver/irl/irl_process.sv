//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module irl_process #(
parameter DEPTH_NBITS = `FLOW_VALUE_DEPTH_NBITS,
parameter BUCKET_NBITS = `CIR_NBITS+2+`EIR_NBITS+2,
parameter EIR_TB_NBITS = `EIR_NBITS+2
) (
input clk,
input `RESET_SIG,

input cla_irl_valid,
input [`DATA_PATH_RANGE] cla_irl_hdr_data,
input cla_irl_meta_type   cla_irl_meta_data,
input cla_irl_sop,
input cla_irl_eop,

input limiting_profile_cir_ack, 
input [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_rdata  /* synthesis keep = 1 */,

input limiting_profile_eir_ack, 
input [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_rdata  /* synthesis keep = 1 */,

input fill_tb_src_ack, 
input [`FILL_TB_NBITS-1:0] fill_tb_src_rdata  /* synthesis keep = 1 */,

input eir_tb_ack, 
input [`EIR_NBITS+2-1:0] eir_tb_rdata  /* synthesis keep = 1 */,

input token_bucket_ack, 
input [BUCKET_NBITS-1:0] token_bucket_rdata  /* synthesis keep = 1 */,


    // outputs
  
output logic irl_lh_valid,
output logic [`DATA_PATH_RANGE] irl_lh_hdr_data,
output irl_lh_meta_type   irl_lh_meta_data,
output logic irl_lh_sop,
output logic irl_lh_eop,

output logic limiting_profile_cir_rd, 
output logic [`LIMITER_NBITS-1:0] limiting_profile_cir_raddr,

output logic limiting_profile_cir_wr, 
output logic [`LIMITER_NBITS-1:0] limiting_profile_cir_waddr,
output logic [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_wdata,

output logic limiting_profile_eir_rd, 
output logic [`LIMITER_NBITS-1:0] limiting_profile_eir_raddr,

output logic limiting_profile_eir_wr, 
output logic [`LIMITER_NBITS-1:0] limiting_profile_eir_waddr,
output logic [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_wdata,

output logic fill_tb_src_rd, 
output logic [DEPTH_NBITS-1:0] fill_tb_src_raddr,

output logic fill_tb_src_wr, 
output logic [DEPTH_NBITS-1:0] fill_tb_src_waddr,
output logic [`FILL_TB_NBITS-1:0] fill_tb_src_wdata,

output logic eir_tb_rd, 
output logic [`PORT_ID_NBITS-1:0] eir_tb_raddr,

output logic eir_tb_wr, 
output logic [`PORT_ID_NBITS-1:0] eir_tb_waddr,
output logic [`EIR_NBITS+2-1:0] eir_tb_wdata,

output logic token_bucket_rd, 
output logic [DEPTH_NBITS-1:0] token_bucket_raddr,

output logic token_bucket_wr, 
output logic [DEPTH_NBITS-1:0] token_bucket_waddr,
output logic [BUCKET_NBITS-1:0] token_bucket_wdata

);


/***************************** LOCAL VARIABLES *******************************/

localparam TYPE1_SRC_PORT = {(`PORT_ID_NBITS){1'b1}};
localparam TYPE1_TOKEN_BUCKET = {(DEPTH_NBITS){1'b0}};
localparam TYPE1_LIMITING_PROFILE = {(`LIMITER_NBITS){1'b0}};

localparam [1:0]  INIT_IDLE = 0,
         INIT_COUNT = 1,
         INIT_DONE = 2;

localparam CTR_NBITS = 8;
localparam CTR_END_VALUE = {(CTR_NBITS){1'b1}};

logic [1:0] init_st, nxt_init_st;

logic init_wr;
logic [DEPTH_NBITS-1:0] init_count;

logic init_wr1;
logic [DEPTH_NBITS-1:0] init_count1;

logic limiting_profile_cir_ack_d1;

logic cla_irl_valid_d1;
logic [`DATA_PATH_RANGE] cla_irl_hdr_data_d1;
cla_irl_meta_type   cla_irl_meta_data_d1;
logic cla_irl_sop_d1;
logic cla_irl_eop_d1;
wire cla_irl_discard = cla_irl_meta_data_d1.discard;
logic cla_irl_discard_d1;
logic cla_irl_discard_d2;
logic cla_irl_discard_d3;
logic cla_irl_discard_d4;

logic en_irl_d1;
logic en_irl_d2;
logic en_irl_d3;
logic en_irl_d4;

logic [`FID_NBITS-1:0] fid_ctr;
logic [CTR_NBITS-1:0] ctr;

wire fill_token_bucket = (ctr==CTR_END_VALUE);

logic [DEPTH_NBITS-1:0] token_bucket_raddr_d1;
logic [DEPTH_NBITS-1:0] token_bucket_raddr_d2;

logic token_bucket_wr_p1;			
logic token_bucket_wr_d1;			
logic [DEPTH_NBITS-1:0] token_bucket_waddr_p1;
logic [DEPTH_NBITS-1:0] token_bucket_waddr_d1;
logic [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata_p1;
logic [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata_d1;

logic [`PORT_ID_NBITS-1:0] eir_tb_raddr_d1;
logic [`PORT_ID_NBITS-1:0] eir_tb_raddr_d2;

logic eir_tb_wr_p1;			
logic eir_tb_wr_d1;			
logic [`PORT_ID_NBITS-1:0] eir_tb_waddr_p1;
logic [`PORT_ID_NBITS-1:0] eir_tb_waddr_d1;
logic [`EIR_NBITS+2-1:0] eir_tb_wdata_p1;
logic [`EIR_NBITS+2-1:0] eir_tb_wdata_d1;

logic fill_tb_src_ack_d1;
logic [DEPTH_NBITS-1:0] fill_tb_src_raddr_d1;
logic [DEPTH_NBITS-1:0] fill_tb_src_raddr_d2;

logic [`FILL_TB_NBITS-1:0] fill_tb_src_rdata_d1;
logic [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_cir_rdata_d1;
logic [`LIMITING_PROFILE_NBITS-1:0] limiting_profile_eir_rdata_d1;
logic [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata_d1;
logic [`EIR_NBITS+2-1:0] eir_tb_rdata_d1;

logic [`CLA_IRL_META_LEN_RANGE] len_d1;
logic [`CLA_IRL_META_LEN_RANGE] len_d2;
wire [`CLA_IRL_META_LEN_RANGE] len = cla_irl_meta_data_d1.len;
wire [`CLA_IRL_META_FID_RANGE] fid = cla_irl_meta_data_d1.fid;
wire [`CLA_IRL_META_PORT_RANGE] src_port = cla_irl_meta_data_d1.port;
wire type3 = cla_irl_meta_data_d1.type3;
wire type1 = (cla_irl_hdr_data_d1[127:120]==8'h90)&~type3;

logic type1_d1;
logic type1_d2;

logic lat_fifo_rd5_d1;
logic lat_fifo_rd5_d2;
logic lat_fifo_rd5_d3;
logic lat_fifo_rd5_d4;

logic lat_fifo_empty5;
logic [`CLA_IRL_META_FID_RANGE] lat_fifo_fid_ctr;

logic in_fifo_valid;
logic [`DATA_PATH_RANGE] in_fifo_hdr_data;
cla_irl_meta_type   in_fifo_meta_data;
logic in_fifo_sop;
logic in_fifo_eop;

wire in_fifo_discard = in_fifo_meta_data.discard;

wire en_irl = cla_irl_valid_d1&cla_irl_sop_d1;

wire lat_fifo_rd5 = ~en_irl&~lat_fifo_empty5;

logic in_fifo_empty;
logic lat_fifo_empty;
logic in_fifo_rd_en;
wire in_fifo_rd = ~in_fifo_empty&in_fifo_rd_en;

logic lat_fifo_no_token;
wire lat_fifo_rd = in_fifo_rd&in_fifo_eop;

wire en_type1 = en_irl_d2&type1_d2;

wire zero_rate = fill_tb_src_rdata_d1[`LIMITER_NBITS-1:0]==0;
wire full_rate = fill_tb_src_rdata_d1[`LIMITER_NBITS-1:0]==63;

logic lat_fifo_zero_rate;
logic lat_fifo_full_rate;

/***************************** NON REGISTERED OUTPUTS ************************/

assign fill_tb_src_rd = en_irl|~lat_fifo_empty5;
assign fill_tb_src_raddr = en_irl?fid:lat_fifo_fid_ctr;

assign token_bucket_raddr = en_type1?TYPE1_TOKEN_BUCKET:fill_tb_src_raddr_d2;
assign eir_tb_raddr = en_type1?TYPE1_SRC_PORT:fill_tb_src_rdata_d1[`FILL_TB_NBITS-1:`LIMITER_NBITS];

assign limiting_profile_cir_raddr = en_type1?TYPE1_LIMITING_PROFILE:fill_tb_src_rdata_d1[`LIMITER_NBITS-1:0];
assign limiting_profile_eir_raddr = limiting_profile_cir_raddr;

/***************************** REGISTERED OUTPUTS ****************************/

assign token_bucket_rd = fill_tb_src_ack_d1;

assign limiting_profile_cir_rd = token_bucket_rd;
assign limiting_profile_eir_rd = token_bucket_rd;

 
always @(posedge clk) begin

		limiting_profile_cir_waddr <= init_count1;
		limiting_profile_cir_wdata <= 0;

		limiting_profile_eir_waddr <= init_count1;
		limiting_profile_eir_wdata <= 0;

		fill_tb_src_waddr <= init_count1;
		fill_tb_src_wdata <= 0;

		token_bucket_waddr <= token_bucket_waddr_p1;
		token_bucket_wdata <= token_bucket_wdata_p1;

		eir_tb_waddr <= eir_tb_waddr_p1;
		eir_tb_wdata <= eir_tb_wdata_p1;

		irl_lh_hdr_data <= in_fifo_hdr_data;			

		irl_lh_meta_data.traffic_class <= in_fifo_meta_data.traffic_class;
		irl_lh_meta_data.hdr_len <= in_fifo_meta_data.hdr_len;
		irl_lh_meta_data.buf_ptr <= in_fifo_meta_data.buf_ptr;
		irl_lh_meta_data.len <= in_fifo_meta_data.len;
		irl_lh_meta_data.port <= in_fifo_meta_data.port;
		irl_lh_meta_data.rci <= in_fifo_meta_data.rci;
		irl_lh_meta_data.fid <= in_fifo_meta_data.fid;
		irl_lh_meta_data.tid <= in_fifo_meta_data.tid;
		irl_lh_meta_data.type1 <= in_fifo_meta_data.type1;
		irl_lh_meta_data.type3 <= in_fifo_meta_data.type3;
		irl_lh_meta_data.discard <= in_fifo_discard|lat_fifo_no_token;			

		irl_lh_sop <= in_fifo_sop;			
		irl_lh_eop <= in_fifo_eop;			
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		limiting_profile_cir_wr <= 1'b0; 
		limiting_profile_eir_wr <= 1'b0; 
		fill_tb_src_wr <= 1'b0; 
		token_bucket_wr <= 1'b0;			
		eir_tb_wr <= 1'b0;			
		irl_lh_valid <= 1'b0;			

    end else begin

		limiting_profile_cir_wr <= init_wr1; 
		limiting_profile_eir_wr <= init_wr1; 
		fill_tb_src_wr <= init_wr1; 
		token_bucket_wr <= token_bucket_wr_p1;			
		eir_tb_wr <= eir_tb_wr_p1;			

		irl_lh_valid <= in_fifo_rd;			
    end

/***************************** PROGRAM BODY **********************************/

logic [2:0] same_eir_tb_address_p1;
assign same_eir_tb_address_p1[0] = (eir_tb_raddr_d1==eir_tb_raddr_d2)&eir_tb_wr_p1;
assign same_eir_tb_address_p1[1] = (eir_tb_raddr_d1==eir_tb_waddr)&eir_tb_wr;
assign same_eir_tb_address_p1[2] = (eir_tb_raddr_d1==eir_tb_waddr_d1)&eir_tb_wr_d1;

logic [`EIR_NBITS+2-1:0] meir_tb_wdata;
wire [`EIR_NBITS+2-1:0] meir_tb_wdata_p1 = same_eir_tb_address_p1[1]?eir_tb_wdata:eir_tb_wdata_d1;

logic same_eir_tb_address0;
logic same_eir_tb_address21;

wire [`EIR_NBITS+2-1:0] meir_tb_rdata_d1 = same_eir_tb_address0?eir_tb_wdata:same_eir_tb_address21?meir_tb_wdata:eir_tb_rdata_d1;

logic [2:0] same_token_address_p1;
assign same_token_address_p1[0] = (token_bucket_raddr_d1==token_bucket_raddr_d2)&token_bucket_wr_p1;
assign same_token_address_p1[1] = (token_bucket_raddr_d1==token_bucket_waddr)&token_bucket_wr;
assign same_token_address_p1[2] = (token_bucket_raddr_d1==token_bucket_waddr_d1)&token_bucket_wr_d1;
wire same_token_address21_p1 = |same_token_address_p1[2:1];

logic [`CIR_NBITS+2+`EIR_NBITS+2-1:0] mtoken_bucket_wdata;
wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] mtoken_bucket_wdata_p1 = same_token_address_p1[1]?token_bucket_wdata:token_bucket_wdata_d1;

logic same_token_address0;
logic same_token_address21;

wire [`CIR_NBITS+2+`EIR_NBITS+2-1:0] mtoken_bucket_rdata_d1 = same_token_address0?token_bucket_wdata:same_token_address21?mtoken_bucket_wdata:token_bucket_rdata_d1;

wire [`CIR_NBITS+2-1:0] cir = mtoken_bucket_rdata_d1[`CIR_NBITS+2-1:0];
wire [`EIR_NBITS+2-1:0] eir = mtoken_bucket_rdata_d1[`CIR_NBITS+2+`EIR_NBITS+2-1:`CIR_NBITS+2];

wire negative_cir = cir[`CIR_NBITS+2-1]; 
wire negative_eir = eir[`EIR_NBITS+2-1]; 
wire no_token = negative_cir&negative_eir; // negative CIR and EIR tokens

wire positive_cir = ~negative_cir;
wire positive_eir = ~negative_eir;

// Token bucket update
assign token_bucket_wr_p1 = init_wr|(~lat_fifo_zero_rate&~lat_fifo_full_rate&~no_token&en_irl_d4&~cla_irl_discard_d4)|lat_fifo_rd5_d4;
assign token_bucket_waddr_p1 = init_wr?init_count:token_bucket_raddr_d2;

wire [`CIR_NBITS+2-1:0] new_cir = cir[`CIR_NBITS+2-1]?cir:(cir-len_d2);
wire [`EIR_NBITS+2-1:0] new_eir = (~eir[`CIR_NBITS+2-1]&cir[`CIR_NBITS+2-1])?(eir-len_d2):eir;

wire [`CIR_NBITS-1:0] cir_token = limiting_profile_cir_rdata_d1[`CIR_NBITS-1:0];
wire [`CIR_NBITS-1:0] cir_burst = limiting_profile_cir_rdata_d1[(`CIR_NBITS*2)-1:`CIR_NBITS];
wire [`EIR_NBITS-1:0] eir_token = limiting_profile_eir_rdata_d1[`EIR_NBITS-1:0];
wire [`EIR_NBITS-1:0] eir_burst = limiting_profile_eir_rdata_d1[(`EIR_NBITS*2)-1:`EIR_NBITS];

//wire [`CIR_NBITS+2-1:0] cir_minus_burst = {1'b0, cir[`CIR_NBITS+2-1-1:0]}-cir_burst;
//wire over_cir_burst = ~cir[`CIR_NBITS+2-1]&~cir_minus_burst[`CIR_NBITS+2-1];
wire over_cir_burst = ~cir[`CIR_NBITS+2-1]&(cir[`CIR_NBITS+2-1-1:0]>cir_burst);
wire [`CIR_NBITS+2-1:0] new_fill_cir = over_cir_burst?cir:cir + cir_token;

//wire [`EIR_NBITS+2-1:0] eir_minus_burst = {1'b0, eir[`EIR_NBITS+2-1-1:0]}-eir_burst;
//wire over_eir_burst = ~eir[`EIR_NBITS+2-1]&~eir_minus_burst[`EIR_NBITS+2-1];
wire over_eir_burst = ~eir[`EIR_NBITS+2-1]&(eir[`EIR_NBITS+2-1-1:0]>eir_burst);
wire eir_available = ~meir_tb_rdata_d1[`EIR_NBITS+1];

wire [`EIR_NBITS+2-1:0] new_fill_eir = over_cir_burst|over_eir_burst|~eir_available?eir:eir+eir_token;
assign token_bucket_wdata_p1 = init_wr?0:en_irl_d4?{new_eir, new_cir}:{new_fill_eir, new_fill_cir};

// EIR Token bucket

assign eir_tb_wr_p1 = init_wr|lat_fifo_rd5_d4;
assign eir_tb_waddr_p1 = init_wr?init_count:eir_tb_raddr_d2;
assign eir_tb_wdata_p1 = init_wr?0:over_cir_burst&~meir_tb_rdata_d1[`EIR_NBITS]?meir_tb_rdata_d1+cir_token:(~over_eir_burst&eir_available&~over_cir_burst)?meir_tb_rdata_d1-eir_token:meir_tb_rdata_d1;

always @(posedge clk) begin
        
	cla_irl_hdr_data_d1 <= cla_irl_hdr_data;
	cla_irl_meta_data_d1 <= cla_irl_meta_data;
	cla_irl_sop_d1 <= cla_irl_sop;
	cla_irl_eop_d1 <= cla_irl_eop;

	fill_tb_src_raddr_d1 <= fill_tb_src_raddr;
	fill_tb_src_raddr_d2 <= fill_tb_src_raddr_d1;

	token_bucket_raddr_d1 <= token_bucket_raddr;
	token_bucket_raddr_d2 <= token_bucket_raddr_d1;

	token_bucket_waddr_d1 <= token_bucket_waddr;
	token_bucket_wdata_d1 <= token_bucket_wdata;

	mtoken_bucket_wdata <= mtoken_bucket_wdata_p1;

	eir_tb_raddr_d1 <= eir_tb_raddr;
	eir_tb_raddr_d2 <= eir_tb_raddr_d1;

	eir_tb_waddr_d1 <= eir_tb_waddr;
	eir_tb_wdata_d1 <= eir_tb_wdata;

	meir_tb_wdata <= meir_tb_wdata_p1;

	same_eir_tb_address0 <= same_eir_tb_address_p1[0];
	same_eir_tb_address21 <= |same_eir_tb_address_p1[2:1];

	same_token_address0 <= same_token_address_p1[0];
	same_token_address21 <= |same_token_address_p1[2:1];

	len_d1 <= len;
	len_d2 <= len_d1;

	type1_d1 <= type1;
	type1_d2 <= type1_d1;

	cla_irl_discard_d1 <= cla_irl_discard;
	cla_irl_discard_d2 <= cla_irl_discard_d1;
	cla_irl_discard_d3 <= cla_irl_discard_d2;
	cla_irl_discard_d4 <= cla_irl_discard_d3;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		limiting_profile_cir_ack_d1 <= 1'b0;
		cla_irl_valid_d1 <= 1'b0;
		en_irl_d1 <= 1'b0;
		en_irl_d2 <= 1'b0;
		en_irl_d3 <= 1'b0;
		en_irl_d4 <= 1'b0;
	    	init_wr <= 0;
		init_count <= 0;
		init_wr1 <= 0;
		init_count1 <= 0;
		ctr <= 0;
		fid_ctr <= 0;

		fill_tb_src_ack_d1 <= 0;
		lat_fifo_rd5_d1 <= 1'b0;
		lat_fifo_rd5_d2 <= 1'b0;
		lat_fifo_rd5_d3 <= 1'b0;
		lat_fifo_rd5_d4 <= 1'b0;

		token_bucket_wr_d1 <= 1'b0;
		eir_tb_wr_d1 <= 1'b0;

		in_fifo_rd_en <= 1'b0;
    end else begin
		limiting_profile_cir_ack_d1 <= limiting_profile_cir_ack;
		cla_irl_valid_d1 <= cla_irl_valid;
		en_irl_d1 <= en_irl;
		en_irl_d2 <= en_irl_d1;
		en_irl_d3 <= en_irl_d2;
		en_irl_d4 <= en_irl_d3;
	    	init_wr <= (nxt_init_st==INIT_COUNT);
		init_count <= init_wr?(init_count+1):init_count;
		init_wr1 <= (nxt_init_st==INIT_COUNT);
		init_count1 <= init_wr1?(init_count1+1):init_count1;
		ctr <= fill_token_bucket?0:ctr+1;
		fid_ctr <= ~fill_token_bucket?fid_ctr:fid_ctr+1;

		fill_tb_src_ack_d1 <= fill_tb_src_ack;
		lat_fifo_rd5_d1 <= lat_fifo_rd5;
		lat_fifo_rd5_d2 <= lat_fifo_rd5_d1;
		lat_fifo_rd5_d3 <= lat_fifo_rd5_d2;
		lat_fifo_rd5_d4 <= lat_fifo_rd5_d3;

		token_bucket_wr_d1 <= token_bucket_wr;
		eir_tb_wr_d1 <= eir_tb_wr;

		in_fifo_rd_en <= ~lat_fifo_empty?1'b1:lat_fifo_rd?1'b0:in_fifo_rd_en;
    end
 
/***************************** NEXT STATE ASSIGNMENT **************************/
	always @(*)  begin
		nxt_init_st = init_st;
		case (init_st)		
			INIT_IDLE: nxt_init_st = INIT_COUNT;
			INIT_COUNT: if (&init_count) nxt_init_st = INIT_DONE;
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

sfifo2f_fo #(DEPTH_NBITS, 6) u_sfifo2f_fo_50(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(fid_ctr),				
		.rd(lat_fifo_rd5),
		.wr(fill_token_bucket),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty5),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_fid_ctr)       
);


sfifo2f1 #(1) u_sfifo2f1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({(lat_fifo_zero_rate|no_token)}&~lat_fifo_full_rate),				
		.rd(lat_fifo_rd),
		.wr(en_irl_d4),

		.count(),
		.full(),
		.empty(lat_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_no_token)       
);

sfifo2f_fo #(2, 3) u_sfifo2f_fo_6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({zero_rate, full_rate}),				
		.rd(limiting_profile_cir_ack_d1),
		.wr(limiting_profile_cir_rd),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_zero_rate, lat_fifo_full_rate})       
);

sfifo2f_fo #(128+2, 3) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({cla_irl_hdr_data_d1, cla_irl_sop_d1, cla_irl_eop_d1}),               
        .rd(in_fifo_rd),
        .wr(cla_irl_valid_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({in_fifo_hdr_data, in_fifo_sop, in_fifo_eop})               
    );

sfifo_cla_irl #(3) u_sfifo_cla_irl(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(cla_irl_meta_data_d1),               
        .rd(in_fifo_rd),
        .wr(cla_irl_valid_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(in_fifo_meta_data)               
    );


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

