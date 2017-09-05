//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : scheduler data structure
//===========================================================================

`include "defines.vh"

module tm_sch_ds1 (


input clk, 

input deficit_counter_wr,			
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_waddr,
input [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_wdata,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] deficit_counter_raddr,
output [`DEFICIT_COUNTER_NBITS+`TQNA_NBITS-1:0] deficit_counter_rdata /* synthesis keep = 1 */,

input token_bucket_wr,			
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] token_bucket_waddr,
input [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_wdata,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] token_bucket_raddr,
output [`CIR_NBITS+2+`EIR_NBITS+2-1:0] token_bucket_rdata /* synthesis keep = 1 */,

input eir_tb_wr,			
input [`PORT_ID_NBITS-1:0] eir_tb_waddr,
input [`EIR_NBITS+2-1:0] eir_tb_wdata,
input [`PORT_ID_NBITS-1:0] eir_tb_raddr,
output [`EIR_NBITS+2-1:0] eir_tb_rdata /* synthesis keep = 1 */,

input event_fifo_wr,			
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_waddr,
input [`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_wdata,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_raddr,
output [`SECOND_LVL_QUEUE_ID_NBITS+2-1:0] event_fifo_rdata /* synthesis keep = 1 */,

input event_fifo_rd_ptr_wr0,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr0,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata0,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr0,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata0,

input event_fifo_rd_ptr_wr1,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr1,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata1,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr1,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata1,

input event_fifo_rd_ptr_wr2,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr2,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata2,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr2,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata2,

input event_fifo_rd_ptr_wr3,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr3,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata3,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr3,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata3,

input event_fifo_rd_ptr_wr4,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr4,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata4,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr4,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata4,

input event_fifo_rd_ptr_wr5,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr5,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata5,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr5,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata5,

input event_fifo_rd_ptr_wr6,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr6,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata6,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr6,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata6,

input event_fifo_rd_ptr_wr7,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_waddr7,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_wdata7,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_rd_ptr_raddr7,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_rd_ptr_rdata7,

input event_fifo_wr_ptr_wr0,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr0,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata0,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr0,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata0,

input event_fifo_wr_ptr_wr1,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr1,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata1,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr1,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata1,

input event_fifo_wr_ptr_wr2,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr2,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata2,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr2,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata2,

input event_fifo_wr_ptr_wr3,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr3,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata3,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr3,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata3,

input event_fifo_wr_ptr_wr4,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr4,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata4,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr4,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata4,

input event_fifo_wr_ptr_wr5,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr5,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata5,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr5,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata5,

input event_fifo_wr_ptr_wr6,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr6,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata6,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr6,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata6,

input event_fifo_wr_ptr_wr7,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_waddr7,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_wdata7,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_wr_ptr_raddr7,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_wr_ptr_rdata7,

input event_fifo_count_wr0,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr0,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata0,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr0,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata0,

input event_fifo_count_wr1,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr1,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata1,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr1,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata1,

input event_fifo_count_wr2,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr2,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata2,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr2,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata2,

input event_fifo_count_wr3,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr3,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata3,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr3,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata3,

input event_fifo_count_wr4,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr4,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata4,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr4,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata4,

input event_fifo_count_wr5,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr5,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata5,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr5,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata5,

input event_fifo_count_wr6,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr6,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata6,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr6,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata6,

input event_fifo_count_wr7,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr7,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_wdata7,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr7,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_count_rdata7,

input event_fifo_count_wr,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_waddr,
input [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_wdata,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_count_raddr,
output [(`SECOND_LVL_QUEUE_ID_NBITS<<1)-1:0] event_fifo_count_rdata  /* synthesis keep = 1 */,

input event_fifo_f1_count_wr,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_waddr,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_wdata,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] event_fifo_f1_count_raddr,
output [`SECOND_LVL_QUEUE_ID_NBITS-1:0] event_fifo_f1_count_rdata  /* synthesis keep = 1 */,

input wdrr_sch_tqna_wr,			
input [`SECOND_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_waddr,
input [`TQNA_NBITS-1:0] wdrr_sch_tqna_wdata,
input [`SECOND_LVL_SCH_ID_NBITS-1:0] wdrr_sch_tqna_raddr,
output [`TQNA_NBITS-1:0] wdrr_sch_tqna_rdata  /* synthesis keep = 1 */,

input semaphore_wr,			
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] semaphore_waddr,
input semaphore_wdata,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] semaphore_raddr,
output semaphore_rdata  /* synthesis keep = 1 */
);

/***************************** MEMORY ***************************************/

ram_1r1w #(`DEFICIT_COUNTER_NBITS+`TQNA_NBITS, `SECOND_LVL_QUEUE_ID_NBITS) u_ram_1r1w_3(
		.clk(clk),
		.wr(deficit_counter_wr),
		.raddr(deficit_counter_raddr),
		.waddr(deficit_counter_waddr),
		.din(deficit_counter_wdata),

		.dout(deficit_counter_rdata));

ram_1r1w #(`CIR_NBITS+2+`EIR_NBITS+2, `SECOND_LVL_QUEUE_ID_NBITS) u_ram_1r1w_4(
		.clk(clk),
		.wr(token_bucket_wr),
		.raddr(token_bucket_raddr),
		.waddr(token_bucket_waddr),
		.din(token_bucket_wdata),

		.dout(token_bucket_rdata));

ram_1r1w #(`EIR_NBITS+2, `PORT_ID_NBITS) u_ram_1r1w_41(
		.clk(clk),
		.wr(eir_tb_wr),
		.raddr(eir_tb_raddr),
		.waddr(eir_tb_waddr),
		.din(eir_tb_wdata),

		.dout(eir_tb_rdata));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS+2, `SECOND_LVL_QUEUE_ID_NBITS) u_ram_1r1w_5(
		.clk(clk),
		.wr(event_fifo_wr),
		.raddr(event_fifo_raddr),
		.waddr(event_fifo_waddr),
		.din(event_fifo_wdata),

		.dout(event_fifo_rdata));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_60(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr0),
		.raddr(event_fifo_rd_ptr_raddr0),
		.waddr(event_fifo_rd_ptr_waddr0),
		.din(event_fifo_rd_ptr_wdata0),

		.dout(event_fifo_rd_ptr_rdata0));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_61(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr1),
		.raddr(event_fifo_rd_ptr_raddr1),
		.waddr(event_fifo_rd_ptr_waddr1),
		.din(event_fifo_rd_ptr_wdata1),

		.dout(event_fifo_rd_ptr_rdata1));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_62(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr2),
		.raddr(event_fifo_rd_ptr_raddr2),
		.waddr(event_fifo_rd_ptr_waddr2),
		.din(event_fifo_rd_ptr_wdata2),

		.dout(event_fifo_rd_ptr_rdata2));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_63(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr3),
		.raddr(event_fifo_rd_ptr_raddr3),
		.waddr(event_fifo_rd_ptr_waddr3),
		.din(event_fifo_rd_ptr_wdata3),

		.dout(event_fifo_rd_ptr_rdata3));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_64(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr4),
		.raddr(event_fifo_rd_ptr_raddr4),
		.waddr(event_fifo_rd_ptr_waddr4),
		.din(event_fifo_rd_ptr_wdata4),

		.dout(event_fifo_rd_ptr_rdata4));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_65(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr5),
		.raddr(event_fifo_rd_ptr_raddr5),
		.waddr(event_fifo_rd_ptr_waddr5),
		.din(event_fifo_rd_ptr_wdata5),

		.dout(event_fifo_rd_ptr_rdata5));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_66(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr6),
		.raddr(event_fifo_rd_ptr_raddr6),
		.waddr(event_fifo_rd_ptr_waddr6),
		.din(event_fifo_rd_ptr_wdata6),

		.dout(event_fifo_rd_ptr_rdata6));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_67(
		.clk(clk),
		.wr(event_fifo_rd_ptr_wr7),
		.raddr(event_fifo_rd_ptr_raddr7),
		.waddr(event_fifo_rd_ptr_waddr7),
		.din(event_fifo_rd_ptr_wdata7),

		.dout(event_fifo_rd_ptr_rdata7));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_70(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr0),
		.raddr(event_fifo_wr_ptr_raddr0),
		.waddr(event_fifo_wr_ptr_waddr0),
		.din(event_fifo_wr_ptr_wdata0),

		.dout(event_fifo_wr_ptr_rdata0));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_71(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr1),
		.raddr(event_fifo_wr_ptr_raddr1),
		.waddr(event_fifo_wr_ptr_waddr1),
		.din(event_fifo_wr_ptr_wdata1),

		.dout(event_fifo_wr_ptr_rdata1));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_72(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr2),
		.raddr(event_fifo_wr_ptr_raddr2),
		.waddr(event_fifo_wr_ptr_waddr2),
		.din(event_fifo_wr_ptr_wdata2),

		.dout(event_fifo_wr_ptr_rdata2));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_73(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr3),
		.raddr(event_fifo_wr_ptr_raddr3),
		.waddr(event_fifo_wr_ptr_waddr3),
		.din(event_fifo_wr_ptr_wdata3),

		.dout(event_fifo_wr_ptr_rdata3));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_74(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr4),
		.raddr(event_fifo_wr_ptr_raddr4),
		.waddr(event_fifo_wr_ptr_waddr4),
		.din(event_fifo_wr_ptr_wdata4),

		.dout(event_fifo_wr_ptr_rdata4));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_75(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr5),
		.raddr(event_fifo_wr_ptr_raddr5),
		.waddr(event_fifo_wr_ptr_waddr5),
		.din(event_fifo_wr_ptr_wdata5),

		.dout(event_fifo_wr_ptr_rdata5));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_76(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr6),
		.raddr(event_fifo_wr_ptr_raddr6),
		.waddr(event_fifo_wr_ptr_waddr6),
		.din(event_fifo_wr_ptr_wdata6),

		.dout(event_fifo_wr_ptr_rdata6));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_77(
		.clk(clk),
		.wr(event_fifo_wr_ptr_wr7),
		.raddr(event_fifo_wr_ptr_raddr7),
		.waddr(event_fifo_wr_ptr_waddr7),
		.din(event_fifo_wr_ptr_wdata7),

		.dout(event_fifo_wr_ptr_rdata7));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_80(
		.clk(clk),
		.wr(event_fifo_count_wr0),
		.raddr(event_fifo_count_raddr0),
		.waddr(event_fifo_count_waddr0),
		.din(event_fifo_count_wdata0),

		.dout(event_fifo_count_rdata0));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_81(
		.clk(clk),
		.wr(event_fifo_count_wr1),
		.raddr(event_fifo_count_raddr1),
		.waddr(event_fifo_count_waddr1),
		.din(event_fifo_count_wdata1),

		.dout(event_fifo_count_rdata1));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_82(
		.clk(clk),
		.wr(event_fifo_count_wr2),
		.raddr(event_fifo_count_raddr2),
		.waddr(event_fifo_count_waddr2),
		.din(event_fifo_count_wdata2),

		.dout(event_fifo_count_rdata2));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_83(
		.clk(clk),
		.wr(event_fifo_count_wr3),
		.raddr(event_fifo_count_raddr3),
		.waddr(event_fifo_count_waddr3),
		.din(event_fifo_count_wdata3),

		.dout(event_fifo_count_rdata3));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_84(
		.clk(clk),
		.wr(event_fifo_count_wr4),
		.raddr(event_fifo_count_raddr4),
		.waddr(event_fifo_count_waddr4),
		.din(event_fifo_count_wdata4),

		.dout(event_fifo_count_rdata4));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_85(
		.clk(clk),
		.wr(event_fifo_count_wr5),
		.raddr(event_fifo_count_raddr5),
		.waddr(event_fifo_count_waddr5),
		.din(event_fifo_count_wdata5),

		.dout(event_fifo_count_rdata5));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_86(
		.clk(clk),
		.wr(event_fifo_count_wr6),
		.raddr(event_fifo_count_raddr6),
		.waddr(event_fifo_count_waddr6),
		.din(event_fifo_count_wdata6),

		.dout(event_fifo_count_rdata6));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_87(
		.clk(clk),
		.wr(event_fifo_count_wr7),
		.raddr(event_fifo_count_raddr7),
		.waddr(event_fifo_count_waddr7),
		.din(event_fifo_count_wdata7),

		.dout(event_fifo_count_rdata7));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS<<1, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_88(
		.clk(clk),
		.wr(event_fifo_count_wr),
		.raddr(event_fifo_count_raddr),
		.waddr(event_fifo_count_waddr),
		.din(event_fifo_count_wdata),

		.dout(event_fifo_count_rdata));

ram_1r1w #(`SECOND_LVL_QUEUE_ID_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_89(
		.clk(clk),
		.wr(event_fifo_f1_count_wr),
		.raddr(event_fifo_f1_count_raddr),
		.waddr(event_fifo_f1_count_waddr),
		.din(event_fifo_f1_count_wdata),

		.dout(event_fifo_f1_count_rdata));

ram_1r1w #(`TQNA_NBITS, `SECOND_LVL_SCH_ID_NBITS) u_ram_1r1w_11(
		.clk(clk),
		.wr(wdrr_sch_tqna_wr),
		.raddr(wdrr_sch_tqna_raddr),
		.waddr(wdrr_sch_tqna_waddr),
		.din(wdrr_sch_tqna_wdata),

		.dout(wdrr_sch_tqna_rdata));

ram_1r1w #(1, `SECOND_LVL_QUEUE_ID_NBITS) u_ram_1r1w_12(
		.clk(clk),
		.wr(semaphore_wr),
		.raddr(semaphore_raddr),
		.waddr(semaphore_waddr),
		.din(semaphore_wdata),

		.dout(semaphore_rdata));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

