//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module asa_reg (


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

output reg [`SUB_EXP_TIME_NBITS-1:0]  default_sub_exp_time,
output reg [`SCI_NBITS-1:0]  supervisor_sci,
output reg [15:0]  class2pri

);

/***************************** LOCAL VARIABLES *******************************/

reg n_pio_ack;
reg n_pio_rvalid;

reg sel_default_sub_exp_time;
reg sel_supervisor_sci;
reg sel_class2pri;

wire wr_default_sub_exp_time = reg_wr&reg_bs&sel_default_sub_exp_time;
wire wr_supervisor_sci = reg_wr&reg_bs&sel_supervisor_sci;
wire wr_class2pri = reg_wr&reg_bs&sel_class2pri;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_rvalid = 1'b0;
	sel_default_sub_exp_time = 1'b0;
	sel_supervisor_sci = 1'b0;
	sel_class2pri = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};

	case(reg_addr[`ASA_REG_ADDR_RANGE])
		`ASA_DEFAULT_SUB_EXP_TIME: begin
			n_pio_rvalid = 1'b1;
			sel_default_sub_exp_time = 1'b1;
			pio_rdata = {default_sub_exp_time};
		end
		`ASA_SUPERVISOR_SCI: begin
			n_pio_rvalid = 1'b1;
			sel_supervisor_sci = 1'b1;
			pio_rdata = {{(`PIO_NBITS-`BUF_PTR_NBITS){1'b0}}, supervisor_sci};
		end
		`ASA_CLASS2PRI: begin
			n_pio_rvalid = 1'b1;
			sel_class2pri = 1'b1;
			pio_rdata = {{(`PIO_NBITS-4){1'b0}}, class2pri};
		end
	endcase
end

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		pio_ack <= 1'b0;
		pio_rvalid <= 1'b0;

		default_sub_exp_time <= 15'b0;
		supervisor_sci <= {(`SCI_NBITS){1'b0}};
		class2pri <= 15'b0;
	end else begin
		pio_ack <= clk_div?n_pio_ack:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid:pio_rvalid;

		default_sub_exp_time <= wr_default_sub_exp_time?reg_din[15:0]:default_sub_exp_time;
		supervisor_sci <= wr_supervisor_sci?reg_din[`SCI_NBITS-1:0]:supervisor_sci;
		class2pri <= wr_class2pri?reg_din[15:0]:class2pri;
	end
end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		n_pio_ack <= 1'b0;
	end else begin
		n_pio_ack <= (reg_rd|reg_wr)?1'b1:clk_div?1'b0:n_pio_ack;
	end
end

endmodule

