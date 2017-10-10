//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module decap_mem_rci #(
parameter DEPTH_NBITS = `RCI_HASH_TABLE_DEPTH_NBITS,
parameter BUCKET_NBITS = `RCI_HASH_BUCKET_NBITS,
parameter VALUE_NBITS = `RCI_VALUE_NBITS,
parameter VALUE_DEPTH_NBITS = `RCI_VALUE_DEPTH_NBITS,
parameter WM_NBITS = 64
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_rci_hash_table,
input reg_ms_rci_value,

output reg rci_hash_table_mem_ack,
output reg [`PIO_RANGE] rci_hash_table_mem_rdata,

output reg rci_value_mem_ack,
output reg [`PIO_RANGE] rci_value_mem_rdata,

input rci_hash_table0_rd, 
input [DEPTH_NBITS-1:0] rci_hash_table0_raddr,

input rci_hash_table1_rd, 
input [DEPTH_NBITS-1:0] rci_hash_table1_raddr,

input rci_value_rd, 
input [VALUE_DEPTH_NBITS-1:0] rci_value_raddr,

output rci_hash_table0_ack, 
output [BUCKET_NBITS-1:0] rci_hash_table0_rdata,

output rci_hash_table1_ack, 
output [BUCKET_NBITS-1:0] rci_hash_table1_rdata,

output rci_value_ack, 
output [VALUE_NBITS-1:0] rci_value_rdata

);

/***************************** LOCAL VARIABLES *******************************/

wire rci_hash_table0_mem_ack;
wire [`PIO_RANGE] rci_hash_table0_mem_rdata;

wire rci_hash_table1_mem_ack;
wire [`PIO_RANGE] rci_hash_table1_mem_rdata;

wire rci_value0_mem_ack;
wire [`PIO_RANGE] rci_value0_mem_rdata;

wire rci_value1_mem_ack;
wire [`PIO_RANGE] rci_value1_mem_rdata;

wire rci_value2_mem_ack;
wire [`PIO_RANGE] rci_value2_mem_rdata;

wire rci_value3_mem_ack;
wire [`PIO_RANGE] rci_value3_mem_rdata;

wire rci_value4_mem_ack;
wire [`PIO_RANGE] rci_value4_mem_rdata;

wire [`PIO_ADDR_MSB-2:0] reg_addr_dw = reg_addr[`PIO_ADDR_MSB:2];

wire reg_ms_rci_hash_table0 = reg_ms_rci_hash_table&~reg_addr_dw[DEPTH_NBITS];
wire reg_ms_rci_hash_table1 = reg_ms_rci_hash_table&reg_addr_dw[DEPTH_NBITS];

wire [`PIO_ADDR_MSB-3:0] reg_addr_qw = reg_addr[`PIO_ADDR_MSB:3];

wire reg_ms_rci_value0 = reg_ms_rci_value&reg_addr_qw[2:0]==0;
wire reg_ms_rci_value1 = reg_ms_rci_value&reg_addr_qw[2:0]==1;
wire reg_ms_rci_value2 = reg_ms_rci_value&reg_addr_qw[2:0]==2;
wire reg_ms_rci_value3 = reg_ms_rci_value&reg_addr_qw[2:0]==3;
wire reg_ms_rci_value4 = reg_ms_rci_value&reg_addr_qw[2:0]==4;

wire [`PIO_RANGE] rci_value_reg_addr = {reg_addr[`PIO_ADDR_MSB:0+6], reg_addr[2:0]};
wire [`PIO_RANGE] rci_value_reg_addr1 = {reg_addr[`PIO_ADDR_MSB:0+6], reg_addr[1:0]};

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	rci_hash_table_mem_ack = ~reg_addr_dw[DEPTH_NBITS]?rci_hash_table0_mem_ack:rci_hash_table1_mem_ack;
	rci_hash_table_mem_rdata = ~reg_addr_dw[DEPTH_NBITS]?rci_hash_table0_mem_rdata:rci_hash_table1_mem_rdata;
	case (reg_addr_qw[2:0])
		3'h0: begin
			rci_value_mem_ack = rci_value0_mem_ack;
			rci_value_mem_rdata = rci_value0_mem_rdata;
		end
		3'h1: begin
			rci_value_mem_ack = rci_value1_mem_ack;
			rci_value_mem_rdata = rci_value1_mem_rdata;
		end
		3'h2: begin
			rci_value_mem_ack = rci_value2_mem_ack;
			rci_value_mem_rdata = rci_value2_mem_rdata;
		end
		3'h3: begin
			rci_value_mem_ack = rci_value3_mem_ack;
			rci_value_mem_rdata = rci_value3_mem_rdata;
		end
		default: begin
			rci_value_mem_ack = rci_value4_mem_ack;
			rci_value_mem_rdata = rci_value4_mem_rdata;
		end
	endcase
end
	
/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

pio_mem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_mem0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_hash_table0),

		.app_mem_rd(rci_hash_table0_rd),
		.app_mem_raddr(rci_hash_table0_raddr),

        	.mem_ack(rci_hash_table0_mem_ack),
        	.mem_rdata(rci_hash_table0_mem_rdata),

		.app_mem_ack(rci_hash_table0_ack),
		.app_mem_rdata(rci_hash_table0_rdata)
);

pio_mem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_mem1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_hash_table1),

		.app_mem_rd(rci_hash_table1_rd),
		.app_mem_raddr(rci_hash_table1_raddr),

        	.mem_ack(rci_hash_table1_mem_ack),
        	.mem_rdata(rci_hash_table1_mem_rdata),

		.app_mem_ack(rci_hash_table1_ack),
		.app_mem_rdata(rci_hash_table1_rdata)
);

pio_wmem #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(rci_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value0),

		.app_mem_rd(rci_value_rd),
		.app_mem_raddr(rci_value_raddr),

        	.mem_ack(rci_value0_mem_ack),
        	.mem_rdata(rci_value0_mem_rdata),

		.app_mem_ack(rci_value_ack),
		.app_mem_rdata(rci_value_rdata[WM_NBITS*1-1:WM_NBITS*0])
);

pio_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(rci_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value1),

		.app_mem_rd(rci_value_rd),
		.app_mem_raddr(rci_value_raddr),

        	.mem_ack(rci_value1_mem_ack),
        	.mem_rdata(rci_value1_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(rci_value_rdata[WM_NBITS*2-1:WM_NBITS*1])
);

pio_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(rci_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value2),

		.app_mem_rd(rci_value_rd),
		.app_mem_raddr(rci_value_raddr),

        	.mem_ack(rci_value2_mem_ack),
        	.mem_rdata(rci_value2_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(rci_value_rdata[WM_NBITS*3-1:WM_NBITS*2])
);

pio_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(rci_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value3),

		.app_mem_rd(rci_value_rd),
		.app_mem_raddr(rci_value_raddr),

        	.mem_ack(rci_value3_mem_ack),
        	.mem_rdata(rci_value3_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(rci_value_rdata[WM_NBITS*4-1:WM_NBITS*3])
);

pio_mem #(VALUE_NBITS-4*WM_NBITS, VALUE_DEPTH_NBITS) u_pio_mem20(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(rci_value_reg_addr1),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value4),

		.app_mem_rd(rci_value_rd),
		.app_mem_raddr(rci_value_raddr),

        	.mem_ack(rci_value4_mem_ack),
        	.mem_rdata(rci_value4_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(rci_value_rdata[VALUE_NBITS-1:WM_NBITS*4])
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

