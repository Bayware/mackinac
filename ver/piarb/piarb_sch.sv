//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_sch # (
parameter QUEUE_ID_NBITS = 5, // log2(`NUM_OF_PU);
parameter QUEUE_ENTRIES_NBITS = `PU_QUEUE_ENTRIES_NBITS,
parameter QUEUE_DEPTH = `NUM_OF_PU,
parameter QUEUE_PAYLOAD_NBITS = `PU_QUEUE_PAYLOAD_NBITS

) (

input clk, `RESET_SIG,

input enq_ack,			
input enq_to_empty,
input [QUEUE_ID_NBITS-1:0] enq_ack_qid,

input deq_depth_ack,
input deq_depth_from_emptyp2,

output reg deq_req,			
output reg [QUEUE_ID_NBITS-1:0] deq_qid
);

/***************************** LOCAL VARIABLES *******************************/

wire deq_qid_fifo_empty;
wire [QUEUE_ID_NBITS-1:0] lat_fifo_deq_qid;

wire [QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid;

wire enq_fifo_empty;

wire deq_push = deq_depth_ack&deq_depth_from_emptyp2;
wire push = deq_push|~enq_fifo_empty;
wire [QUEUE_ID_NBITS-1:0] push_data = deq_push?lat_fifo_deq_qid:lat_fifo_enq_qid;

wire enq_fifo_rd = ~deq_push&~enq_fifo_empty;

wire event_fifo_empty;
wire [QUEUE_ID_NBITS-1:0] deq_qid_p1;

/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	deq_qid <= deq_qid_p1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		deq_req <= 0;

	end else begin

		deq_req <= ~event_fifo_empty;

	end

/***************************** PROGRAM BODY **********************************/

/***************************** FIFO ***************************************/


sfifo2f_fo #(QUEUE_ID_NBITS, 4) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({enq_ack_qid}),				
		.rd(enq_fifo_rd),
		.wr(enq_ack&enq_to_empty),

		.ncount(),
		.count(),
		.full(),
		.empty(enq_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_qid})       
	);

sfifo2f_fo #(QUEUE_ID_NBITS, 4) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({deq_qid}),				
		.rd(deq_depth_ack),
		.wr(deq_req),

		.ncount(),
		.count(),
		.full(),
		.empty(deq_qid_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_deq_qid})       
	);

wire [QUEUE_ID_NBITS-1:0] deq_qid_p;
wire event_fifo_empty_p, lat_fifo_full;
wire lat_fifo_wr = ~event_fifo_empty_p&~lat_fifo_full;

tm_sch_event_fifo #(QUEUE_ID_NBITS, QUEUE_ID_NBITS) u_tm_sch_event_fifo_0(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.push(push),  		
	.push_data(push_data),  

	.pop(lat_fifo_wr), 

	// outputs

	.pop_data({deq_qid_p}), 
	.sch_fifo_empty(event_fifo_empty_p), 
	.fifo_count()
);

sfifo2f_fo #(QUEUE_ID_NBITS, 4) u_sfifo2f_fo_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({deq_qid_p}),				
		.rd(~event_fifo_empty),
		.wr(lat_fifo_wr),

		.ncount(),
		.count(),
		.full(lat_fifo_full),
		.empty(event_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({deq_qid_p1})       
);


/***************************** DIAGNOSTICS **********************************/

	// synopsys translate_off

	// synopsys translate_on

endmodule

