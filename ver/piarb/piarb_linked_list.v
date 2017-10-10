//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module piarb_linked_list #(
parameter BUF_NBITS = `PIARB_BUF_PTR_NBITS	
) (
	input clk,
	input `RESET_SIG,

input enq_buf_valid,
input [BUF_NBITS-1:0] enq_buf_ptr_cur,
input [BUF_NBITS-1:0] enq_buf_ptr_nxt,

input buf_req,
input [BUF_NBITS-1:0] buf_req_ptr,

output inc_ll_rd_count,
output inc_ll_wr_count,

output reg buf_ack_valid,
output reg [BUF_NBITS-1:0] buf_ack_ptr

);


/***************************** LOCAL VARIABLES *******************************/
reg enq_buf_valid_d1;
reg [BUF_NBITS-1:0] enq_buf_ptr_cur_d1;
reg [BUF_NBITS-1:0] enq_buf_ptr_nxt_d1;

reg buf_req_d1;
reg buf_req_d2;
reg [BUF_NBITS-1:0] buf_req_ptr_d1;

wire [BUF_NBITS-1:0] deq_buf_ptr_nxt /* synthesis DONT_TOUCH */;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign inc_ll_rd_count = buf_req_d1;
assign inc_ll_wr_count = enq_buf_valid_d1;

always @(posedge clk) begin
	buf_ack_ptr <= deq_buf_ptr_nxt;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		buf_ack_valid <= 0;
	end else begin
		buf_ack_valid <= buf_req_d2;
	end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin
	        enq_buf_ptr_cur_d1 <= enq_buf_ptr_cur;
	        enq_buf_ptr_nxt_d1 <= enq_buf_ptr_nxt;

		buf_req_ptr_d1 <= buf_req_ptr;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		enq_buf_valid_d1 <= 0;
		buf_req_d1 <= 0;
		buf_req_d2 <= 0;
	end else begin
		enq_buf_valid_d1 <= enq_buf_valid;
		buf_req_d1 <= buf_req;
		buf_req_d2 <= buf_req_d1;
	end

/***************************** MEMORY ***************************************/
ram_1r1w_ultra #(BUF_NBITS, BUF_NBITS) u_ram_1r1w_ultra(
	.clk(clk),
	.wr(enq_buf_valid_d1),
	.raddr(buf_req_ptr_d1),
	.waddr(enq_buf_ptr_cur_d1),
	.din(enq_buf_ptr_nxt_d1),

	.dout(deq_buf_ptr_nxt));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

