//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_switch_info_mem #(
parameter NUM_OF_PU = `NUM_OF_PU,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter DEPTH_NBITS = `SWITCH_INFO_DEPTH_NBITS
) ( 
	input clk,
	input `RESET_SIG,

	input clk_div,
	
	input [`PIO_RANGE] reg_addr,
	input [`PIO_RANGE] reg_din,
	input reg_rd,
	input reg_wr,
	input reg_ms_switch_info,
	
	output reg switch_info_mem_ack,
	output reg [`PIO_RANGE] switch_info_mem_rdata,

	input [NUM_OF_PU-1:0] io_req, 
	input io_type io_cmd[NUM_OF_PU-1:0], 

	output logic [NUM_OF_PU-1:0] io_ack,
	output logic [WIDTH_NBITS-1:0] io_ack_data[NUM_OF_PU-1:0]
);

integer i;

io_type io_cmd_d1[NUM_OF_PU-1:0]; 

logic [NUM_OF_PU-1:0] in_fifo_wr;
logic [NUM_OF_PU-1:0] in_fifo_empty;

logic [NUM_OF_PU-1:0] ack;
wire [NUM_OF_PU-1:0] in_fifo_rd = ack;

wire [NUM_OF_PU-1:0] arb_rd_req = ~in_fifo_empty&~in_fifo_rd;
logic [`PU_ID_NBITS-1:0] arb_rd_sel;
logic arb_rd_gnt;

logic [`PU_ID_NBITS-1:0] fifo_arb_sel;

logic switch_info_ack;
logic [WIDTH_NBITS-1:0] switch_info_rdata;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_ack <= 0;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
		io_ack_data[i] <= 0;
    end else begin
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin 
        	io_ack[i] <= switch_info_ack&(fifo_arb_sel==i);
		io_ack_data[i] <= switch_info_ack&(fifo_arb_sel==i)?switch_info_rdata:0;
	end
    end


always @(*)
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin
		in_fifo_wr[i] = io_req[i]&(io_cmd[i].addr[`PU_MEM_MULTI_DEPTH_RANGE]==`PU_SWITCH_INFO_MEM);
	end

always @(posedge clk) 
	for (i = 0; i < NUM_OF_PU ; i = i + 1)  
		io_cmd_d1[i] <= io_req[i]?io_cmd[i]:io_cmd_d1[i];

wire switch_info_rd = arb_rd_gnt;
wire [DEPTH_NBITS-1:0] switch_info_raddr = {io_cmd_d1[arb_rd_sel].fid, io_cmd_d1[arb_rd_sel].addr[DEPTH_NBITS-1:0]};

genvar gi;

generate
for (gi = 0; gi < NUM_OF_PU ; gi = gi + 1) begin 
	sfifo1f #(1) u_sfifo1f(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(in_fifo_wr[gi]), .din(1'b1), .dout(), .rd(in_fifo_rd[gi]), .full(), .empty(in_fifo_empty[gi]));

end
endgenerate

rr_arb20 u_rr_arb_20_0 (
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.en(1'b1),
	.req(arb_rd_req),

	.ack(ack),
	.sel(arb_rd_sel),
	.gnt(arb_rd_gnt)
);

logic [`PU_ID_NBITS-1:0] arb_fifo_dout;
logic arb_fifo_empty;
logic arb_fifo_full;
//logic arb_fifo_rd = ~arb_fifo_empty&~arb_fifo_full;;
//sfifo1f #(`PU_ID_NBITS) u_sfifo1f(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(arb_rd_gnt), .din(arb_rd_sel), .dout(arb_fifo_dout), .rd(arb_fifo_rd), .full(), .empty(arb_fifo_empty));

sfifo2f_fo #(`PU_ID_NBITS, 2) u_sfifo2f_fo(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(arb_rd_sel),
		.rd(switch_info_ack),
		.wr(arb_rd_gnt),
		.ncount(),
		.count(),
		.full(arb_fifo_full),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_arb_sel)
);

pio_mem_bram #(WIDTH_NBITS, DEPTH_NBITS) u_pio_mem_bram(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_switch_info),

		.app_mem_rd(switch_info_rd),
		.app_mem_raddr(switch_info_raddr),

        	.mem_ack(switch_info_mem_ack),
        	.mem_rdata(switch_info_mem_rdata),

		.app_mem_ack(switch_info_ack),
		.app_mem_rdata(switch_info_rdata)
);

endmodule            
