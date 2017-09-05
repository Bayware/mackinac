//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module piarb_sch # (
parameter QUEUE_ID_NBITS = 5; // log2(`NUM_OF_PU);
parameter QUEUE_ENTRIES_NBITS = `PU_QUEUE_ENTRIES_NBITS;
parameter QUEUE_DEPTH = `NUM_OF_PU;
parameter QUEUE_PAYLOAD_NBITS = `PU_QUEUE_PAYLOAD_NBITS;

) (

input clk, `RESET_SIG,

input qm_enq_ack,			
input qm_enq_to_empty,
input [QUEUE_ID_NBITS-1:0] qm_enq_ack_qid,

input sch_deq_depth_ack,
input sch_deq_depth_from_emptyp2,

input deq_ack,
input [QUEUE_ID_NBITS-1:0] deq_ack_qid,
input [QUEUE_PAYLOAD_NBITS-1:0] sch_deq_pkt_desc,

output reg sch_enq_req,
output reg [DESC_NBITS-1:0] sch_enq_desc, // only buf_ptr required
output reg [ID_NBITS-1:0] sch_enq_src_port,
output reg [ID_NBITS-1:0] sch_enq_dst_port,
output reg [LEN_NBITS-1:0] sch_enq_len,

output reg sch_deq,			
output reg [QUEUE_ID_NBITS-1:0] sch_deq_qid
);

/***************************** LOCAL VARIABLES *******************************/

reg deq_ack_d1;
reg [QUEUE_PAYLOAD_NBITS-1:0] sch_deq_pkt_desc_d1;

wire deq_qid_fifo_empty;
wire [QUEUE_ID_NBITS-1:0] lat_fifo_deq_qid;

wire [QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid;

wire enq_fifo_empty;

wire push = sch_deq_depth_ack&sch_deq_depth_from_emptyp2|~enq_fifo_empty;
wire [QUEUE_ID_NBITS-1:0] push_data = ~enq_fifo_empty?:lat_fifo_deq_qid;

wire event_fifo_empty;
wire [QUEUE_ID_NBITS-1:0] deq_qid_p1;

/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	sch_deq_qid <= deq_qid_p1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		sch_deq <= 0;

	end else begin

		sch_deq <= ~event_fifo_empty;

	end

/***************************** PROGRAM BODY **********************************/

/***************************** FIFO ***************************************/


sfifo2f_fo #(QUEUE_ID_NBITS, 4) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({qm_enq_ack_qid}),				
		.rd(queue_profile_ack_d1),
		.wr(qm_enq_ack&qm_enq_to_empty),

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

		.din({sch_deq_qid}),				
		.rd(sch_deq_depth_ack),
		.wr(sch_deq),

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

