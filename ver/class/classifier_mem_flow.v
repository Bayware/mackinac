//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module classifier_mem_flow #(
parameter DEPTH_NBITS = `FLOW_HASH_TABLE_DEPTH_NBITS,
parameter BUCKET_NBITS = `FLOW_HASH_BUCKET_NBITS,
parameter VALUE_NBITS = `FLOW_VALUE_NBITS,
parameter VALUE_DEPTH_NBITS = `FLOW_VALUE_DEPTH_NBITS
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_flow_hash_table,

output reg flow_hash_table_mem_ack,
output reg [`PIO_RANGE] flow_hash_table_mem_rdata,

input ecdsa_classifier_flow_valid,
input [`FID_NBITS-1:0] ecdsa_classifier_fid,
input [`EXP_TIME_NBITS-1:0] ecdsa_classifier_flow_etime,

input [`REAL_TIME_NBITS-1:0] current_time,
input asa_classifier_valid,
input [`FID_NBITS-1:0] asa_classifier_fid,

input flow_hash_table0_rd, 
input [DEPTH_NBITS-1:0] flow_hash_table0_raddr,

input flow_hash_table0_wr, 
input [DEPTH_NBITS-1:0] flow_hash_table0_waddr,
input [BUCKET_NBITS-1:0] flow_hash_table0_wdata,

input flow_hash_table1_rd, 
input [DEPTH_NBITS-1:0] flow_hash_table1_raddr,

input flow_hash_table1_wr, 
input [DEPTH_NBITS-1:0] flow_hash_table1_waddr,
input [BUCKET_NBITS-1:0] flow_hash_table1_wdata,

input flow_key_rd, 
input [VALUE_DEPTH_NBITS-1:0] flow_key_raddr,

input flow_key_wr, 
input [VALUE_DEPTH_NBITS-1:0] flow_key_waddr,
input [VALUE_NBITS-1:0] flow_key_wdata,

input flow_etime_rd, 
input [VALUE_DEPTH_NBITS-1:0] flow_etime_raddr,

output flow_hash_table0_ack, 
output [BUCKET_NBITS-1:0] flow_hash_table0_rdata,

output flow_hash_table1_ack, 
output [BUCKET_NBITS-1:0] flow_hash_table1_rdata,

output reg flow_key_ack, 
output [VALUE_NBITS-1:0] flow_key_rdata /* synthesis keep = 1 */,

output reg flow_etime_ack, 
output [`EXP_TIME_NBITS-1:0] flow_etime_rdata /* synthesis keep = 1 */

);

/***************************** LOCAL VARIABLES *******************************/

reg init_wr;
reg [VALUE_DEPTH_NBITS:0] init_addr;

reg [`REAL_TIME_NBITS-1:0] current_time_d1;

reg asa_classifier_valid_d1;
reg [`FID_NBITS-1:0] asa_classifier_fid_d1;

reg ecdsa_classifier_flow_valid_d1;
reg [`FID_NBITS-1:0] ecdsa_classifier_fid_d1;
reg [`EXP_TIME_NBITS-1:0] ecdsa_classifier_flow_etime_d1;

reg flow_key_wr_d1; 
reg [VALUE_DEPTH_NBITS-1:0] flow_key_waddr_d1;
reg [`FLOW_KEY_NBITS-1:0] flow_key_wdata_d1;

reg flow_etime_wr; 
reg [VALUE_DEPTH_NBITS-1:0] flow_etime_waddr;
reg [`EXP_TIME_NBITS-1:0] flow_etime_wdata;

wire flow_hash_table0_mem_ack;
wire [`PIO_RANGE] flow_hash_table0_mem_rdata;

wire flow_hash_table1_mem_ack;
wire [`PIO_RANGE] flow_hash_table1_mem_rdata;

wire [`PIO_ADDR_MSB-3:0] reg_addr_qw = reg_addr[`PIO_ADDR_MSB:3];

wire reg_ms_flow_hash_table0 = reg_ms_flow_hash_table&~reg_addr_qw[DEPTH_NBITS];
wire reg_ms_flow_hash_table1 = reg_ms_flow_hash_table&reg_addr_qw[DEPTH_NBITS];

wire flow_fifo_empty;
wire [`FID_NBITS-1:0] flow_fifo_fid;
wire [`EXP_TIME_NBITS-1:0] flow_fifo_etime;
wire flow_fifo_rd = ~asa_classifier_valid_d1&~flow_fifo_empty;

wire n_flow_etime_wr = asa_classifier_valid_d1|~flow_fifo_empty;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	flow_hash_table_mem_ack = ~reg_addr_qw[DEPTH_NBITS]?flow_hash_table0_mem_ack:flow_hash_table1_mem_ack;
	flow_hash_table_mem_rdata = ~reg_addr_qw[DEPTH_NBITS]?flow_hash_table0_mem_rdata:flow_hash_table1_mem_rdata;
end
	
/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	        flow_key_ack <= 1'b0;
	        flow_etime_ack <= 1'b0;
	end else begin
	        flow_key_ack <= flow_key_rd;
	        flow_etime_ack <= flow_etime_rd;
	end


/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin
	        current_time_d1 <= current_time;
	        asa_classifier_fid_d1 <= asa_classifier_fid;
		ecdsa_classifier_fid_d1 <= ecdsa_classifier_fid;
		ecdsa_classifier_flow_etime_d1 <= ecdsa_classifier_flow_etime;
	        flow_key_waddr_d1 <= flow_key_waddr;
	        flow_key_wdata_d1 <= flow_key_wdata;
	        flow_etime_waddr <= asa_classifier_valid_d1?asa_classifier_fid_d1:flow_fifo_fid;
	        flow_etime_wdata <= asa_classifier_valid_d1?current_time_d1:flow_fifo_etime;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	    	init_wr <= 1'b1;
	    	init_addr <= 0;
	        asa_classifier_valid_d1 <= 1'b1;
		ecdsa_classifier_flow_valid_d1 <= 1'b0;
	        flow_key_wr_d1 <= 1'b0;
	        flow_etime_wr <= 1'b0;
	end else begin
	    	init_wr <= ~init_addr[VALUE_DEPTH_NBITS];
	    	init_addr <= init_addr[VALUE_DEPTH_NBITS]?(1<<VALUE_DEPTH_NBITS):init_addr+1;
	        asa_classifier_valid_d1 <= asa_classifier_valid;
		ecdsa_classifier_flow_valid_d1 <= ecdsa_classifier_flow_valid;
	        flow_key_wr_d1 <= flow_key_wr;
	        flow_etime_wr <= n_flow_etime_wr;
	end

pio_rw_wmem_bram #(BUCKET_NBITS, DEPTH_NBITS) u_pio_rw_wmem_bram0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_flow_hash_table0),

		.app_mem_rd(flow_hash_table0_rd),
		.app_mem_raddr(flow_hash_table0_raddr),

		.app_mem_wr(flow_hash_table0_wr),
		.app_mem_waddr(flow_hash_table0_waddr),
		.app_mem_wdata(flow_hash_table0_wdata),

        	.mem_ack(flow_hash_table0_mem_ack),
        	.mem_rdata(flow_hash_table0_mem_rdata),

		.app_mem_ack(flow_hash_table0_ack),
		.app_mem_rdata(flow_hash_table0_rdata)
);

pio_rw_wmem_bram #(BUCKET_NBITS, DEPTH_NBITS) u_pio_rw_wmem_bram1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_flow_hash_table1),

		.app_mem_rd(flow_hash_table1_rd),
		.app_mem_raddr(flow_hash_table1_raddr),

		.app_mem_wr(flow_hash_table1_wr),
		.app_mem_waddr(flow_hash_table1_waddr),
		.app_mem_wdata(flow_hash_table1_wdata),

        	.mem_ack(flow_hash_table1_mem_ack),
        	.mem_rdata(flow_hash_table1_mem_rdata),

		.app_mem_ack(flow_hash_table1_ack),
		.app_mem_rdata(flow_hash_table1_rdata)
);

ram_1r1w_bram #(`FLOW_KEY_NBITS, VALUE_DEPTH_NBITS) u_ram_1r1w_bram_0(
		.clk(clk),
		.wr(init_wr|flow_key_wr_d1),
		.raddr(flow_key_raddr),
		.waddr(init_wr?init_addr[VALUE_DEPTH_NBITS-1:0]:flow_key_waddr_d1),
		.din(init_wr?{(`FLOW_KEY_NBITS){1'b0}}:flow_key_wdata_d1),

		.dout(flow_key_rdata)
);

ram_1r1w_bram #(`EXP_TIME_NBITS, VALUE_DEPTH_NBITS) u_ram_1r1w_bram_2(
		.clk(clk),
		.wr(init_wr|flow_etime_wr),
		.raddr(flow_etime_raddr),
		.waddr(init_wr?init_addr[VALUE_DEPTH_NBITS-1:0]:flow_etime_waddr),
		.din(init_wr?{(`EXP_TIME_NBITS){1'b0}}:flow_etime_wdata),

		.dout(flow_etime_rdata)
);

sfifo2f_fo #(`FID_NBITS+`EXP_TIME_NBITS, 2) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({ecdsa_classifier_fid_d1, ecdsa_classifier_flow_etime_d1}),
        .rd(flow_fifo_rd),
        .wr(ecdsa_classifier_flow_valid_d1),

        .ncount(),
        .count(),
        .full(),
        .empty(flow_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({flow_fifo_fid, flow_fifo_etime})
    );


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

