//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module classifier_mem_topic #(
parameter DEPTH_NBITS = `TOPIC_HASH_TABLE_DEPTH_NBITS,
parameter BUCKET_NBITS = `TOPIC_HASH_BUCKET_NBITS,
parameter VALUE_NBITS = `TOPIC_VALUE_NBITS,
parameter VALUE_DEPTH_NBITS = `TOPIC_VALUE_DEPTH_NBITS
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_topic_hash_table,

output reg topic_hash_table_mem_ack,
output reg [`PIO_RANGE] topic_hash_table_mem_rdata,

input ecdsa_classifier_topic_valid,
input [`TID_NBITS-1:0] ecdsa_classifier_tid,
input [`EXP_TIME_NBITS-1:0] ecdsa_classifier_topic_etime,

input topic_hash_table0_rd, 
input [DEPTH_NBITS-1:0] topic_hash_table0_raddr,

input topic_hash_table0_wr, 
input [DEPTH_NBITS-1:0] topic_hash_table0_waddr,
input [BUCKET_NBITS-1:0] topic_hash_table0_wdata,

input topic_hash_table1_rd, 
input [DEPTH_NBITS-1:0] topic_hash_table1_raddr,

input topic_hash_table1_wr, 
input [DEPTH_NBITS-1:0] topic_hash_table1_waddr,
input [BUCKET_NBITS-1:0] topic_hash_table1_wdata,

input topic_key_rd, 
input [VALUE_DEPTH_NBITS-1:0] topic_key_raddr,

input topic_key_wr,
input [VALUE_DEPTH_NBITS-1:0] topic_key_waddr,
input [`TOPIC_KEY_NBITS-1:0] topic_key_wdata,

input topic_etime_rd, 
input [VALUE_DEPTH_NBITS-1:0] topic_etime_raddr,

output topic_hash_table0_ack, 
output [BUCKET_NBITS-1:0] topic_hash_table0_rdata  /* synthesis keep = 1 */,

output topic_hash_table1_ack, 
output [BUCKET_NBITS-1:0] topic_hash_table1_rdata  /* synthesis keep = 1 */,

output reg topic_key_ack, 
output [VALUE_NBITS-1:0] topic_key_rdata  /* synthesis keep = 1 */,

output reg topic_etime_ack, 
output [`EXP_TIME_NBITS-1:0] topic_etime_rdata  /* synthesis keep = 1 */


);

/***************************** LOCAL VARIABLES *******************************/
reg init_wr;
reg [VALUE_DEPTH_NBITS:0] init_addr;

reg topic_key_wr_d1; 
reg [VALUE_DEPTH_NBITS-1:0] topic_key_waddr_d1;
reg [`TOPIC_KEY_NBITS-1:0] topic_key_wdata_d1;

reg topic_etime_wr; 
reg [VALUE_DEPTH_NBITS-1:0] topic_etime_waddr;
reg [`EXP_TIME_NBITS-1:0] topic_etime_wdata;

wire topic_hash_table0_mem_ack;
wire [`PIO_RANGE] topic_hash_table0_mem_rdata;

wire topic_hash_table1_mem_ack;
wire [`PIO_RANGE] topic_hash_table1_mem_rdata;

wire [`PIO_ADDR_MSB-3:0] reg_addr_qw = reg_addr[`PIO_ADDR_MSB:3];

wire reg_ms_topic_hash_table0 = reg_ms_topic_hash_table&~reg_addr_qw[DEPTH_NBITS];
wire reg_ms_topic_hash_table1 = reg_ms_topic_hash_table&reg_addr_qw[DEPTH_NBITS];

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	topic_hash_table_mem_ack = ~reg_addr_qw[DEPTH_NBITS]?topic_hash_table0_mem_ack:topic_hash_table1_mem_ack;
	topic_hash_table_mem_rdata = ~reg_addr_qw[DEPTH_NBITS]?topic_hash_table0_mem_rdata:topic_hash_table1_mem_rdata;
end
	
/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	        topic_key_ack <= 1'b0;
	        topic_etime_ack <= 1'b0;
	end else begin
	        topic_key_ack <= topic_key_rd;
	        topic_etime_ack <= topic_etime_rd;
	end


/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
	        topic_key_waddr_d1 <= topic_key_waddr;
	        topic_key_wdata_d1 <= topic_key_wdata;
	        topic_etime_waddr <= ecdsa_classifier_tid;
	        topic_etime_wdata <= ecdsa_classifier_topic_etime;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	        init_wr <= 1'b1;
	        init_addr <= 0;
	        topic_key_wr_d1 <= 1'b0;
	        topic_etime_wr <= 1'b0;
	end else begin
	        init_wr <= ~init_addr[VALUE_DEPTH_NBITS];
	        init_addr <= init_addr[VALUE_DEPTH_NBITS]?(1<<VALUE_DEPTH_NBITS):init_addr+1;
	        topic_key_wr_d1 <= topic_key_wr;
	        topic_etime_wr <= ecdsa_classifier_topic_valid;
	end


pio_rw_wmem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_rw_wmem0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_hash_table0),

		.app_mem_rd(topic_hash_table0_rd),
		.app_mem_raddr(topic_hash_table0_raddr),

		.app_mem_wr(topic_hash_table0_wr),
		.app_mem_waddr(topic_hash_table0_waddr),
		.app_mem_wdata(topic_hash_table0_wdata),

        	.mem_ack(topic_hash_table0_mem_ack),
        	.mem_rdata(topic_hash_table0_mem_rdata),

		.app_mem_ack(topic_hash_table0_ack),
		.app_mem_rdata(topic_hash_table0_rdata)
);

pio_rw_wmem #(BUCKET_NBITS, DEPTH_NBITS) u_pio_rw_wmem1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_hash_table1),

		.app_mem_rd(topic_hash_table1_rd),
		.app_mem_raddr(topic_hash_table1_raddr),

		.app_mem_wr(topic_hash_table1_wr),
		.app_mem_waddr(topic_hash_table1_waddr),
		.app_mem_wdata(topic_hash_table1_wdata),

        	.mem_ack(topic_hash_table1_mem_ack),
        	.mem_rdata(topic_hash_table1_mem_rdata),

		.app_mem_ack(topic_hash_table1_ack),
		.app_mem_rdata(topic_hash_table1_rdata)
);

ram_1r1w #(`TOPIC_KEY_NBITS, VALUE_DEPTH_NBITS) u_ram_1r1w_0(
		.clk(clk),
		.wr(init_wr|topic_key_wr_d1),
		.raddr(topic_key_raddr),
		.waddr(init_wr?init_addr[VALUE_DEPTH_NBITS-1:0]:topic_key_waddr_d1),
		.din(init_wr?{(`TOPIC_KEY_NBITS){1'b0}}:topic_key_wdata_d1),

		.dout(topic_key_rdata)
);

ram_1r1w #(`EXP_TIME_NBITS, VALUE_DEPTH_NBITS) u_ram_1r1w_2(
		.clk(clk),
		.wr(init_wr|topic_etime_wr),
		.raddr(topic_etime_raddr),
		.waddr(init_wr?init_addr[VALUE_DEPTH_NBITS-1:0]:topic_etime_waddr),
		.din(init_wr?{(`EXP_TIME_NBITS){1'b0}}:topic_etime_wdata),

		.dout(topic_etime_rdata)
);

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

