//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap_mem_ekey #(
parameter DEPTH_NBITS = `EEKEY_HASH_TABLE_DEPTH_NBITS,
parameter BUCKET_NBITS = `EEKEY_HASH_BUCKET_NBITS,
parameter VALUE_NBITS = `EEKEY_VALUE_NBITS,
parameter VALUE_DEPTH_NBITS = `EEKEY_VALUE_DEPTH_NBITS,
parameter WM_NBITS = 64
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_ekey_hash_table,
input reg_ms_ekey_value,

output reg ekey_hash_table_mem_ack,
output reg [`PIO_RANGE] ekey_hash_table_mem_rdata,

output reg ekey_value_mem_ack,
output reg [`PIO_RANGE] ekey_value_mem_rdata,

input ekey_hash_table0_rd, 
input [DEPTH_NBITS-1:0] ekey_hash_table0_raddr,

input ekey_hash_table1_rd, 
input [DEPTH_NBITS-1:0] ekey_hash_table1_raddr,

input ekey_value_rd, 
input [VALUE_DEPTH_NBITS-1:0] ekey_value_raddr,

input ekey_value_wr, 
input [VALUE_DEPTH_NBITS-1:0] ekey_value_waddr,
input [WM_NBITS-1:0] ekey_value_wdata,

output ekey_hash_table0_ack, 
output [BUCKET_NBITS-1:0] ekey_hash_table0_rdata,

output ekey_hash_table1_ack, 
output [BUCKET_NBITS-1:0] ekey_hash_table1_rdata,

output ekey_value_ack, 
output [VALUE_NBITS-1:0] ekey_value_rdata

);

/***************************** LOCAL VARIABLES *******************************/

wire ekey_hash_table0_mem_ack;
wire [`PIO_RANGE] ekey_hash_table0_mem_rdata;

wire ekey_hash_table1_mem_ack;
wire [`PIO_RANGE] ekey_hash_table1_mem_rdata;

wire ekey_value0_mem_ack;
wire [`PIO_RANGE] ekey_value0_mem_rdata;

wire ekey_value1_mem_ack;
wire [`PIO_RANGE] ekey_value1_mem_rdata;

wire ekey_value2_mem_ack;
wire [`PIO_RANGE] ekey_value2_mem_rdata;

wire ekey_value3_mem_ack;
wire [`PIO_RANGE] ekey_value3_mem_rdata;

wire ekey_value4_mem_ack;
wire [`PIO_RANGE] ekey_value4_mem_rdata;

wire [`PIO_ADDR_MSB-3:0] reg_addr_qw = reg_addr[`PIO_ADDR_MSB:3];

wire reg_ms_ekey_hash_table0 = reg_ms_ekey_hash_table&~reg_addr_qw[DEPTH_NBITS];
wire reg_ms_ekey_hash_table1 = reg_ms_ekey_hash_table&reg_addr_qw[DEPTH_NBITS];

wire reg_ms_ekey_value0 = reg_ms_ekey_value&reg_addr_qw[2:0]==0;
wire reg_ms_ekey_value1 = reg_ms_ekey_value&reg_addr_qw[2:0]==1;
wire reg_ms_ekey_value2 = reg_ms_ekey_value&reg_addr_qw[2:0]==2;
wire reg_ms_ekey_value3 = reg_ms_ekey_value&reg_addr_qw[2:0]==3;
wire reg_ms_ekey_value4 = reg_ms_ekey_value&reg_addr_qw[2:0]==4;

wire [`PIO_RANGE] ekey_value_reg_addr = {reg_addr[`PIO_ADDR_MSB:0+6], reg_addr[2:0]};

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	ekey_hash_table_mem_ack = ~reg_addr_qw[DEPTH_NBITS]?ekey_hash_table0_mem_ack:ekey_hash_table1_mem_ack;
	ekey_hash_table_mem_rdata = ~reg_addr_qw[DEPTH_NBITS]?ekey_hash_table0_mem_rdata:ekey_hash_table1_mem_rdata;
	case (reg_addr_qw[2:0])
		3'h0: begin
			ekey_value_mem_ack = ekey_value0_mem_ack;
			ekey_value_mem_rdata = ekey_value0_mem_rdata;
		end
		3'h1: begin
			ekey_value_mem_ack = ekey_value1_mem_ack;
			ekey_value_mem_rdata = ekey_value1_mem_rdata;
		end
		3'h2: begin
			ekey_value_mem_ack = ekey_value2_mem_ack;
			ekey_value_mem_rdata = ekey_value2_mem_rdata;
		end
		3'h3: begin
			ekey_value_mem_ack = ekey_value3_mem_ack;
			ekey_value_mem_rdata = ekey_value3_mem_rdata;
		end
		default: begin
			ekey_value_mem_ack = ekey_value4_mem_ack;
			ekey_value_mem_rdata = ekey_value4_mem_rdata;
		end
	endcase
end
	
/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/


pio_wmem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_wmem0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_hash_table0),

		.app_mem_rd(ekey_hash_table0_rd),
		.app_mem_raddr(ekey_hash_table0_raddr),

        	.mem_ack(ekey_hash_table0_mem_ack),
        	.mem_rdata(ekey_hash_table0_mem_rdata),

		.app_mem_ack(ekey_hash_table0_ack),
		.app_mem_rdata(ekey_hash_table0_rdata)
);

pio_wmem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_wmem1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_hash_table1),

		.app_mem_rd(ekey_hash_table1_rd),
		.app_mem_raddr(ekey_hash_table1_raddr),

        	.mem_ack(ekey_hash_table1_mem_ack),
        	.mem_rdata(ekey_hash_table1_mem_rdata),

		.app_mem_ack(ekey_hash_table1_ack),
		.app_mem_rdata(ekey_hash_table1_rdata)
);

pio_rw_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_rw_wmem_bram2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(ekey_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_value0),

		.app_mem_rd(ekey_value_rd),
		.app_mem_raddr(ekey_value_raddr),

		.app_mem_wr(ekey_value_wr),
		.app_mem_waddr(ekey_value_waddr),
		.app_mem_wdata(ekey_value_wdata),

        	.mem_ack(ekey_value0_mem_ack),
        	.mem_rdata(ekey_value0_mem_rdata),

		.app_mem_ack(ekey_value_ack),
		.app_mem_rdata(ekey_value_rdata[WM_NBITS*1-1:WM_NBITS*0])
);

pio_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(ekey_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_value1),

		.app_mem_rd(ekey_value_rd),
		.app_mem_raddr(ekey_value_raddr),

        	.mem_ack(ekey_value1_mem_ack),
        	.mem_rdata(ekey_value1_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(ekey_value_rdata[WM_NBITS*2-1:WM_NBITS*1])
);

pio_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(ekey_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_value2),

		.app_mem_rd(ekey_value_rd),
		.app_mem_raddr(ekey_value_raddr),

        	.mem_ack(ekey_value2_mem_ack),
        	.mem_rdata(ekey_value2_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(ekey_value_rdata[WM_NBITS*3-1:WM_NBITS*2])
);

pio_wmem_bram #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(ekey_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_value3),

		.app_mem_rd(ekey_value_rd),
		.app_mem_raddr(ekey_value_raddr),

        	.mem_ack(ekey_value3_mem_ack),
        	.mem_rdata(ekey_value3_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(ekey_value_rdata[WM_NBITS*4-1:WM_NBITS*3])
);

pio_wmem_bram #(VALUE_NBITS-4*WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem_bram6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(ekey_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_ekey_value4),

		.app_mem_rd(ekey_value_rd),
		.app_mem_raddr(ekey_value_raddr),

        	.mem_ack(ekey_value4_mem_ack),
        	.mem_rdata(ekey_value4_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(ekey_value_rdata[VALUE_NBITS-1:WM_NBITS*4])
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

