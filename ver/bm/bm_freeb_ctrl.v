//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : free buffer control
//===========================================================================

`include "defines.vh"

module bm_freeb_ctrl (
    input clk,
    input `RESET_SIG,

    input freeb_init,   

    input rel_buf_valid,
    input [`BUF_PTR_NBITS-1:0] rel_buf_ptr,  

    input asa_bm_bp, 

    input aggr_bm_buf_req, 

    input aggr_bm_packet_valid,    
    input [`BUF_PTR_NBITS-1:0] aggr_bm_buf_ptr,        
    input [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb,    
    input aggr_bm_sop,            
    input [`PORT_ID_NBITS-1:0] aggr_bm_port_id,        

    // outputs

    output reg init_read_count_valid,
    output reg [`BUF_PTR_NBITS-1:0] init_read_count_ptr,

    output inc_freeb_rd_count, 
    output reg inc_freeb_wr_count,

    output reg freeb_init_done,    

    output reg enq_buf_valid, 
    output reg [`BUF_PTR_NBITS-1:0] fb_buf_ptr_prev,
    output reg [`BUF_PTR_NBITS-1:0] fb_buf_ptr_cur,

    output reg bm_aggr_buf_valid, 
    output reg [`BUF_PTR_NBITS-1:0] bm_aggr_buf_ptr,    
    output reg bm_aggr_buf_available   
    
);


/***************************** LOCAL VARIABLES *******************************/

localparam [1:0]  INIT_IDLE = 0,
         RESET_FREEB = 1,
         INIT_FREEB = 2,
         INIT_DONE = 3;

reg [1:0] init_st, nxt_init_st;

reg [`BUF_PTR_NBITS-1:0] bm_aggr_buf_ptr_saved[`NUM_OF_PORTS-1:0];

reg asa_bm_bp_d1;

reg aggr_bm_buf_req_d1;
reg aggr_bm_buf_req_d2;


reg aggr_bm_packet_valid_d1;
reg [`BUF_PTR_NBITS-1:0] aggr_bm_buf_ptr_d1;
reg [`BUF_PTR_LSB_RANGE] aggr_bm_buf_ptr_lsb_d1;

reg aggr_bm_sop_d1;
reg [`PORT_ID_NBITS-1:0] aggr_bm_port_id_d1;

reg rel_buf_valid_d1;
reg [`BUF_PTR_NBITS-1:0] rel_buf_ptr_d1;

reg fifo_rd_d1;

reg fifo_reset;
reg freeb_init_wr;

reg prefetch_fifo_rd;

integer i;

wire [`BUF_PTR_NBITS-1:0] prefetch_fifo_dout;
wire prefetch_fifo_empty, prefetch_fifo_full, prefetch_fifo_fullm1, prefetch_fifo_emptyp2;
wire [2:0] prefetch_fifo_count;

wire [`BUF_PTR_NBITS-1:0] fifo_dout;
wire fifo_empty, fifo_full;
wire [`BUF_PTR_NBITS-1:0] fifo_wptr;
wire [`BUF_PTR_NBITS:0] fifo_count;

wire enable_rd = ~asa_bm_bp_d1&aggr_bm_buf_req_d1;

wire prefetch_fifo_rd_p1 = freeb_init_done&enable_rd&(prefetch_fifo_rd?(prefetch_fifo_count>1):~prefetch_fifo_empty);

wire save_buf_ptr = aggr_bm_packet_valid_d1&~|aggr_bm_buf_ptr_lsb_d1;

wire fifo_wr = freeb_init_wr|rel_buf_valid_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign inc_freeb_rd_count = prefetch_fifo_rd;
 
always @(posedge clk) begin
        bm_aggr_buf_available <= prefetch_fifo_rd;
        bm_aggr_buf_ptr <= prefetch_fifo_dout;

        fb_buf_ptr_prev <= bm_aggr_buf_ptr_saved[aggr_bm_port_id_d1];
        fb_buf_ptr_cur <= aggr_bm_buf_ptr_d1;
        init_read_count_ptr <= fifo_wptr;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        bm_aggr_buf_valid <= 0;
        enq_buf_valid <= 0;
        freeb_init_done <= 0;
        init_read_count_valid <= 0;
        inc_freeb_wr_count <= 0;
    end else begin
        bm_aggr_buf_valid <= aggr_bm_buf_req_d2;
        enq_buf_valid <= save_buf_ptr&~aggr_bm_sop_d1;
        freeb_init_done <= (nxt_init_st==INIT_DONE);
        init_read_count_valid <= freeb_init_wr;
        inc_freeb_wr_count <= fifo_wr;
    end

/***************************** PROGRAM BODY **********************************/

wire prefetch_fifo_wr = fifo_rd_d1;
wire fifo_rd = ~freeb_init_wr&~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);

always @(posedge clk) begin
        
        rel_buf_ptr_d1 <= rel_buf_ptr;
        aggr_bm_buf_ptr_d1 <= aggr_bm_buf_ptr;
        aggr_bm_port_id_d1 <= aggr_bm_port_id;
        aggr_bm_buf_ptr_lsb_d1 <= aggr_bm_buf_ptr_lsb;
        aggr_bm_sop_d1 <= aggr_bm_sop;

        for (i = 0; i < `NUM_OF_PORTS; i = i + 1) 
            bm_aggr_buf_ptr_saved[i] <= save_buf_ptr&(aggr_bm_port_id_d1==i)?aggr_bm_buf_ptr_d1:bm_aggr_buf_ptr_saved[i];
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	fifo_reset <= `ACTIVE_RESET_LEVEL;
        asa_bm_bp_d1 <= 0;
        aggr_bm_buf_req_d1 <= 0;
        aggr_bm_buf_req_d2 <= 0;
        aggr_bm_packet_valid_d1 <= 0;
        rel_buf_valid_d1 <= 0;
        freeb_init_wr <= 1'b0;
        fifo_rd_d1 <= 0;
        prefetch_fifo_rd <= 0;
    end else begin
	fifo_reset <= (nxt_init_st==RESET_FREEB)?`ACTIVE_RESET_LEVEL:`INACTIVE_RESET_LEVEL;
        asa_bm_bp_d1 <= asa_bm_bp;
        aggr_bm_buf_req_d1 <= aggr_bm_buf_req;
        aggr_bm_buf_req_d2 <= aggr_bm_buf_req_d1;
        aggr_bm_packet_valid_d1 <= aggr_bm_packet_valid;
        rel_buf_valid_d1 <= rel_buf_valid;
        freeb_init_wr <= (nxt_init_st==INIT_FREEB);
        fifo_rd_d1 <= fifo_rd;
        prefetch_fifo_rd <= prefetch_fifo_rd_p1;
    end
 
/***************************** NEXT STATE ASSIGNMENT **************************/
always @(init_st or freeb_init or fifo_wptr)  begin
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

wire [`BUF_PTR_NBITS-1:0] fifo_din = freeb_init_wr?fifo_wptr[`BUF_PTR_NBITS-1:0]:rel_buf_ptr_d1;

sfifo2f_ram #(`BUF_PTR_NBITS, `BUF_PTR_NBITS) u_sfifo2f_ram(
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

sfifo2f_fo #(`BUF_PTR_NBITS, 2) sfifo2f_fo_inst(
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

