//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap_mem_tunnel #(
parameter DEPTH_NBITS = `TUNNEL_HASH_TABLE_DEPTH_NBITS,
parameter BUCKET_NBITS = `TUNNEL_HASH_BUCKET_NBITS,
parameter VALUE_NBITS = `TUNNEL_VALUE_NBITS,
parameter VALUE_DEPTH_NBITS = `TUNNEL_VALUE_DEPTH_NBITS,
parameter WM_NBITS = 64
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_tunnel_hash_table,
input reg_ms_tunnel_value,

output reg tunnel_hash_table_mem_ack,
output reg [`PIO_RANGE] tunnel_hash_table_mem_rdata,

output reg tunnel_value_mem_ack,
output reg [`PIO_RANGE] tunnel_value_mem_rdata,

input tunnel_hash_table0_rd, 
input [DEPTH_NBITS-1:0] tunnel_hash_table0_raddr,

input tunnel_hash_table1_rd, 
input [DEPTH_NBITS-1:0] tunnel_hash_table1_raddr,

input tunnel_value_rd, 
input [VALUE_DEPTH_NBITS-1:0] tunnel_value_raddr,

output tunnel_hash_table0_ack, 
output [BUCKET_NBITS-1:0] tunnel_hash_table0_rdata  /* synthesis keep = 1 */,

output tunnel_hash_table1_ack, 
output [BUCKET_NBITS-1:0] tunnel_hash_table1_rdata  /* synthesis keep = 1 */,

output tunnel_value_ack, 
output [VALUE_NBITS-1:0] tunnel_value_rdata  /* synthesis keep = 1 */

);

/***************************** LOCAL VARIABLES *******************************/

wire tunnel_hash_table0_mem_ack;
wire [`PIO_RANGE] tunnel_hash_table0_mem_rdata;

wire tunnel_hash_table1_mem_ack;
wire [`PIO_RANGE] tunnel_hash_table1_mem_rdata;

wire tunnel_value0_mem_ack;
wire [`PIO_RANGE] tunnel_value0_mem_rdata;

wire tunnel_value1_mem_ack;
wire [`PIO_RANGE] tunnel_value1_mem_rdata;

wire tunnel_value2_mem_ack;
wire [`PIO_RANGE] tunnel_value2_mem_rdata;

wire tunnel_value3_mem_ack;
wire [`PIO_RANGE] tunnel_value3_mem_rdata;

wire tunnel_value4_mem_ack;
wire [`PIO_RANGE] tunnel_value4_mem_rdata;

wire tunnel_value5_mem_ack;
wire [`PIO_RANGE] tunnel_value5_mem_rdata;

wire [`PIO_ADDR_MSB-2:0] reg_addr_dw = reg_addr[`PIO_ADDR_MSB:2];

wire reg_ms_tunnel_hash_table0 = reg_ms_tunnel_hash_table&~reg_addr_dw[DEPTH_NBITS];
wire reg_ms_tunnel_hash_table1 = reg_ms_tunnel_hash_table&reg_addr_dw[DEPTH_NBITS];

wire [`PIO_ADDR_MSB-3:0] reg_addr_qw = reg_addr[`PIO_ADDR_MSB:3];

wire reg_ms_tunnel_value0 = reg_ms_tunnel_value&reg_addr_qw[2:0]==0;
wire reg_ms_tunnel_value1 = reg_ms_tunnel_value&reg_addr_qw[2:0]==1;
wire reg_ms_tunnel_value2 = reg_ms_tunnel_value&reg_addr_qw[2:0]==2;
wire reg_ms_tunnel_value3 = reg_ms_tunnel_value&reg_addr_qw[2:0]==3;
wire reg_ms_tunnel_value4 = reg_ms_tunnel_value&reg_addr_qw[2:0]==4;
wire reg_ms_tunnel_value5 = reg_ms_tunnel_value&reg_addr_qw[2:0]==5;

wire [`PIO_RANGE] tunnel_value_reg_addr = {reg_addr[`PIO_ADDR_MSB:0+6], reg_addr[2:0]};

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	tunnel_hash_table_mem_ack = ~reg_addr_dw[DEPTH_NBITS]?tunnel_hash_table0_mem_ack:tunnel_hash_table1_mem_ack;
	tunnel_hash_table_mem_rdata = ~reg_addr_dw[DEPTH_NBITS]?tunnel_hash_table0_mem_rdata:tunnel_hash_table1_mem_rdata;
	case (reg_addr_qw[2:0])
		3'h0: begin
			tunnel_value_mem_ack = tunnel_value0_mem_ack;
			tunnel_value_mem_rdata = tunnel_value0_mem_rdata;
		end
		3'h1: begin
			tunnel_value_mem_ack = tunnel_value1_mem_ack;
			tunnel_value_mem_rdata = tunnel_value1_mem_rdata;
		end
		3'h2: begin
			tunnel_value_mem_ack = tunnel_value2_mem_ack;
			tunnel_value_mem_rdata = tunnel_value2_mem_rdata;
		end
		3'h3: begin
			tunnel_value_mem_ack = tunnel_value3_mem_ack;
			tunnel_value_mem_rdata = tunnel_value3_mem_rdata;
		end
		3'h4: begin
			tunnel_value_mem_ack = tunnel_value4_mem_ack;
			tunnel_value_mem_rdata = tunnel_value4_mem_rdata;
		end
		default: begin
			tunnel_value_mem_ack = tunnel_value5_mem_ack;
			tunnel_value_mem_rdata = tunnel_value5_mem_rdata;
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
        	.reg_ms(reg_ms_tunnel_hash_table0),

		.app_mem_rd(tunnel_hash_table0_rd),
		.app_mem_raddr(tunnel_hash_table0_raddr),

        	.mem_ack(tunnel_hash_table0_mem_ack),
        	.mem_rdata(tunnel_hash_table0_mem_rdata),

		.app_mem_ack(tunnel_hash_table0_ack),
		.app_mem_rdata(tunnel_hash_table0_rdata)
);

pio_mem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_mem1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_hash_table1),

		.app_mem_rd(tunnel_hash_table1_rd),
		.app_mem_raddr(tunnel_hash_table1_raddr),

        	.mem_ack(tunnel_hash_table1_mem_ack),
        	.mem_rdata(tunnel_hash_table1_mem_rdata),

		.app_mem_ack(tunnel_hash_table1_ack),
		.app_mem_rdata(tunnel_hash_table1_rdata)
);

pio_wmem #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(tunnel_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_value0),

		.app_mem_rd(tunnel_value_rd),
		.app_mem_raddr(tunnel_value_raddr),

        	.mem_ack(tunnel_value0_mem_ack),
        	.mem_rdata(tunnel_value0_mem_rdata),

		.app_mem_ack(tunnel_value_ack),
		.app_mem_rdata(tunnel_value_rdata[WM_NBITS*1-1:WM_NBITS*0])
);

pio_wmem #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(tunnel_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_value1),

		.app_mem_rd(tunnel_value_rd),
		.app_mem_raddr(tunnel_value_raddr),

        	.mem_ack(tunnel_value1_mem_ack),
        	.mem_rdata(tunnel_value1_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(tunnel_value_rdata[WM_NBITS*2-1:WM_NBITS*1])
);

pio_wmem #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(tunnel_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_value2),

		.app_mem_rd(tunnel_value_rd),
		.app_mem_raddr(tunnel_value_raddr),

        	.mem_ack(tunnel_value2_mem_ack),
        	.mem_rdata(tunnel_value2_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(tunnel_value_rdata[WM_NBITS*3-1:WM_NBITS*2])
);

pio_wmem #(WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(tunnel_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_value3),

		.app_mem_rd(tunnel_value_rd),
		.app_mem_raddr(tunnel_value_raddr),

        	.mem_ack(tunnel_value3_mem_ack),
        	.mem_rdata(tunnel_value3_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(tunnel_value_rdata[WM_NBITS*4-1:WM_NBITS*3])
);

pio_wmem #(WM_NBITS*5-4*WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(tunnel_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_value4),

		.app_mem_rd(tunnel_value_rd),
		.app_mem_raddr(tunnel_value_raddr),

        	.mem_ack(tunnel_value4_mem_ack),
        	.mem_rdata(tunnel_value4_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(tunnel_value_rdata[WM_NBITS*5-1:WM_NBITS*4])
);


pio_wmem #(VALUE_NBITS-5*WM_NBITS, VALUE_DEPTH_NBITS) u_pio_wmem7(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(tunnel_value_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_tunnel_value5),

		.app_mem_rd(tunnel_value_rd),
		.app_mem_raddr(tunnel_value_raddr),

        	.mem_ack(tunnel_value5_mem_ack),
        	.mem_rdata(tunnel_value5_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(tunnel_value_rdata[VALUE_NBITS-1:WM_NBITS*5])
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

