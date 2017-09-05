//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module piarb_qm #(
parameter QUEUE_ID_NBITS = `PU_ID_NBITS, // log2(`NUM_OF_PU);
parameter ID_NBITS = 5, // log2(`NUM_OF_PU);
parameter QUEUE_ENTRIES_NBITS = `PU_QUEUE_ENTRIES_NBITS,
parameter QUEUE_PAYLOAD_NBITS = `PU_QUEUE_PAYLOAD_NBITS
) (

input clk, 
input `RESET_SIG,

input enq_req, 
input [QUEUE_ID_NBITS-1:0] enq_qid,
input pu_queue_payload_type enq_desc,
input enq_fid_sel,

input deq_req, 
input [QUEUE_ID_NBITS-1:0] deq_qid,

input pu_fid_done, 
input [QUEUE_ID_NBITS-1:0] pu_id,
input pu_fid_sel,



output reg head_wr,
output reg [QUEUE_ID_NBITS-1:0] head_raddr,
output reg [QUEUE_ID_NBITS-1:0] head_waddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] head_wdata,
input [QUEUE_ENTRIES_NBITS-1:0] head_rdata,

output reg tail_wr,
output reg [QUEUE_ID_NBITS-1:0] tail_raddr,
output reg [QUEUE_ID_NBITS-1:0] tail_waddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] tail_wdata,
input [QUEUE_ENTRIES_NBITS-1:0] tail_rdata,

output reg depth_wr,
output reg [QUEUE_ID_NBITS-1:0] depth_raddr,
output reg [QUEUE_ID_NBITS-1:0] depth_waddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] depth_wdata,
input [QUEUE_ENTRIES_NBITS-1:0] depth_rdata,

output reg depth_fid0_wr,
output reg [QUEUE_ID_NBITS-1:0] depth_fid0_raddr,
output reg [QUEUE_ID_NBITS-1:0] depth_fid0_waddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_wdata,
input [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_rdata,

output reg depth_fid1_wr,
output reg [QUEUE_ID_NBITS-1:0] depth_fid1_raddr,
output reg [QUEUE_ID_NBITS-1:0] depth_fid1_waddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_wdata,
input [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_rdata,

output reg ll_wr,
output reg [QUEUE_ENTRIES_NBITS-1:0] ll_raddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] ll_waddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] ll_wdata,
input [QUEUE_ENTRIES_NBITS-1:0] ll_rdata,

output reg desc_wr,
output reg [QUEUE_ENTRIES_NBITS-1:0] desc_raddr,
output reg [QUEUE_ENTRIES_NBITS-1:0] desc_waddr,
output pu_queue_payload_type desc_wdata,
input pu_queue_payload_type desc_rdata,

output reg enq_ack, 
output reg enq_to_empty, 
output reg [QUEUE_ID_NBITS-1:0] enq_ack_qid,
output reg [`PORT_ID_NBITS-1:0] enq_ack_dst_port,

output reg deq_depth_ack, 
output reg deq_depth_from_emptyp2, 

output reg deq_ack, 
output reg [QUEUE_ID_NBITS-1:0] deq_ack_qid,
output pu_queue_payload_type deq_ack_desc
);

/***************************** LOCAL VARIABLES *******************************/

localparam MIN_QUEUE_ID_AVAILABLE_LEVEL = (1<<6);
localparam MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL = (1<<QUEUE_ENTRIES_NBITS)-MIN_QUEUE_ID_AVAILABLE_LEVEL;

localparam [1:0]	INIT_IDLE = 0,
		 	INIT_COUNT = 1,
		 	INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [QUEUE_ENTRIES_NBITS-1:0] init_count;

reg enq_req_d1; 
reg [QUEUE_ID_NBITS-1:0] enq_qid_d1;
pu_queue_payload_type enq_desc_d1;

reg deq_req_d1; 
reg [QUEUE_ID_NBITS-1:0] deq_qid_d1;
reg [QUEUE_ID_NBITS-1:0] deq_qid_d2;
reg [QUEUE_ID_NBITS-1:0] deq_qid_d3;
reg [QUEUE_ID_NBITS-1:0] deq_qid_d4;



reg [3:0] alpha_d1; 

reg pu_done_active_d1; 
reg pu_done_active_d2; 
reg pu_done_active_d3; 
reg pu_done_active_d4; 
reg pu_done_active_d5; 

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

reg [QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid_d1;
reg [QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid_d2;
reg [QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid_d3;

reg lat_fifo_enq_fid_sel_d1;
reg lat_fifo_enq_fid_sel_d2;
reg lat_fifo_enq_fid_sel_d3;

reg [QUEUE_ENTRIES_NBITS-1:0] freeq_head_d1;
reg [QUEUE_ENTRIES_NBITS-1:0] freeq_head_d2;
reg [QUEUE_ENTRIES_NBITS-1:0] freeq_head_d3;
reg [QUEUE_ENTRIES_NBITS-1:0] freeq_head_d4;

reg [QUEUE_ENTRIES_NBITS-1:0] head_wdata_d1;

reg depth_wr_d1; 
reg depth_wr_d2; 
reg [QUEUE_ID_NBITS-1:0] depth_waddr_d1;
reg [QUEUE_ID_NBITS-1:0] depth_waddr_d2;
reg [QUEUE_ID_NBITS-1:0] depth_raddr_d1;
reg [QUEUE_ID_NBITS-1:0] depth_raddr_d2;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_wdata_d1;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_wdata_d2;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_rdata_d1;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_rdata_d1;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_rdata_d1;

reg [QUEUE_ID_NBITS-1:0] tail_waddr_d1;
reg [QUEUE_ID_NBITS-1:0] tail_waddr_d2;
reg [QUEUE_ENTRIES_NBITS-1:0] tail_wdata_d1;

reg tail_same_address;
reg head_same_address;
reg depth_same_address0;
reg depth_same_address21;

reg depth_fid0_wr_d1;
reg depth_fid0_wr_d2;
reg [QUEUE_ID_NBITS-1:0] depth_fid0_waddr_d1;
reg [QUEUE_ID_NBITS-1:0] depth_fid0_waddr_d2;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_wdata_d1;
reg [QUEUE_ID_NBITS-1:0] depth_fid0_raddr_d1;
reg [QUEUE_ID_NBITS-1:0] depth_fid0_raddr_d2;

reg depth_fid1_wr_d1;
reg depth_fid1_wr_d2;
reg [QUEUE_ID_NBITS-1:0] depth_fid1_waddr_d1;
reg [QUEUE_ID_NBITS-1:0] depth_fid1_waddr_d2;
reg [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_wdata_d1;
reg [QUEUE_ID_NBITS-1:0] depth_fid1_raddr_d1;
reg [QUEUE_ID_NBITS-1:0] depth_fid1_raddr_d2;

reg depth_fid0_same_address0;
reg depth_fid0_same_address21;

reg depth_fid1_same_address0;
reg depth_fid1_same_address21;

reg [QUEUE_ENTRIES_NBITS-1:0] mdepth_wdata;
reg [QUEUE_ENTRIES_NBITS-1:0] mdepth_fid0_wdata;
reg [QUEUE_ENTRIES_NBITS-1:0] mdepth_fid1_wdata;

reg [QUEUE_ENTRIES_NBITS:0] port_queue_count0;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count1;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count2;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count3;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count4;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count5;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count6;
reg [QUEUE_ENTRIES_NBITS:0] port_queue_count7;

reg [7:0] port_queue_count_inc;
reg [7:0] port_queue_count_dec;

reg [QUEUE_ENTRIES_NBITS:0] queue_threshold;

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

reg [QUEUE_ENTRIES_NBITS-1:0] mhead_rdata_d1;

reg fifo_wr5;

reg [QUEUE_ID_NBITS-1:0] lat_fifo_pu_id_d1;
reg [QUEUE_ID_NBITS-1:0] lat_fifo_pu_id_d2;
reg [QUEUE_ID_NBITS-1:0] lat_fifo_pu_id_d3;
reg lat_fifo_pu_fid_sel_d1;
reg lat_fifo_pu_fid_sel_d2;
reg lat_fifo_pu_fid_sel_d3;

reg [`NUM_OF_PU-1:0] src_queue_available;
reg [`NUM_OF_PU-1:0] dst_queue_available;
//

wire[3:0] alpha = 0;

wire lat_fifo_empty3;
wire [QUEUE_ID_NBITS-1:0] lat_fifo_pu_id;
wire lat_fifo_pu_fid_sel;

wire deq_active = deq_req_d1;
wire pu_done_active = deq_active&~lat_fifo_empty3;

wire [QUEUE_ENTRIES_NBITS-1:0] freeq_head;
wire [QUEUE_ENTRIES_NBITS:0] freeq_count;

wire [QUEUE_ENTRIES_NBITS-1:0] nfreeq_head, nfreeq_tail;

//
wire lat_fifo_enq_fid_sel;
wire [QUEUE_ID_NBITS-1:0] lat_fifo_enq_qid;
pu_queue_payload_type lat_fifo_enq_desc;
wire [`PORT_ID_NBITS-1:0] lat_fifo_enq_src_port = lat_fifo_enq_desc.pp_piarb_meta.port;
wire [`PORT_ID_NBITS-1:0] lat_fifo_enq_dst_port = 0;

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

wire [QUEUE_ID_NBITS-1:0] fifo_tail_raddr;
wire [QUEUE_ENTRIES_NBITS-1:0] fifo_freeq_head;
wire fifo_empty5;
wire fifo_rd5 = ~deq_active_d4&~fifo_empty5;

wire head_wr_p1 = (deq_active_d4&deq_from_emptyp2_p1)|fifo_rd5;	
wire [QUEUE_ID_NBITS-1:0] head_waddr_p1 = deq_active_d4?depth_waddr:fifo_tail_raddr;
	
wire enq_depth_wr_p1 = (enq_active_d3/*&~disable_enq_wr*/);
wire deq_depth_wr_p1 = (deq_active_d3/*&~disable_deq_wr*/);
wire depth_fid_wr_p1 = (pu_done_active_d3/*&~disable_deq_wr*/);
wire cdepth_wr_p1 = deq_depth_wr_p1|enq_depth_wr_p1;
wire cdepth_fid0_wr_p1 = depth_fid_wr_p1&~lat_fifo_pu_fid_sel_d3|enq_depth_wr_p1&~lat_fifo_enq_fid_sel_d3;
wire cdepth_fid1_wr_p1 = depth_fid_wr_p1&lat_fifo_pu_fid_sel_d3|enq_depth_wr_p1&lat_fifo_enq_fid_sel_d3;

wire [QUEUE_ENTRIES_NBITS-1:0] mtail_rdata = tail_same_address?tail_wdata_d1:tail_rdata;
wire [QUEUE_ENTRIES_NBITS-1:0] mhead_rdata = head_same_address?head_wdata:head_rdata;

wire [2:0] depth_same_address_p1;
assign depth_same_address_p1[0] = (depth_raddr_d1==depth_raddr_d2)&cdepth_wr_p1;
assign depth_same_address_p1[1] = (depth_raddr_d1==depth_waddr)&depth_wr;
assign depth_same_address_p1[2] = (depth_raddr_d1==depth_waddr_d1)&depth_wr_d1;

wire [QUEUE_ENTRIES_NBITS-1:0] mdepth_wdata_p1 = depth_same_address_p1[1]?depth_wdata:depth_wdata_d1;

wire [QUEUE_ENTRIES_NBITS-1:0] mdepth_rdata = depth_same_address0?depth_wdata:
							depth_same_address21?mdepth_wdata:depth_rdata_d1;

wire enq_to_empty_p1 = /*disable_enq_wr?(mdepth_rdata==1):*/(mdepth_rdata==0);

wire [2:0] depth_fid0_same_address_p1;
assign depth_fid0_same_address_p1[0] = (depth_fid0_raddr_d1==depth_fid0_raddr_d2)&cdepth_fid0_wr_p1;
assign depth_fid0_same_address_p1[1] = (depth_fid0_raddr_d1==depth_fid0_waddr)&depth_fid0_wr;
assign depth_fid0_same_address_p1[2] = (depth_fid0_raddr_d1==depth_fid0_waddr_d1)&depth_fid0_wr_d1;

wire [QUEUE_ENTRIES_NBITS-1:0] mdepth_fid0_wdata_p1 = depth_fid0_same_address_p1[1]?depth_fid0_wdata:depth_fid0_wdata_d1;

wire [QUEUE_ENTRIES_NBITS-1:0] mdepth_fid0_rdata = depth_fid0_same_address0?depth_fid0_wdata:
							depth_fid0_same_address21?mdepth_fid0_wdata:depth_fid0_rdata_d1;

wire [2:0] depth_fid1_same_address_p1;
assign depth_fid1_same_address_p1[0] = (depth_fid1_raddr_d1==depth_fid1_raddr_d2)&cdepth_fid1_wr_p1;
assign depth_fid1_same_address_p1[1] = (depth_fid1_raddr_d1==depth_fid1_waddr)&depth_fid1_wr;
assign depth_fid1_same_address_p1[2] = (depth_fid1_raddr_d1==depth_fid1_waddr_d1)&depth_fid1_wr_d1;

wire [QUEUE_ENTRIES_NBITS-1:0] mdepth_fid1_wdata_p1 = depth_fid1_same_address_p1[1]?depth_fid1_wdata:depth_fid1_wdata_d1;

wire [QUEUE_ENTRIES_NBITS-1:0] mdepth_fid1_rdata = depth_fid1_same_address0?depth_fid1_wdata:
							depth_fid1_same_address21?mdepth_fid1_wdata:depth_fid1_rdata_d1;


wire [`NUM_OF_PU-1:0] dst_queue_available_p1;
wire freeq_avail = (freeq_count>MIN_QUEUE_ID_AVAILABLE_LEVEL);
assign dst_queue_available_p1[0] = freeq_avail;
assign dst_queue_available_p1[1] = freeq_avail;
assign dst_queue_available_p1[2] = freeq_avail;
assign dst_queue_available_p1[3] = freeq_avail;
assign dst_queue_available_p1[4] = freeq_avail;
assign dst_queue_available_p1[5] = freeq_avail;
assign dst_queue_available_p1[6] = freeq_avail;
assign dst_queue_available_p1[7] = freeq_avail;

wire [`NUM_OF_PU-1:0] src_queue_available_p1;
assign src_queue_available_p1[0] = (port_queue_count0<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[1] = (port_queue_count1<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[2] = (port_queue_count2<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[3] = (port_queue_count3<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[4] = (port_queue_count4<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[5] = (port_queue_count5<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[6] = (port_queue_count6<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);
assign src_queue_available_p1[7] = (port_queue_count7<MAX_PORT_QUEUE_ID_AVAILABLE_LEVEL);

wire init_wr = init_st==INIT_COUNT;

wire depth_wr_p1 = init_wr|cdepth_wr_p1;
wire [QUEUE_ID_NBITS-1:0] depth_waddr_p1 = init_wr?init_count:depth_raddr_d2;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_wdata_p1 = init_wr?0:deq_active_d3?mdepth_rdata-1:mdepth_rdata+1;

wire depth_fid0_wr_p1 = init_wr|cdepth_fid0_wr_p1;
wire [QUEUE_ID_NBITS-1:0] depth_fid0_waddr_p1 = init_wr?init_count:depth_fid0_raddr_d2;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_fid0_wdata_p1 = init_wr?0:pu_done_active_d3?mdepth_fid0_rdata-1:mdepth_fid0_rdata+1;

wire depth_fid1_wr_p1 = init_wr|cdepth_fid1_wr_p1;
wire [QUEUE_ID_NBITS-1:0] depth_fid1_waddr_p1 = init_wr?init_count:depth_fid1_raddr_d2;
wire [QUEUE_ENTRIES_NBITS-1:0] depth_fid1_wdata_p1 = init_wr?0:pu_done_active_d3?mdepth_fid1_rdata-1:mdepth_fid1_rdata+1;


/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		enq_ack_qid <= depth_raddr_d2;
		enq_ack_dst_port <= lat_fifo_enq_dst_port_d3;
		enq_to_empty <= enq_to_empty_p1;

		deq_depth_from_emptyp2 <= mdepth_rdata>1;

		deq_ack_qid <= depth_waddr;
		deq_ack_desc <= desc_rdata;

		head_raddr <= deq_qid_d1;
		head_wr <= head_wr_p1;	
		head_waddr <= head_waddr_p1;	
		head_wdata <= deq_active_d4?ll_rdata:fifo_freeq_head;	

		tail_raddr <= lat_fifo_enq_qid;	
		tail_wr <= enq_active_d1;
		tail_waddr <= tail_raddr;
		tail_wdata <= freeq_head_d1;

		depth_raddr <= deq_active?deq_qid_d1:lat_fifo_enq_qid;
		depth_wr <= depth_wr_p1;
		depth_waddr <= depth_waddr_p1;
		depth_wdata <= depth_wdata_p1;

		depth_fid0_raddr <= pu_done_active?lat_fifo_pu_id_d1:lat_fifo_enq_qid;
		depth_fid0_wr <= depth_fid0_wr_p1;
		depth_fid0_waddr <= depth_fid0_waddr_p1;
		depth_fid0_wdata <= depth_fid0_wdata_p1;

		depth_fid1_raddr <= pu_done_active?lat_fifo_pu_id_d1:lat_fifo_enq_qid;
		depth_fid1_wr <= depth_fid1_wr_p1;
		depth_fid1_waddr <= depth_fid1_waddr_p1;
		depth_fid1_wdata <= depth_fid1_wdata_p1;

		ll_raddr <= mhead_rdata;
		ll_wr <= enq_active_d2&(depth_rdata!=0);
		ll_waddr <= mtail_rdata;
		ll_wdata <= freeq_head_d2;

		desc_raddr <= mhead_rdata;
		desc_wr <= enq_active;
		desc_waddr <= freeq_head;
		desc_wdata <= lat_fifo_enq_desc;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		enq_ack <= 0;
		deq_depth_ack <= 0;
		deq_ack <= 0;
		src_queue_available <= 0;
		dst_queue_available <= 0;
	end else begin
		enq_ack <= enq_active_d3;
		deq_depth_ack <= deq_active_d3;
		deq_ack <= deq_active_d4;
		src_queue_available <= src_queue_available_p1;
		dst_queue_available <= dst_queue_available_p1;
	end

/***************************** PROGRAM BODY **********************************/


integer i;

always @(*) begin
    for (i = 0; i < `NUM_OF_PU; i = i+1) begin
		port_queue_count_dec[i] = deq_active_d5&(deq_src_port_d1==i);
		port_queue_count_inc[i] = enq_active_d4&(lat_fifo_enq_src_port_d4==i);
	end
end

always @(posedge clk) begin
		alpha_d1 <= alpha;

		enq_qid_d1 <= enq_qid;
		enq_desc_d1 <= enq_desc;

		deq_qid_d1 <= deq_qid;
		deq_qid_d2 <= deq_qid_d1;
		deq_qid_d3 <= deq_qid_d2;
		deq_qid_d4 <= deq_qid_d3;

		deq_src_port_d1 <= desc_rdata.pp_piarb_meta.port;;
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

		lat_fifo_enq_fid_sel_d1 <= lat_fifo_enq_fid_sel;
		lat_fifo_enq_fid_sel_d2 <= lat_fifo_enq_fid_sel_d1;
		lat_fifo_enq_fid_sel_d3 <= lat_fifo_enq_fid_sel_d2;

		lat_fifo_pu_fid_sel_d1 <= lat_fifo_pu_fid_sel;
		lat_fifo_pu_fid_sel_d2 <= lat_fifo_pu_fid_sel_d1;
		lat_fifo_pu_fid_sel_d3 <= lat_fifo_pu_fid_sel_d2;

		lat_fifo_pu_id_d1 <= lat_fifo_pu_id;
		lat_fifo_pu_id_d2 <= lat_fifo_pu_id_d1;
		lat_fifo_pu_id_d3 <= lat_fifo_pu_id_d2;

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

		pu_done_active_d1 <= pu_done_active;
		pu_done_active_d2 <= pu_done_active_d1;
		pu_done_active_d3 <= pu_done_active_d2;
		pu_done_active_d4 <= pu_done_active_d3;
		pu_done_active_d5 <= pu_done_active_d4;

		tail_wdata_d1 <= tail_wdata;
		head_wdata_d1 <= head_wdata;
		depth_wdata_d1 <= depth_wdata;
		depth_wdata_d2 <= depth_wdata_d1;

		depth_rdata_d1 <= depth_rdata;

		tail_waddr_d1 <= tail_waddr;
		tail_waddr_d2 <= tail_waddr_d1;

		depth_wr_d1 <= depth_wr;
		depth_wr_d2 <= depth_wr_d1;
		depth_raddr_d1 <= depth_raddr;
		depth_raddr_d2 <= depth_raddr_d1;
		depth_waddr_d1 <= depth_waddr;
		depth_waddr_d2 <= depth_waddr_d1;

		depth_fid0_wr_d1 <= depth_fid0_wr;
		depth_fid0_raddr_d1 <= depth_fid0_raddr;
		depth_fid0_raddr_d2 <= depth_fid0_raddr_d1;
		depth_fid0_waddr_d1 <= depth_fid0_waddr;
		depth_fid0_waddr_d2 <= depth_fid0_waddr_d1;

		depth_fid1_wr_d2 <= depth_fid1_wr_d1;
		depth_fid1_raddr_d1 <= depth_fid1_raddr;
		depth_fid1_raddr_d2 <= depth_fid1_raddr_d1;
		depth_fid1_waddr_d1 <= depth_fid1_waddr;
		depth_fid1_waddr_d2 <= depth_fid1_waddr_d1;

		tail_same_address <= tail_wr&(tail_raddr==tail_waddr);
		head_same_address <= deq_active_d4&deq_from_emptyp2_p1&(head_raddr==depth_waddr);
		depth_same_address0 <= depth_same_address_p1[0];
		depth_same_address21 <= |depth_same_address_p1[2:1];

		depth_fid0_same_address0 <= depth_fid0_same_address_p1[0];
		depth_fid0_same_address21 <= |depth_fid0_same_address_p1[2:1];

		depth_fid1_same_address0 <= depth_fid1_same_address_p1[0];
		depth_fid1_same_address21 <= |depth_fid1_same_address_p1[2:1];

		mdepth_wdata <= mdepth_wdata_p1;
		mdepth_fid0_wdata <= mdepth_fid0_wdata_p1;
		mdepth_fid1_wdata <= mdepth_fid1_wdata_p1;

		queue_threshold <= alpha_d1[3]?freeq_count>>alpha_d1[2:0]:freeq_count<<alpha_d1[2:0];

		mhead_rdata_d1 <= mhead_rdata;

end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		deq_req_d1 <= 0;
		enq_req_d1 <= 0;

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

		deq_req_d1 <= deq_req;
		enq_req_d1 <= enq_req;

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
sfifo2f_fo #(QUEUE_ID_NBITS+1, 3) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({enq_qid_d1, enq_fid_sel}),				
		.rd(lat_fifo_rd),
		.wr(enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_enq_qid, lat_fifo_enq_fid_sel})       
	);

sfifo_pu_queue_payload #(3) u_sfifo_pu_queue_payload(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(enq_desc_d1),				
		.rd(lat_fifo_rd),
		.wr(enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_enq_desc)       
	);

sfifo2f_fo #(QUEUE_ID_NBITS+QUEUE_ENTRIES_NBITS, 2) u_sfifo2f_fo_5(
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

sfifo2f_fo #(QUEUE_ID_NBITS+1, 3) u_sfifo2f_fo_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pu_id, pu_fid_sel}),				
		.rd(pu_done_active),
		.wr(pu_fid_done),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty3),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_pu_id, lat_fifo_fid_sel})       
	);

tm_freeq_fifo #(QUEUE_ENTRIES_NBITS) u_tm_freeq_fifo(
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

