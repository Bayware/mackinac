//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module logic_hash (

input clk,
input `RESET_SIG,


input ecdsa_lh_wr,
input [`FID_NBITS-1:0] ecdsa_lh_waddr,
input [`LOGIC_HASH_NBITS-1:0] ecdsa_lh_wdata,
input [`SERIAL_NUM_NBITS-1:0]   ecdsa_lh_sn_wdata,
input [`PPL_NBITS-1:0]   ecdsa_lh_ppl_wdata,


input irl_lh_valid,
input [`DATA_PATH_RANGE] irl_lh_hdr_data,
input irl_lh_meta_type   irl_lh_meta_data,
input irl_lh_sop,
input irl_lh_eop,

output logic lh_ecdsa_hash_valid,
output logic [`LOGIC_HASH_NBITS-1:0] lh_ecdsa_hash_data,

input ecdsa_lh_ready,

output logic lh_pp_valid,
output logic [`DATA_PATH_RANGE] lh_pp_hdr_data,
output lh_pp_meta_type   lh_pp_meta_data,
output logic lh_pp_sop,
output logic lh_pp_eop,

output logic lh_ecdsa_valid,
output logic [`DATA_PATH_RANGE] lh_ecdsa_hdr_data,
output lh_ecdsa_meta_type   lh_ecdsa_meta_data,
output logic lh_ecdsa_sop,
output logic lh_ecdsa_eop


);


/***************************** LOCAL VARIABLES *******************************/
localparam SEL_TYPE3 = 0,
	   SEL_TYPE12 = 1;

localparam LH_FIFO_DEPTH_NBITS = 10-4;

logic init_wr;
logic [`FID_NBITS:0] init_addr;

logic ecdsa_lh_wr_d1;
logic [`FID_NBITS-1:0] ecdsa_lh_waddr_d1;
logic [`LOGIC_HASH_NBITS-1:0] ecdsa_lh_wdata_d1;
logic [`SERIAL_NUM_NBITS-1:0]   ecdsa_lh_sn_wdata_d1;
logic [`PPL_NBITS-1:0]   ecdsa_lh_ppl_wdata_d1;

logic irl_lh_valid_d1;
logic [`DATA_PATH_RANGE] irl_lh_hdr_data_d1;
irl_lh_meta_type   irl_lh_meta_data_d1;
logic irl_lh_sop_d1;
logic irl_lh_eop_d1;

wire in_type3 = irl_lh_meta_data_d1.type3;
wire in_type1 = irl_lh_meta_data_d1.type1;
wire set_type3 = irl_lh_valid_d1&irl_lh_sop_d1&in_type3;
wire set_type1 = irl_lh_valid_d1&irl_lh_sop_d1&in_type1&~in_type3;
wire set_type2 = irl_lh_valid_d1&irl_lh_sop_d1&~in_type1&~in_type3;
logic type1;
logic type3;

wire lat_fifo_wr = irl_lh_valid_d1&(set_type3|type3);

wire in_fifo_wr = irl_lh_valid_d1&~(set_type3|type3);

logic lh_valid;
logic [`LOGIC_HASH_NBITS-1:0] lh_data;

wire serial_num_rd = set_type1; 
logic serial_num_ack;
logic serial_num_ack_d1;
wire [`FID_NBITS-1:0] serial_num_raddr = irl_lh_meta_data_d1.fid;
logic [`SERIAL_NUM_NBITS-1:0]   serial_num_rdata /* synthesis DONT_TOUCH */;
logic [`SERIAL_NUM_NBITS-1:0]   serial_num_rdata_d1;
logic [`PPL_NBITS-1:0]   ppl_rdata /* synthesis DONT_TOUCH */;
logic [`PPL_NBITS-1:0]   ppl_rdata_d1;

wire [`SERIAL_NUM_NBITS-1:0] pkt_serial_num = irl_lh_hdr_data_d1[`SERIAL_NUM_POS:`SERIAL_NUM_POS-`SERIAL_NUM_NBITS+1];
logic [`SERIAL_NUM_NBITS-1:0] pkt_serial_num_d1;
logic [`SERIAL_NUM_NBITS-1:0] pkt_serial_num_d2;

wire serial_num_compare = pkt_serial_num_d2==serial_num_rdata_d1;

logic sc_fifo_empty;
wire sc_fifo_wr = serial_num_ack_d1;
logic sc_fifo_data;

wire logic_hash_rd = set_type1|set_type2; 
logic logic_hash_ack;
wire [`FID_NBITS-1:0] logic_hash_raddr = irl_lh_meta_data_d1.fid;
logic [`LOGIC_HASH_NBITS-1:0]   logic_hash_rdata /* synthesis DONT_TOUCH */;

logic [`LOGIC_HASH_NBITS-1:0]   lh_gen_fifo_data;
logic lh_gen_fifo_empty;

logic [`LOGIC_HASH_NBITS-1:0]   lh_fifo_data;
logic lh_fifo_empty;

logic in_fifo_type1;

logic sel_st;
logic n_sel_st;

wire sel_type12 = sel_st==SEL_TYPE12;

wire logic_hash_compare = lh_gen_fifo_empty|lh_fifo_empty|(lh_gen_fifo_data==lh_fifo_data);

logic [`DATA_PATH_NBITS-1:0] lat_fifo_data;
logic lat_fifo_sop;
logic lat_fifo_eop;
irl_lh_meta_type  lat_fifo_meta_data;

logic lat_fifo_empty;
wire lat_fifo_rd = ~sel_type12&~lat_fifo_empty;
wire lat_fifo_rd_last = lat_fifo_rd&lat_fifo_eop;

logic in_fifo_empty;
logic [`DATA_PATH_NBITS-1:0] in_fifo_data;
logic in_fifo_sop;
logic in_fifo_eop;
irl_lh_meta_type  in_fifo_meta_data;

wire set_type1_st = ~in_fifo_empty&in_fifo_sop&logic_hash_compare&in_fifo_type1&~sc_fifo_empty&~sc_fifo_data;
logic type1_st;
wire sel_type1 = set_type1_st|type1_st;

wire set_type1to2_st = ~in_fifo_empty&in_fifo_sop&logic_hash_compare&in_fifo_type1&~sc_fifo_empty&sc_fifo_data;
logic type1to2_st;

wire sel_type1to2 = set_type1to2_st|type1to2_st;

wire set_type2_st = ~in_fifo_empty&in_fifo_sop&logic_hash_compare&~in_fifo_type1;
logic type2_st;
wire sel_type2 = set_type2_st|type2_st;

wire set_discard_st = ~in_fifo_empty&in_fifo_sop&~logic_hash_compare;
logic discard_st;
wire sel_discard = set_discard_st|discard_st;

wire sel_pp = sel_type1to2|sel_type2|sel_discard;

logic in_fifo_rd_en;
wire in_fifo_rd_type1 = sel_type1&~in_fifo_empty&in_fifo_rd_en;
wire in_fifo_rd_type12 = sel_type12&sel_type1&~sel_type1to2&~in_fifo_empty&in_fifo_rd_en;
wire in_fifo_rd_type2 = sel_type12&sel_type2&~in_fifo_empty&in_fifo_rd_en;
wire in_fifo_rd_discard = sel_type12&sel_discard&~in_fifo_empty&in_fifo_rd_en;
wire in_fifo_rd = in_fifo_rd_type1|in_fifo_rd_type12|in_fifo_rd_type2|in_fifo_rd_discard;
wire in_fifo_rd_1st = in_fifo_rd&in_fifo_sop;
wire in_fifo_rd_last = in_fifo_rd&in_fifo_eop;
wire in_fifo_rd_type1_1st = in_fifo_rd_type1&in_fifo_sop;
wire in_fifo_rd_type1_last = in_fifo_rd_type1&in_fifo_eop;
wire in_fifo_rd_type12_1st = in_fifo_rd_type12&in_fifo_sop;
wire in_fifo_rd_type12_last = in_fifo_rd_type12&in_fifo_eop;
wire in_fifo_rd_type2_1st = in_fifo_rd_type2&in_fifo_sop;
wire in_fifo_rd_type2_last = in_fifo_rd_type2&in_fifo_eop;
wire in_fifo_rd_discard_1st = in_fifo_rd_discard&in_fifo_sop;
wire in_fifo_rd_discard_last = in_fifo_rd_discard&in_fifo_eop;
wire in_fifo_rd_pp = in_fifo_rd_type12|in_fifo_rd_type2|in_fifo_rd_discard;
wire in_fifo_rd_pp_last = in_fifo_rd_type12_last|in_fifo_rd_type2_last|in_fifo_rd_discard_last;

wire lh_gen_fifo_rd = in_fifo_rd_1st;
wire lh_fifo_rd = lh_gen_fifo_rd;
wire sc_fifo_rd = in_fifo_rd_type1_1st|in_fifo_rd_type12_1st|in_fifo_rd_discard_1st&in_fifo_type1;

irl_lh_meta_type  min_fifo_meta_data;
assign min_fifo_meta_data.traffic_class = in_fifo_meta_data.traffic_class;
assign min_fifo_meta_data.hdr_len = in_fifo_meta_data.hdr_len;
assign min_fifo_meta_data.buf_ptr = in_fifo_meta_data.buf_ptr;
assign min_fifo_meta_data.len = in_fifo_meta_data.len;
assign min_fifo_meta_data.port = in_fifo_meta_data.port;
assign min_fifo_meta_data.rci = in_fifo_meta_data.rci;
assign min_fifo_meta_data.fid = in_fifo_meta_data.fid;
assign min_fifo_meta_data.tid = in_fifo_meta_data.tid;
assign min_fifo_meta_data.type1 = in_fifo_meta_data.type1&~sel_type1to2;
assign min_fifo_meta_data.type3 = in_fifo_meta_data.type3|sel_discard;
assign min_fifo_meta_data.discard = in_fifo_meta_data.discard|sel_discard;

logic [9:0] data_cnt;

wire disable_out = (sel_type1to2&data_cnt<6|sel_discard|sel_type2&in_fifo_sop)&~in_fifo_eop;

logic [127-16:0] data_sv;
logic in_fifo_sop_d1;
logic in_fifo_eop_d1;

wire sel_ntype2 = sel_type1|sel_type1to2|sel_discard;
wire min_fifo_rd = ~disable_out&in_fifo_rd_pp|in_fifo_eop_d1;
wire min_fifo_sop = sel_type1to2?data_cnt==6:sel_discard?in_fifo_eop:sel_type2?in_fifo_sop_d1:in_fifo_sop&~in_fifo_eop_d1;
wire min_fifo_eop = sel_ntype2?in_fifo_eop:in_fifo_eop_d1;
wire [`DATA_PATH_RANGE] min_fifo_data = sel_ntype2?in_fifo_data:{data_sv, in_fifo_data[127:127-15]};

wire logic_hash_wr = ecdsa_lh_wr_d1;
wire [`FID_NBITS-1:0] logic_hash_waddr = ecdsa_lh_waddr_d1;
wire [`LOGIC_HASH_NBITS-1:0] logic_hash_wdata = ecdsa_lh_wdata_d1;

wire wpending_fifo_rd = ecdsa_lh_wr_d1;

/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

	lh_ecdsa_hash_data <= lh_gen_fifo_data;

	lh_pp_hdr_data <= lat_fifo_rd?lat_fifo_data:min_fifo_data;
	lh_pp_meta_data.hdr_len <= lat_fifo_rd?lat_fifo_meta_data.hdr_len:min_fifo_meta_data.hdr_len;
	lh_pp_meta_data.buf_ptr <= lat_fifo_rd?lat_fifo_meta_data.buf_ptr:min_fifo_meta_data.buf_ptr;
	lh_pp_meta_data.len <= lat_fifo_rd?lat_fifo_meta_data.len:min_fifo_meta_data.len;
	lh_pp_meta_data.port <= lat_fifo_rd?lat_fifo_meta_data.port:min_fifo_meta_data.port;
	lh_pp_meta_data.rci <= lat_fifo_rd?lat_fifo_meta_data.rci:min_fifo_meta_data.rci;
	lh_pp_meta_data.fid <= lat_fifo_rd?lat_fifo_meta_data.fid:min_fifo_meta_data.fid;
	lh_pp_meta_data.tid <= lat_fifo_rd?lat_fifo_meta_data.tid:min_fifo_meta_data.tid;
	lh_pp_meta_data.type1 <= lat_fifo_rd?lat_fifo_meta_data.type1:min_fifo_meta_data.type1;
	lh_pp_meta_data.type3 <= lat_fifo_rd?lat_fifo_meta_data.type3:min_fifo_meta_data.type3;
	lh_pp_meta_data.discard <= lat_fifo_rd?lat_fifo_meta_data.discard:min_fifo_meta_data.discard;
	lh_pp_sop <= lat_fifo_rd?lat_fifo_sop:min_fifo_sop;
	lh_pp_eop <= lat_fifo_rd?lat_fifo_eop:min_fifo_eop;

	lh_ecdsa_hdr_data <= in_fifo_data;
	lh_ecdsa_meta_data.traffic_class <= in_fifo_meta_data.traffic_class;
	lh_ecdsa_meta_data.hdr_len <= in_fifo_meta_data.hdr_len;
	lh_ecdsa_meta_data.buf_ptr <= in_fifo_meta_data.buf_ptr;
	lh_ecdsa_meta_data.len <= in_fifo_meta_data.len;
	lh_ecdsa_meta_data.port <= in_fifo_meta_data.port;
	lh_ecdsa_meta_data.rci <= in_fifo_meta_data.rci;
	lh_ecdsa_meta_data.fid <= in_fifo_meta_data.fid;
	lh_ecdsa_meta_data.tid <= in_fifo_meta_data.tid;
	lh_ecdsa_meta_data.type1 <= in_fifo_meta_data.type1;
	lh_ecdsa_meta_data.type3 <= in_fifo_meta_data.type3;
	lh_ecdsa_meta_data.discard <= in_fifo_meta_data.discard;
	lh_ecdsa_sop <= in_fifo_sop;
	lh_ecdsa_eop <= in_fifo_eop;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		lh_ecdsa_hash_valid <= 1'b0;
		lh_ecdsa_valid <= 1'b0;
		lh_pp_valid <= 1'b0;
    end else begin

		lh_ecdsa_hash_valid <= lh_gen_fifo_rd;
		lh_ecdsa_valid <= in_fifo_rd_type1;
		lh_pp_valid <= min_fifo_rd|lat_fifo_rd;
    end

/***************************** PROGRAM BODY **********************************/

always @(*) begin
	n_sel_st = sel_st;
	case (sel_st)
		SEL_TYPE3:
			if (lat_fifo_empty&sel_pp) n_sel_st = SEL_TYPE12;
			else if (lat_fifo_rd_last&sel_pp) n_sel_st = SEL_TYPE12;
		SEL_TYPE12:
			if (in_fifo_empty) n_sel_st = SEL_TYPE3;
			else if (in_fifo_rd_pp_last&~lat_fifo_empty) n_sel_st = SEL_TYPE3;
	endcase
end

always @(posedge clk) begin
        
		irl_lh_hdr_data_d1 <= irl_lh_hdr_data;
		irl_lh_meta_data_d1 <= irl_lh_meta_data;
		irl_lh_sop_d1 <= irl_lh_sop;
		irl_lh_eop_d1 <= irl_lh_eop;

		ecdsa_lh_waddr_d1 <= ecdsa_lh_waddr;
		ecdsa_lh_wdata_d1 <= ecdsa_lh_wdata;
		ecdsa_lh_sn_wdata_d1 <= ecdsa_lh_sn_wdata;
		ecdsa_lh_ppl_wdata_d1 <= ecdsa_lh_ppl_wdata;

                serial_num_rdata_d1 <= serial_num_rdata;
                ppl_rdata_d1 <= ppl_rdata;

		pkt_serial_num_d1 <= pkt_serial_num;
		pkt_serial_num_d2 <= pkt_serial_num_d1;

		data_sv <= in_fifo_rd?in_fifo_data[127-16:0]:data_sv;
		in_fifo_sop_d1 <= in_fifo_rd?in_fifo_sop:in_fifo_sop_d1;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		init_wr <= 1'b1;
		init_addr <= 0;

		ecdsa_lh_wr_d1 <= 1'b0;

		irl_lh_valid_d1 <= 1'b0;

		serial_num_ack <= 1'b0;
		serial_num_ack_d1 <= 1'b0;

		in_fifo_rd_en <= 1'b0;

		type1 <= 1'b0;
		type3 <= 1'b0;
		logic_hash_ack <= 1'b0;

		discard_st <= 1'b0;
		type1to2_st <= 1'b0;
		type1_st <= 1'b0;
		type2_st <= 1'b0;

		data_cnt <= 0;

		sel_st <= SEL_TYPE12;

		in_fifo_eop_d1 <= 1'b0;

    end else begin

		init_wr <= ~init_addr[`FID_NBITS];
		init_addr <= ~init_addr[`FID_NBITS]?init_addr+1:(1<<`FID_NBITS);

		ecdsa_lh_wr_d1 <= ecdsa_lh_wr;

		irl_lh_valid_d1 <= irl_lh_valid;

		serial_num_ack <= serial_num_rd;
		serial_num_ack_d1 <= serial_num_ack;

		in_fifo_rd_en <= in_fifo_rd_last?1'b0:lh_valid?1'b1:in_fifo_rd_en;

		type1 <= irl_lh_valid_d1&irl_lh_eop_d1?1'b0:set_type1?1'b1:type1; 
		type3 <= irl_lh_valid_d1&irl_lh_eop_d1?1'b0:set_type3?1'b1:type3; 
		logic_hash_ack <= logic_hash_rd;

		discard_st <= set_discard_st?1'b1:in_fifo_rd_type12_last?1'b0:discard_st;
		type1to2_st <= set_type1to2_st?1'b1:in_fifo_rd_type12_last?1'b0:type1to2_st;
		type1_st <= set_type1_st?1'b1:in_fifo_rd_type1_last?1'b0:type1_st;
		type2_st <= set_type2_st?1'b1:in_fifo_rd_type2_last?1'b0:type2_st;

		data_cnt <= in_fifo_rd_last?0:~in_fifo_rd?data_cnt:data_cnt+1;

		sel_st <= n_sel_st;

		in_fifo_eop_d1 <= sel_type2&in_fifo_rd&in_fifo_eop;
    end


ram_1r1w_ultra #(`LOGIC_HASH_NBITS, `FID_NBITS) u_ram_1r1w_ultra_0(
		.clk(clk),
		.wr(logic_hash_wr|init_wr),
		.raddr(logic_hash_raddr),
		.waddr(init_wr?init_addr[`FID_NBITS-1:0]:logic_hash_waddr),
		.din(init_wr?{(`LOGIC_HASH_NBITS){1'b0}}:logic_hash_wdata),

		.dout(logic_hash_rdata)
);

ram_1r1w_ultra #(`PPL_NBITS+`SERIAL_NUM_NBITS, `FID_NBITS) u_ram_1r1w_ultra_1(
		.clk(clk),
		.wr(ecdsa_lh_wr_d1|init_wr),
		.raddr(serial_num_raddr),
		.waddr(init_wr?init_addr[`FID_NBITS-1:0]:ecdsa_lh_waddr_d1),
		.din(init_wr?{(`PPL_NBITS+`SERIAL_NUM_NBITS){1'b0}}:{ecdsa_lh_ppl_wdata_d1, ecdsa_lh_sn_wdata_d1}),

		.dout({ppl_rdata, serial_num_rdata})
);


logic_hash_gen u_logic_hash_gen(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),
		.irl_lh_valid(irl_lh_valid),
		.irl_lh_hdr_data(irl_lh_hdr_data),
		.irl_lh_meta_data(irl_lh_meta_data),
		.irl_lh_sop(irl_lh_sop),
		.irl_lh_eop(irl_lh_eop),

		.lh_valid(lh_valid),
		.lh_data(lh_data)
);

sfifo2f_bram_pf #(1+`DATA_PATH_NBITS+2, 6) u_sfifo2f_bram_pf_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({(set_type1|type1), irl_lh_hdr_data_d1, irl_lh_sop_d1, irl_lh_eop_d1}),               
        .rd(in_fifo_rd),
        .wr(in_fifo_wr),

        .count(),
        .full(),
        .empty(in_fifo_empty),
        .dout({in_fifo_type1, in_fifo_data, in_fifo_sop, in_fifo_eop})               
    );

sfifo_irl_lh #(6) u_sfifo_irl_lh_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(irl_lh_meta_data_d1),               
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

sfifo2f_bram_pf #(`DATA_PATH_NBITS+2, 6) u_sfifo2f_bram_pf_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({irl_lh_hdr_data_d1, irl_lh_sop_d1, irl_lh_eop_d1}),               
        .rd(lat_fifo_rd),
        .wr(lat_fifo_wr),

        .count(),
        .full(),
        .empty(lat_fifo_empty),
        .dout({lat_fifo_data, lat_fifo_sop, lat_fifo_eop})               
    );

sfifo_irl_lh #(6) u_sfifo_irl_lh_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(irl_lh_meta_data_d1),               
        .rd(lat_fifo_rd),
        .wr(lat_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(lat_fifo_meta_data)               
    );

sfifo2f1 #(`LOGIC_HASH_NBITS) u_sfifo2f1_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({logic_hash_rdata}),               
        .rd(lh_fifo_rd),
        .wr(logic_hash_ack),

        .count(),
        .full(),
        .empty(lh_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({lh_fifo_data})               
);

sfifo2f1 #(`LOGIC_HASH_NBITS) u_sfifo2f1_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({lh_data}),               
        .rd(lh_gen_fifo_rd),
        .wr(lh_valid),

        .count(),
        .full(),
        .empty(lh_gen_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({lh_gen_fifo_data})               
);

sfifo2f1 #(1) u_sfifo2f1_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({serial_num_compare}),               
        .rd(sc_fifo_rd),
        .wr(sc_fifo_wr),

        .count(),
        .full(),
        .empty(sc_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({sc_fifo_data})               
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

