//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : free buffer control
//===========================================================================

`include "defines.vh"

module edit_mem_freeb_ctrl #(
parameter BPTR_NBITS = `EM_BUF_PTR_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS
) (
    input clk,
    input `RESET_SIG,

    input freeb_init,   

    input rel_buf_valid,
    input [BPTR_NBITS-1:0] rel_buf_ptr,  

    input pu_buf_req, 

    // outputs

    output reg init_read_count_valid,
    output reg [BPTR_NBITS-1:0] init_read_count_ptr,

    output reg inc_freeb_rd_count, 
    output reg inc_freeb_wr_count,

    output reg freeb_init_done,    

    output reg pu_buf_valid, 
    output reg [BPTR_NBITS-1:0] pu_buf_ptr,    
    output reg pu_buf_available   
    
);


/***************************** LOCAL VARIABLES *******************************/

localparam [1:0]  INIT_IDLE = 0,
         RESET_FREEB = 1,
         INIT_FREEB = 2,
         INIT_DONE = 3;

reg [1:0] init_st, nxt_init_st;

reg pu_buf_req_d1;
reg pu_buf_req_d2;

reg rel_buf_valid_d1;
reg [BPTR_NBITS-1:0] rel_buf_ptr_d1;

reg fifo_rd_d1;

reg fifo_reset;
reg freeb_init_wr;

reg prefetch_fifo_rd;

wire [BPTR_NBITS-1:0] prefetch_fifo_dout;
wire prefetch_fifo_empty, prefetch_fifo_full, prefetch_fifo_fullm1, prefetch_fifo_emptyp2;
wire [2:0] prefetch_fifo_count;

wire [BPTR_NBITS-1:0] fifo_dout;
wire fifo_empty, fifo_full;
wire [BPTR_NBITS-1:0] fifo_wptr;
wire [BPTR_NBITS:0] fifo_count;

wire enable_rd = pu_buf_req_d1;

wire prefetch_fifo_rd_p1 = freeb_init_done&enable_rd&(prefetch_fifo_rd?(prefetch_fifo_count>1):~prefetch_fifo_empty);

wire fifo_wr = freeb_init_wr|rel_buf_valid_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign inc_freeb_rd_count = prefetch_fifo_rd;
 
always @(posedge clk) begin
        pu_buf_available <= prefetch_fifo_rd;
        pu_buf_ptr <= prefetch_fifo_dout;

        init_read_count_ptr <= fifo_wptr;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        pu_buf_valid <= 0;
        freeb_init_done <= 0;
        init_read_count_valid <= 0;
        inc_freeb_wr_count <= 0;
    end else begin
        pu_buf_valid <= pu_buf_req_d2;
        freeb_init_done <= (nxt_init_st==INIT_DONE);
        init_read_count_valid <= freeb_init_wr;
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
        pu_buf_req_d1 <= 0;
        pu_buf_req_d2 <= 0;
        rel_buf_valid_d1 <= 0;
        freeb_init_wr <= 1'b0;
        fifo_rd_d1 <= 0;
        prefetch_fifo_rd <= 0;
    end else begin
	fifo_reset <= (nxt_init_st==RESET_FREEB)?`ACTIVE_RESET_LEVEL:`INACTIVE_RESET_LEVEL;
        pu_buf_req_d1 <= pu_buf_req;
        pu_buf_req_d2 <= pu_buf_req_d1;
        rel_buf_valid_d1 <= rel_buf_valid;
        freeb_init_wr <= (nxt_init_st==INIT_FREEB);
        fifo_rd_d1 <= fifo_rd;
        prefetch_fifo_rd <= prefetch_fifo_rd_p1;
    end
 
/***************************** NEXT STATE ASSIGNMENT **************************/
always @(*)  begin
    nxt_init_st = init_st;
    case (init_st)      
        INIT_IDLE: nxt_init_st = RESET_FREEB;
        RESET_FREEB: nxt_init_st = INIT_FREEB;
        INIT_FREEB: if (&fifo_wptr) nxt_init_st = INIT_DONE;
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
    .count(prefetch_fifo_count),
    .full(prefetch_fifo_full),
    .empty(prefetch_fifo_empty),
    .fullm1(prefetch_fifo_fullm1),
    .emptyp2(prefetch_fifo_emptyp2),
    .dout(prefetch_fifo_dout)       
);

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off

// synopsys translate_on

endmodule

