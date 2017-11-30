//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_tag_result_mem #(
parameter NUM_OF_PU = `NUM_OF_PU,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter DEPTH_NBITS = `TAG_RESULT_DEPTH_NBITS
) ( 
	input clk,
	input `RESET_SIG,

	input clk_div,
	
	input tag_lookup_valid,
	input [`RCI_NBITS-1:0] tag_lookup_result,
	input [2:0] tag_lookup_result_num,
	input [`PU_ID_NBITS-1:0] tag_lookup_result_pid,

	input tag_lookup_status_valid,
	input [3:0] tag_lookup_status,
	input [`PU_ID_NBITS-1:0] tag_lookup_status_pid,

	input [NUM_OF_PU-1:0] io_req, 
	input io_type io_cmd[NUM_OF_PU-1:0], 

	output logic [NUM_OF_PU-1:0] io_ack,
	output logic [WIDTH_NBITS-1:0] io_ack_data[NUM_OF_PU-1:0]
);

integer i;

logic [NUM_OF_PU-1:0] io_req_d1;
logic [NUM_OF_PU-1:0] io_req_d2;

logic [NUM_OF_PU-1:0] io_rd_req_d2;

io_type io_cmd_d1[NUM_OF_PU-1:0]; 

logic [NUM_OF_PU-1:0] ram_wr_l;
logic [NUM_OF_PU-1:0] ram_wr_h;
logic [DEPTH_NBITS-1:0] ram_waddr[NUM_OF_PU-1:0];
logic [WIDTH_NBITS/2-1:0] ram_wdata_l[NUM_OF_PU-1:0];
logic [WIDTH_NBITS/2-1:0] ram_wdata_h[NUM_OF_PU-1:0];

logic [DEPTH_NBITS-1:0] ram_raddr[NUM_OF_PU-1:0];
(* dont_touch = "true" *) logic [WIDTH_NBITS/2-1:0] ram_rdata_l[NUM_OF_PU-1:0] ;
(* dont_touch = "true" *) logic [WIDTH_NBITS/2-1:0] ram_rdata_h[NUM_OF_PU-1:0] ;


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_ack <= 0;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
		io_ack_data[i] <= 0;
    end else begin
        io_ack <= io_req_d2;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
		io_ack_data[i] <= io_rd_req_d2[i]?{ram_rdata_h[i], ram_rdata_l[i]}:0;
    end

always @(*)
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin
		ram_wr_l[i] = tag_lookup_valid&(i==tag_lookup_result_pid)&tag_lookup_result_num[0]|tag_lookup_status_valid&(i==tag_lookup_status_pid);
		ram_wr_h[i] = tag_lookup_valid&(i==tag_lookup_result_pid)&~tag_lookup_result_num[0]|tag_lookup_status_valid&(i==tag_lookup_status_pid);
		ram_waddr[i] = tag_lookup_status_valid?0:tag_lookup_result_num[2:1]+1;
		ram_wdata_l[i] = tag_lookup_status_valid?tag_lookup_status:tag_lookup_result;
		ram_wdata_h[i] = tag_lookup_status_valid?0:tag_lookup_result;

		ram_raddr[i] = io_cmd_d1[i].addr[DEPTH_NBITS-1:0];
	end

always @(posedge clk) 
	io_cmd_d1 <= io_cmd;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_req_d1 <= 0;
        io_req_d2 <= 0;
        io_rd_req_d2 <= 0;
    end else begin
        io_req_d1 <= io_req;
        io_req_d2 <= io_req_d1&(io_cmd_d1[i].addr[`PU_MEM_MULTI_DEPTH_RANGE]==`PU_TAG_LOOKUP_RESULT);
        io_rd_req_d2 <= io_req_d1&~io_cmd_d1[i].wr&(io_cmd_d1[i].addr[`PU_MEM_MULTI_DEPTH_RANGE]==`PU_TAG_LOOKUP_RESULT);
    end

genvar gi;

generate
for (gi = 0; gi < NUM_OF_PU ; gi = gi + 1) begin 

	ram_1r1w_ultra #(WIDTH_NBITS/2, `TAG_RESULT_DEPTH_NBITS) u_ram_1r1w_ultra_h(
		.clk(clk),
		.wr(ram_wr_h[gi]),
		.raddr(ram_raddr[gi]),
		.waddr(ram_waddr[gi]),
		.din(ram_wdata_h[gi]),

		.dout(ram_rdata_h[gi])
	);

	ram_1r1w_ultra #(WIDTH_NBITS/2, `TAG_RESULT_DEPTH_NBITS) u_ram_1r1w_ultra_l(
		.clk(clk),
		.wr(ram_wr_l[gi]),
		.raddr(ram_raddr[gi]),
		.waddr(ram_waddr[gi]),
		.din(ram_wdata_l[gi]),

		.dout(ram_rdata_l[gi])
	);

end
endgenerate

endmodule            
