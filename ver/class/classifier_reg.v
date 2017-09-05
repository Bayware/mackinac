//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module classifier_reg (


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

output reg [`AGING_TIME_NBITS-1:0]  aging_time

);

/***************************** LOCAL VARIABLES *******************************/

reg n_pio_ack;
reg n_pio_rvalid;

reg sel_aging_time;

wire wr_aging_time = reg_wr&reg_bs&sel_aging_time;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_rvalid = 1'b0;
	sel_aging_time = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};

	case(reg_addr[`CLASSIFIER_REG_ADDR_RANGE])
		`CLASSIFIER_AGING_TIME: begin
			n_pio_rvalid = 1'b1;
			sel_aging_time = 1'b1;
			pio_rdata = {{(`PIO_NBITS-`AGING_TIME_NBITS){1'b0}}, aging_time};
		end
	endcase
end

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		pio_ack <= 1'b0;
		pio_rvalid <= 1'b0;

		aging_time <= {(`AGING_TIME_NBITS){1'b0}};
	end else begin
		pio_ack <= clk_div?n_pio_ack:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid:pio_rvalid;

		aging_time <= wr_aging_time?reg_din[`AGING_TIME_NBITS-1:0]:aging_time;
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

