/*
 * Path Parser
 */

`include "defines.vh"

import meta_package::*;

module pp
  (
   input      clk,
   input      `RESET_SIG,

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

   input     pu_pp_buf_fifo_rd,
   input [`PIARB_INST_BUF_FIFO_DEPTH_NBITS:0] pu_pp_inst_buf_fifo_count,

   output     pp_ecdsa_ready,

   output reg pp_pu_hop_valid,
   output reg [`HOP_INFO_RANGE] pp_pu_hop_data,
   output reg pp_pu_hop_sop,
   output reg pp_pu_hop_eop,
   output pp_piarb_meta_type pp_pu_meta_data,
   output reg [`CHUNK_LEN_NBITS-1:0] pp_pu_pp_loc,
   
   output  pp_pu_valid,
   output  pp_pu_sop,
   output  pp_pu_eop,
   output  [`DATA_PATH_RANGE] pp_pu_data,
   output  [`DATA_PATH_VB_RANGE] pp_pu_valid_bytes,
   output [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_loc,
   output [`CHUNK_LEN_NBITS-1:0] pp_pu_pd_len,
   output  pp_pu_inst_pd

   );

localparam FIFO_DEPTH_NBITS   = 4;
localparam BUF_FIFO_DEPTH_NBITS   = `PIARB_BUF_FIFO_DEPTH_NBITS;
localparam INST_BUF_FIFO_DEPTH_NBITS   = `PIARB_INST_BUF_FIFO_DEPTH_NBITS;

reg [BUF_FIFO_DEPTH_NBITS:0] buf_fifo_count;
reg [INST_BUF_FIFO_DEPTH_NBITS:0] inst_buf_fifo_count;


reg [1:0] pp_id1;
reg      pp_valid1;
reg [`DATA_PATH_RANGE] pp_data1;
reg pp_eop1;
reg [`CHUNK_LEN_NBITS-1:0] pp_len1;
reg      pp_meta_valid1;
reg [`PP_META_RCI_RANGE] pp_meta_rci1;

reg [1:0] pp_id2;
reg      pp_valid2;
reg [`DATA_PATH_RANGE] pp_data2;
reg pp_eop2;
reg [`CHUNK_LEN_NBITS-1:0] pp_len2;
reg      pp_meta_valid2;
reg [`PP_META_RCI_RANGE] pp_meta_rci2;

reg [1:0] pp_id3;
reg      pp_valid3;
reg [`DATA_PATH_RANGE] pp_data3;
reg pp_eop3;
reg [`CHUNK_LEN_NBITS-1:0] pp_len3;
reg      pp_meta_valid3;
reg [`PP_META_RCI_RANGE] pp_meta_rci3;


reg pp_meta_fifo_rd;

reg pp_meta_valid;

reg pp_valid0;
reg [`DATA_PATH_RANGE] pp_data0;
reg pp_eop0;
reg [`CHUNK_LEN_NBITS-1:0] pp_len0;
reg pp_meta_valid0;
reg [`PP_META_RCI_RANGE] pp_meta_rci0;
pp_meta_type pp_meta_data;
reg [31:0] pp_creation_time;
reg [`CHUNK_LEN_NBITS-1:0] pp_loc;

reg     p_pp_pu_hop_error;
reg     pp_pu_hop_error;

pp_piarb_meta_type pp_pu_meta_data_p1;

wire [1:0] pp_id0;

wire pp_valid0_p1;
wire [`DATA_PATH_RANGE] pp_data0_p1;
wire pp_sop0_p1;
wire pp_eop0_p1;
reg [`CHUNK_LEN_NBITS-1:0] pp_len0_p1;
wire pp_meta_valid0_p1;
wire [`PP_META_RCI_RANGE] pp_meta_rci0_p1;
pp_meta_type pp_meta_data_p1;
wire [31:0] pp_creation_time_p1;
wire [`CHUNK_LEN_NBITS-1:0] pp_loc_p1;


wire en_arb = pp_valid0_p1&pp_sop0_p1;

wire [1:0] fifo_pp_id;
wire     pu_pp_hop_ready0 = (fifo_pp_id==2'b00);
wire     pu_pp_hop_ready1 = (fifo_pp_id==2'b01);
wire     pu_pp_hop_ready2 = (fifo_pp_id==2'b10);
wire     pu_pp_hop_ready3 = (fifo_pp_id==2'b11);

wire     path_parser_ready0;
wire     path_parser_ready1;
wire     path_parser_ready2;
wire     path_parser_ready3;

wire     pp_pu_hop_valid0;
wire [`HOP_INFO_RANGE] pp_pu_hop_data0;
wire     pp_pu_hop_sop0;
wire     pp_pu_hop_eop0;
wire     pp_pu_hop_error0;

wire     pp_pu_hop_valid1;
wire [`HOP_INFO_RANGE] pp_pu_hop_data1;
wire     pp_pu_hop_sop1;
wire     pp_pu_hop_eop1;
wire     pp_pu_hop_error1;

wire     pp_pu_hop_valid2;
wire [`HOP_INFO_RANGE] pp_pu_hop_data2;
wire     pp_pu_hop_sop2;
wire     pp_pu_hop_eop2;
wire     pp_pu_hop_error2;

wire     pp_pu_hop_valid3;
wire [`HOP_INFO_RANGE] pp_pu_hop_data3;
wire     pp_pu_hop_sop3;
wire     pp_pu_hop_eop3;
wire     pp_pu_hop_error3;

wire pp_meta_fifo_empty;
pp_meta_type pp_meta_fifo_data;
wire [31:0] pp_meta_fifo_creation_time;
wire [`CHUNK_LEN_NBITS-1:0] pp_meta_fifo_pp_loc;

wire out_discard = pp_meta_fifo_data.discard;
wire out_type3 = pp_meta_fifo_data.type3;

wire no_pp = out_type3|out_discard;

assign pp_pu_meta_data_p1.domain_id = pp_meta_fifo_data.domain_id;
assign pp_pu_meta_data_p1.hdr_len = pp_meta_fifo_data.hdr_len;
assign pp_pu_meta_data_p1.buf_ptr = pp_meta_fifo_data.buf_ptr;
assign pp_pu_meta_data_p1.len = pp_meta_fifo_data.len;
assign pp_pu_meta_data_p1.port = pp_meta_fifo_data.port;
assign pp_pu_meta_data_p1.rci = pp_meta_fifo_data.rci;
assign pp_pu_meta_data_p1.fid_sel = pp_meta_fifo_data.fid_sel;
assign pp_pu_meta_data_p1.fid = pp_meta_fifo_data.fid;
assign pp_pu_meta_data_p1.tid = pp_meta_fifo_data.tid;
assign pp_pu_meta_data_p1.type1 = pp_meta_fifo_data.type1&~p_pp_pu_hop_error;
assign pp_pu_meta_data_p1.type3 = pp_meta_fifo_data.type3|p_pp_pu_hop_error;
assign pp_pu_meta_data_p1.creation_time = pp_meta_fifo_creation_time;
assign pp_pu_meta_data_p1.discard = out_discard|p_pp_pu_hop_error;

/**************************************************************************/

always @* 
  if (no_pp) 
	    p_pp_pu_hop_error = 1'b0;
  else 
    case (fifo_pp_id)
	2'b00: begin
	    p_pp_pu_hop_error = pp_pu_hop_error0;
	end
	2'b01: begin
	    p_pp_pu_hop_error = pp_pu_hop_error1;
	end
	2'b10: begin
	    p_pp_pu_hop_error = pp_pu_hop_error2;
	end
	default: begin
	    p_pp_pu_hop_error = pp_pu_hop_error3;
	end
    endcase

always @(posedge clk) begin
  pp_pu_meta_data <= pp_pu_meta_data_p1;
  pp_pu_pp_loc <= pp_meta_fifo_pp_loc;
  pp_pu_hop_error <= p_pp_pu_hop_error;
  if (no_pp) begin
	    pp_pu_hop_sop <= 1'b1;
	    pp_pu_hop_eop <= 1'b1;
	    pp_pu_hop_data <= pp_pu_hop_data0;
  end else begin
    case (fifo_pp_id)
	2'b00: begin
	    pp_pu_hop_sop <= pp_pu_hop_sop0;
	    pp_pu_hop_eop <= pp_pu_hop_eop0;
	    pp_pu_hop_data <= pp_pu_hop_data0;
	end
	2'b01: begin
	    pp_pu_hop_sop <= pp_pu_hop_sop1;
	    pp_pu_hop_eop <= pp_pu_hop_eop1;
	    pp_pu_hop_data <= pp_pu_hop_data1;
	end
	2'b10: begin
	    pp_pu_hop_sop <= pp_pu_hop_sop2;
	    pp_pu_hop_eop <= pp_pu_hop_eop2;
	    pp_pu_hop_data <= pp_pu_hop_data2;
	end
	default: begin
	    pp_pu_hop_sop <= pp_pu_hop_sop3;
	    pp_pu_hop_eop <= pp_pu_hop_eop3;
	    pp_pu_hop_data <= pp_pu_hop_data3;
	end
    endcase
  end
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	pp_pu_hop_valid <= 1'b0;
	pp_meta_fifo_rd <= 1'b0;
    end else begin
	  if (no_pp) begin
		    pp_pu_hop_valid <= ~pp_meta_fifo_empty&~pp_meta_fifo_rd;
	    	    pp_meta_fifo_rd <= ~pp_meta_fifo_empty&~pp_meta_fifo_rd;
	  end else begin
	    case (fifo_pp_id)
		2'd0: begin
		    pp_pu_hop_valid <= pp_pu_hop_valid0;
	    	    pp_meta_fifo_rd <= pp_pu_hop_valid0&pp_pu_hop_eop0;
		end
		2'd1: begin
		    pp_pu_hop_valid <= pp_pu_hop_valid1;
	    	    pp_meta_fifo_rd <= pp_pu_hop_valid1&pp_pu_hop_eop1;
		end
		2'd2: begin
		    pp_pu_hop_valid <= pp_pu_hop_valid2;
	    	    pp_meta_fifo_rd <= pp_pu_hop_valid2&pp_pu_hop_eop2;
		end
		default: begin
		    pp_pu_hop_valid <= pp_pu_hop_valid3;
	    	    pp_meta_fifo_rd <= pp_pu_hop_valid3&pp_pu_hop_eop3;
		end
	    endcase
	  end
    end

/**************************************************************************/
always @(posedge clk) begin

    pp_data0 <= pp_data0_p1;
    pp_eop0 <= pp_eop0_p1;
    pp_len0 <= pp_len0_p1;
    pp_meta_rci0 <= pp_meta_rci0_p1;

    pp_meta_data <= pp_meta_data_p1;
    pp_creation_time <= pp_creation_time_p1;
    pp_loc <= pp_loc_p1;

    pp_id1 <= pp_id0;
    pp_valid1 <= pp_valid0;
    pp_data1 <= pp_data0;
    pp_eop1 <= pp_eop0;
    pp_len1 <= pp_len0;
    pp_meta_valid1 <= pp_meta_valid0;
    pp_meta_rci1 <= pp_meta_rci0;

    pp_id2 <= pp_id1;
    pp_valid2 <= pp_valid1;
    pp_data2 <= pp_data1;
    pp_eop2 <= pp_eop1;
    pp_len2 <= pp_len1;
    pp_meta_valid2 <= pp_meta_valid1;
    pp_meta_rci2 <= pp_meta_rci1;

    pp_id3 <= pp_id2;
    pp_valid3 <= pp_valid2;
    pp_data3 <= pp_data2;
    pp_eop3 <= pp_eop2;
    pp_len3 <= pp_len2;
    pp_meta_valid3 <= pp_meta_valid2;
    pp_meta_rci3 <= pp_meta_rci2;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	pp_valid0 <= 1'b0;
	pp_meta_valid <= 1'b0;
	pp_meta_valid0 <= 1'b0;
    end else begin
	pp_valid0 <= pp_valid0_p1;
	pp_meta_valid <= pp_meta_valid0_p1;
	pp_meta_valid0 <= pp_meta_valid0_p1&~pp_meta_data_p1.type3;
    end

/**************************************************************************/

sfifo2f_fo #(2+32+`CHUNK_LEN_NBITS, FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({pp_id0, pp_creation_time, pp_loc}),              
        .rd(pp_meta_fifo_rd),
        .wr(pp_meta_valid),

        .ncount(),
        .count(),
        .full(),
        .empty(pp_meta_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({fifo_pp_id, pp_meta_fifo_creation_time, pp_meta_fifo_pp_loc})       
    );

sfifo_pp_meta #(FIFO_DEPTH_NBITS) u_sfifo_pp_meta_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(pp_meta_data),              
        .rd(pp_meta_fifo_rd),
        .wr(pp_meta_valid),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout(pp_meta_fifo_data)       
    );

rr_arb4 u_rr_arb4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),
	.req({path_parser_ready3, path_parser_ready2, path_parser_ready1, path_parser_ready0}),
	.en(en_arb),
	.sel(pp_id0)
);

pp_front_end u_pp_front_end(

        .ecdsa_pp_valid(ecdsa_pp_valid),
        .ecdsa_pp_sop(ecdsa_pp_sop),
        .ecdsa_pp_eop(ecdsa_pp_eop),
        .ecdsa_pp_data(ecdsa_pp_data),
        .ecdsa_pp_meta_data(ecdsa_pp_meta_data),
        .ecdsa_pp_auth_len(ecdsa_pp_auth_len),

        .lh_pp_valid(lh_pp_valid),
        .lh_pp_sop(lh_pp_sop),
        .lh_pp_eop(lh_pp_eop),
        .lh_pp_hdr_data(lh_pp_hdr_data),
        .lh_pp_meta_data(lh_pp_meta_data),

        .pp_pu_hop_valid(pp_pu_hop_valid),
        .pp_pu_hop_sop(pp_pu_hop_sop),
        .pp_pu_hop_eop(pp_pu_hop_eop),
        .pp_pu_hop_error(pp_pu_hop_error),
        .pp_pu_hop_type3(pp_pu_meta_data.type3),

        .pu_pp_buf_fifo_rd(pu_pp_buf_fifo_rd),
        .pu_pp_inst_buf_fifo_count(pu_pp_inst_buf_fifo_count),


        .pp_ecdsa_ready(pp_ecdsa_ready),

        .pp_valid0(pp_valid0_p1),
        .pp_data0(pp_data0_p1),
        .pp_sop0(pp_sop0_p1),
        .pp_eop0(pp_eop0_p1),
        .pp_len0(pp_len0_p1),
        .pp_meta_valid0(pp_meta_valid0_p1),
        .pp_meta_rci0(pp_meta_rci0_p1),
        .pp_meta_data(pp_meta_data_p1),
        .pp_creation_time(pp_creation_time_p1),
        .pp_loc(pp_loc_p1),

        .pp_pu_valid(pp_pu_valid),
        .pp_pu_sop(pp_pu_sop),
        .pp_pu_eop(pp_pu_eop),
        .pp_pu_data(pp_pu_data),
        .pp_pu_valid_bytes(pp_pu_valid_bytes),
        .pp_pu_pd_loc(pp_pu_pd_loc),
        .pp_pu_pd_len(pp_pu_pd_len),
        .pp_pu_inst_pd(pp_pu_inst_pd),

        .clk(clk),
        .`RESET_SIG(`RESET_SIG)

);

pp_top #(0) u_pp_top_0(
    pp_valid0,
    pp_data0,
    pp_eop0,
    pp_len0,
    pp_id0,

    pp_meta_valid0,
    pp_meta_rci0,

    pu_pp_hop_ready0,

    path_parser_ready0,

    pp_pu_hop_valid0,
    pp_pu_hop_data0,
    pp_pu_hop_sop0,
    pp_pu_hop_eop0,
    pp_pu_hop_error0,

    clk,
    `RESET_SIG
    );
   
pp_top #(1) u_pp_top_1(
    pp_valid1,
    pp_data1,
    pp_eop1,
    pp_len1,
    pp_id1,

    pp_meta_valid1,
    pp_meta_rci1,

    pu_pp_hop_ready1,

    path_parser_ready1,

    pp_pu_hop_valid1,
    pp_pu_hop_data1,
    pp_pu_hop_sop1,
    pp_pu_hop_eop1,
    pp_pu_hop_error1,

    clk,
    `RESET_SIG
    );
   
pp_top #(2) u_pp_top_2(
    pp_valid2,
    pp_data2,
    pp_eop2,
    pp_len2,
    pp_id2,

    pp_meta_valid2,
    pp_meta_rci2,

    pu_pp_hop_ready2,

    path_parser_ready2,

    pp_pu_hop_valid2,
    pp_pu_hop_data2,
    pp_pu_hop_sop2,
    pp_pu_hop_eop2,
    pp_pu_hop_error2,

    clk,
    `RESET_SIG
    );
   
pp_top #(3) u_pp_top_3(
    pp_valid3,
    pp_data3,
    pp_eop3,
    pp_len3,
    pp_id3,

    pp_meta_valid3,
    pp_meta_rci3,

    pu_pp_hop_ready3,

    path_parser_ready3,

    pp_pu_hop_valid3,
    pp_pu_hop_data3,
    pp_pu_hop_sop3,
    pp_pu_hop_eop3,
    pp_pu_hop_error3,

    clk,
    `RESET_SIG
    );
   

endmodule 
