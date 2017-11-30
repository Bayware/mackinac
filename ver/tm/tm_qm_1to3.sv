//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm_qm_1to3 #(

parameter SIZE_NBITS = `FIRST_LVL_QUEUE_ID_NBITS>>3,
parameter MIN_QUEUE_AVAILABLE_LEVEL = 8,
parameter MAX_PORT_QUEUE_AVAILABLE_LEVEL = ((1<<SIZE_NBITS)-(1<<(SIZE_NBITS-2)))
) (


input clk, 
input `RESET_SIG,

input [3:0] alpha, 

input enq_req, 
input [SIZE_NBITS-1:0] enq_qid,
input sch_pkt_desc_type enq_pkt_desc,

input deq_req, 
input [SIZE_NBITS-1:0] deq_qid,

input next_qm_avail_req,		
input [SIZE_NBITS-1:0] next_qm_avail_req_qid,

input [`NUM_OF_PORTS-1:0] bm_tm_bp,


output reg head_wr,
output reg [SIZE_NBITS-1:0] head_raddr,
output reg [SIZE_NBITS-1:0] head_waddr,
output reg [SIZE_NBITS-1:0] head_wdata,
input [SIZE_NBITS-1:0] head_rdata,

output reg tail_wr,
output reg [SIZE_NBITS-1:0] tail_raddr,
output reg [SIZE_NBITS-1:0] tail_waddr,
output reg [SIZE_NBITS-1:0] tail_wdata,
input [SIZE_NBITS-1:0] tail_rdata,

output reg depth_wr,
output reg [SIZE_NBITS-1:0] depth_raddr,
output reg [SIZE_NBITS-1:0] depth_waddr,
output reg [SIZE_NBITS-1:0] depth_wdata,
input [SIZE_NBITS-1:0] depth_rdata,

output reg depth1_wr,
output reg [SIZE_NBITS-1:0] depth1_raddr,
output reg [SIZE_NBITS-1:0] depth1_waddr,
output reg [SIZE_NBITS-1:0] depth1_wdata,
input [SIZE_NBITS-1:0] depth1_rdata,

output reg ll_wr,
output reg [SIZE_NBITS-1:0] ll_raddr,
output reg [SIZE_NBITS-1:0] ll_waddr,
output reg [SIZE_NBITS-1:0] ll_wdata,
input [SIZE_NBITS-1:0] ll_rdata,

output reg pkt_desc_wr,
output reg [SIZE_NBITS-1:0] pkt_desc_raddr,
output reg [SIZE_NBITS-1:0] pkt_desc_waddr,
output sch_pkt_desc_type pkt_desc_wdata,
input sch_pkt_desc_type pkt_desc_rdata,

output reg next_qm_avail_ack,	
output reg next_qm_available,
	
output reg [`NUM_OF_PORTS-1:0] src_queue_available,
output reg [`NUM_OF_PORTS-1:0] dst_queue_available,

output reg enq_ack, 
output reg enq_to_empty, 
output reg [SIZE_NBITS-1:0] enq_ack_qid,
output reg [`PORT_ID_NBITS-1:0] enq_ack_dst_port,

output reg deq_depth_ack, 
output reg deq_depth_from_emptyp2, 

output reg deq_ack, 
output reg [SIZE_NBITS-1:0] deq_ack_qid,
output sch_pkt_desc_type deq_pkt_desc
);

/***************************** LOCAL VARIABLES *******************************/

localparam [1:0]	INIT_IDLE = 0,
		 	INIT_COUNT = 1,
		 	INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [SIZE_NBITS-1:0] init_count;

reg enq_req_d1; 
reg [SIZE_NBITS-1:0] enq_qid_d1;
sch_pkt_desc_type enq_pkt_desc_d1;

reg deq_req_d1; 
reg [SIZE_NBITS-1:0] deq_qid_d1;
reg [SIZE_NBITS-1:0] deq_qid_d2;
reg [SIZE_NBITS-1:0] deq_qid_d3;
reg [SIZE_NBITS-1:0] deq_qid_d4;


reg [`NUM_OF_PORTS-1:0] bm_tm_bp_d1;

reg next_qm_avail_req_d1;		
reg next_qm_avail_req_d2;		
reg next_qm_avail_req_d3;		

reg [3:0] alpha_d1; 

reg deq_active_d1; 
reg deq_active_d2; 
reg deq_active_d3; 
reg deq_active_d4; 
reg deq_active_d5; 

reg enq_active_d1;
reg enq_active_d2;
reg enq_active_d3;
reg enq_active_d4;

reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_src_port_d1;
reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_src_port_d2;
reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_src_port_d3;
reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_src_port_d4;

reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port_d1;
reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port_d2;
reg [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port_d3;

reg [SIZE_NBITS-1:0] lat_fifo_enq_qid_d1;
reg [SIZE_NBITS-1:0] lat_fifo_enq_qid_d2;
reg [SIZE_NBITS-1:0] lat_fifo_enq_qid_d3;

reg [SIZE_NBITS-1:0] freeq_head_d1;
reg [SIZE_NBITS-1:0] freeq_head_d2;
reg [SIZE_NBITS-1:0] freeq_head_d3;
reg [SIZE_NBITS-1:0] freeq_head_d4;

reg [SIZE_NBITS-1:0] head_wdata_d1;

reg depth_wr_d1; 
reg depth_wr_d2; 
reg [SIZE_NBITS-1:0] depth_waddr_d1;
reg [SIZE_NBITS-1:0] depth_waddr_d2;
reg [SIZE_NBITS-1:0] depth_raddr_d1;
reg [SIZE_NBITS-1:0] depth_raddr_d2;
reg [SIZE_NBITS-1:0] depth_wdata_d1;
reg [SIZE_NBITS-1:0] depth_wdata_d2;
reg [SIZE_NBITS-1:0] depth_rdata_d1;
reg [SIZE_NBITS-1:0] depth1_rdata_d1;

reg [SIZE_NBITS-1:0] tail_waddr_d1;
reg [SIZE_NBITS-1:0] tail_waddr_d2;
reg [SIZE_NBITS-1:0] tail_wdata_d1;

reg tail_same_address;
reg head_same_address;
reg depth_same_address0;
reg depth_same_address21;

reg [SIZE_NBITS-1:0] mdepth_wdata;

reg [SIZE_NBITS:0] port_queue_count0;
reg [SIZE_NBITS:0] port_queue_count1;
reg [SIZE_NBITS:0] port_queue_count2;
reg [SIZE_NBITS:0] port_queue_count3;
reg [SIZE_NBITS:0] port_queue_count4;
reg [SIZE_NBITS:0] port_queue_count5;
reg [SIZE_NBITS:0] port_queue_count6;
reg [SIZE_NBITS:0] port_queue_count7;

reg [7:0] port_queue_count_inc;
reg [7:0] port_queue_count_dec;

reg [SIZE_NBITS:0] queue_threshold;

reg deq_from_emptyp2_p1;

reg disable_deq_wr1_d1;
reg disable_deq_wr2_d1;
reg disable_deq_wr2_d2;

reg disable_enq_wr1_d1;
reg disable_enq_wr2_d1;
reg disable_enq_wr2_d2;

reg same_qid_d1;
reg same_qid_d2;
reg same_qid_d3;

reg [`PORT_ID_NBITS-1:0] deq_src_port_d1;

reg [SIZE_NBITS-1:0] mhead_rdata_d1;

reg fifo_wr5;

//

wire deq_active = deq_req_d1;

wire [SIZE_NBITS-1:0] freeq_head;
wire [SIZE_NBITS:0] freeq_count;

wire [SIZE_NBITS-1:0] nfreeq_head, nfreeq_tail;

//
wire [SIZE_NBITS-1:0] lat_fifo_enq_qid;
sch_pkt_desc_type lat_fifo_enq_pkt_desc;
wire [`PORT_ID_NBITS-1:0] lat_fifo_enq_src_port = lat_fifo_enq_pkt_desc.src_port;
wire [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port = lat_fifo_enq_pkt_desc.dst_port;

wire same_qid = lat_fifo_enq_qid==deq_qid_d1;

wire lat_fifo_empty;
wire lat_fifo_rd = (~deq_req_d1)&~lat_fifo_empty;

wire enq_active = lat_fifo_rd;

wire get_q_req = enq_active;

//

wire disable_deq_wr1 = (deq_qid_d4==lat_fifo_enq_qid_d2)&enq_active_d2;
wire disable_deq_wr2 = (deq_qid_d4==lat_fifo_enq_qid_d1)&enq_active_d1;
wire disable_deq_wr = disable_deq_wr1|disable_deq_wr2|same_qid_d3|disable_enq_wr1_d1|disable_enq_wr2_d2;

wire disable_enq_wr1 = (lat_fifo_enq_qid_d3==deq_qid_d3)&deq_active_d2;
wire disable_enq_wr2 = (lat_fifo_enq_qid_d3==deq_qid_d2)&deq_active_d1;
wire disable_enq_wr = disable_enq_wr1|disable_enq_wr2|same_qid_d3|disable_deq_wr1_d1|disable_deq_wr2_d2;

//

wire [SIZE_NBITS-1:0] fifo_tail_raddr;
wire [SIZE_NBITS-1:0] fifo_freeq_head;
wire fifo_empty5;
wire fifo_rd5 = ~deq_active_d4&~fifo_empty5;

wire deq_wr_head = deq_active_d4&deq_from_emptyp2_p1;
wire head_wr_p1 = deq_wr_head|fifo_rd5;	
wire [SIZE_NBITS-1:0] head_waddr_p1 = deq_wr_head?depth_waddr:fifo_tail_raddr;
	
wire enq_depth_wr_p1 = (enq_active_d3/*&~disable_enq_wr*/);
wire deq_depth_wr_p1 = (deq_active_d3/*&~disable_deq_wr*/);
wire cdepth_wr_p1 = deq_depth_wr_p1|enq_depth_wr_p1;

wire [SIZE_NBITS-1:0] mtail_rdata = tail_same_address?tail_wdata_d1:tail_rdata;
wire [SIZE_NBITS-1:0] mhead_rdata = head_same_address?head_wdata:head_rdata;

wire [2:0] depth_same_address_p1;
assign depth_same_address_p1[0] = (depth_raddr_d1==depth_raddr_d2)&cdepth_wr_p1;
assign depth_same_address_p1[1] = (depth_raddr_d1==depth_waddr)&depth_wr;
assign depth_same_address_p1[2] = (depth_raddr_d1==depth_waddr_d1)&depth_wr_d1;

wire [SIZE_NBITS-1:0] mdepth_wdata_p1 = depth_same_address_p1[1]?depth_wdata:depth_wdata_d1;

wire [SIZE_NBITS-1:0] mdepth_rdata = depth_same_address0?depth_wdata:
									depth_same_address21?mdepth_wdata:depth_rdata_d1;

wire enq_to_empty_p1 = /*disable_enq_wr?(mdepth_rdata==1):*/(mdepth_rdata==0);

wire [`NUM_OF_PORTS-1:0] dst_queue_available_p1;
wire freeq_avail = (freeq_count>MIN_QUEUE_AVAILABLE_LEVEL);
assign dst_queue_available_p1[0] = ~bm_tm_bp_d1[0]&freeq_avail;
assign dst_queue_available_p1[1] = ~bm_tm_bp_d1[1]&freeq_avail;
assign dst_queue_available_p1[2] = ~bm_tm_bp_d1[2]&freeq_avail;
assign dst_queue_available_p1[3] = ~bm_tm_bp_d1[3]&freeq_avail;
assign dst_queue_available_p1[4] = ~bm_tm_bp_d1[4]&freeq_avail;
assign dst_queue_available_p1[5] = ~bm_tm_bp_d1[5]&freeq_avail;
assign dst_queue_available_p1[6] = ~bm_tm_bp_d1[6]&freeq_avail;

wire [`NUM_OF_PORTS-1:0] src_queue_available_p1;
assign src_queue_available_p1[0] = (port_queue_count0<MAX_PORT_QUEUE_AVAILABLE_LEVEL);
assign src_queue_available_p1[1] = (port_queue_count1<MAX_PORT_QUEUE_AVAILABLE_LEVEL);
assign src_queue_available_p1[2] = (port_queue_count2<MAX_PORT_QUEUE_AVAILABLE_LEVEL);
assign src_queue_available_p1[3] = (port_queue_count3<MAX_PORT_QUEUE_AVAILABLE_LEVEL);
assign src_queue_available_p1[4] = (port_queue_count4<MAX_PORT_QUEUE_AVAILABLE_LEVEL);
assign src_queue_available_p1[5] = (port_queue_count5<MAX_PORT_QUEUE_AVAILABLE_LEVEL);
assign src_queue_available_p1[6] = (port_queue_count6<MAX_PORT_QUEUE_AVAILABLE_LEVEL);

wire init_wr = init_st==INIT_COUNT;

wire depth_wr_p1 = init_wr|cdepth_wr_p1;
wire [SIZE_NBITS-1:0] depth_waddr_p1 = init_wr?init_count:depth_raddr_d2;
wire [SIZE_NBITS-1:0] depth_wdata_p1 = init_wr?0:deq_active_d3?mdepth_rdata-1:mdepth_rdata+1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		enq_ack_qid <= depth_raddr_d2;
		enq_ack_dst_port <= lat_fifo_enq_dst_port_d3;
		enq_to_empty <= enq_to_empty_p1;

		deq_depth_from_emptyp2 <= mdepth_rdata>1;

		deq_ack_qid <= depth_waddr;
		deq_pkt_desc <= pkt_desc_rdata;
		next_qm_available <= depth1_rdata_d1<queue_threshold;

		head_raddr <= deq_qid_d1;
		head_wr <= head_wr_p1;	
		head_waddr <= head_waddr_p1;	
		head_wdata <= deq_wr_head?ll_rdata:fifo_freeq_head;	

		tail_raddr <= lat_fifo_enq_qid;	
		tail_wr <= enq_active_d1;
		tail_waddr <= tail_raddr;
		tail_wdata <= freeq_head_d1;

		depth_raddr <= deq_active?deq_qid_d1:lat_fifo_enq_qid;
		depth_wr <= depth_wr_p1;
		depth_waddr <= depth_waddr_p1;
		depth_wdata <= depth_wdata_p1;

		depth1_raddr <= next_qm_avail_req_qid;
		depth1_wr <= depth_wr_p1;
		depth1_waddr <= depth_waddr_p1;
		depth1_wdata <= depth_wdata_p1;

		ll_raddr <= mhead_rdata;
		ll_wr <= enq_active_d2&(depth_rdata!=0);
		ll_waddr <= mtail_rdata;
		ll_wdata <= freeq_head_d2;

		pkt_desc_raddr <= mhead_rdata;
		pkt_desc_wr <= enq_active;
		pkt_desc_waddr <= freeq_head;
		pkt_desc_wdata <= lat_fifo_enq_pkt_desc;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		next_qm_avail_ack <= 0;
		enq_ack <= 0;
		deq_depth_ack <= 0;
		deq_ack <= 0;
		src_queue_available <= 0;
		dst_queue_available <= 0;
	end else begin
		next_qm_avail_ack <= next_qm_avail_req_d3;
		enq_ack <= enq_active_d3;
		deq_depth_ack <= deq_active_d3;
		deq_ack <= deq_active_d4;
		src_queue_available <= src_queue_available_p1;
		dst_queue_available <= dst_queue_available_p1;
	end

/***************************** PROGRAM BODY **********************************/


integer i;

always @(*) begin
    for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
		port_queue_count_dec[i] = deq_active_d5&(deq_src_port_d1==i);
		port_queue_count_inc[i] = enq_active_d4&(lat_fifo_enq_src_port_d4==i);
	end
end

always @(posedge clk) begin
		alpha_d1 <= alpha;

		enq_qid_d1 <= enq_qid;
		enq_pkt_desc_d1 <= enq_pkt_desc;

		deq_qid_d1 <= deq_qid;
		deq_qid_d2 <= deq_qid_d1;
		deq_qid_d3 <= deq_qid_d2;
		deq_qid_d4 <= deq_qid_d3;

		deq_src_port_d1 <= pkt_desc_rdata.src_port;
		freeq_head_d1 <= enq_active?freeq_head:freeq_head_d1;
		freeq_head_d2 <= freeq_head_d1;
		freeq_head_d3 <= freeq_head_d2;
		freeq_head_d4 <= freeq_head_d3;

		lat_fifo_enq_src_port_d1 <= lat_fifo_enq_src_port;
		lat_fifo_enq_src_port_d2 <= lat_fifo_enq_src_port_d1;
		lat_fifo_enq_src_port_d3 <= lat_fifo_enq_src_port_d2;
		lat_fifo_enq_src_port_d4 <= lat_fifo_enq_src_port_d3;

		lat_fifo_enq_dst_port_d1 <= lat_fifo_enq_dst_port;
		lat_fifo_enq_dst_port_d2 <= lat_fifo_enq_dst_port_d1;
		lat_fifo_enq_dst_port_d3 <= lat_fifo_enq_dst_port_d2;

		lat_fifo_enq_qid_d1 <= lat_fifo_enq_qid;
		lat_fifo_enq_qid_d2 <= lat_fifo_enq_qid_d1;
		lat_fifo_enq_qid_d3 <= lat_fifo_enq_qid_d2;

		deq_from_emptyp2_p1 <= mdepth_rdata>1;

		disable_deq_wr1_d1 <= disable_deq_wr1&deq_active_d3;
		disable_deq_wr2_d1 <= disable_deq_wr2&deq_active_d3;
		disable_deq_wr2_d2 <= disable_deq_wr2_d1;

		disable_enq_wr1_d1 <= disable_enq_wr1&enq_active_d3;
		disable_enq_wr2_d1 <= disable_enq_wr2&enq_active_d3;
		disable_enq_wr2_d2 <= disable_enq_wr2_d1;

		same_qid_d1 <= same_qid&deq_req_d1&~lat_fifo_empty;
		same_qid_d2 <= same_qid_d1;
		same_qid_d3 <= same_qid_d2;

		enq_active_d1 <= enq_active;
		enq_active_d2 <= enq_active_d1;
		enq_active_d3 <= enq_active_d2;
		enq_active_d4 <= enq_active_d3;

		deq_active_d1 <= deq_active;
		deq_active_d2 <= deq_active_d1;
		deq_active_d3 <= deq_active_d2;
		deq_active_d4 <= deq_active_d3;
		deq_active_d5 <= deq_active_d4;

		tail_wdata_d1 <= tail_wdata;
		head_wdata_d1 <= head_wdata;
		depth_wdata_d1 <= depth_wdata;
		depth_wdata_d2 <= depth_wdata_d1;

		depth_rdata_d1 <= depth_rdata;
		depth1_rdata_d1 <= depth1_rdata;

		tail_waddr_d1 <= tail_waddr;
		tail_waddr_d2 <= tail_waddr_d1;

		depth_wr_d1 <= depth_wr;
		depth_wr_d2 <= depth_wr_d1;
		depth_raddr_d1 <= depth_raddr;
		depth_raddr_d2 <= depth_raddr_d1;
		depth_waddr_d1 <= depth_waddr;
		depth_waddr_d2 <= depth_waddr_d1;

		tail_same_address <= tail_wr&(tail_raddr==tail_waddr);
		head_same_address <= deq_active_d4&deq_from_emptyp2_p1&(head_raddr==depth_waddr);
		depth_same_address0 <= depth_same_address_p1[0];
		depth_same_address21 <= |depth_same_address_p1[2:1];

		mdepth_wdata <= mdepth_wdata_p1;

		queue_threshold <= alpha_d1[3]?freeq_count>>alpha_d1[2:0]:freeq_count<<alpha_d1[2:0];

		mhead_rdata_d1 <= mhead_rdata;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		bm_tm_bp_d1 <= 0;

		deq_req_d1 <= 0;
		enq_req_d1 <= 0;

		next_qm_avail_req_d1 <= 0;
		next_qm_avail_req_d2 <= 0;
		next_qm_avail_req_d3 <= 0;

		init_count <= 0;

		port_queue_count0 <= 0;
		port_queue_count1 <= 0;
		port_queue_count2 <= 0;
		port_queue_count3 <= 0;
		port_queue_count4 <= 0;
		port_queue_count5 <= 0;
		port_queue_count6 <= 0;
		port_queue_count7 <= 0;

		fifo_wr5 <= 0;

	end else begin
		bm_tm_bp_d1 <= bm_tm_bp;

		deq_req_d1 <= deq_req;
		enq_req_d1 <= enq_req;

		next_qm_avail_req_d1 <= next_qm_avail_req;
		next_qm_avail_req_d2 <= next_qm_avail_req_d1;
		next_qm_avail_req_d3 <= next_qm_avail_req_d2;

		init_count <= init_wr?init_count+1:init_count;

		port_queue_count0 <= ~(port_queue_count_inc[0]^port_queue_count_dec[0])?port_queue_count0:
							port_queue_count_inc[0]?port_queue_count0+1:port_queue_count0-1;
		port_queue_count1 <= ~(port_queue_count_inc[1]^port_queue_count_dec[1])?port_queue_count1:
							port_queue_count_inc[1]?port_queue_count1+1:port_queue_count1-1;
		port_queue_count2 <= ~(port_queue_count_inc[2]^port_queue_count_dec[2])?port_queue_count2:
							port_queue_count_inc[2]?port_queue_count2+1:port_queue_count2-1;
		port_queue_count3 <= ~(port_queue_count_inc[3]^port_queue_count_dec[3])?port_queue_count3:
							port_queue_count_inc[3]?port_queue_count3+1:port_queue_count3-1;
		port_queue_count4 <= ~(port_queue_count_inc[4]^port_queue_count_dec[4])?port_queue_count4:
							port_queue_count_inc[4]?port_queue_count4+1:port_queue_count4-1;
		port_queue_count5 <= ~(port_queue_count_inc[5]^port_queue_count_dec[5])?port_queue_count5:
							port_queue_count_inc[5]?port_queue_count5+1:port_queue_count5-1;
		port_queue_count6 <= ~(port_queue_count_inc[6]^port_queue_count_dec[6])?port_queue_count6:
							port_queue_count_inc[6]?port_queue_count6+1:port_queue_count6-1;
		port_queue_count7 <= ~(port_queue_count_inc[7]^port_queue_count_dec[7])?port_queue_count7:
							port_queue_count_inc[7]?port_queue_count7+1:port_queue_count7-1;

		fifo_wr5 <= enq_active_d3&enq_to_empty_p1;

	end

/***************************** NEXT STATE ASSIGNMENT **************************/

			always @(init_st or init_count)  begin
				nxt_init_st = init_st;
				case (init_st)		
					INIT_IDLE: nxt_init_st = INIT_COUNT;
					INIT_COUNT: if (&init_count) nxt_init_st = INIT_DONE;
					INIT_DONE: nxt_init_st = INIT_DONE;
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
sfifo2f_fo #(SIZE_NBITS, 3) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({enq_qid_d1}),				
		.rd(lat_fifo_rd),
		.wr(enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_qid})       
	);

sfifo_sch_pkt_desc #(3) u_sfifo_sch_pkt_desc_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(enq_pkt_desc_d1),				
		.rd(lat_fifo_rd),
		.wr(enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_enq_pkt_desc)       
	);

sfifo2f_fo #(SIZE_NBITS+SIZE_NBITS, 2) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({tail_waddr_d2, freeq_head_d4}),				
		.rd(fifo_rd5),
		.wr(fifo_wr5),

		.ncount(),
		.count(),
		.full(),
		.empty(fifo_empty5),
		.fullm1(),
		.emptyp2(),
		.dout({fifo_tail_raddr, fifo_freeq_head})       
	);

tm_freeq_fifo #(SIZE_NBITS) u_tm_freeq_fifo(
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.rel_q_valid(deq_active_d3),  	
	.rel_q_idx(mhead_rdata_d1),  

	.dec_freeq_count(get_q_req),
	.get_q_req(get_q_req), 

	// outputs

	.freeq_head(freeq_head), 
	.freeq_count(freeq_count)
	
);

/***************************** MEMORY ***************************************/

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

