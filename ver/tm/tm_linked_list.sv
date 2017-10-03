//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm_linked_list (


input clk, 
input `RESET_SIG,

input [3:0] alpha, 

input queue_depth_req, 

input poll_ack, 
input poll_drop, 

input enq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] enq_qid,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] enq_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] enq_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] enq_port_queue_id,
input sch_pkt_desc_type enq_pkt_desc,

input deq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] deq_qid,


input depth_enq_ack,
input depth_enq_to_empty,

input depth_deq_ack,
input depth_deq_from_emptyp2,

output reg [`FIRST_LVL_QUEUE_ID_NBITS:0] queue_threshold,

output reg ll_queue_depth_ack, 
output reg ll_queue_depth_drop,

output reg depth_enq_req, 
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_enq_qid,

output reg depth_deq_req, 
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid,

output reg depth_deq_req1, 
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid1,
output reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_id,
output reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_group_id,
output reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_deq_port_queue_id,

output reg active_enq_ack, 
output reg active_enq_to_empty, 
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] active_enq_ack_qid,
output reg [`PORT_ID_NBITS-1:0] active_enq_ack_dst_port,

output reg sch_deq_ack, 
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] sch_deq_ack_qid,
output sch_pkt_desc_type sch_deq_pkt_desc
);

/***************************** LOCAL VARIABLES *******************************/

localparam POLL_LATENCY = 4;

reg [3:0] alpha_d1; 

reg poll_ack_d1; 
reg poll_drop_d1; 


reg deq_active_d1; 
reg deq_active_d2; 
reg deq_active_d3; 
reg deq_active_d4; 

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fifo_deq_qid_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fifo_deq_qid_d2;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fifo_deq_qid_d3;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] freeq_head_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] freeq_head_d2;

reg enq_active_d1;
reg enq_active_d2;

reg ll_wr; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ll_waddr, ll_raddr;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ll_wdata;

reg head_wr; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_waddr, head_raddr;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_wdata;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_wdata_d1;

reg tail_wr; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tail_waddr, tail_raddr;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tail_wdata;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tail_wdata_d1;

reg pkt_desc_wr; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_waddr, pkt_desc_raddr;
pkt_desc_type pkt_desc_wdata;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_raddr_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_raddr_d2;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_raddr_d3;

reg tail_same_address;
reg head_same_address;

reg fifo_depth_enq_to_empty_d1;
reg fifo_depth_enq_to_empty_d2;

reg fifo_depth_deq_from_emptyp2_d1;
reg fifo_depth_deq_from_emptyp2_d2;
reg fifo_depth_deq_from_emptyp2_d3;
reg fifo_depth_deq_from_emptyp2_d4;


wire fifo_empty7;
wire fifo_depth_deq_from_emptyp2;

wire fifo_empty6;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fifo_deq_qid;

wire disable_deq = deq_active_d1&(fifo_deq_qid==fifo_deq_qid_d1)|
                   deq_active_d2&(fifo_deq_qid==fifo_deq_qid_d2)|
                   deq_active_d3&(fifo_deq_qid==fifo_deq_qid_d3);

wire fifo_rd6 = ~fifo_empty6&~fifo_empty7;

wire deq_active = fifo_rd6;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] freeq_head;
wire [`FIRST_LVL_QUEUE_ID_NBITS:0] freeq_count;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ll_rdata  /* synthesis keep = 1 */;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] head_rdata  /* synthesis keep = 1 */;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] tail_rdata  /* synthesis keep = 1 */;
pkt_desc_type pkt_desc_rdata  /* synthesis keep = 1 */;

wire lat_fifo_enq_drop;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid;
sch_pkt_desc_type lat_fifo_enq_pkt_desc;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_enq_conn_id;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_enq_conn_group_id;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_enq_port_queue_id;

wire fifo_empty4;
wire fifo_depth_enq_to_empty;

wire lat_fifo_empty;
wire lat_fifo_rd = ~lat_fifo_empty&~fifo_empty4;

wire enq_active = lat_fifo_rd;

wire get_q_req = enq_active;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fifo_enq_qid;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] fifo_freeq_head;
wire fifo_empty5;
wire fifo_rd5 = ~deq_active_d4&~fifo_empty5;

sch_pkt_desc_type p_desc;
assign p_desc = pkt_desc_rdata.sch_pkt_desc;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		queue_threshold <= alpha_d1[3]?freeq_count>>alpha_d1[2:0]:freeq_count<<alpha_d1[2:0];

		ll_queue_depth_drop <= freeq_count<POLL_LATENCY;

		depth_enq_qid <= enq_qid;

		depth_deq_qid <= deq_qid;

		depth_deq_qid1 <= pkt_desc_rdata.q_id;
		depth_deq_conn_id <= pkt_desc_rdata.conn_id;
		depth_deq_conn_group_id <= pkt_desc_rdata.conn_group_id;
		depth_deq_port_queue_id <= pkt_desc_rdata.port_queue_id;

		active_enq_to_empty <= fifo_depth_enq_to_empty;
		active_enq_ack_qid <= lat_fifo_enq_qid;
		active_enq_ack_dst_port <= lat_fifo_enq_pkt_desc.dst_port;

		sch_deq_ack_qid <= head_raddr_d3;
		sch_deq_pkt_desc <= p_desc;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		ll_queue_depth_ack <= 0;
		depth_enq_req <= 0;
		depth_deq_req <= 0;
		depth_deq_req1 <= 0;
		active_enq_ack <= 0;
		sch_deq_ack <= 0;
	end else begin
		ll_queue_depth_ack <= queue_depth_req;
		depth_enq_req <= enq_req;
		depth_deq_req <= deq_req;
		depth_deq_req1 <= deq_active_d4;
		active_enq_ack <= enq_active;		// should not be too early
		sch_deq_ack <= deq_active_d4;
	end

/***************************** PROGRAM BODY **********************************/

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] mtail_rdata = tail_same_address?tail_wdata_d1:tail_rdata;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] mhead_rdata = head_same_address?head_wdata:head_rdata;

always @(posedge clk) begin
		alpha_d1 <= alpha;

		poll_drop_d1 <= poll_drop;

		fifo_deq_qid_d1 <= fifo_deq_qid;
		fifo_deq_qid_d2 <= fifo_deq_qid_d1;
		fifo_deq_qid_d3 <= fifo_deq_qid_d2;

		tail_raddr <= lat_fifo_enq_qid;	// enq_active
		tail_wr <= enq_active_d1;
		tail_waddr <= tail_raddr;
		tail_wdata <= freeq_head_d1;

		head_raddr <= fifo_deq_qid;	// deq_active
		head_wr <= (deq_active_d4&fifo_depth_deq_from_emptyp2_d4)|~fifo_empty5;	
		head_waddr <= deq_active_d4?head_raddr_d3:fifo_enq_qid;	
		head_wdata <= deq_active_d4?ll_rdata:fifo_freeq_head;	

		ll_raddr <= mhead_rdata;
		ll_wr <= enq_active_d2&~fifo_depth_enq_to_empty_d2;
		ll_waddr <= mtail_rdata;
		ll_wdata <= freeq_head_d2;

		pkt_desc_raddr <= mhead_rdata;
		pkt_desc_wr <= enq_active;
		pkt_desc_waddr <= freeq_head;
		pkt_desc_wdata.q_id <= lat_fifo_enq_qid;
		pkt_desc_wdata.conn_id <= lat_fifo_enq_conn_id;
		pkt_desc_wdata.conn_group_id <= lat_fifo_enq_conn_group_id;
		pkt_desc_wdata.port_queue_id <= lat_fifo_enq_port_queue_id;
		pkt_desc_wdata.sch_pkt_desc <= lat_fifo_enq_pkt_desc;

		head_raddr_d1 <= head_raddr;
		head_raddr_d2 <= head_raddr_d1;
		head_raddr_d3 <= head_raddr_d2;

		tail_same_address <= tail_wr&(tail_raddr==tail_waddr);
		head_same_address <= deq_active_d4&fifo_depth_deq_from_emptyp2_d4&(head_raddr==head_raddr_d3);

		tail_wdata_d1 <= tail_wdata;
		head_wdata_d1 <= head_wdata;

		enq_active_d1 <= enq_active;
		enq_active_d2 <= enq_active_d1;

		deq_active_d1 <= deq_active;
		deq_active_d2 <= deq_active_d1;
		deq_active_d3 <= deq_active_d2;
		deq_active_d4 <= deq_active_d3;

		freeq_head_d1 <= enq_active?freeq_head:freeq_head_d1;
		freeq_head_d2 <= freeq_head_d1;

		fifo_depth_enq_to_empty_d1 <= fifo_depth_enq_to_empty;
		fifo_depth_enq_to_empty_d2 <= fifo_depth_enq_to_empty_d1;

		fifo_depth_deq_from_emptyp2_d1 <= fifo_depth_deq_from_emptyp2;
		fifo_depth_deq_from_emptyp2_d2 <= fifo_depth_deq_from_emptyp2_d1;
		fifo_depth_deq_from_emptyp2_d3 <= fifo_depth_deq_from_emptyp2_d2;
		fifo_depth_deq_from_emptyp2_d4 <= fifo_depth_deq_from_emptyp2_d3;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		poll_ack_d1 <= 0;
	end else begin
		poll_ack_d1 <= poll_ack;
	end


/***************************** FIFO ***************************************/

sfifo2f_fo #(`SECOND_LVL_QUEUE_ID_NBITS+`THIRD_LVL_QUEUE_ID_NBITS+`FOURTH_LVL_QUEUE_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS, 3) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({enq_conn_id, enq_conn_group_id, enq_port_queue_id, enq_qid}),				
		.rd(lat_fifo_rd),
		.wr(enq_req),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_conn_id, lat_fifo_enq_conn_group_id, lat_fifo_enq_port_queue_id, lat_fifo_enq_qid})       
	);

sfifo_sch_pkt_desc #(3) u_sfifo_sch_pkt_desc_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(enq_pkt_desc),				
		.rd(lat_fifo_rd),
		.wr(enq_req),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_enq_pkt_desc)       
	);

sfifo2f_fo #(1, 2) u_sfifo2f_fo_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(depth_enq_to_empty),				
		.rd(lat_fifo_rd),
		.wr(depth_enq_ack),

		.ncount(),
		.count(),
		.full(),
		.empty(fifo_empty4),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_depth_enq_to_empty)       
	);

sfifo2f_fo #(`FIRST_LVL_QUEUE_ID_NBITS+`FIRST_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({lat_fifo_enq_qid, freeq_head}),				
		.rd(fifo_rd5),
		.wr(enq_active&fifo_depth_enq_to_empty),

		.ncount(),
		.count(),
		.full(),
		.empty(fifo_empty5),
		.fullm1(),
		.emptyp2(),
		.dout({fifo_enq_qid, fifo_freeq_head})       
	);

sfifo2f_fo #(`FIRST_LVL_QUEUE_ID_NBITS, 4) u_sfifo2f_fo_6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(deq_qid),				
		.rd(fifo_rd6),
		.wr(deq_req),

		.ncount(),
		.count(),
		.full(),
		.empty(fifo_empty6),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_deq_qid)       
	);

sfifo2f_fo #(1, 3) u_sfifo2f_fo_7(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(depth_deq_from_emptyp2),				
		.rd(fifo_rd6),
		.wr(depth_deq_ack),

		.ncount(),
		.count(),
		.full(),
		.empty(fifo_empty7),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_depth_deq_from_emptyp2)       
	);

tm_freeq_fifo u_tm_freeq_fifo(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.rel_q_valid(deq_active_d2),  	
	.rel_q_idx(mhead_rdata),  

	.dec_freeq_count(poll_ack_d1&~poll_drop_d1),
	.get_q_req(get_q_req), 

	// outputs

	.freeq_head(freeq_head), 
	.freeq_count(freeq_count)
	
);

/***************************** MEMORY ***************************************/
ram_1r1w #(`FIRST_LVL_QUEUE_ID_NBITS, `FIRST_LVL_QUEUE_ID_NBITS) u_ram_1r1w_0(
			.clk(clk),
			.wr(head_wr),
			.raddr(head_raddr),
			.waddr(head_waddr),
			.din(head_wdata),

			.dout(head_rdata));

ram_1r1w #(`FIRST_LVL_QUEUE_ID_NBITS, `FIRST_LVL_QUEUE_ID_NBITS) u_ram_1r1w_1(
        .clk(clk),
        .wr(tail_wr),
        .raddr(tail_raddr),
		.waddr(tail_waddr),
        .din(tail_wdata),

        .dout(tail_rdata));

ram_1r1w #(`FIRST_LVL_QUEUE_ID_NBITS, `FIRST_LVL_QUEUE_ID_NBITS) u_ram_1r1w_2(
		.clk(clk),
		.wr(ll_wr),
		.raddr(ll_raddr),
		.waddr(ll_waddr),
		.din(ll_wdata),

		.dout(ll_rdata));

ram_1r1w_bram_pkt_desc #(`FIRST_LVL_QUEUE_ID_NBITS) u_ram_1r1w_bram_pkt_desc(
		.clk(clk),
		.wr(pkt_desc_wr),
		.raddr(pkt_desc_raddr),
		.waddr(pkt_desc_waddr),
		.din(pkt_desc_wdata),

		.dout(pkt_desc_rdata));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

