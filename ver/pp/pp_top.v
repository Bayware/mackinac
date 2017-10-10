/*
 * Individual Path Parser Block
 */

`include "defines.vh"

module pp_top
  (
   input      pp_valid,
   input [`DATA_PATH_RANGE] pp_data,
   input pp_eop,
   input [1:0] pp_id,

   input      pp_meta_valid,
   input [`PP_META_RCI_RANGE] pp_meta_rci,

   input      pu_pp_hop_ready,

   output     reg path_parser_ready,

   output     pp_pu_hop_valid,
   output [`HOP_INFO_RANGE] pp_pu_hop_data,
   output     pp_pu_hop_sop,
   output     pp_pu_hop_eop,
   output     pp_pu_hop_error,
   
   input      clk,
   input      `RESET_SIG
   );

parameter PP_ID   = 0;

reg rd_ptr;
reg wr_ptr;
reg pp_ready;
reg path_parser_ready0_d1;
reg path_parser_ready1_d1;
reg [`PATH_CHUNK_DEPTH_NBITS-1:0] ram_waddr;

wire [`DATA_PATH_RANGE] ram_rdata /* synthesis DONT_TOUCH */;

wire hop_fifo_full0;
wire hop_fifo_fullm10;
wire parser_done0;
wire [`DATA_PATH_RANGE] ram_rdata0;

wire path_parser_ready0;

wire ram_rd0;
wire [`PATH_CHUNK_ADDR_RANGE] ram_raddr0;

wire hop_fifo_reset0;
wire hop_fifo_wr0;
wire [`HOP_INFO_RANGE] hop_fifo_wdata0;

wire hop_fifo_full1;
wire hop_fifo_fullm11;
wire parser_done1;
wire [`DATA_PATH_RANGE] ram_rdata1;

wire path_parser_ready1;

wire ram_rd1;
wire [`PATH_CHUNK_ADDR_RANGE] ram_raddr1;

wire hop_fifo_reset1;
wire hop_fifo_wr1;
wire [`HOP_INFO_RANGE] hop_fifo_wdata1;
   
wire wen = pp_valid&(pp_id==PP_ID);
wire inc_wr_ptr = wen&pp_eop;

wire n_pp_ready = rd_ptr?path_parser_ready1:path_parser_ready0;
wire inc_rd_ptr = n_pp_ready&~pp_ready;

wire ram_rd = rd_ptr?ram_rd1:ram_rd0;
wire [`PATH_CHUNK_ADDR_RANGE] ram_raddr = rd_ptr?ram_raddr1:ram_raddr0;

/**************************************************************************/
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	path_parser_ready <= 1'b0;
    end else begin
	path_parser_ready <= rd_ptr?path_parser_ready1_d1:path_parser_ready0_d1;
    end

/**************************************************************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	wr_ptr <= 1'b0;
	rd_ptr <= 1'b0;
	ram_waddr <= {(`PATH_CHUNK_DEPTH_NBITS){1'b0}};
	path_parser_ready0_d1 <= 1'b0;
	path_parser_ready1_d1 <= 1'b0;
	pp_ready <= 1'b1;
    end else begin
	wr_ptr <= wr_ptr+inc_wr_ptr;
	rd_ptr <= rd_ptr+inc_rd_ptr;
	ram_waddr <= inc_wr_ptr?{(`PATH_CHUNK_DEPTH_NBITS){1'b0}}:ram_waddr+wen;
	path_parser_ready0_d1 <= path_parser_ready0;
	path_parser_ready1_d1 <= path_parser_ready1;
	pp_ready <= n_pp_ready;
    end

/**************************************************************************/

ram_1r1w_ultra #(`DATA_PATH_NBITS, `PATH_CHUNK_DEPTH_NBITS+1) u_ram_1r1w_ultra(
        .clk(clk),
        .wr(wen),
        .raddr(ram_raddr),
        .waddr({wr_ptr, ram_waddr}),
        .din(pp_data),
        .dout(ram_rdata));

pp_rd_ctrl #(PP_ID, 0) u_pp_rd_ctrl0(
    pp_valid,
    pp_eop,
    pp_id,

    rd_ptr,

    hop_fifo_full0,
    hop_fifo_fullm10,
    parser_done0,
    ram_rdata,

    path_parser_ready0,

    ram_rd0,
    ram_raddr0,

    hop_fifo_reset0,
    hop_fifo_wr0,
    hop_fifo_wdata0,
   
    clk,
    `RESET_SIG
   );

pp_rd_ctrl #(PP_ID, 1) u_pp_rd_ctrl1(
    pp_valid,
    pp_eop,
    pp_id,

    rd_ptr,

    hop_fifo_full1,
    hop_fifo_fullm11,
    parser_done1,
    ram_rdata,

    path_parser_ready1,

    ram_rd1,
    ram_raddr1,

    hop_fifo_reset1,
    hop_fifo_wr1,
    hop_fifo_wdata1,
   
    clk,
    `RESET_SIG
   );

wire pp_meta_valid_g = pp_meta_valid&(pp_id==PP_ID);

pp_sm u_pp_sm(
    hop_fifo_reset0,
    hop_fifo_wr0,
    hop_fifo_wdata0,
    hop_fifo_reset1,
    hop_fifo_wr1,
    hop_fifo_wdata1,

    pp_meta_valid_g,
    pp_meta_rci,

    pu_pp_hop_ready,

    hop_fifo_full0,
    hop_fifo_fullm10,
    hop_fifo_full1,
    hop_fifo_fullm11,
    parser_done0,
    parser_done1,

    pp_pu_hop_valid,
    pp_pu_hop_data,
    pp_pu_hop_sop,
    pp_pu_hop_eop,
    pp_pu_hop_error,

    clk,
    `RESET_SIG
    );
   
endmodule 
