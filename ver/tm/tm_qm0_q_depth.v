//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : QM0 queue
//===========================================================================

`include "defines.vh"

module tm_qm0_q_depth (
	clk,
    reset,

    depth_enq_req,
    depth_enq_qid,

	depth_deq_req,
	depth_deq_qid,

	// outputs

	depth_enq_ack,
	depth_enq_to_empty,	// enqueue to empty queue

	depth_deq_ack,
	depth_deq_from_emptyp2	// dequeue to queue with at least 2 entries

);

input clk, reset;

// egress processor enqueue request
input depth_enq_req; 
input [`QUEUE_BITS-1:0] depth_enq_qid;

// scheduler dequeue  request
input depth_deq_req; 
input [`QUEUE_BITS-1:0] depth_deq_qid;

output depth_enq_ack;
output depth_enq_to_empty;

output depth_deq_ack;
output depth_deq_from_emptyp2;

/***************************** LOCAL VARIABLES *******************************/
parameter [1:0]	 INIT_IDLE = 0,
			 INIT_COUNT = 1,
			 INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [`QUEUE_BITS-1:0] init_count;

reg depth_enq_ack;
reg depth_enq_to_empty;

reg depth_deq_ack;
reg depth_deq_from_emptyp2;

// egress processor enqueue request
reg depth_enq_req_d1; 
reg [`QUEUE_BITS-1:0] depth_enq_qid_d1;

// scheduler dequeue request
reg depth_deq_req_d1; 
reg depth_deq_req_d2;

reg [`QUEUE_BITS-1:0] depth_deq_qid_d1;
reg [`QUEUE_BITS-1:0] depth_deq_qid_d2;

reg ram_queue_wr;
reg [`QUEUE_BITS-1:0] ram_queue_raddr_d1;
reg [`QUEUE_BITS-1:0] ram_queue_waddr;
reg [`QUEUE_BITS-1:0] ram_queue_wdata;
reg [`QUEUE_BITS-1:0] ram_queue_wdata_d1;

reg enq_lat_fifo_rd0_d1;
reg [`QUEUE_BITS-1:0] lat_depth_enq_qid_d1;

reg [1:0] queue_same_addr;

reg same_qid_d1;
reg disable_deq_q_wr1_d1;
reg disable_enq_q_wr1_d1;


wire enq_lat_fifo_empty0;
wire [`QUEUE_BITS-1:0] lat_depth_enq_qid;

wire same_qid = depth_deq_qid_d1==lat_depth_enq_qid;
wire enq_lat_fifo_rd0 = (~depth_deq_req_d1/*|same_qid*/)&~enq_lat_fifo_empty0;

wire disable_deq_q_wr1 = (depth_deq_qid_d2==lat_depth_enq_qid)&enq_lat_fifo_rd0;
wire disable_deq_q_wr = disable_deq_q_wr1|same_qid_d1|disable_enq_q_wr1_d1;

wire disable_enq_q_wr1 = (lat_depth_enq_qid_d1==depth_deq_qid_d1)&depth_deq_req_d1;
wire disable_enq_q_wr = disable_enq_q_wr1|same_qid_d1|disable_deq_q_wr1_d1;

wire ram_queue_wr_p1 = (depth_deq_req_d2/*&~disable_deq_q_wr*/)|(enq_lat_fifo_rd0_d1/*&~disable_enq_q_wr*/);

wire [`QUEUE_BITS-1:0] ram_queue_raddr = depth_deq_req_d1?depth_deq_qid_d1:lat_depth_enq_qid;
 
wire [`QUEUE_BITS-1:0] ram_queue_depth;

/*
wire [`QUEUE_BITS-1:0] mram_queue_depth = queue_same_addr[0]?ram_queue_wdata:
											queue_same_addr[1]?ram_queue_wdata_d1:
											ram_queue_depth;
*/

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		depth_enq_to_empty <= /*disable_enq_q_wr?
									(queue_same_addr[0]?(ram_queue_wdata==1):
									queue_same_addr[1]?(ram_queue_wdata_d1==1):(ram_queue_depth==1)):*/
									(queue_same_addr[0]?(ram_queue_wdata==0):
									queue_same_addr[1]?(ram_queue_wdata_d1==0):(ram_queue_depth==0));
		depth_deq_from_emptyp2 <= queue_same_addr[0]?(ram_queue_wdata>1):
									queue_same_addr[1]?(ram_queue_wdata_d1>1):(ram_queue_depth>1);
end

always @(`CLK_RST) 
    if (reset) begin
		depth_enq_ack <= 0;
		depth_deq_ack <= 0;
	end else begin
		depth_enq_ack <= enq_lat_fifo_rd0_d1;
		depth_deq_ack <= depth_deq_req_d2;
	end

/***************************** PROGRAM BODY **********************************/

wire init_wr = init_st==INIT_COUNT;

always @(posedge clk) begin
		depth_deq_req_d1 <= depth_deq_req;
		depth_deq_req_d2 <= depth_deq_req_d1;
		depth_deq_qid_d1 <= depth_deq_qid;
		depth_deq_qid_d2 <= depth_deq_qid_d1;

		depth_enq_req_d1 <= depth_enq_req;
		depth_enq_qid_d1 <= depth_enq_qid;

		enq_lat_fifo_rd0_d1 <= enq_lat_fifo_rd0;
		lat_depth_enq_qid_d1 <= lat_depth_enq_qid;

		same_qid_d1 <= same_qid&depth_deq_req_d1&~enq_lat_fifo_empty0;

		disable_deq_q_wr1_d1 <= disable_deq_q_wr1&depth_deq_req_d2;

		disable_enq_q_wr1_d1 <= disable_enq_q_wr1&enq_lat_fifo_rd0_d1;

		ram_queue_raddr_d1 <= ram_queue_raddr;
		ram_queue_waddr <= ram_queue_raddr_d1;
		ram_queue_wdata <= depth_deq_req_d2?
									(queue_same_addr[0]?(ram_queue_wdata-1):
									queue_same_addr[1]?(ram_queue_wdata_d1-1):(ram_queue_depth-1)):
									(queue_same_addr[0]?(ram_queue_wdata+1):
									queue_same_addr[1]?(ram_queue_wdata_d1+1):(ram_queue_depth+1));
		ram_queue_wdata_d1 <= ram_queue_wdata;

		queue_same_addr[0] <= ram_queue_wr_p1&(ram_queue_raddr_d1==ram_queue_raddr);
		queue_same_addr[1] <= ram_queue_wr&(ram_queue_waddr==ram_queue_raddr);
end


always @(`CLK_RST) 
    if (reset) begin
		init_count <= 0;
		ram_queue_wr <= 0;
	end else begin
		init_count <= init_wr?init_count+1:init_count;
		ram_queue_wr <= ram_queue_wr_p1;
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
			if (reset)
				init_st <= INIT_IDLE;
			else 
				init_st <= nxt_init_st;


/***************************** FIFO ***************************************/

// arbitration latency FIFO
sfifo2f_fo #(`QUEUE_BITS, 2) u_sfifo2f_fo_4(
		.clk(clk),
		.reset(reset),

		.din({depth_enq_qid_d1}),				
		.rd(enq_lat_fifo_rd0),
		.wr(depth_enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(enq_lat_fifo_empty0),
		.fullm1(),
		.emptyp2(),
		.dout({lat_depth_enq_qid})       
	);


/***************************** MEMORY ***************************************/
// queue depth
ram_1r1w #(`QUEUE_BITS, `QUEUE_BITS) u_ram_1r1w_0(
        .clk(clk),
        .wr(init_wr|ram_queue_wr),
        .raddr(ram_queue_raddr),
		.waddr(init_wr?init_count:ram_queue_waddr),
        .din(init_wr?{(`QUEUE_BITS){1'b0}}:ram_queue_wdata),

        .dout(ram_queue_depth));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

