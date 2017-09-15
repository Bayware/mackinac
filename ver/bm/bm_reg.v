//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module bm_reg (


input clk, 
input `RESET_SIG, 

input clk_div, 

input         reg_bs,
input         reg_rd,
input         reg_wr,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,

output reg    pio_ack,
output reg    pio_rvalid,
output reg [`PIO_RANGE] pio_rdata,

input   	  freeb_init_done,

input         inc_freeb_rd_count,
input         inc_freeb_wr_count,

input         inc_ll_rd_count,
input         inc_ll_wr_count,

output        reg freeb_init,
output reg [3:0]  dt_alpha

);

/***************************** LOCAL VARIABLES *******************************/
reg reg_rd_d1;

reg n_pio_ack;
reg n_pio_rvalid;

reg [`BUF_PTR_RANGE] freeb_rd_count;
reg [`BUF_PTR_RANGE] freeb_wr_count;
reg [`BUF_PTR_RANGE] ll_rd_count;
reg [`BUF_PTR_RANGE] ll_wr_count;

reg sel_freeb_init;
reg sel_freeb_rd_count;
reg sel_freeb_wr_count;
reg sel_ll_rd_count;
reg sel_ll_wr_count;
reg sel_dt_alpha;

wire wr_freeb_init = reg_wr&reg_bs&sel_freeb_init;
wire wr_dt_alpha = reg_wr&reg_bs&sel_dt_alpha;

wire rd_en = reg_rd|reg_rd_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_rvalid = 1'b0;
	sel_freeb_init = 1'b0;
	sel_freeb_rd_count = 1'b0;
	sel_freeb_wr_count = 1'b0;
	sel_ll_rd_count = 1'b0;
	sel_ll_wr_count = 1'b0;
	sel_dt_alpha = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};

	case(reg_addr[`BM_REG_ADDR_RANGE])
		`BM_FREEB_INIT: begin
			n_pio_rvalid = 1'b1;
			sel_freeb_init = 1'b1;
			pio_rdata = {freeb_init_done, 30'b0, freeb_init};
		end
		`BM_FREEB_RD_COUNT: begin
			n_pio_rvalid = 1'b1;
			sel_freeb_rd_count = 1'b1;
			pio_rdata = {{(`PIO_NBITS-`BUF_PTR_NBITS){1'b0}}, freeb_rd_count};
		end
		`BM_FREEB_WR_COUNT: begin
			n_pio_rvalid = 1'b1;
			sel_freeb_wr_count = 1'b1;
			pio_rdata = {{(`PIO_NBITS-`BUF_PTR_NBITS){1'b0}}, freeb_wr_count};
		end
		`BM_LL_RD_COUNT: begin
			n_pio_rvalid = 1'b1;
			sel_ll_rd_count = 1'b1;
			pio_rdata = {{(`PIO_NBITS-`BUF_PTR_NBITS){1'b0}}, ll_rd_count};
		end
		`BM_LL_WR_COUNT: begin
			n_pio_rvalid = 1'b1;
			sel_ll_wr_count = 1'b1;
			pio_rdata = {{(`PIO_NBITS-`BUF_PTR_NBITS){1'b0}}, ll_wr_count};
		end
		`BM_DT_ALPHA: begin
			n_pio_rvalid = 1'b1;
			sel_dt_alpha = 1'b1;
			pio_rdata = {{(`PIO_NBITS-4){1'b0}}, dt_alpha};
		end
	endcase
end

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		pio_ack <= 1'b0;
		pio_rvalid <= 1'b0;

		freeb_init <= 1'b0;
		dt_alpha <= 4'b0;
	end else begin
		pio_ack <= clk_div?n_pio_ack&~rd_en:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid&reg_bs&rd_en&n_pio_ack:pio_rvalid;

		freeb_init <= wr_freeb_init?reg_din[0]:freeb_init;
		dt_alpha <= wr_dt_alpha?reg_din[3:0]:dt_alpha;
	end
end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		freeb_rd_count <= {(`BUF_PTR_NBITS){1'b0}};
		freeb_wr_count <= {(`BUF_PTR_NBITS){1'b0}};
		ll_rd_count <= {(`BUF_PTR_NBITS){1'b0}};
		ll_wr_count <= {(`BUF_PTR_NBITS){1'b0}};
		n_pio_ack <= 1'b0;
		reg_rd_d1 <= 1'b0;
	end else begin
		freeb_rd_count <= freeb_rd_count+inc_freeb_rd_count;
		freeb_wr_count <= freeb_wr_count+inc_freeb_wr_count;
		ll_rd_count <= ll_rd_count+inc_ll_rd_count;
		ll_wr_count <= ll_wr_count+inc_ll_wr_count;
		n_pio_ack <= (reg_rd|reg_wr)&reg_bs?1'b1:clk_div?1'b0:n_pio_ack;
		reg_rd_d1 <= reg_rd?reg_bs:pio_rvalid?1'b0:reg_rd_d1;
	end
end

endmodule

