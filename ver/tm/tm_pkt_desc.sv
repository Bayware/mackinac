//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module tm_pkt_desc (

input clk, 
input `RESET_SIG,

input rd_pkt_desc_req,
input sch_pkt_desc_type rd_pkt_desc_in,

input wr_pkt_desc_req,
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_qid,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_port_queue_id,
input enq_pkt_desc_type wr_pkt_desc,

output reg rd_pkt_desc_ack,
output enq_pkt_desc_type rd_pkt_desc,

output reg wr_pkt_desc_ack,
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_qid,
output reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_conn_id,
output reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_conn_group_id,
output reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_ack_port_queue_id,
output sch_pkt_desc_type wr_pkt_desc_out

);

/***************************** LOCAL VARIABLES *******************************/

localparam [1:0] INIT_IDLE = 0,
		 INIT_FREEQ = 1,
		 INIT_DONE = 2;

localparam EXT_PKT_DESC_NBITS = `SECOND_LVL_QUEUE_ID_NBITS+`THIRD_LVL_QUEUE_ID_NBITS+`FOURTH_LVL_QUEUE_ID_NBITS+`ENQ_PKT_DESC_NBITS;

reg [1:0] init_st, nxt_init_st;
     
reg rd_pkt_desc_req_d1;
reg rd_pkt_desc_req_d2;
sch_pkt_desc_type rd_pkt_desc_in_d1;
sch_pkt_desc_type rd_pkt_desc_in_d2;

reg wr_pkt_desc_req_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_qid_d1;
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_conn_id_d1;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_conn_group_id_d1;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] wr_pkt_desc_port_queue_id_d1;
enq_pkt_desc_type wr_pkt_desc_d1;

reg fifo_rd_d1;

reg freeq_init_wr;

reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_conn_id_d1;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_conn_group_id_d1;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_port_queue_id_d1;
enq_pkt_desc_type pkt_desc_rdata_d1;

wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_conn_id  /* synthesis keep = 1 */;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_conn_group_id  /* synthesis keep = 1 */;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] pkt_desc_port_queue_id  /* synthesis keep = 1 */;
enq_pkt_desc_type pkt_desc_rdata  /* synthesis keep = 1 */;

wire [`PKT_DESC_DEPTH_NBITS-1:0] prefetch_fifo_dout;
wire prefetch_fifo_full, prefetch_fifo_fullm1;

wire [`PKT_DESC_DEPTH_NBITS-1:0] fifo_dout;
wire fifo_empty;
wire [`PKT_DESC_DEPTH_NBITS-1:0] fifo_wptr;

sch_pkt_desc_type wr_pkt_desc_out_p1;
assign wr_pkt_desc_out_p1.src_port = wr_pkt_desc_d1.src_port;
assign wr_pkt_desc_out_p1.dst_port = wr_pkt_desc_d1.dst_port;
assign wr_pkt_desc_out_p1.len = wr_pkt_desc_d1.ed_cmd.len;
assign wr_pkt_desc_out_p1.idx = prefetch_fifo_dout;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/
always @(posedge clk) begin
		rd_pkt_desc <= pkt_desc_rdata;

		wr_pkt_desc_out <= wr_pkt_desc_out_p1;

		wr_pkt_desc_ack_qid <= wr_pkt_desc_qid_d1;
		wr_pkt_desc_ack_conn_id <= wr_pkt_desc_conn_id_d1;
		wr_pkt_desc_ack_conn_group_id <= wr_pkt_desc_conn_group_id_d1;
		wr_pkt_desc_ack_port_queue_id <= wr_pkt_desc_port_queue_id_d1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		rd_pkt_desc_ack <= 0;
		wr_pkt_desc_ack <= 0;
	end else begin
		rd_pkt_desc_ack <= rd_pkt_desc_req_d2;
		wr_pkt_desc_ack <= wr_pkt_desc_req_d1;
	end

/***************************** PROGRAM BODY **********************************/

wire prefetch_fifo_wr = fifo_rd_d1;

wire fifo_rd = ~freeq_init_wr&~fifo_empty&~(prefetch_fifo_wr&prefetch_fifo_fullm1|prefetch_fifo_full);

wire fifo_wr = freeq_init_wr|rd_pkt_desc_req_d1;

always @(posedge clk) begin
		rd_pkt_desc_in_d1 <= rd_pkt_desc_in;
		rd_pkt_desc_in_d2 <= rd_pkt_desc_in_d1;
		wr_pkt_desc_qid_d1 <= wr_pkt_desc_qid;
		wr_pkt_desc_conn_id_d1 <= wr_pkt_desc_conn_id;
		wr_pkt_desc_conn_group_id_d1 <= wr_pkt_desc_conn_group_id;
		wr_pkt_desc_port_queue_id_d1 <= wr_pkt_desc_port_queue_id;
		wr_pkt_desc_d1 <= wr_pkt_desc;

		pkt_desc_conn_id_d1 <= pkt_desc_conn_id;
		pkt_desc_conn_group_id_d1 <= pkt_desc_conn_group_id;
		pkt_desc_port_queue_id_d1 <= pkt_desc_port_queue_id;
		pkt_desc_rdata_d1 <= pkt_desc_rdata;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		rd_pkt_desc_req_d1 <= 0;
		rd_pkt_desc_req_d2 <= 0;
		wr_pkt_desc_req_d1 <= 0;
		freeq_init_wr <= 1'b0;
		fifo_rd_d1 <= 0;
	end else begin
		rd_pkt_desc_req_d1 <= rd_pkt_desc_req;
		rd_pkt_desc_req_d2 <= rd_pkt_desc_req_d1;
		wr_pkt_desc_req_d1 <= wr_pkt_desc_req;
		freeq_init_wr <= (nxt_init_st==INIT_FREEQ);
		fifo_rd_d1 <= fifo_rd;
	end
 
/***************************** NEXT STATE ASSIGNMENT **************************/
always @(*)  begin
	nxt_init_st = init_st;
	case (init_st)		
		INIT_IDLE: nxt_init_st = INIT_FREEQ;
		INIT_FREEQ: if (fifo_wptr==`PKT_DESC_DEPTH-1) nxt_init_st = INIT_DONE;
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

wire [`PKT_DESC_DEPTH_NBITS-1:0] fifo_din = freeq_init_wr?fifo_wptr:rd_pkt_desc_in_d1.idx;

sfifo2f_ram #(`PKT_DESC_DEPTH_NBITS, `PKT_DESC_DEPTH_NBITS, `PKT_DESC_DEPTH) u_sfifo2f_ram(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_din),				
    .rd(fifo_rd),
    .wr(fifo_wr),

	.wptr(fifo_wptr), 
	.count(), 
	.full(),
	.empty(fifo_empty),
    .dout(fifo_dout)       
);

sfifo2f_fo #(`PKT_DESC_DEPTH_NBITS, 2) u_sfifo2f_fo_0(
    .clk(clk),
    .`RESET_SIG(`RESET_SIG),

	.din(fifo_dout),				
    .rd(wr_pkt_desc_req_d1),
    .wr(prefetch_fifo_wr),

	.ncount(),
	.count(),
	.full(prefetch_fifo_full),
	.empty(),
	.fullm1(prefetch_fifo_fullm1),
	.emptyp2(),
    .dout(prefetch_fifo_dout)       
);

/***************************** MEMORY ***************************************/
ext_pkt_desc_type ram_din;
ext_pkt_desc_type ram_dout /* synthesis keep = 1 */;
assign ram_din.conn_id = wr_pkt_desc_conn_id_d1;
assign ram_din.conn_group_id = wr_pkt_desc_conn_group_id_d1;
assign ram_din.port_queue_id = wr_pkt_desc_port_queue_id_d1;
assign ram_din.enq_pkt_desc = wr_pkt_desc_d1;

// packet descriptor memory
ram_1r1w_bram_ext_pkt_desc #(`PKT_DESC_DEPTH_NBITS) u_ram_1r1w_bram_ext_pkt_desc(
		.clk(clk),
		.wr(wr_pkt_desc_req_d1),
		.raddr(rd_pkt_desc_in_d1.idx),
		.waddr(prefetch_fifo_dout),
		.din(ram_din),

		.dout(ram_dout));

assign pkt_desc_conn_id = ram_dout.conn_id;
assign pkt_desc_conn_group_id = ram_dout.conn_group_id;
assign pkt_desc_port_queue_id = ram_dout.port_queue_id;
assign pkt_desc_rdata = ram_dout.enq_pkt_desc;

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

