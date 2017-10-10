//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pu_tag_lookup_mem #(
parameter DEPTH_NBITS = `TAG_HASH_TABLE_DEPTH_NBITS,
parameter BUCKET_NBITS = `TAG_HASH_BUCKET_NBITS,
parameter VALUE_NBITS = `TAG_VALUE_NBITS,
parameter VALUE_DEPTH_NBITS = `TAG_VALUE_DEPTH_NBITS
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_tag_hash_table,
input reg_ms_tag_value,

output reg tag_hash_table_mem_ack,
output reg [`PIO_RANGE] tag_hash_table_mem_rdata,

output tag_value_mem_ack,
output [`PIO_RANGE] tag_value_mem_rdata,

input tag_hash_table0_rd, 
input [DEPTH_NBITS-1:0] tag_hash_table0_raddr,

input tag_hash_table1_rd, 
input [DEPTH_NBITS-1:0] tag_hash_table1_raddr,

input tag_value_rd, 
input [VALUE_DEPTH_NBITS-1:0] tag_value_raddr,

output tag_hash_table0_ack, 
output [BUCKET_NBITS-1:0] tag_hash_table0_rdata,

output tag_hash_table1_ack, 
output [BUCKET_NBITS-1:0] tag_hash_table1_rdata,

output tag_value_ack, 
output [VALUE_NBITS-1:0] tag_value_rdata

);

/***************************** LOCAL VARIABLES *******************************/

wire tag_hash_table0_mem_ack;
wire [`PIO_RANGE] tag_hash_table0_mem_rdata;

wire tag_hash_table1_mem_ack;
wire [`PIO_RANGE] tag_hash_table1_mem_rdata;

wire reg_ms_tag_hash_table0 = reg_ms_tag_hash_table&~reg_addr[DEPTH_NBITS];
wire reg_ms_tag_hash_table1 = reg_ms_tag_hash_table&reg_addr[DEPTH_NBITS];

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	tag_hash_table_mem_ack = reg_addr[DEPTH_NBITS]?tag_hash_table0_mem_ack:tag_hash_table1_mem_ack;
	tag_hash_table_mem_rdata = reg_addr[DEPTH_NBITS]?tag_hash_table0_mem_rdata:tag_hash_table1_mem_rdata;
end
	
/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/


pio_wmem_bram #(BUCKET_NBITS, DEPTH_NBITS) u_pio_wmem_bram0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tag_hash_table0),

		.app_mem_rd(tag_hash_table0_rd),
		.app_mem_raddr(tag_hash_table0_raddr),

        	.mem_ack(tag_hash_table0_mem_ack),
        	.mem_rdata(tag_hash_table0_mem_rdata),

		.app_mem_ack(tag_hash_table0_ack),
		.app_mem_rdata(tag_hash_table0_rdata)
);

pio_wmem_bram #(BUCKET_NBITS, DEPTH_NBITS) u_pio_wmem_bram1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tag_hash_table1),

		.app_mem_rd(tag_hash_table1_rd),
		.app_mem_raddr(tag_hash_table1_raddr),

        	.mem_ack(tag_hash_table1_mem_ack),
        	.mem_rdata(tag_hash_table1_mem_rdata),

		.app_mem_ack(tag_hash_table1_ack),
		.app_mem_rdata(tag_hash_table1_rdata)
);

pio_wmem_bram #(VALUE_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tag_value),

		.app_mem_rd(tag_value_rd),
		.app_mem_raddr(tag_value_raddr),

        	.mem_ack(tag_value_mem_ack),
        	.mem_rdata(tag_value_mem_rdata),

		.app_mem_ack(tag_value_ack),
		.app_mem_rdata(tag_value_rdata)
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

