//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module cla_topic_free_list #(
parameter BPTR_NBITS = `TOPIC_VALUE_DEPTH_NBITS
) (
    input clk,
    input `RESET_SIG,

    input freeb_init,   

    input rel_buf_valid,
    input [BPTR_NBITS-1:0] rel_buf_ptr,  

    input free_buf_rd, 

    // outputs

    output inc_freeb_rd_count, 
    output reg inc_freeb_wr_count,

    output reg freeb_init_done,    

    output wire freeb_empty,    

    output [BPTR_NBITS-1:0] free_buf_ptr    
    
);


/***************************** LOCAL VARIABLES *******************************/

localparam [1:0]  INIT_IDLE = 0,
         RESET_FREEB = 1,
         INIT_FREEB = 2,
         INIT_DONE = 3;

reg [1:0] init_st, nxt_init_st;

reg rel_buf_valid_d1;
reg [BPTR_NBITS-1:0] rel_buf_ptr_d1;

reg fifo_rd_d1;

reg fifo_reset;
reg freeb_init_wr;

integer i;

wire [BPTR_NBITS-1:0] prefetch_fifo_dout;
wire prefetch_fifo_empty, prefetch_fifo_full, prefetch_fifo_fullm1;

wire [BPTR_NBITS-1:0] fifo_dout;
wire fifo_empty, fifo_full;
wire [BPTR_NBITS-1:0] fifo_wptr;
wire [BPTR_NBITS:0] fifo_count;

wire prefetch_fifo_rd = freeb_init_done&free_buf_rd;

wire fifo_wr = freeb_init_wr|rel_buf_valid_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign inc_freeb_rd_count = prefetch_fifo_rd;
assign free_buf_ptr = prefetch_fifo_dout;
assign freeb_empty = prefetch_fifo_empty;
 
always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        freeb_init_done <= 0;
        inc_freeb_wr_count <= 0;
    end else begin
        freeb_init_done <= (nxt_init_st==INIT_DONE);
        inc_freeb_wr_count <= fifo_wr;
    end

/***************************** PROGRAM BODY **********************************/

wire prefetch_fifo_wr = fifo_rd_d1;
wire fifo_rd = ~freeb_init_wr&~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);

always @(posedge clk) begin
        
        rel_buf_ptr_d1 <= rel_buf_ptr;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	fifo_reset <= `ACTIVE_RESET_LEVEL;
        rel_buf_valid_d1 <= 0;
        freeb_init_wr <= 1'b0;
        fifo_rd_d1 <= 0;
    end else begin
	fifo_reset <= (nxt_init_st==RESET_FREEB)?`ACTIVE_RESET_LEVEL:`INACTIVE_RESET_LEVEL;
        rel_buf_valid_d1 <= rel_buf_valid;
        freeb_init_wr <= (nxt_init_st==INIT_FREEB);
        fifo_rd_d1 <= fifo_rd;
    end
 
/***************************** NEXT STATE ASSIGNMENT **************************/
always @*  begin
    nxt_init_st = init_st;
    case (init_st)      
        INIT_IDLE: nxt_init_st = RESET_FREEB;
        RESET_FREEB: nxt_init_st = INIT_FREEB;
        INIT_FREEB: if (&fifo_wptr[BPTR_NBITS-1:1]) nxt_init_st = INIT_DONE;
        INIT_DONE: if (freeb_init) nxt_init_st = INIT_IDLE;
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

wire [BPTR_NBITS-1:0] fifo_din = freeb_init_wr?fifo_wptr[BPTR_NBITS-1:0]:rel_buf_ptr_d1;

sfifo2f_ram #(BPTR_NBITS, BPTR_NBITS) u_sfifo2f_ram(
    .clk(clk),
    .`RESET_SIG(fifo_reset),

    .din(fifo_din),             
    .rd(fifo_rd),
    .wr(fifo_wr),

    .wptr(fifo_wptr), 
    .count(fifo_count), 
    .full(fifo_full),
    .empty(fifo_empty),
    .dout(fifo_dout)       
);

sfifo2f_fo #(BPTR_NBITS, 2) sfifo2f_fo_inst(
    .clk(clk),
    .`RESET_SIG(fifo_reset),

    .din(fifo_dout),                
    .rd(prefetch_fifo_rd),
    .wr(prefetch_fifo_wr),

    .ncount(),
    .count(),
    .full(prefetch_fifo_full),
    .empty(prefetch_fifo_empty),
    .fullm1(prefetch_fifo_fullm1),
    .emptyp2(),
    .dout(prefetch_fifo_dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

