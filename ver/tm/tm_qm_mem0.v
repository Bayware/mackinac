//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : first level queue manager memory
//===========================================================================

`include "defines.vh"

module tm_qm_mem0 (


input clk, 
input `RESET_SIG, 

input clk_div,

input reg_ms,
input reg_rd,
input reg_wr,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,

input queue_association_rd, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_association_raddr,


output mem_ack,
output [`PIO_RANGE] mem_rdata,

output queue_association_ack, 
output [`QUEUE_ASSOCIATION_NBITS-1:0] queue_association_rdata  /* synthesis keep = 1 */


);
/***************************** LOCAL VARIABLES *******************************/

/***************************** NON REGISTERED OUTPUTS ************************/



/***************************** REGISTERED OUTPUTS ****************************/



/***************************** PROGRAM BODY **********************************/

pio_mem_bram #(`QUEUE_ASSOCIATION_NBITS, `FIRST_LVL_QUEUE_ID_NBITS) u_pio_mem_bram(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

		.reg_addr(reg_addr),
		.reg_din(reg_din),
		.reg_rd(reg_rd),
		.reg_wr(reg_wr),
		.reg_ms(reg_ms),

		.app_mem_rd(queue_association_rd),
		.app_mem_raddr(queue_association_raddr),

		.mem_ack(mem_ack),
		.mem_rdata(mem_rdata),

		.app_mem_ack(queue_association_ack),
		.app_mem_rdata(queue_association_rdata)
);

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

