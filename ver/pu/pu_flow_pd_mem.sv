//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_flow_pd_mem #(
parameter NUM_OF_PU = `NUM_OF_PU,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter DEPTH_NBITS = `FLOW_PD_NBITS-2+`FID_NBITS
) ( 
	input clk,
	input `RESET_SIG,

	input [NUM_OF_PU-1:0] io_req, 
	input io_type io_cmd[NUM_OF_PU-1:0], 

	output logic [NUM_OF_PU-1:0] io_ack,
	output logic [WIDTH_NBITS-1:0] io_ack_data[NUM_OF_PU-1:0]
);

integer i;

io_type io_cmd_d1[NUM_OF_PU-1:0]; 

logic [NUM_OF_PU-1:0] in_fifo_wr;
logic [NUM_OF_PU-1:0] in_fifo_rd;
logic [NUM_OF_PU-1:0] in_fifo_rd_d1;
logic [NUM_OF_PU-1:0] in_fifo_empty;

logic [NUM_OF_PU-1:0] arb_rd_req;
logic [`PU_ID_NBITS-1:0] arb_rd_sel;
logic arb_rd_gnt;

logic [NUM_OF_PU-1:0] arb_wr_req;
logic [`PU_ID_NBITS-1:0] arb_wr_sel;
logic arb_wr_gnt;

logic [`PU_ID_NBITS-1:0] fifo_arb_sel;

logic [WIDTH_NBITS-1:0] ram_rdata;
wire [WIDTH_NBITS-1:0] flow_pd_rdata = ram_rdata;
wire flow_pd_ack = in_fifo_rd_d1;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_ack <= 0;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
		io_ack_data[i] <= 0;
    end else begin
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin 
        	io_ack[i] <= flow_pd_ack&(fifo_arb_sel==i);
		io_ack_data[i] <= flow_pd_ack&(fifo_arb_sel==i)?flow_pd_rdata:0;
	end
    end


always @(*)
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin 
		in_fifo_wr[i] = io_req[i]&(io_cmd[i].addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_FLOW_MEM);
        	in_fifo_rd[i] = ~in_fifo_empty[i]&((i==arb_wr_sel)&arb_wr_gnt|(i==arb_rd_sel)&arb_rd_gnt);
		arb_rd_req[i] = ~in_fifo_empty[i]&~io_cmd_d1[i].wr&~in_fifo_rd[i];
		arb_wr_req[i] = ~in_fifo_empty[i]&io_cmd_d1[i].wr&~in_fifo_rd[i];
	end

always @(posedge clk) 
	for (i = 0; i < NUM_OF_PU ; i = i + 1)  
		io_cmd_d1[i] <= io_req[i]?io_cmd[i]:io_cmd_d1[i];

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        in_fifo_rd_d1 <= 0;
    end else begin
        in_fifo_rd_d1 <= in_fifo_rd;
    end


wire [DEPTH_NBITS-1:0] ram_raddr = {io_cmd_d1[arb_rd_sel].fid, io_cmd_d1[arb_rd_sel].addr[`FLOW_PD_NBITS-2-1:0]};

wire ram_wr = io_cmd_d1[arb_wr_sel].wr&arb_wr_gnt;
wire [WIDTH_NBITS-1:0] ram_wdata = io_cmd_d1[arb_wr_sel].wdata;
wire [DEPTH_NBITS-1:0] ram_waddr = {io_cmd_d1[arb_wr_sel].fid, io_cmd_d1[arb_wr_sel].addr[`FLOW_PD_NBITS-2-1:0]};

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

	.sel(arb_rd_sel),
	.gnt(arb_rd_gnt)
);

rr_arb20 u_rr_arb_20_1 (
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.en(1'b1),
	.req(arb_wr_req),

	.sel(arb_wr_sel),
	.gnt(arb_wr_gnt)
);


sfifo2f_fo #(`PU_ID_NBITS, 1) u_sfifo2f_fo(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(arb_rd_sel),
		.rd(flow_pd_ack),
		.wr(arb_rd_gnt),
		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_arb_sel)
);

ram_1r1w #(WIDTH_NBITS, DEPTH_NBITS) u_ram_1r1w(
		.clk(clk),
		.wr(ram_wr),
		.raddr(ram_raddr),
		.waddr(ram_waddr),
		.din(ram_wdata),

		.dout(ram_rdata)
);


endmodule            
