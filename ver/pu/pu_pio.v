//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pu_pio(


input clk, 
input `RESET_SIG, 

input clk_div,

input         reg_bs,
input         reg_wr,
input         reg_rd,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,

input conn_context_mem_ack,
input [`PIO_RANGE] conn_context_mem_rdata,

input switch_info_mem_ack,
input [`PIO_RANGE] switch_info_mem_rdata,

input tag_hash_table_mem_ack,
input [`PIO_RANGE] tag_hash_table_mem_rdata,

input tag_value_mem_ack,
input [`PIO_RANGE] tag_value_mem_rdata,

input pu_registers_mem_ack,
input [`PIO_RANGE] pu_registers_mem_rdata,

output reg reg_ms_conn_context,
output reg reg_ms_switch_info,
output reg reg_ms_tag_hash_table,
output reg reg_ms_tag_value,
output reg reg_ms_pu_registers,

output reg    pio_ack,
output reg    pio_rvalid,
output reg [`PIO_RANGE] pio_rdata

);

/***************************** LOCAL VARIABLES *******************************/
reg reg_rd_d1;

reg n_pio_ack, n_pio_rvalid;

reg n_none_selected_ack;
reg none_selected_ack;

wire rd_en = reg_rd|reg_rd_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_ack = 1'b0;
	n_pio_rvalid = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};
	reg_ms_conn_context = 1'b0;
	reg_ms_switch_info = 1'b0;
	reg_ms_tag_hash_table = 1'b0;
	reg_ms_tag_value = 1'b0;

	case(reg_addr[`PU_MEM_ADDR_RANGE])
            `PU_CONNECTION_CONTEXT: begin
		n_pio_ack = conn_context_mem_ack;
		n_pio_rvalid = reg_bs;
		pio_rdata = conn_context_mem_rdata;
		reg_ms_conn_context = reg_bs;
	    end
            `PU_SWITCH_INFO: begin
		n_pio_ack = switch_info_mem_ack;
		n_pio_rvalid = reg_bs;
		pio_rdata = switch_info_mem_rdata;
		reg_ms_switch_info = reg_bs;
	    end
            `PU_TAG_HASH_TABLE: begin
		n_pio_ack = tag_hash_table_mem_ack;
		n_pio_rvalid = reg_bs;
		pio_rdata = tag_hash_table_mem_rdata;
		reg_ms_tag_hash_table = reg_bs;
	    end
            `PU_TAG_VALUE: begin
		n_pio_ack = tag_value_mem_ack;
		n_pio_rvalid = reg_bs;
		pio_rdata = tag_value_mem_rdata;
		reg_ms_tag_value = reg_bs;
	    end
            `PU_REGISTERS: begin
		n_pio_ack = pu_registers_mem_ack;
		n_pio_rvalid = reg_bs;
		pio_rdata = pu_registers_mem_rdata;
		reg_ms_tag_value = reg_bs;
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
		pio_ack <= clk_div?n_pio_ack&~rd_en:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid&reg_bs&rd_en&n_pio_ack:pio_rvalid;
		n_none_selected_ack <= (reg_rd|reg_wr)&reg_bs?1'b1:clk_div?1'b0:n_none_selected_ack;
		none_selected_ack <= clk_div?n_none_selected_ack:none_selected_ack;
	end
end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) 
	if(`ACTIVE_RESET) begin
		reg_rd_d1 <= 1'b0;
	end else begin
		reg_rd_d1 <= reg_rd?reg_bs:pio_rvalid?1'b0:reg_rd_d1;
	end


endmodule

