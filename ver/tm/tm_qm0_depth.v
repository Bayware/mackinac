//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_qm0_depth (


input clk, 
input `RESET_SIG,


input enq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] enq_qid,


input deq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] deq_qid,

output reg enq_ack,
output reg enq_to_empty,

output reg deq_ack,
output reg deq_from_emptyp2
);

/***************************** LOCAL VARIABLES *******************************/
parameter [1:0]	 INIT_IDLE = 0,
			 INIT_COUNT = 1,
			 INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] init_count;

// egress processor enqueue request
reg enq_req_d1; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] enq_qid_d1;

// scheduler dequeue request
reg deq_req_d1; 
reg deq_req_d2;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] deq_qid_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] deq_qid_d2;

reg ram_queue_wr;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_raddr_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_waddr;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_wdata;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_wdata_d1;

reg enq_lat_fifo_rd0_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_enq_qid_d1;

reg [1:0] queue_same_addr;

reg same_qid_d1;
reg disable_deq_q_wr1_d1;
reg disable_enq_q_wr1_d1;


wire enq_lat_fifo_empty0;
wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_enq_qid;

wire same_qid = deq_qid_d1==lat_enq_qid;
wire enq_lat_fifo_rd0 = (~deq_req_d1)&~enq_lat_fifo_empty0;

wire disable_deq_q_wr1 = (deq_qid_d2==lat_enq_qid)&enq_lat_fifo_rd0;
wire disable_deq_q_wr = disable_deq_q_wr1|same_qid_d1|disable_enq_q_wr1_d1;

wire disable_enq_q_wr1 = (lat_enq_qid_d1==deq_qid_d1)&deq_req_d1;
wire disable_enq_q_wr = disable_enq_q_wr1|same_qid_d1|disable_deq_q_wr1_d1;

wire ram_queue_wr_p1 = (deq_req_d2)|(enq_lat_fifo_rd0_d1);

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_raddr = deq_req_d1?deq_qid_d1:lat_enq_qid;
 
(* dont_touch = "true" *) wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_depth ;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		enq_to_empty <= (queue_same_addr[0]?(ram_queue_wdata==0):queue_same_addr[1]?(ram_queue_wdata_d1==0):(ram_queue_depth==0));
		deq_from_emptyp2 <= queue_same_addr[0]?(ram_queue_wdata>1):queue_same_addr[1]?(ram_queue_wdata_d1>1):(ram_queue_depth>1);
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		enq_ack <= 0;
		deq_ack <= 0;
	end else begin
		enq_ack <= enq_lat_fifo_rd0_d1;
		deq_ack <= deq_req_d2;
	end

/***************************** PROGRAM BODY **********************************/

wire init_wr = init_st==INIT_COUNT;

always @(posedge clk) begin
		deq_req_d1 <= deq_req;
		deq_req_d2 <= deq_req_d1;
		deq_qid_d1 <= deq_qid;
		deq_qid_d2 <= deq_qid_d1;

		enq_req_d1 <= enq_req;
		enq_qid_d1 <= enq_qid;

		enq_lat_fifo_rd0_d1 <= enq_lat_fifo_rd0;
		lat_enq_qid_d1 <= lat_enq_qid;

		same_qid_d1 <= same_qid&deq_req_d1&~enq_lat_fifo_empty0;

		disable_deq_q_wr1_d1 <= disable_deq_q_wr1&deq_req_d2;

		disable_enq_q_wr1_d1 <= disable_enq_q_wr1&enq_lat_fifo_rd0_d1;

		ram_queue_raddr_d1 <= ram_queue_raddr;
		ram_queue_waddr <= ram_queue_raddr_d1;
		ram_queue_wdata <= deq_req_d2?
							(queue_same_addr[0]?(ram_queue_wdata-1):
							queue_same_addr[1]?(ram_queue_wdata_d1-1):(ram_queue_depth-1)):
							(queue_same_addr[0]?(ram_queue_wdata+1):
							queue_same_addr[1]?(ram_queue_wdata_d1+1):(ram_queue_depth+1));
		ram_queue_wdata_d1 <= ram_queue_wdata;

		queue_same_addr[0] <= ram_queue_wr_p1&(ram_queue_raddr_d1==ram_queue_raddr);
		queue_same_addr[1] <= ram_queue_wr&(ram_queue_waddr==ram_queue_raddr);
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
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
			if (`ACTIVE_RESET)
				init_st <= INIT_IDLE;
			else 
				init_st <= nxt_init_st;


/***************************** FIFO ***************************************/

sfifo2f_fo #(`FIRST_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({enq_qid_d1}),				
		.rd(enq_lat_fifo_rd0),
		.wr(enq_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(enq_lat_fifo_empty0),
		.fullm1(),
		.emptyp2(),
		.dout({lat_enq_qid})       
	);


/***************************** MEMORY ***************************************/

ram_1r1w_bram #(`FIRST_LVL_QUEUE_ID_NBITS, `FIRST_LVL_QUEUE_ID_NBITS) u_ram_1r1w_bram_0(
        .clk(clk),
        .wr(init_wr|ram_queue_wr),
        .raddr(ram_queue_raddr),
		.waddr(init_wr?init_count:ram_queue_waddr),
        .din(init_wr?{(`FIRST_LVL_QUEUE_ID_NBITS){1'b0}}:ram_queue_wdata),

        .dout(ram_queue_depth));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

