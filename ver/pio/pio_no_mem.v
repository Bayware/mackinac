//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pio_no_mem (

input clk, 
input `RESET_SIG, 

input clk_div, 

input reg_rd,
input reg_wr,
input reg_ms,

output reg   mem_ack,
output reg [`PIO_RANGE] mem_rdata

);
/***************************** LOCAL VARIABLES *******************************/

reg n_mem_ack;

wire ram_wr = reg_ms&reg_wr;
wire ram_rd = reg_ms&reg_rd;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/


always @(posedge clk) begin
        mem_rdata <= 0;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	mem_ack <= 0;
    end else begin
	mem_ack <= clk_div?n_mem_ack:mem_ack;
    end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		n_mem_ack <= 0;
	end else begin
		n_mem_ack <= ram_wr|ram_rd?1'b1:clk_div?1'b0:n_mem_ack;
	end

endmodule

