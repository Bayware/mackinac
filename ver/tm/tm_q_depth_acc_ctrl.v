//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : qm0 q depth access control
//===========================================================================

`include "defines.vh"
`include "datapath.vh"

module tm_q_depth_acc_ctrl (
	clk,
    reset,

    queue_depth_req,
	queue_id, 

    q_group_depth_req,
	q_group_id,

	tunnel_depth_req,
	tunnel_id,

	port_queue_depth_req,
	port_queue_id,

	depth_deq_req,
	depth_deq_qid,
	depth_deq_q_group_id,
	depth_deq_tunnel_id,
	depth_deq_port_queue_id,

	// outputs

	queue_depth_ack,
	queue_depth,

	q_group_depth_ack,
	q_group_depth,

	tunnel_depth_ack,
	tunnel_depth,

	port_queue_depth_ack,
	port_queue_depth

);

input clk, reset;

// queue depth request from queue wred
input queue_depth_req; 
input [`QUEUE_BITS-1:0] queue_id;

// queue group depth request from queue group wred
input q_group_depth_req; 
input [`QUEUE_GROUP_BITS-1:0] q_group_id;

// tunnel depth request	from tunnel wred
input tunnel_depth_req; 
input [`TUNNEL_BITS-1:0] tunnel_id;

// port depth request from port wred
input port_queue_depth_req; 
input [`FOURTH_QUEUE_BITS-1:0] port_queue_id;

input depth_deq_req; 
input [`QUEUE_BITS-1:0] depth_deq_qid;
input [`QUEUE_GROUP_BITS-1:0] depth_deq_q_group_id;
input [`TUNNEL_BITS-1:0] depth_deq_tunnel_id;
input [`FOURTH_QUEUE_BITS-1:0] depth_deq_port_queue_id;

output queue_depth_ack;
output [`QUEUE_BITS-1:0] queue_depth;

output q_group_depth_ack;
output [`QUEUE_BITS-1:0] q_group_depth;

output tunnel_depth_ack;
output [`QUEUE_BITS-1:0] tunnel_depth;

output port_queue_depth_ack;
output [`QUEUE_BITS-1:0] port_queue_depth;

/***************************** LOCAL VARIABLES *******************************/
parameter [1:0]	 INIT_IDLE = 0,
			 INIT_COUNT = 1,
			 INIT_DONE = 2;

reg [1:0] init_st, nxt_init_st;
reg [`QUEUE_BITS-1:0] init_count;

reg queue_depth_req_d1; 
reg [`QUEUE_BITS-1:0] queue_id_d1;
// queue group depth request
reg q_group_depth_req_d1; 
reg [`QUEUE_GROUP_BITS-1:0] q_group_id_d1;
// tunnel depth request
reg tunnel_depth_req_d1; 
reg [`TUNNEL_BITS-1:0] tunnel_id_d1;
// port depth request
reg port_queue_depth_req_d1; 
reg [`FOURTH_QUEUE_BITS-1:0] port_queue_id_d1;

reg depth_deq_req_d1; 
reg [`QUEUE_BITS-1:0] depth_deq_qid_d1;
reg [`QUEUE_GROUP_BITS-1:0] depth_deq_q_group_id_d1;
reg [`TUNNEL_BITS-1:0] depth_deq_tunnel_id_d1;
reg [`FOURTH_QUEUE_BITS-1:0] depth_deq_port_queue_id_d1;

//
reg depth_deq_req_d2; 
reg [`QUEUE_BITS-1:0] depth_deq_qid_d2;
reg [`QUEUE_GROUP_BITS-1:0] depth_deq_q_group_id_d2;
reg [`TUNNEL_BITS-1:0] depth_deq_tunnel_id_d2;
reg [`FOURTH_QUEUE_BITS-1:0] depth_deq_port_queue_id_d2;

reg queue_depth_ack;
reg [`QUEUE_BITS-1:0] queue_depth;

reg q_group_depth_ack;
reg [`QUEUE_BITS-1:0] q_group_depth;

reg tunnel_depth_ack;
reg [`QUEUE_BITS-1:0] tunnel_depth;

reg port_queue_depth_ack;
reg [`QUEUE_BITS-1:0] port_queue_depth;

reg [`QUEUE_BITS-1:0] ram_queue_raddr_d1;
reg [`QUEUE_GROUP_BITS-1:0] ram_q_group_raddr_d1;
reg [`TUNNEL_BITS-1:0] ram_tunnel_raddr_d1;
reg [`FOURTH_QUEUE_BITS-1:0] ram_port_queue_raddr_d1;

reg [`QUEUE_BITS-1:0] ram_queue_waddr;
reg [`QUEUE_GROUP_BITS-1:0] ram_q_group_waddr;
reg [`TUNNEL_BITS-1:0] ram_tunnel_waddr;
reg [`FOURTH_QUEUE_BITS-1:0] ram_port_queue_waddr;

reg [`QUEUE_BITS-1:0] ram_queue_wdata;
reg [`QUEUE_BITS-1:0] ram_q_group_wdata;
reg [`QUEUE_BITS-1:0] ram_tunnel_wdata;
reg [`QUEUE_BITS-1:0] ram_port_queue_wdata;

reg [`QUEUE_BITS-1:0] ram_queue_wdata_d1;
reg [`QUEUE_BITS-1:0] ram_q_group_wdata_d1;
reg [`QUEUE_BITS-1:0] ram_tunnel_wdata_d1;
reg [`QUEUE_BITS-1:0] ram_port_queue_wdata_d1;

reg same_qid_d1;
reg same_q_group_id_d1;
reg same_tunnel_id_d1;
reg same_port_queue_id_d1;

reg ram_queue_wr;
reg ram_q_group_wr;
reg ram_tunnel_wr;
reg ram_port_queue_wr;

reg [1:0] queue_same_addr;
reg [1:0] q_group_same_addr;
reg [1:0] tunnel_same_addr;
reg [1:0] port_queue_same_addr;

reg disable_deq_q_wr1_d1;
reg disable_deq_q_group_wr1_d1;
reg disable_deq_tunnel_wr1_d1;
reg disable_deq_port_wr1_d1;

reg disable_enq_q_wr1_d1;
reg disable_enq_q_group_wr1_d1;
reg disable_enq_tunnel_wr1_d1;
reg disable_enq_port_wr1_d1;

reg lat_fifo_rd0_d1;
reg lat_fifo_rd1_d1;
reg lat_fifo_rd2_d1;
reg lat_fifo_rd3_d1;

reg [`QUEUE_BITS-1:0] lat_fifo_dout0_d1;
reg [`QUEUE_GROUP_BITS-1:0] lat_fifo_dout1_d1;
reg [`TUNNEL_BITS-1:0] lat_fifo_dout2_d1;
reg [`FOURTH_QUEUE_BITS-1:0] lat_fifo_dout3_d1;


wire lat_fifo_empty0;
wire lat_fifo_empty1;
wire lat_fifo_empty2;
wire lat_fifo_empty3;

wire [`QUEUE_BITS-1:0] lat_fifo_dout0;
wire [`QUEUE_GROUP_BITS-1:0] lat_fifo_dout1;
wire [`TUNNEL_BITS-1:0] lat_fifo_dout2;
wire [`FOURTH_QUEUE_BITS-1:0] lat_fifo_dout3;

wire same_qid = depth_deq_qid_d1==lat_fifo_dout0;
wire lat_fifo_rd0 = (~depth_deq_req_d1/*|same_qid*/)&~lat_fifo_empty0;

wire same_q_group_id = depth_deq_q_group_id_d1==lat_fifo_dout1;
wire lat_fifo_rd1 = (~depth_deq_req_d1/*|same_q_group_id*/)&~lat_fifo_empty1;

wire same_tunnel_id = depth_deq_tunnel_id_d1==lat_fifo_dout2;
wire lat_fifo_rd2 = (~depth_deq_req_d1/*|same_tunnel_id*/)&~lat_fifo_empty2;

wire same_port_queue_id = depth_deq_port_queue_id_d1==lat_fifo_dout3;
wire lat_fifo_rd3 = (~depth_deq_req_d1/*|same_port_queue_id*/)&~lat_fifo_empty3;

wire disable_deq_q_wr1 = (depth_deq_qid_d2==lat_fifo_dout0)&lat_fifo_rd0;
wire disable_deq_q_wr = disable_deq_q_wr1|same_qid_d1|disable_enq_q_wr1_d1;

wire disable_deq_q_group_wr1 = (depth_deq_q_group_id_d2==lat_fifo_dout1)&lat_fifo_rd1;
wire disable_deq_q_group_wr = disable_deq_q_group_wr1|same_q_group_id_d1|disable_enq_q_group_wr1_d1;

wire disable_deq_tunnel_wr1 = (depth_deq_tunnel_id_d2==lat_fifo_dout2)&lat_fifo_rd2;
wire disable_deq_tunnel_wr = disable_deq_tunnel_wr1|same_tunnel_id_d1|disable_enq_tunnel_wr1_d1;

wire disable_deq_port_wr1 = (depth_deq_port_queue_id_d2==lat_fifo_dout3)&lat_fifo_rd3;
wire disable_deq_port_wr = disable_deq_port_wr1|same_port_queue_id_d1|disable_enq_port_wr1_d1;

wire disable_enq_q_wr1 = (lat_fifo_dout0_d1==depth_deq_qid_d1)&depth_deq_req_d1;
wire disable_enq_q_wr = disable_enq_q_wr1|same_qid_d1|disable_deq_q_wr1_d1;

wire disable_enq_q_group_wr1 = (lat_fifo_dout1_d1==depth_deq_q_group_id_d1)&depth_deq_req_d1;
wire disable_enq_q_group_wr = disable_enq_q_group_wr1|same_q_group_id_d1|disable_deq_q_group_wr1_d1;

wire disable_enq_tunnel_wr1 = (lat_fifo_dout2_d1==depth_deq_tunnel_id_d1)&depth_deq_req_d1;
wire disable_enq_tunnel_wr = disable_enq_tunnel_wr1|same_tunnel_id_d1|disable_deq_tunnel_wr1_d1;

wire disable_enq_port_wr1 = (lat_fifo_dout3_d1==depth_deq_port_queue_id_d1)&depth_deq_req_d1;
wire disable_enq_port_wr = disable_enq_port_wr1|same_port_queue_id_d1|disable_deq_port_wr1_d1;

wire ram_queue_wr_p1 = (depth_deq_req_d2/*&~disable_deq_q_wr*/)|(lat_fifo_rd0_d1/*&~disable_enq_q_wr*/);
wire ram_q_group_wr_p1 = (depth_deq_req_d2/*&~disable_deq_q_group_wr*/)|(lat_fifo_rd1_d1/*&~disable_enq_q_group_wr*/);
wire ram_tunnel_wr_p1 = (depth_deq_req_d2/*&~disable_deq_tunnel_wr*/)|(lat_fifo_rd2_d1/*&~disable_enq_tunnel_wr*/);
wire ram_port_queue_wr_p1 = (depth_deq_req_d2/*&~disable_deq_port_wr*/)|(lat_fifo_rd3_d1/*&~disable_enq_port_wr*/);

wire [`QUEUE_BITS-1:0] ram_queue_raddr = depth_deq_req_d1?depth_deq_qid_d1:lat_fifo_dout0;
wire [`QUEUE_GROUP_BITS-1:0] ram_q_group_raddr = depth_deq_req_d1?depth_deq_q_group_id_d1:lat_fifo_dout1;
wire [`TUNNEL_BITS-1:0] ram_tunnel_raddr = depth_deq_req_d1?depth_deq_tunnel_id_d1:lat_fifo_dout2;
wire [`FOURTH_QUEUE_BITS-1:0] ram_port_queue_raddr = depth_deq_req_d1?depth_deq_port_queue_id_d1:lat_fifo_dout3;
 
wire [`QUEUE_BITS-1:0] ram_queue_depth;
wire [`QUEUE_BITS-1:0] ram_q_group_depth;
wire [`QUEUE_BITS-1:0] ram_tunnel_depth;
wire [`QUEUE_BITS-1:0] ram_port_queue_queue_depth;

wire [`QUEUE_BITS-1:0] mram_queue_depth = queue_same_addr[0]?ram_queue_wdata:
											queue_same_addr[1]?ram_queue_wdata_d1:
											ram_queue_depth;

wire [`QUEUE_BITS-1:0] mram_q_group_depth = q_group_same_addr[0]?ram_q_group_wdata:
											q_group_same_addr[1]?ram_q_group_wdata_d1:
											ram_q_group_depth;

wire [`QUEUE_BITS-1:0] mram_tunnel_depth = tunnel_same_addr[0]?ram_tunnel_wdata:
											tunnel_same_addr[1]?ram_tunnel_wdata_d1:
											ram_tunnel_depth;

wire [`QUEUE_BITS-1:0] mram_port_queue_queue_depth = port_queue_same_addr[0]?ram_port_queue_wdata:
											port_queue_same_addr[1]?ram_port_queue_wdata_d1:
											ram_port_queue_queue_depth;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		queue_depth <= ram_queue_depth;
		q_group_depth <= ram_q_group_depth;
		tunnel_depth <= ram_tunnel_depth;
		port_queue_depth <= ram_port_queue_queue_depth;
end

always @(`CLK_RST) 
    if (reset) begin
		queue_depth_ack <= 0;
		q_group_depth_ack <= 0;
		tunnel_depth_ack <= 0;
		port_queue_depth_ack <= 0;
	end else begin
		queue_depth_ack <= lat_fifo_rd0_d1;
		q_group_depth_ack <= lat_fifo_rd1_d1;
		tunnel_depth_ack <= lat_fifo_rd2_d1;
		port_queue_depth_ack <= lat_fifo_rd3_d1;
	end

/***************************** PROGRAM BODY **********************************/

wire init_wr = init_st==INIT_COUNT;

always @(posedge clk) begin
		depth_deq_req_d1 <= depth_deq_req;
		depth_deq_req_d2 <= depth_deq_req_d1;

		depth_deq_qid_d1 <= depth_deq_qid;
		depth_deq_q_group_id_d1 <= depth_deq_q_group_id;
		depth_deq_tunnel_id_d1 <= depth_deq_tunnel_id;
		depth_deq_port_queue_id_d1 <= depth_deq_port_queue_id;

		depth_deq_qid_d2 <= depth_deq_qid_d1;
		depth_deq_q_group_id_d2 <= depth_deq_q_group_id_d1;
		depth_deq_tunnel_id_d2 <= depth_deq_tunnel_id_d1;
		depth_deq_port_queue_id_d2 <= depth_deq_port_queue_id_d1;

		queue_depth_req_d1 <= queue_depth_req;
		q_group_depth_req_d1 <= q_group_depth_req;
		tunnel_depth_req_d1 <= tunnel_depth_req;
		port_queue_depth_req_d1 <= port_queue_depth_req;

		queue_id_d1 <= queue_id;
		q_group_id_d1 <= q_group_id;
		tunnel_id_d1 <= tunnel_id;
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
		same_q_group_id_d1 <= same_q_group_id&depth_deq_req_d1&~lat_fifo_empty1;
		same_tunnel_id_d1 <= same_tunnel_id&depth_deq_req_d1&~lat_fifo_empty2;
		same_port_queue_id_d1 <= same_port_queue_id&depth_deq_req_d1&~lat_fifo_empty3;

		disable_deq_q_wr1_d1 <= disable_deq_q_wr1&depth_deq_req_d2;
		disable_deq_q_group_wr1_d1 <= disable_deq_q_group_wr1&depth_deq_req_d2;
		disable_deq_tunnel_wr1_d1 <= disable_deq_tunnel_wr1&depth_deq_req_d2;
		disable_deq_port_wr1_d1 <= disable_deq_port_wr1&depth_deq_req_d2;

		disable_enq_q_wr1_d1 <= disable_enq_q_wr1&lat_fifo_rd0_d1;
		disable_enq_q_group_wr1_d1 <= disable_enq_q_group_wr1&lat_fifo_rd1_d1;
		disable_enq_tunnel_wr1_d1 <= disable_enq_tunnel_wr1&lat_fifo_rd2_d1;
		disable_enq_port_wr1_d1 <= disable_enq_port_wr1&lat_fifo_rd3_d1;

		ram_queue_raddr_d1 <= ram_queue_raddr;
		ram_q_group_raddr_d1 <= ram_q_group_raddr;
		ram_tunnel_raddr_d1 <= ram_tunnel_raddr;
		ram_port_queue_raddr_d1 <= ram_port_queue_raddr;

		ram_queue_waddr <= ram_queue_raddr_d1;
		ram_q_group_waddr <= ram_q_group_raddr_d1;
		ram_tunnel_waddr <= ram_tunnel_raddr_d1;
		ram_port_queue_waddr <= ram_port_queue_raddr_d1;

		ram_queue_wdata <= depth_deq_req_d2?mram_queue_depth-1:mram_queue_depth+1;
		ram_q_group_wdata <= depth_deq_req_d2?mram_q_group_depth-1:mram_q_group_depth+1;
		ram_tunnel_wdata <= depth_deq_req_d2?mram_tunnel_depth-1:mram_tunnel_depth+1;
		ram_port_queue_wdata <= depth_deq_req_d2?mram_port_queue_queue_depth-1:mram_port_queue_queue_depth+1;

		ram_queue_wdata_d1 <= ram_queue_wdata;
		ram_q_group_wdata_d1 <= ram_q_group_wdata;
		ram_tunnel_wdata_d1 <= ram_tunnel_wdata;
		ram_port_queue_wdata_d1 <= ram_port_queue_wdata;

		queue_same_addr[0] <= ram_queue_wr_p1&(ram_queue_raddr_d1==ram_queue_raddr);
		queue_same_addr[1] <= ram_queue_wr&(ram_queue_waddr==ram_queue_raddr);
		q_group_same_addr[0] <= ram_q_group_wr_p1&(ram_q_group_raddr_d1==ram_q_group_raddr);
		q_group_same_addr[1] <= ram_q_group_wr&(ram_q_group_waddr==ram_q_group_raddr);
		tunnel_same_addr[0] <= ram_tunnel_wr_p1&(ram_tunnel_raddr_d1==ram_tunnel_raddr);
		tunnel_same_addr[1] <= ram_tunnel_wr&(ram_tunnel_waddr==ram_tunnel_raddr);
		port_queue_same_addr[0] <= ram_port_queue_wr_p1&(ram_port_queue_raddr_d1==ram_port_queue_raddr);
		port_queue_same_addr[1] <= ram_port_queue_wr&(ram_port_queue_waddr==ram_port_queue_raddr);
end


always @(`CLK_RST) 
    if (reset) begin
		init_count <= 0;
		ram_queue_wr <= 0;
		ram_q_group_wr <= 0;
		ram_tunnel_wr <= 0;
		ram_port_queue_wr <= 0;
	end else begin
		init_count <= init_wr?init_count+1:init_count;
		ram_queue_wr <= ram_queue_wr_p1;
		ram_q_group_wr <= ram_q_group_wr_p1;
		ram_tunnel_wr <= ram_tunnel_wr_p1;
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
			if (reset)
				init_st <= INIT_IDLE;
			else 
				init_st <= nxt_init_st;


/***************************** FIFO ***************************************/

// arbitration latency FIFO
sfifo2f_fo #(`QUEUE_BITS, 2) u_sfifo2f_fo_0(
		.clk(clk),
		.reset(reset),

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

	sfifo2f_fo #(`QUEUE_GROUP_BITS, 2) u_sfifo2f_fo_1(
			.clk(clk),
			.reset(reset),

			.din(q_group_id_d1),				
			.rd(lat_fifo_rd1),
			.wr(q_group_depth_req_d1),

			.ncount(),
			.count(),
			.full(),
			.empty(lat_fifo_empty1),
			.fullm1(),
			.emptyp2(),
			.dout(lat_fifo_dout1)       
		);
	sfifo2f_fo #(`TUNNEL_BITS, 2) u_sfifo2f_fo_2(
			.clk(clk),
			.reset(reset),

			.din(tunnel_id_d1),				
			.rd(lat_fifo_rd2),
			.wr(tunnel_depth_req_d1),

			.ncount(),
			.count(),
			.full(),
			.empty(lat_fifo_empty2),
			.fullm1(),
			.emptyp2(),
			.dout(lat_fifo_dout2)       
		);
	sfifo2f_fo #(`FOURTH_QUEUE_BITS, 2) u_sfifo2f_fo_3(
			.clk(clk),
			.reset(reset),

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
// queue depth
ram_1r1w #(`QUEUE_BITS, `QUEUE_BITS) u_ram_1r1w_0(
        .clk(clk),
        .wr(init_wr|ram_queue_wr),
        .raddr(ram_queue_raddr),
		.waddr(init_wr?init_count:ram_queue_waddr),
        .din(init_wr?{(`QUEUE_BITS){1'b0}}:ram_queue_wdata),

        .dout(ram_queue_depth));
ram_1r1w #(`QUEUE_BITS, `QUEUE_GROUP_BITS) u_ram_1r1w_1(
		.clk(clk),
		.wr(init_wr|ram_q_group_wr),
		.raddr(ram_q_group_raddr),
		.waddr(init_wr?init_count[`QUEUE_GROUP_BITS-1:0]:ram_q_group_waddr),
		.din(init_wr?{(`QUEUE_BITS){1'b0}}:ram_q_group_wdata),

		.dout(ram_q_group_depth));

ram_1r1w #(`QUEUE_BITS, `TUNNEL_BITS) u_ram_1r1w_2(
		.clk(clk),
		.wr(init_wr|ram_tunnel_wr),
		.raddr(ram_tunnel_raddr),
		.waddr(init_wr?init_count[`TUNNEL_BITS-1:0]:ram_tunnel_waddr),
		.din(init_wr?{(`QUEUE_BITS){1'b0}}:ram_tunnel_wdata),

		.dout(ram_tunnel_depth));

ram_1r1w #(`QUEUE_BITS, `FOURTH_QUEUE_BITS) u_ram_1r1w_3(
		.clk(clk),
		.wr(init_wr|ram_port_queue_wr),
		.raddr(ram_port_queue_raddr),
		.waddr(init_wr?init_count[`FOURTH_QUEUE_BITS-1:0]:ram_port_queue_waddr),
		.din(init_wr?{(`QUEUE_BITS){1'b0}}:ram_port_queue_wdata),

		.dout(ram_port_queue_queue_depth));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

