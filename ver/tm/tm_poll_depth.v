//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_poll_depth #(

parameter SIZE_NBITS = `FIRST_LVL_QUEUE_ID_NBITS
) (

input clk, 
input `RESET_SIG,

input poll_req, 
input [SIZE_NBITS-1:0] qid,

input ll_queue_depth_ack,
input ll_queue_depth_drop,
input [`FIRST_LVL_QUEUE_ID_NBITS:0] queue_threshold,

input queue_depth_ack,
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_depth,


output reg poll_ack, 
output reg poll_drop,
output reg [SIZE_NBITS-1:0] poll_ack_qid,

output reg queue_depth_req, 
output reg [SIZE_NBITS-1:0] queue_id
);

/***************************** LOCAL VARIABLES *******************************/

reg ll_queue_depth_drop_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS:0] queue_threshold_d1;

reg queue_depth_ack_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_depth_d1;

wire [SIZE_NBITS-1:0] fifo_qid;

wire [`FIRST_LVL_QUEUE_ID_NBITS:0] fifo_queue_threshold;
wire fifo_queue_depth_drop;

wire fifo_rd = queue_depth_ack_d1;
wire queue_over_threshold = {1'b0, queue_depth_d1}>fifo_queue_threshold;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		queue_id <= qid;
		poll_drop <= fifo_queue_depth_drop|queue_over_threshold;
		poll_ack_qid <= fifo_qid;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		queue_depth_req <= 0;
		poll_ack <= 0;
	end else begin
		queue_depth_req <= poll_req;
		poll_ack <= fifo_rd;
	end

/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
		queue_threshold_d1 <= queue_threshold;
		queue_depth_d1 <= queue_depth;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		queue_depth_ack_d1 <= 0;
	end else begin
		queue_depth_ack_d1 <= queue_depth_ack;
	end 


/***************************** FIFO ***************************************/

sfifo2f_fo #(1+`FIRST_LVL_QUEUE_ID_NBITS+1, 2) u_sfifo2f_fo_1(
			.clk(clk),
			.`RESET_SIG(`RESET_SIG),

			.din({ll_queue_depth_drop, queue_threshold}),				
			.rd(fifo_rd),
			.wr(ll_queue_depth_ack),

			.ncount(),
			.count(),
			.full(),
			.empty(),
			.fullm1(),
			.emptyp2(),
			.dout({fifo_queue_depth_drop, fifo_queue_threshold})       
		);


sfifof_fo #(SIZE_NBITS, 3, 6) u_sfifof_fo_2(
			.clk(clk),
			.`RESET_SIG(`RESET_SIG),

			.din({qid}),				
			.rd(fifo_rd),
			.wr(poll_req),

			.count(),
			.full(),
			.empty(),
			.fullm1(),
			.emptyp2(),
			.dout({fifo_qid})       
		);

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

