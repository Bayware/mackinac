//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_depth_acc (


input clk, 
input `RESET_SIG,

input queue_depth_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_id,

input conn_depth_req, 
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] conn_id,

input conn_group_depth_req, 
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] conn_group_id,

input port_queue_depth_req, 
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] port_queue_id,

input depth_deq_req, 
input [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid,
input [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_id,
input [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_group_id,
input [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_deq_port_queue_id,

output reg queue_depth_ack,
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_depth,

output reg conn_depth_ack,
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] conn_depth,

output reg conn_group_depth_ack,
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] conn_group_depth,

output reg port_queue_depth_ack,
output reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] port_queue_depth
);

/***************************** LOCAL VARIABLES *******************************/
parameter [1:0]	 INIT_IDLE = 0,
			 INIT_COUNT = 1,
			 INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] init_count;

reg queue_depth_req_d1; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] queue_id_d1;

reg conn_depth_req_d1; 
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] conn_id_d1;

reg conn_group_depth_req_d1; 
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] conn_group_id_d1;

reg port_queue_depth_req_d1; 
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] port_queue_id_d1;

reg depth_deq_req_d1; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid_d1;
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_id_d1;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_group_id_d1;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_deq_port_queue_id_d1;

//
reg depth_deq_req_d2; 
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] depth_deq_qid_d2;
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_id_d2;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] depth_deq_conn_group_id_d2;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] depth_deq_port_queue_id_d2;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_raddr_d1;
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ram_conn_raddr_d1;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group_raddr_d1;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue_raddr_d1;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_waddr;
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ram_conn_waddr;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group_waddr;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue_waddr;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_wdata;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_conn_wdata;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group_wdata;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue_wdata;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_wdata_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_conn_wdata_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group_wdata_d1;
reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue_wdata_d1;

reg same_qid_d1;
reg same_conn_id_d1;
reg same_conn_group_id_d1;
reg same_port_queue_id_d1;

reg ram_queue_wr;
reg ram_conn_wr;
reg ram_conn_group_wr;
reg ram_port_queue_wr;

reg [1:0] queue_same_addr;
reg [1:0] conn_same_addr;
reg [1:0] conn_group_same_addr;
reg [1:0] port_queue_same_addr;

reg disable_deq_q_wr1_d1;
reg disable_deq_conn_wr1_d1;
reg disable_deq_conn_group_wr1_d1;
reg disable_deq_port_wr1_d1;

reg disable_enq_q_wr1_d1;
reg disable_enq_conn_wr1_d1;
reg disable_enq_conn_group_wr1_d1;
reg disable_enq_port_wr1_d1;

reg lat_fifo_rd0_d1;
reg lat_fifo_rd1_d1;
reg lat_fifo_rd2_d1;
reg lat_fifo_rd3_d1;

reg [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout0_d1;
reg [`SECOND_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout1_d1;
reg [`THIRD_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout2_d1;
reg [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout3_d1;


wire lat_fifo_empty0;
wire lat_fifo_empty1;
wire lat_fifo_empty2;
wire lat_fifo_empty3;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout0;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout1;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout2;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] lat_fifo_dout3;

wire same_qid = depth_deq_qid_d1==lat_fifo_dout0;
wire lat_fifo_rd0 = (~depth_deq_req_d1/*|same_qid*/)&~lat_fifo_empty0;

wire same_conn_id = depth_deq_conn_id_d1==lat_fifo_dout1;
wire lat_fifo_rd1 = (~depth_deq_req_d1/*|same_conn_id*/)&~lat_fifo_empty1;

wire same_conn_group_id = depth_deq_conn_group_id_d1==lat_fifo_dout2;
wire lat_fifo_rd2 = (~depth_deq_req_d1/*|same_conn_group_id*/)&~lat_fifo_empty2;

wire same_port_queue_id = depth_deq_port_queue_id_d1==lat_fifo_dout3;
wire lat_fifo_rd3 = (~depth_deq_req_d1/*|same_port_queue_id*/)&~lat_fifo_empty3;

wire disable_deq_q_wr1 = (depth_deq_qid_d2==lat_fifo_dout0)&lat_fifo_rd0;
wire disable_deq_q_wr = disable_deq_q_wr1|same_qid_d1|disable_enq_q_wr1_d1;

wire disable_deq_conn_wr1 = (depth_deq_conn_id_d2==lat_fifo_dout1)&lat_fifo_rd1;
wire disable_deq_conn_wr = disable_deq_conn_wr1|same_conn_id_d1|disable_enq_conn_wr1_d1;

wire disable_deq_conn_group_wr1 = (depth_deq_conn_group_id_d2==lat_fifo_dout2)&lat_fifo_rd2;
wire disable_deq_conn_group_wr = disable_deq_conn_group_wr1|same_conn_group_id_d1|disable_enq_conn_group_wr1_d1;

wire disable_deq_port_wr1 = (depth_deq_port_queue_id_d2==lat_fifo_dout3)&lat_fifo_rd3;
wire disable_deq_port_wr = disable_deq_port_wr1|same_port_queue_id_d1|disable_enq_port_wr1_d1;

wire disable_enq_q_wr1 = (lat_fifo_dout0_d1==depth_deq_qid_d1)&depth_deq_req_d1;
wire disable_enq_q_wr = disable_enq_q_wr1|same_qid_d1|disable_deq_q_wr1_d1;

wire disable_enq_conn_wr1 = (lat_fifo_dout1_d1==depth_deq_conn_id_d1)&depth_deq_req_d1;
wire disable_enq_conn_wr = disable_enq_conn_wr1|same_conn_id_d1|disable_deq_conn_wr1_d1;

wire disable_enq_conn_group_wr1 = (lat_fifo_dout2_d1==depth_deq_conn_group_id_d1)&depth_deq_req_d1;
wire disable_enq_conn_group_wr = disable_enq_conn_group_wr1|same_conn_group_id_d1|disable_deq_conn_group_wr1_d1;

wire disable_enq_port_wr1 = (lat_fifo_dout3_d1==depth_deq_port_queue_id_d1)&depth_deq_req_d1;
wire disable_enq_port_wr = disable_enq_port_wr1|same_port_queue_id_d1|disable_deq_port_wr1_d1;

wire ram_queue_wr_p1 = (depth_deq_req_d2/*&~disable_deq_q_wr*/)|(lat_fifo_rd0_d1/*&~disable_enq_q_wr*/);
wire ram_conn_wr_p1 = (depth_deq_req_d2/*&~disable_deq_conn_wr*/)|(lat_fifo_rd1_d1/*&~disable_enq_conn_wr*/);
wire ram_conn_group_wr_p1 = (depth_deq_req_d2/*&~disable_deq_conn_group_wr*/)|(lat_fifo_rd2_d1/*&~disable_enq_conn_group_wr*/);
wire ram_port_queue_wr_p1 = (depth_deq_req_d2/*&~disable_deq_port_wr*/)|(lat_fifo_rd3_d1/*&~disable_enq_port_wr*/);

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_raddr = depth_deq_req_d1?depth_deq_qid_d1:lat_fifo_dout0;
wire [`SECOND_LVL_QUEUE_ID_NBITS-1:0] ram_conn_raddr = depth_deq_req_d1?depth_deq_conn_id_d1:lat_fifo_dout1;
wire [`THIRD_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group_raddr = depth_deq_req_d1?depth_deq_conn_group_id_d1:lat_fifo_dout2;
wire [`FOURTH_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue_raddr = depth_deq_req_d1?depth_deq_port_queue_id_d1:lat_fifo_dout3;
 
(* keep = "true" *) wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_queue_depth ;
(* keep = "true" *) wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_conn_depth ;
(* keep = "true" *) wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_conn_group_depth ;
(* keep = "true" *) wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] ram_port_queue_queue_depth ;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] mram_queue_depth = queue_same_addr[0]?ram_queue_wdata:
											queue_same_addr[1]?ram_queue_wdata_d1:
											ram_queue_depth;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] mram_conn_depth = conn_same_addr[0]?ram_conn_wdata:
											conn_same_addr[1]?ram_conn_wdata_d1:
											ram_conn_depth;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] mram_conn_group_depth = conn_group_same_addr[0]?ram_conn_group_wdata:
											conn_group_same_addr[1]?ram_conn_group_wdata_d1:
											ram_conn_group_depth;

wire [`FIRST_LVL_QUEUE_ID_NBITS-1:0] mram_port_queue_queue_depth = port_queue_same_addr[0]?ram_port_queue_wdata:
											port_queue_same_addr[1]?ram_port_queue_wdata_d1:
											ram_port_queue_queue_depth;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		queue_depth <= ram_queue_depth;
		conn_depth <= ram_conn_depth;
		conn_group_depth <= ram_conn_group_depth;
		port_queue_depth <= ram_port_queue_queue_depth;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		queue_depth_ack <= 0;
		conn_depth_ack <= 0;
		conn_group_depth_ack <= 0;
		port_queue_depth_ack <= 0;
	end else begin
		queue_depth_ack <= lat_fifo_rd0_d1;
		conn_depth_ack <= lat_fifo_rd1_d1;
		conn_group_depth_ack <= lat_fifo_rd2_d1;
		port_queue_depth_ack <= lat_fifo_rd3_d1;
	end

/***************************** PROGRAM BODY **********************************/

wire init_wr = init_st==INIT_COUNT;

always @(posedge clk) begin
		depth_deq_req_d1 <= depth_deq_req;
		depth_deq_req_d2 <= depth_deq_req_d1;

		depth_deq_qid_d1 <= depth_deq_qid;
		depth_deq_conn_id_d1 <= depth_deq_conn_id;
		depth_deq_conn_group_id_d1 <= depth_deq_conn_group_id;
		depth_deq_port_queue_id_d1 <= depth_deq_port_queue_id;

		depth_deq_qid_d2 <= depth_deq_qid_d1;
		depth_deq_conn_id_d2 <= depth_deq_conn_id_d1;
		depth_deq_conn_group_id_d2 <= depth_deq_conn_group_id_d1;
		depth_deq_port_queue_id_d2 <= depth_deq_port_queue_id_d1;

		queue_depth_req_d1 <= queue_depth_req;
		conn_depth_req_d1 <= conn_depth_req;
		conn_group_depth_req_d1 <= conn_group_depth_req;
		port_queue_depth_req_d1 <= port_queue_depth_req;

		queue_id_d1 <= queue_id;
		conn_id_d1 <= conn_id;
		conn_group_id_d1 <= conn_group_id;
		port_queue_id_d1 <= port_queue_id;

		lat_fifo_rd0_d1 <= lat_fifo_rd0;
		lat_fifo_rd1_d1 <= lat_fifo_rd1;
		lat_fifo_rd2_d1 <= lat_fifo_rd2;
		lat_fifo_rd3_d1 <= lat_fifo_rd3;

		lat_fifo_dout0_d1 <= lat_fifo_dout0;
		lat_fifo_dout1_d1 <= lat_fifo_dout1;
		lat_fifo_dout2_d1 <= lat_fifo_dout2;
		lat_fifo_dout3_d1 <= lat_fifo_dout3;

		same_qid_d1 <= same_qid&depth_deq_req_d1&~lat_fifo_empty0;
		same_conn_id_d1 <= same_conn_id&depth_deq_req_d1&~lat_fifo_empty1;
		same_conn_group_id_d1 <= same_conn_group_id&depth_deq_req_d1&~lat_fifo_empty2;
		same_port_queue_id_d1 <= same_port_queue_id&depth_deq_req_d1&~lat_fifo_empty3;

		disable_deq_q_wr1_d1 <= disable_deq_q_wr1&depth_deq_req_d2;
		disable_deq_conn_wr1_d1 <= disable_deq_conn_wr1&depth_deq_req_d2;
		disable_deq_conn_group_wr1_d1 <= disable_deq_conn_group_wr1&depth_deq_req_d2;
		disable_deq_port_wr1_d1 <= disable_deq_port_wr1&depth_deq_req_d2;

		disable_enq_q_wr1_d1 <= disable_enq_q_wr1&lat_fifo_rd0_d1;
		disable_enq_conn_wr1_d1 <= disable_enq_conn_wr1&lat_fifo_rd1_d1;
		disable_enq_conn_group_wr1_d1 <= disable_enq_conn_group_wr1&lat_fifo_rd2_d1;
		disable_enq_port_wr1_d1 <= disable_enq_port_wr1&lat_fifo_rd3_d1;

		ram_queue_raddr_d1 <= ram_queue_raddr;
		ram_conn_raddr_d1 <= ram_conn_raddr;
		ram_conn_group_raddr_d1 <= ram_conn_group_raddr;
		ram_port_queue_raddr_d1 <= ram_port_queue_raddr;

		ram_queue_waddr <= ram_queue_raddr_d1;
		ram_conn_waddr <= ram_conn_raddr_d1;
		ram_conn_group_waddr <= ram_conn_group_raddr_d1;
		ram_port_queue_waddr <= ram_port_queue_raddr_d1;

		ram_queue_wdata <= depth_deq_req_d2?mram_queue_depth-1:mram_queue_depth+1;
		ram_conn_wdata <= depth_deq_req_d2?mram_conn_depth-1:mram_conn_depth+1;
		ram_conn_group_wdata <= depth_deq_req_d2?mram_conn_group_depth-1:mram_conn_group_depth+1;
		ram_port_queue_wdata <= depth_deq_req_d2?mram_port_queue_queue_depth-1:mram_port_queue_queue_depth+1;

		ram_queue_wdata_d1 <= ram_queue_wdata;
		ram_conn_wdata_d1 <= ram_conn_wdata;
		ram_conn_group_wdata_d1 <= ram_conn_group_wdata;
		ram_port_queue_wdata_d1 <= ram_port_queue_wdata;

		queue_same_addr[0] <= ram_queue_wr_p1&(ram_queue_raddr_d1==ram_queue_raddr);
		queue_same_addr[1] <= ram_queue_wr&(ram_queue_waddr==ram_queue_raddr);
		conn_same_addr[0] <= ram_conn_wr_p1&(ram_conn_raddr_d1==ram_conn_raddr);
		conn_same_addr[1] <= ram_conn_wr&(ram_conn_waddr==ram_conn_raddr);
		conn_group_same_addr[0] <= ram_conn_group_wr_p1&(ram_conn_group_raddr_d1==ram_conn_group_raddr);
		conn_group_same_addr[1] <= ram_conn_group_wr&(ram_conn_group_waddr==ram_conn_group_raddr);
		port_queue_same_addr[0] <= ram_port_queue_wr_p1&(ram_port_queue_raddr_d1==ram_port_queue_raddr);
		port_queue_same_addr[1] <= ram_port_queue_wr&(ram_port_queue_waddr==ram_port_queue_raddr);
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		init_count <= 0;
		ram_queue_wr <= 0;
		ram_conn_wr <= 0;
		ram_conn_group_wr <= 0;
		ram_port_queue_wr <= 0;
	end else begin
		init_count <= init_wr?init_count+1:init_count;
		ram_queue_wr <= ram_queue_wr_p1;
		ram_conn_wr <= ram_conn_wr_p1;
		ram_conn_group_wr <= ram_conn_group_wr_p1;
		ram_port_queue_wr <= ram_port_queue_wr_p1;
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

// arbitration latency FIFO
sfifo2f_fo #(`FIRST_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(queue_id_d1),				
		.rd(lat_fifo_rd0),
		.wr(queue_depth_req_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty0),
		.fullm1(),
		.emptyp2(),
		.dout(lat_fifo_dout0)       
	);

	sfifo2f_fo #(`SECOND_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_1(
			.clk(clk),
			.`RESET_SIG(`RESET_SIG),

			.din(conn_id_d1),				
			.rd(lat_fifo_rd1),
			.wr(conn_depth_req_d1),

			.ncount(),
			.count(),
			.full(),
			.empty(lat_fifo_empty1),
			.fullm1(),
			.emptyp2(),
			.dout(lat_fifo_dout1)       
		);
	sfifo2f_fo #(`THIRD_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_2(
			.clk(clk),
			.`RESET_SIG(`RESET_SIG),

			.din(conn_group_id_d1),				
			.rd(lat_fifo_rd2),
			.wr(conn_group_depth_req_d1),

			.ncount(),
			.count(),
			.full(),
			.empty(lat_fifo_empty2),
			.fullm1(),
			.emptyp2(),
			.dout(lat_fifo_dout2)       
		);
	sfifo2f_fo #(`FOURTH_LVL_QUEUE_ID_NBITS, 2) u_sfifo2f_fo_3(
			.clk(clk),
			.`RESET_SIG(`RESET_SIG),

			.din(port_queue_id_d1),				
			.rd(lat_fifo_rd3),
			.wr(port_queue_depth_req_d1),

			.ncount(),
			.count(),
			.full(),
			.empty(lat_fifo_empty3),
			.fullm1(),
			.emptyp2(),
			.dout(lat_fifo_dout3)       
		);

/***************************** MEMORY ***************************************/
ram_1r1w_bram #(`FIRST_LVL_QUEUE_ID_NBITS, `FIRST_LVL_QUEUE_ID_NBITS) u_ram_1r1w_bram_0(
        .clk(clk),
        .wr(init_wr|ram_queue_wr),
        .raddr(ram_queue_raddr),
		.waddr(init_wr?init_count:ram_queue_waddr),
        .din(init_wr?{(`FIRST_LVL_QUEUE_ID_NBITS){1'b0}}:ram_queue_wdata),

        .dout(ram_queue_depth));

ram_1r1w_bram #(`FIRST_LVL_QUEUE_ID_NBITS, `SECOND_LVL_QUEUE_ID_NBITS) u_ram_1r1w_bram_1(
		.clk(clk),
		.wr(init_wr|ram_conn_wr),
		.raddr(ram_conn_raddr),
		.waddr(init_wr?init_count[`SECOND_LVL_QUEUE_ID_NBITS-1:0]:ram_conn_waddr),
		.din(init_wr?{(`FIRST_LVL_QUEUE_ID_NBITS){1'b0}}:ram_conn_wdata),

		.dout(ram_conn_depth));

ram_1r1w_bram #(`FIRST_LVL_QUEUE_ID_NBITS, `THIRD_LVL_QUEUE_ID_NBITS) u_ram_1r1w_bram_2(
		.clk(clk),
		.wr(init_wr|ram_conn_group_wr),
		.raddr(ram_conn_group_raddr),
		.waddr(init_wr?init_count[`THIRD_LVL_QUEUE_ID_NBITS-1:0]:ram_conn_group_waddr),
		.din(init_wr?{(`FIRST_LVL_QUEUE_ID_NBITS){1'b0}}:ram_conn_group_wdata),

		.dout(ram_conn_group_depth));

ram_1r1w_bram #(`FIRST_LVL_QUEUE_ID_NBITS, `FOURTH_LVL_QUEUE_ID_NBITS) u_ram_1r1w_bram_3(
		.clk(clk),
		.wr(init_wr|ram_port_queue_wr),
		.raddr(ram_port_queue_raddr),
		.waddr(init_wr?init_count[`FOURTH_LVL_QUEUE_ID_NBITS-1:0]:ram_port_queue_waddr),
		.din(init_wr?{(`FIRST_LVL_QUEUE_ID_NBITS){1'b0}}:ram_port_queue_wdata),

		.dout(ram_port_queue_queue_depth));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

