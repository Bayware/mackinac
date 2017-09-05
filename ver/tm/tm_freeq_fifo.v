//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_freeq_fifo #(
parameter SIZE_NBITS = `FIRST_LVL_QUEUE_ID_NBITS
) (

input clk, 
input `RESET_SIG,

input rel_q_valid,
input [SIZE_NBITS-1:0] rel_q_idx,

input dec_freeq_count,
input get_q_req,

output [SIZE_NBITS-1:0] freeq_head,
output reg [SIZE_NBITS:0] freeq_count
	
);

/***************************** LOCAL VARIABLES *******************************/

localparam [1:0]	 INIT_IDLE = 0,
		 INIT_FREEQ = 1,
		 INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;

reg fifo_rd_d1;

reg freeq_init_wr;


wire [SIZE_NBITS-1:0] prefetch_fifo_dout;
wire prefetch_fifo_full, prefetch_fifo_fullm1;

wire [SIZE_NBITS-1:0] fifo_dout;
wire fifo_empty, fifo_full;
wire [SIZE_NBITS-1:0] fifo_wptr;

wire fifo_wr = freeq_init_wr|rel_q_valid;

/***************************** NON REGISTERED OUTPUTS ************************/

assign freeq_head = prefetch_fifo_dout;

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		freeq_count <= 0;
	end else begin
		freeq_count <= ~(fifo_wr^dec_freeq_count)?freeq_count:fifo_wr?freeq_count+1:freeq_count-1;
	end

/***************************** PROGRAM BODY **********************************/

wire prefetch_fifo_wr = fifo_rd_d1;

wire fifo_rd = ~freeq_init_wr&~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		freeq_init_wr <= 1'b0;
		fifo_rd_d1 <= 0;
	end else begin
		freeq_init_wr <= (nxt_init_st==INIT_FREEQ);
		fifo_rd_d1 <= fifo_rd;
	end
 
/***************************** NEXT STATE ASSIGNMENT **************************/
always @(init_st or fifo_wptr)  begin
	nxt_init_st = init_st;
	case (init_st)		
		INIT_IDLE: nxt_init_st = INIT_FREEQ;
		INIT_FREEQ: if (&fifo_wptr) nxt_init_st = INIT_DONE;
		INIT_DONE: nxt_init_st = INIT_DONE;
		default: nxt_init_st = INIT_IDLE;
	endcase
end

/***************************** STATE MACHINE *******************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET)
		init_st <= INIT_IDLE;
	else 
		init_st <= nxt_init_st;

/***************************** FIFO ***************************************/

wire [SIZE_NBITS-1:0] fifo_din = freeq_init_wr?fifo_wptr:rel_q_idx;

sfifo2f_ram #(SIZE_NBITS, SIZE_NBITS) u_sfifo2f_ram(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_din),				
    .rd(fifo_rd),
    .wr(fifo_wr),

	.wptr(fifo_wptr), 
	.count(), 
	.full(fifo_full),
	.empty(fifo_empty),
    .dout(fifo_dout)       
);

sfifo2f_fo #(SIZE_NBITS, 2) u_sfifo2f_fo(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_dout),				
    .rd(get_q_req),
    .wr(prefetch_fifo_wr),

	.ncount(),
	.count(),
	.full(prefetch_fifo_full),
	.empty(),
	.fullm1(prefetch_fifo_fullm1),
	.emptyp2(),
    .dout(prefetch_fifo_dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

