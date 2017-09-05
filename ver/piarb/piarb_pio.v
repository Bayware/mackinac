//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module piarb_pio(


input clk, 
input `RESET_SIG, 

input clk_div,

input         reg_bs,
input         reg_wr,
input         reg_rd,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,

input topic_value_mem_ack,
input [`PIO_RANGE] topic_value_mem_rdata,

output reg reg_ms_topic_value,

output reg    pio_ack,
output reg    pio_rvalid,
output reg [`PIO_RANGE] pio_rdata

);

/***************************** LOCAL VARIABLES *******************************/
reg n_pio_ack, n_pio_rvalid;

reg n_none_selected_ack;
reg none_selected_ack;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_ack = 1'b0;
	n_pio_rvalid = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};
	reg_ms_topic_value = 1'b0;

	case(reg_addr[`PIARB_MEM_ADDR_RANGE])
            `PIARB_TOPIC_VALUE: begin
		n_pio_ack = topic_value_mem_ack;
		n_pio_rvalid = 1'b1;
		pio_rdata = topic_value_mem_rdata;
		reg_ms_topic_value = 1'b1;
	    end
            default: begin
		n_pio_ack = none_selected_ack;
	    end

	endcase
end

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		pio_ack <= 1'b0;
		pio_rvalid <= 1'b0;
		n_none_selected_ack <= 1'b0;
		none_selected_ack <= 1'b0;
	end else begin
		pio_ack <= clk_div?n_pio_ack:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid:pio_rvalid;
		n_none_selected_ack <= (reg_rd|reg_wr)?1'b1:clk_div?1'b0:n_none_selected_ack;
		none_selected_ack <= clk_div?n_none_selected_ack:none_selected_ack;
	end
end

/***************************** PROGRAM BODY **********************************/


endmodule

