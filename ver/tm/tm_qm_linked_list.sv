//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : queue manager linked list
//===========================================================================

`include "defines.vh"

import meta_package:;*;

module tm_qm_linked_list (
	clk,
    reset,

	alpha,

    queue_depth_req,	// wred request for queue depth
    queue_depth_req_hp,	
    queue_depth_req_mirror,	

	wred_ack,
	wred_drop,

	enq_req,			// enqueue operation
	enq_qid,			// queue ID
	enq_q_group_id,			
	enq_tunnel_id,			
	enq_port_queue_id,			
	enq_pkt_desc,		// packet descriptor index

	deq_req,			// dequeue operation
	deq_qid,

	depth_enq_ack,			
	depth_enq_to_empty,	// enqueue to empty queue

	depth_deq_ack,			
	depth_deq_from_emptyp2,	

	// outputs

	queue_threshold,

	ll_queue_depth_ack,	// freeq_count will be checked and decremented if not 0	
	ll_queue_depth_drop,	// freeq_count==0	
					 
    depth_enq_req,		// enqueue depths request
    depth_enq_qid,

	depth_deq_req,		// dequeue depths request
	depth_deq_qid,

	depth_deq_req1,		// dequeue depths request
	depth_deq_qid1,
	depth_deq_q_group_id,
	depth_deq_tunnel_id,
	depth_deq_port_queue_id,

	esrh_enq_ack,			
	esrh_enq_ack_qid,
	esrh_enq_ack_dst_port,
	esrh_enq_to_empty,

	sch_deq_ack,			// dequeue acknowledgement
	sch_deq_ack_qid,
	sch_deq_pkt_desc

);

input clk, reset;

input [3:0] alpha; 

input queue_depth_req; 
input queue_depth_req_hp; 
input queue_depth_req_mirror; 

input wred_ack; 
input wred_drop; 

input enq_req; 
input [`QUEUE_BITS-1:0] enq_qid;
input [`QUEUE_GROUP_BITS-1:0] enq_q_group_id;
input [`TUNNEL_BITS-1:0] enq_tunnel_id;
input [`FOURTH_QUEUE_BITS-1:0] enq_port_queue_id;
input sch_pkt_desc_type enq_pkt_desc;

input deq_req; 
input [`QUEUE_BITS-1:0] deq_qid;

// queue properties returned

input depth_enq_ack;
input depth_enq_to_empty;

input depth_deq_ack;
input depth_deq_from_emptyp2;

output [`QUEUE_BITS:0] queue_threshold;

output ll_queue_depth_ack; 
output ll_queue_depth_drop;

output depth_enq_req; 
output [`QUEUE_BITS-1:0] depth_enq_qid;

// scheduler dequeue  request
output depth_deq_req; 
output [`QUEUE_BITS-1:0] depth_deq_qid;

output depth_deq_req1; 
output [`QUEUE_BITS-1:0] depth_deq_qid1;
output [`QUEUE_GROUP_BITS-1:0] depth_deq_q_group_id;
output [`TUNNEL_BITS-1:0] depth_deq_tunnel_id;
output [`FOURTH_QUEUE_BITS-1:0] depth_deq_port_queue_id;

output esrh_enq_ack; 
output esrh_enq_to_empty; 
output [`QUEUE_BITS-1:0] esrh_enq_ack_qid;
output [`PORT_BITS-1:0] esrh_enq_ack_dst_port;

output sch_deq_ack; 
output [`QUEUE_BITS-1:0] sch_deq_ack_qid;
output sch_pkt_desc_type sch_deq_pkt_desc;

/***************************** LOCAL VARIABLES *******************************/

reg [`QUEUE_BITS:0] queue_threshold;

reg esrh_enq_ack; 
reg esrh_enq_to_empty; 
reg [`QUEUE_BITS-1:0] esrh_enq_ack_qid;
reg [`PORT_BITS-1:0] esrh_enq_ack_dst_port;

reg depth_deq_req; 
reg [`QUEUE_BITS-1:0] depth_deq_qid;

reg depth_deq_req1; 
reg [`QUEUE_BITS-1:0] depth_deq_qid1;
reg [`QUEUE_GROUP_BITS-1:0] depth_deq_q_group_id;
reg [`TUNNEL_BITS-1:0] depth_deq_tunnel_id;
reg [`FOURTH_QUEUE_BITS-1:0] depth_deq_port_queue_id;

reg ll_queue_depth_ack; 
reg ll_queue_depth_drop;

reg depth_enq_req; 
reg [`QUEUE_BITS-1:0] depth_enq_qid;

reg sch_deq_ack; 
reg [`QUEUE_BITS-1:0] sch_deq_ack_qid; 
sch_pkt_desc_type sch_deq_pkt_desc;

reg [3:0] alpha_d1; 

reg wred_ack_d1; 
reg wred_drop_d1; 


reg deq_active_d1; 
reg deq_active_d2; 
reg deq_active_d3; 
reg deq_active_d4; 

reg [`QUEUE_BITS-1:0] fifo_deq_qid_d1;
reg [`QUEUE_BITS-1:0] fifo_deq_qid_d2;
reg [`QUEUE_BITS-1:0] fifo_deq_qid_d3;

reg [`QUEUE_BITS-1:0] freeq_head_d1;
reg [`QUEUE_BITS-1:0] freeq_head_d2;

reg enq_active_d1;
reg enq_active_d2;

reg ll_wr; 
reg [`QUEUE_BITS-1:0] ll_waddr, ll_raddr;
reg [`QUEUE_BITS-1:0] ll_wdata;

reg head_wr; 
reg [`QUEUE_BITS-1:0] head_waddr, head_raddr;
reg [`QUEUE_BITS-1:0] head_wdata;

reg [`QUEUE_BITS-1:0] head_wdata_d1;

reg tail_wr; 
reg [`QUEUE_BITS-1:0] tail_waddr, tail_raddr;
reg [`QUEUE_BITS-1:0] tail_wdata;

reg [`QUEUE_BITS-1:0] tail_wdata_d1;

reg pkt_desc_wr; 
reg [`QUEUE_BITS-1:0] pkt_desc_waddr, pkt_desc_raddr;
reg [`QUEUE_BITS+`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS-1:0] pkt_desc_wdata;
sch_pkt-desc_type pkt_desc_wdata_struct;

reg [`QUEUE_BITS-1:0] head_raddr_d1;
reg [`QUEUE_BITS-1:0] head_raddr_d2;
reg [`QUEUE_BITS-1:0] head_raddr_d3;

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
wire [`QUEUE_BITS-1:0] fifo_deq_qid;

// dequeue rate: every 4 clocks
wire disable_deq = deq_active_d1&(fifo_deq_qid==fifo_deq_qid_d1)|
                   deq_active_d2&(fifo_deq_qid==fifo_deq_qid_d2)|
                   deq_active_d3&(fifo_deq_qid==fifo_deq_qid_d3);

wire fifo_rd6 = ~fifo_empty6&~fifo_empty7/*&~disable_deq*/;

wire deq_active = fifo_rd6;

wire [`QUEUE_BITS-1:0] freeq_head;
wire [`QUEUE_BITS:0] freeq_count;

wire [`QUEUE_BITS-1:0] ll_rdata  /* synthesis keep = 1 */;
wire [`QUEUE_BITS-1:0] head_rdata  /* synthesis keep = 1 */;
wire [`QUEUE_BITS-1:0] tail_rdata  /* synthesis keep = 1 */;
wire [`QUEUE_BITS+`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS-1:0] pkt_desc_rdata  /* synthesis keep = 1 */;
sch_pkt_desc_type pkt_desc_rdata_struct  /* synthesis keep = 1 */;

wire lat_fifo_enq_drop;
wire [`QUEUE_BITS-1:0] lat_fifo_enq_qid;
sch_pkt_desc_type lat_fifo_enq_pkt_desc;
wire [`QUEUE_GROUP_BITS-1:0] lat_fifo_enq_q_group_id;
wire [`TUNNEL_BITS-1:0] lat_fifo_enq_tunnel_id;
wire [`FOURTH_QUEUE_BITS-1:0] lat_fifo_enq_port_queue_id;

wire fifo_empty4;
wire fifo_depth_enq_to_empty;

wire lat_fifo_empty;
wire lat_fifo_rd = ~lat_fifo_empty&~fifo_empty4;

wire enq_active = lat_fifo_rd;

wire get_q_req = enq_active;

wire [`QUEUE_BITS-1:0] fifo_enq_qid;
wire [`QUEUE_BITS-1:0] fifo_freeq_head;
wire fifo_empty5;
wire fifo_rd5 = ~deq_active_d4&~fifo_empty5;

sch_pkt_desc_type p_desc = pkt_desc_rdata_struct;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		queue_threshold <= alpha_d1[3]?freeq_count>>alpha_d1[2:0]:freeq_count<<alpha_d1[2:0];

		ll_queue_depth_drop <= queue_depth_req_hp?freeq_count<`WRED_LATENCY:
								queue_depth_req_mirror?freeq_count<(`Q_HP_RESERVED+1):
														freeq_count<`Q_HP_RESERVED;
		depth_enq_qid <= enq_qid;

		depth_deq_qid <= deq_qid;

		depth_deq_qid1 <= pkt_desc_rdata[`QUEUE_BITS+`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE-1:`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE];
		depth_deq_q_group_id <= pkt_desc_rdata[`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE-1:`TUNNEL_BITS+`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE];
		depth_deq_tunnel_id <= pkt_desc_rdata[`TUNNEL_BITS+`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE-1:`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE];
		depth_deq_port_queue_id <= pkt_desc_rdata[`FOURTH_QUEUE_BITS+`SCH_PKT_DESC_SIZE-1:`SCH_PKT_DESC_SIZE];

		esrh_enq_to_empty <= fifo_depth_enq_to_empty;
		esrh_enq_ack_qid <= lat_fifo_enq_qid;
		esrh_enq_ack_dst_port <= lat_fifo_enq_pkt_desc.dst_port;

		sch_deq_ack_qid <= head_raddr_d3;
		sch_deq_pkt_desc <= p_desc;
end

always @(`CLK_RST) 
    if (reset) begin
		ll_queue_depth_ack <= 0;
		depth_enq_req <= 0;
		depth_deq_req <= 0;
		depth_deq_req1 <= 0;
		esrh_enq_ack <= 0;
		sch_deq_ack <= 0;
	end else begin
		ll_queue_depth_ack <= queue_depth_req;
		depth_enq_req <= enq_req;
		depth_deq_req <= deq_req;
		depth_deq_req1 <= deq_active_d4;
		esrh_enq_ack <= enq_active;		// should not be too early
		sch_deq_ack <= deq_active_d4;
	end

/***************************** PROGRAM BODY **********************************/

wire [`QUEUE_BITS-1:0] mtail_rdata = tail_same_address?tail_wdata_d1:tail_rdata;
wire [`QUEUE_BITS-1:0] mhead_rdata = head_same_address?head_wdata:head_rdata;

always @(posedge clk) begin
		alpha_d1 <= alpha;

		wred_drop_d1 <= wred_drop;

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
		pkt_desc_wdata <= {lat_fifo_enq_qid, lat_fifo_enq_q_group_id, lat_fifo_enq_tunnel_id, lat_fifo_enq_port_queue_id, lat_fifo_enq_pkt_desc};

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
/*
1 clock throughput to the same queue
enq_active: read tail, freeq_head update initiated   
enq_active_d1: tail address available, freeq_head updated, and write packet descriptor
enq_active_d2: tail data available; write tail
enq_active_d3: write head if empty, and write ll

1 clock throughput to the same queue
deq_active: read head initiated
deq_active_d1: head_raddr available
deq_active_d2: head data available
deq_active_d3: release to freeq, read ll, read packet descriptor 
deq_active_d4: ll data available (write head address available)
deq_active_d5: write head
*/

always @(`CLK_RST) 
    if (reset) begin
		wred_ack_d1 <= 0;
	end else begin
		wred_ack_d1 <= wred_ack;
	end


/***************************** FIFO ***************************************/

// arbitration latency FIFO 
sfifo2f_fo #(`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS+`QUEUE_BITS, 3) u_sfifo2f_fo_1(
		.clk(clk),
		.reset(reset),

		.din({enq_q_group_id, enq_tunnel_id, enq_port_queue_id, enq_qid}),				
		.rd(lat_fifo_rd),
		.wr(enq_req),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_q_group_id, lat_fifo_enq_tunnel_id, lat_fifo_enq_port_queue_id, lat_fifo_enq_qid})       
	);

sfifo_sch_pkt_desc #(3) u_sfifo_sch_pkt_desc_1(
		.clk(clk),
		.reset(reset),

		.din({enq_pkt_desc}),				
		.rd(lat_fifo_rd),
		.wr(enq_req),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_pkt_desc})       
	);

// save depth_enq_to_empty
sfifo2f_fo #(1, 2) u_sfifo2f_fo_4(
		.clk(clk),
		.reset(reset),

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

// save "writing to head for empty queue" for arbitration latency
sfifo2f_fo #(`QUEUE_BITS+`QUEUE_BITS, 2) u_sfifo2f_fo_5(
		.clk(clk),
		.reset(reset),

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

// deq rate adaptation FIFO
sfifo2f_fo #(`QUEUE_BITS, 4) u_sfifo2f_fo_6(
		.clk(clk),
		.reset(reset),

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

// save depth_deq_from_emptyp2
sfifo2f_fo #(1, 3) u_sfifo2f_fo_7(
		.clk(clk),
		.reset(reset),

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
	.reset(reset),

	.rel_q_valid(deq_active_d2),  		// release queue ready pulse
	.rel_q_idx(mhead_rdata),  

	.dec_freeq_count(wred_ack_d1&~wred_drop_d1), // pre-decrement when wred request is active
	.get_q_req(get_q_req), 

	// outputs

	.freeq_head(freeq_head), 
	.freeq_count(freeq_count)
	
);

/***************************** MEMORY ***************************************/
// head memory
ram_1r1w #(`QUEUE_BITS, `QUEUE_BITS) u_ram_1r1w_0(
			.clk(clk),
			.wr(head_wr),
			.raddr(head_raddr),
			.waddr(head_waddr),
			.din(head_wdata),

			.dout(head_rdata));

// tail memory
ram_1r1w #(`QUEUE_BITS, `QUEUE_BITS) u_ram_1r1w_1(
        .clk(clk),
        .wr(tail_wr),
        .raddr(tail_raddr),
		.waddr(tail_waddr),
        .din(tail_wdata),

        .dout(tail_rdata));

// linked list memory
ram_1r1w #(`QUEUE_BITS, `QUEUE_BITS) u_ram_1r1w_2(
		.clk(clk),
		.wr(ll_wr),
		.raddr(ll_raddr),
		.waddr(ll_waddr),
		.din(ll_wdata),

		.dout(ll_rdata));

// packet descriptor memory
ram_1r1w #(`QUEUE_BITS+`QUEUE_GROUP_BITS+`TUNNEL_BITS+`FOURTH_QUEUE_BITS, `QUEUE_BITS) u_ram_1r1w_3(
		.clk(clk),
		.wr(pkt_desc_wr),
		.raddr(pkt_desc_raddr),
		.waddr(pkt_desc_waddr),
		.din(pkt_desc_wdata),

		.dout(pkt_desc_rdata));

ram_1r1w_bram_sch_pkt_desc #(`QUEUE_BITS) u_ram_1r1w_bram_sch_pkt_desc(
		.clk(clk),
		.wr(pkt_desc_wr),
		.raddr(pkt_desc_raddr),
		.waddr(pkt_desc_waddr),
		.din(pkt_desc_wdata_struct),

		.dout(pkt_desc_rdata_struct));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

