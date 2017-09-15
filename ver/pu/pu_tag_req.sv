//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_tag_req #(
parameter NUM_OF_PU = `NUM_OF_PU,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS
) ( 
	input clk,
	input `RESET_SIG,

	input clk_div,
	
	input [`PIO_RANGE] reg_addr,
	input [`PIO_RANGE] reg_din,
	input reg_rd,
	input reg_wr,
	input reg_ms_tag_hash_table,
	input reg_ms_tag_value,

	output reg tag_hash_table_mem_ack,
	output reg [`PIO_RANGE] tag_hash_table_mem_rdata,

	output tag_value_mem_ack,
	output [`PIO_RANGE] tag_value_mem_rdata,

	output logic tag_lookup_valid,
	output logic [`RCI_NBITS-1:0] tag_lookup_result,
	output logic [2:0] tag_lookup_result_num,
	output logic [`PU_ID_NBITS-1:0] tag_lookup_result_pid,

	output logic tag_lookup_status_valid,
	output logic [3:0] tag_lookup_status,
	output logic [`PU_ID_NBITS-1:0] tag_lookup_status_pid,

	input [NUM_OF_PU-1:0] io_req, 
	input io_type io_cmd[NUM_OF_PU-1:0], 

	output logic [NUM_OF_PU-1:0] io_ack,
	output logic [WIDTH_NBITS-1:0] io_ack_data[NUM_OF_PU-1:0]
);

integer i;

io_type io_cmd_d1[NUM_OF_PU-1:0]; 

logic [NUM_OF_PU-1:0] in_fifo_wr;
logic [NUM_OF_PU-1:0] in_fifo_rd;
logic [NUM_OF_PU-1:0] in_fifo_empty;

wire [NUM_OF_PU-1:0] arb_wr_req = ~in_fifo_empty&~in_fifo_rd;
logic [`PU_ID_NBITS-1:0] arb_wr_sel;
logic arb_wr_gnt;

logic [2:0] cnt;

wire tag_key_valid = arb_wr_gnt;
wire [`TAG_NBITS-1:0] tag_key = io_cmd_d1[arb_wr_sel].wdata;
wire [`PU_ID_NBITS-1:0] tag_pid = arb_wr_sel;

wire en = ~tag_key_valid&(cnt==0);

always @(*)
	for (i = 0; i < NUM_OF_PU ; i = i + 1)
		io_ack_data[i] = 0;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_ack <= 0;
    end else begin
        io_ack <= in_fifo_rd;
    end

always @(*)
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin
		in_fifo_wr[i] = io_req[i]&io_cmd[i].wr&(io_cmd[i].addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_TAG_LOOKUP_REQ);
        	in_fifo_rd[i] = ~in_fifo_empty[i]&(i==arb_wr_sel)&arb_wr_gnt;
	end

always @(posedge clk) begin
	for (i = 0; i < NUM_OF_PU ; i = i + 1)  
		io_cmd_d1[i] <= io_req[i]?io_cmd[i]:io_cmd_d1[i];
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        cnt <= 0;
    end else begin
        cnt <= tag_key_valid?7:cnt==0?0:cnt-1;
    end

genvar gi;

generate
for (gi = 0; gi < NUM_OF_PU ; gi = gi + 1) begin 
	sfifo1f #(1) u_sfifo1f(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(in_fifo_wr[i]), .din(1'b1), .dout(), .rd(in_fifo_rd[gi]), .full(), .empty(in_fifo_empty[gi]));

end
endgenerate

rr_arb20 u_rr_arb_20_0 (
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.en(en),
	.req(arb_wr_req),

	.sel(arb_wr_sel),
	.gnt(arb_wr_gnt)
);

localparam TAG_DEPTH_NBITS = `TAG_HASH_TABLE_DEPTH_NBITS;
localparam TAG_BUCKET_NBITS = `TAG_HASH_BUCKET_NBITS;
localparam TAG_VALUE_NBITS = `TAG_VALUE_NBITS;
localparam TAG_VALUE_DEPTH_NBITS = `TAG_VALUE_DEPTH_NBITS;

logic tag_hash_table0_ack; 
wire [TAG_BUCKET_NBITS-1:0] tag_hash_table0_rdata  /* synthesis keep = 1 */;

logic tag_hash_table1_ack; 
wire [TAG_BUCKET_NBITS-1:0] tag_hash_table1_rdata  /* synthesis keep = 1 */;

logic tag_value_ack; 
wire [TAG_VALUE_NBITS-1:0] tag_value_rdata; /* synthesis keep = 1 */

logic tag_hash_table0_rd; 
logic [TAG_DEPTH_NBITS-1:0] tag_hash_table0_raddr;

logic tag_hash_table1_rd; 
logic [TAG_DEPTH_NBITS-1:0] tag_hash_table1_raddr;

logic tag_value_rd; 
logic [TAG_VALUE_DEPTH_NBITS-1:0] tag_value_raddr;

pu_tag_lookup  u_pu_tag_lookup(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

        	.tag_key_valid(tag_key_valid),
        	.tag_key(tag_key),
        	.tag_pid(tag_pid),

		.tag_hash_table0_ack(tag_hash_table0_ack),
		.tag_hash_table0_rdata(tag_hash_table0_rdata),

		.tag_hash_table1_ack(tag_hash_table1_ack),
		.tag_hash_table1_rdata(tag_hash_table1_rdata),

		.tag_value_ack(tag_value_ack),
		.tag_value_rdata(tag_value_rdata),

		.tag_lookup_valid(tag_lookup_valid),
		.tag_lookup_result(tag_lookup_result),
		.tag_lookup_result_num(tag_lookup_result_num),
		.tag_lookup_result_pid(tag_lookup_result_pid),

		.tag_lookup_status_valid(tag_lookup_status_valid),
		.tag_lookup_status(tag_lookup_status),
		.tag_lookup_status_pid(tag_lookup_status_pid),

		.tag_hash_table0_rd(tag_hash_table0_rd),
		.tag_hash_table0_raddr(tag_hash_table0_raddr),

		.tag_hash_table1_rd(tag_hash_table1_rd),
		.tag_hash_table1_raddr(tag_hash_table1_raddr),

		.tag_value_rd(tag_value_rd),
		.tag_value_raddr(tag_value_raddr)

);

pu_tag_lookup_mem  u_pu_tag_lookup_mem(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms_tag_hash_table(reg_ms_tag_hash_table),
        	.reg_ms_tag_value(reg_ms_tag_value),

        	.tag_hash_table_mem_ack(tag_hash_table_mem_ack),
        	.tag_hash_table_mem_rdata(tag_hash_table_mem_rdata),

		.tag_value_mem_ack(tag_value_mem_ack),
		.tag_value_mem_rdata(tag_value_mem_rdata),

		.tag_hash_table0_rd(tag_hash_table0_rd),
		.tag_hash_table0_raddr(tag_hash_table0_raddr),

		.tag_hash_table1_rd(tag_hash_table1_rd),
		.tag_hash_table1_raddr(tag_hash_table1_raddr),

		.tag_value_rd(tag_value_rd),
		.tag_value_raddr(tag_value_raddr),

		.tag_hash_table0_ack(tag_hash_table0_ack),
		.tag_hash_table0_rdata(tag_hash_table0_rdata),

		.tag_hash_table1_ack(tag_hash_table1_ack),
		.tag_hash_table1_rdata(tag_hash_table1_rdata),

		.tag_value_ack(tag_value_ack),
		.tag_value_rdata(tag_value_rdata)
);

endmodule            
