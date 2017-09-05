//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module decap_mem #(
parameter QUEUE_NBITS = `FIRST_LVL_QUEUE_ID_NBITS;
parameter SCH_NBITS = `FIRST_LVL_SCH_ID_NBITS;
parameter QUEUE_PROFILE_NBITS = `FIRST_LVL_QUEUE_PROFILE_NBITS;
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_rci_hash_table0,
input reg_ms_rci_hash_table1,
input reg_ms_rci_value0,
input reg_ms_rci_value1,
input reg_ms_rci_value2,
input reg_ms_rci_value3,
input reg_ms_rci_value4,
input reg_ms_key_hash_table0,
input reg_ms_key_hash_table1,
input reg_ms_key_value0,
input reg_ms_key_value1,
input reg_ms_key_value2,
input reg_ms_key_value3,
input reg_ms_key_value4,

input rci_hash_table0_rd, 
input [QUEUE_NBITS-1:0] rci_hash_table0_raddr,

input rci_hash_table1_rd, 
input [QUEUE_NBITS-1:0] rci_hash_table1_raddr,

input rci_value0_rd, 
input [QUEUE_NBITS-1:0] rci_value0_raddr,

input rci_value1_rd, 
input [QUEUE_NBITS-1:0] rci_value1_raddr,

input rci_value2_rd, 
input [QUEUE_NBITS-1:0] rci_value2_raddr,

input rci_value3_rd, 
input [QUEUE_NBITS-1:0] rci_value3_raddr,

input rci_value4_rd, 
input [QUEUE_NBITS-1:0] rci_value4_raddr,

input key_hash_table0_rd, 
input [QUEUE_NBITS-1:0] key_hash_table0_raddr,

input key_hash_table1_rd, 
input [SCH_NBITS-1:0] key_hash_table1_raddr,

input key_value0_rd, 
input [QUEUE_NBITS-1:0] key_value0_raddr,

input key_value1_rd, 
input [QUEUE_NBITS-1:0] key_value1_raddr,

input key_value2_rd, 
input [QUEUE_NBITS-1:0] key_value2_raddr,

input key_value3_rd, 
input [QUEUE_NBITS-1:0] key_value3_raddr,

input key_value4_rd, 
input [QUEUE_NBITS-1:0] key_value4_raddr,

output rci_hash_table0_mem_ack,
output [`PIO_RANGE] rci_hash_table0_mem_rdata[7:0],

output rci_hash_table1_mem_ack,
output [`PIO_RANGE] rci_hash_table1_mem_rdata[7:0],

output rci_value0_mem_ack,
output [`PIO_RANGE] rci_value0_mem_rdata[7:0],

output rci_value1_mem_ack,
output [`PIO_RANGE] rci_value1_mem_rdata[7:0],

output rci_value2_mem_ack,
output [`PIO_RANGE] rci_value2_mem_rdata[7:0],

output rci_value3_mem_ack,
output [`PIO_RANGE] rci_value3_mem_rdata[7:0],

output rci_value4_mem_ack,
output [`PIO_RANGE] rci_value4_mem_rdata[7:0],

output key_hash_table0_mem_ack,
output [`PIO_RANGE] key_hash_table0_mem_rdata[7:0],

output key_hash_table1_mem_ack,
output [`PIO_RANGE] key_hash_table1_mem_rdata[7:0],

output key_value0_mem_ack,
output [`PIO_RANGE] key_value0_mem_rdata[7:0],

output key_hash_table1_mem_ack,
output [`WDRR_N_NBITS-1:0] key_hash_table1_mem_rdata  /* synthesis keep = 1 */,

output rci_hash_table0_ack, 
output [QUEUE_PROFILE_NBITS-1:0] rci_hash_table0_rdata  /* synthesis keep = 1 */,

output rci_hash_table1_ack, 
output [`WDRR_QUANTUM_NBITS-1:0] rci_hash_table1_rdata  /* synthesis keep = 1 */,

output rci_value0_ack, 
output [`SHAPING_PROFILE_NBITS-1:0] rci_value0_rdata  /* synthesis keep = 1 */,

output rci_value1_ack, 
output [`SHAPING_PROFILE_NBITS-1:0] rci_value1_rdata  /* synthesis keep = 1 */,

output rci_value2_ack, 
output [`SHAPING_PROFILE_NBITS-1:0] rci_value2_rdata  /* synthesis keep = 1 */,

output rci_value3_ack, 
output [`SHAPING_PROFILE_NBITS-1:0] rci_value3_rdata  /* synthesis keep = 1 */,

output rci_value4_ack, 
output [`SHAPING_PROFILE_NBITS-1:0] rci_value4_rdata  /* synthesis keep = 1 */,

output key_hash_table0_ack, 
output [`SHAPING_PROFILE_NBITS-1:0] key_hash_table0_rdata  /* synthesis keep = 1 */,

output key_hash_table1_ack, 
output [`WDRR_N_NBITS-1:0] key_hash_table1_rdata  /* synthesis keep = 1 */,

output key_value0_ack, 
output [`PORT_ID_NBITS-1:0] key_value0_rdata  /* synthesis keep = 1 */,

output key_value1_ack, 
output [`PORT_ID_NBITS-1:0] key_value1_rdata  /* synthesis keep = 1 */,

output key_value2_ack, 
output [`PORT_ID_NBITS-1:0] key_value2_rdata  /* synthesis keep = 1 */,

output key_value3_ack, 
output [`PORT_ID_NBITS-1:0] key_value3_rdata  /* synthesis keep = 1 */,

output key_value4_ack, 
output [`PORT_ID_NBITS-1:0] key_value4_rdata  /* synthesis keep = 1 */

);

/***************************** LOCAL VARIABLES *******************************/


/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

pio_mem #(QUEUE_PROFILE_NBITS, QUEUE_NBITS) u_pio_mem0(
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

pio_mem #(`WDRR_QUANTUM_NBITS, QUEUE_NBITS) u_pio_mem1(
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

pio_wmem #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_wmem0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value0),

		.app_mem_rd(rci_value0_rd),
		.app_mem_raddr(rci_value0_raddr),

        	.mem_ack(rci_value0_mem_ack),
        	.mem_rdata(rci_value0_mem_rdata),

		.app_mem_ack(rci_value0_ack),
		.app_mem_rdata(rci_value0_rdata)
);

pio_wmem #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_wmem1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value1),

		.app_mem_rd(rci_value1_rd),
		.app_mem_raddr(rci_value1_raddr),

        	.mem_ack(rci_value1_mem_ack),
        	.mem_rdata(rci_value1_mem_rdata),

		.app_mem_ack(rci_value1_ack),
		.app_mem_rdata(rci_value1_rdata)
);

pio_wmem #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_wmem2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value2),

		.app_mem_rd(rci_value2_rd),
		.app_mem_raddr(rci_value2_raddr),

        	.mem_ack(rci_value2_mem_ack),
        	.mem_rdata(rci_value2_mem_rdata),

		.app_mem_ack(rci_value2_ack),
		.app_mem_rdata(rci_value2_rdata)
);

pio_wmem #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_wmem3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value3),

		.app_mem_rd(rci_value3_rd),
		.app_mem_raddr(rci_value3_raddr),

        	.mem_ack(rci_value3_mem_ack),
        	.mem_rdata(rci_value3_mem_rdata),

		.app_mem_ack(rci_value3_ack),
		.app_mem_rdata(rci_value3_rdata)
);

pio_mem #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_mem2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_rci_value4),

		.app_mem_rd(rci_value4_rd),
		.app_mem_raddr(rci_value4_raddr),

        	.mem_ack(rci_value4_mem_ack),
        	.mem_rdata(rci_value4_mem_rdata),

		.app_mem_ack(rci_value4_ack),
		.app_mem_rdata(rci_value4_rdata)
);

pio_mem #(`SHAPING_PROFILE_NBITS, QUEUE_NBITS) u_pio_mem3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_hash_table0),

		.app_mem_rd(key_hash_table0_rd),
		.app_mem_raddr(key_hash_table0_raddr),

        	.mem_ack(key_hash_table0_mem_ack),
        	.mem_rdata(key_hash_table0_mem_rdata),

		.app_mem_ack(key_hash_table0_ack),
		.app_mem_rdata(key_hash_table0_rdata)
);

pio_mem #(`WDRR_N_NBITS, SCH_NBITS) u_pio_mem4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_hash_table1),

		.app_mem_rd(key_hash_table1_rd),
		.app_mem_raddr(key_hash_table1_raddr),

        	.mem_ack(key_hash_table1_mem_ack),
        	.mem_rdata(key_hash_table1_mem_rdata),

		.app_mem_ack(key_hash_table1_ack),
		.app_mem_rdata(key_hash_table1_rdata)
);

pio_wmem #(`PORT_ID_NBITS, QUEUE_NBITS) u_pio_wmem4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_value0),

		.app_mem_rd(key_value0_rd),
		.app_mem_raddr(key_value0_raddr),

        	.mem_ack(key_value0_mem_ack),
        	.mem_rdata(key_value0_mem_rdata),

		.app_mem_ack(key_value0_ack),
		.app_mem_rdata(key_value0_rdata)
);

pio_wmem #(`PORT_ID_NBITS, QUEUE_NBITS) u_pio_wmem5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_value1),

		.app_mem_rd(key_value1_rd),
		.app_mem_raddr(key_value1_raddr),

        	.mem_ack(key_value1_mem_ack),
        	.mem_rdata(key_value1_mem_rdata),

		.app_mem_ack(key_value1_ack),
		.app_mem_rdata(key_value1_rdata)
);

pio_wmem #(`PORT_ID_NBITS, QUEUE_NBITS) u_pio_wmem6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_value2),

		.app_mem_rd(key_value2_rd),
		.app_mem_raddr(key_value2_raddr),

        	.mem_ack(key_value2_mem_ack),
        	.mem_rdata(key_value2_mem_rdata),

		.app_mem_ack(key_value2_ack),
		.app_mem_rdata(key_value2_rdata)
);

pio_wmem #(`PORT_ID_NBITS, QUEUE_NBITS) u_pio_wmem7(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_value3),

		.app_mem_rd(key_value3_rd),
		.app_mem_raddr(key_value3_raddr),

        	.mem_ack(key_value3_mem_ack),
        	.mem_rdata(key_value3_mem_rdata),

		.app_mem_ack(key_value3_ack),
		.app_mem_rdata(key_value3_rdata)
);

pio_mem #(`PORT_ID_NBITS, QUEUE_NBITS) u_pio_mem5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_key_value4),

		.app_mem_rd(key_value4_rd),
		.app_mem_raddr(key_value4_raddr),

        	.mem_ack(key_value4_mem_ack),
        	.mem_rdata(key_value4_mem_rdata),

		.app_mem_ack(key_value4_ack),
		.app_mem_rdata(key_value4_rdata)
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

