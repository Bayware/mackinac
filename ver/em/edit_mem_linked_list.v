//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : buffer linked list
//===========================================================================

`include "defines.vh"

module edit_mem_linked_list #(
parameter BPTR_NBITS = `EM_BUF_PTR_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS,
parameter LEN_NBITS = `PD_CHUNK_DEPTH_NBITS,
parameter RC_NBITS = `READ_COUNT_NBITS,
parameter SIZE = `DATA_PATH_NBYTES
) (
input clk,
input `RESET_SIG,

input enq_buf_valid,
input [BPTR_NBITS-1:0] enq_buf_ptr_cur,
input [BPTR_NBITS-1:0] enq_buf_ptr_nxt,

input buf_req,
input [BPTR_NBITS-1:0] buf_req_ptr,

input asa_em_read_count_valid,
input [BPTR_NBITS-1:0] asa_em_buf_ptr,
input [`PORT_ID_NBITS-1:0] asa_em_rc_port_id,
input [RC_NBITS-1:0] asa_em_read_count,
input [LEN_NBITS-1:0] asa_em_pd_length,

output inc_ll_rd_count,
output inc_ll_wr_count,

output reg buf_ack_valid,
output reg [BPTR_NBITS-1:0] buf_ack_ptr,

output reg read_count_valid, 
output reg [`PORT_ID_NBITS-1:0] read_count_port_id,
output reg [BPTR_NBITS-1:0] read_count_buf_ptr,
output reg [RC_NBITS-1:0] read_count

);


/***************************** LOCAL VARIABLES *******************************/
reg enq_buf_valid_d1;
reg [BPTR_NBITS-1:0] enq_buf_ptr_cur_d1;
reg [BPTR_NBITS-1:0] enq_buf_ptr_nxt_d1;

reg buf_req_d1;
reg buf_req_d2;
reg buf_req_d3;
reg [BPTR_NBITS-1:0] buf_req_ptr_d1;

reg asa_em_read_count_valid_d1;
reg [BPTR_NBITS-1:0] asa_em_buf_ptr_d1;
reg [`PORT_ID_NBITS-1:0] asa_em_rc_port_id_d1;
reg [RC_NBITS-1:0] asa_em_read_count_d1;
reg [LEN_NBITS-1:0] asa_em_pd_length_d1;

reg asa_em_read_count_valid_d2;
reg [BPTR_NBITS-1:0] asa_em_buf_ptr_d2;
reg [`PORT_ID_NBITS-1:0] asa_em_rc_port_id_d2;
reg [RC_NBITS-1:0] asa_em_read_count_d2;
reg [LEN_NBITS-1:0] asa_em_pd_length_d2;

reg [BPTR_NBITS-1:0] deq_buf_ptr;

reg [LEN_NBITS+1-1:0] pd_length;
reg rc_sop;
reg rc_st;
reg pending_rc_req;
reg [BPTR_NBITS-1:0] saved_buf_ptr;

reg rc_eop_d1;
reg rc_eop_d2;

reg rc_deq_valid_d1;
reg rc_deq_valid_d2;


wire [BPTR_NBITS-1:0] deq_buf_ptr_nxt  /* synthesis DONT_TOUCH */;

wire [BPTR_NBITS-1:0] fifo_buf_ptr;
wire [`PORT_ID_NBITS-1:0] fifo_port_id;
wire [RC_NBITS-1:0] fifo_read_count;
wire [LEN_NBITS-1:0] fifo_pd_length;
wire fifo_empty;

wire first_rc_eop = fifo_pd_length<(SIZE+1);
wire rc_eop = rc_sop?first_rc_eop:pd_length<(SIZE+1);

wire fifo_rd = ~buf_req_d1&~fifo_empty&~rc_st;

wire rc_deq_valid_1st = fifo_rd&~first_rc_eop;
wire mrc_deq_valid_d2 = rc_deq_valid_d2&~rc_eop_d2;
wire rc_deq_valid_nxt = ~buf_req_d1&rc_st&(mrc_deq_valid_d2|pending_rc_req);
wire rc_deq_valid = rc_deq_valid_1st|rc_deq_valid_nxt;

wire save_buf_ptr = buf_req_d1&rc_st&mrc_deq_valid_d2;

wire clr_rc_st = rc_deq_valid_nxt&rc_eop;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign inc_ll_rd_count = buf_req_d1;
assign inc_ll_wr_count = enq_buf_valid_d1;

always @(posedge clk) begin
		buf_ack_ptr <= deq_buf_ptr_nxt;
	    read_count_port_id <= fifo_rd?fifo_port_id:read_count_port_id;
	    read_count_buf_ptr <= fifo_rd?fifo_buf_ptr:pending_rc_req?saved_buf_ptr:deq_buf_ptr_nxt;
	    read_count <= fifo_rd?fifo_read_count:read_count;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		buf_ack_valid <= 0;
		read_count_valid <= 0;
	end else begin
		buf_ack_valid <= buf_req_d3;
		read_count_valid <= fifo_rd|rc_deq_valid;
	end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin
	    enq_buf_ptr_cur_d1 <= enq_buf_ptr_cur;
	    enq_buf_ptr_nxt_d1 <= enq_buf_ptr_nxt;

		asa_em_read_count_d1 <= asa_em_read_count;
	    asa_em_rc_port_id_d1 <= asa_em_rc_port_id;
	    asa_em_buf_ptr_d1 <= asa_em_buf_ptr;
		asa_em_pd_length_d1 <= asa_em_pd_length;

		asa_em_read_count_d2 <= asa_em_read_count_d1;
	    asa_em_rc_port_id_d2 <= asa_em_rc_port_id_d1;
	    asa_em_buf_ptr_d2 <= asa_em_buf_ptr_d1;
		asa_em_pd_length_d2 <= asa_em_pd_length_d1;

		buf_req_ptr_d1 <= buf_req_ptr;

	    saved_buf_ptr <= save_buf_ptr?deq_buf_ptr_nxt:saved_buf_ptr;

		deq_buf_ptr <= buf_req_d1?buf_req_ptr_d1:fifo_rd?fifo_buf_ptr:pending_rc_req?saved_buf_ptr:deq_buf_ptr_nxt;

		rc_eop_d1 <= rc_eop;
		rc_eop_d2 <= rc_eop_d1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		enq_buf_valid_d1 <= 0;
		asa_em_read_count_valid_d1 <= 0;
		asa_em_read_count_valid_d2 <= 0;
		buf_req_d1 <= 0;
		buf_req_d2 <= 0;
		buf_req_d3 <= 0;
		pd_length <= 0;
		rc_sop <= 1;
		rc_st <= 0;
		rc_deq_valid_d1 <= 0;
		rc_deq_valid_d2 <= 0;
		pending_rc_req <= 0;
	end else begin
		enq_buf_valid_d1 <= enq_buf_valid;
		asa_em_read_count_valid_d1 <= asa_em_read_count_valid;
		asa_em_read_count_valid_d2 <= asa_em_read_count_valid_d1&(asa_em_pd_length_d1!=0);
		buf_req_d1 <= buf_req;
		buf_req_d2 <= buf_req_d1;
		buf_req_d3 <= buf_req_d2;
		pd_length <= fifo_rd?{1'b0, fifo_pd_length}-SIZE:rc_deq_valid?pd_length-SIZE:pd_length;
		rc_sop <= clr_rc_st?1'b1:rc_deq_valid?1'b0:rc_sop;
		
		rc_st <= rc_deq_valid_1st?1'b1:clr_rc_st?1'b0:rc_st;
		rc_deq_valid_d1 <= rc_deq_valid;
		rc_deq_valid_d2 <= rc_deq_valid_d1;
		
		pending_rc_req <= save_buf_ptr?1'b1:~buf_req_d1?1'b0:pending_rc_req;
	end

/***************************** FIFO ***************************************/

sfifo2f_fo #(RC_NBITS+`PORT_ID_NBITS+BPTR_NBITS+LEN_NBITS, 8) u_sfifo2f_fo(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din({asa_em_read_count_d2, asa_em_rc_port_id_d2, asa_em_buf_ptr_d2, asa_em_pd_length_d2}),				
    .rd(fifo_rd),
    .wr(asa_em_read_count_valid_d2),

	.ncount(),
	.count(),
	.full(),
	.empty(fifo_empty),
	.fullm1(),
	.emptyp2(),
    .dout({fifo_read_count, fifo_port_id, fifo_buf_ptr, fifo_pd_length})       
);

/***************************** MEMORY ***************************************/
ram_1r1w_ultra #(BPTR_NBITS, BPTR_NBITS) u_ram_1r1w_ultra(
	.clk(clk),
	.wr(enq_buf_valid_d1),
	.raddr(deq_buf_ptr),
	.waddr(enq_buf_ptr_cur_d1),
	.din(enq_buf_ptr_nxt_d1),

	.dout(deq_buf_ptr_nxt));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

