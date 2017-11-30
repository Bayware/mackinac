//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_topic_pd_mem #(
parameter NUM_OF_PU = `NUM_OF_PU,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter DEPTH_NBITS = `TOPIC_PD_NBITS-2+`TID_NBITS
) ( 
	input clk,
	input `RESET_SIG,

	input [NUM_OF_PU-1:0] io_req, 
	input io_type io_cmd[NUM_OF_PU-1:0], 

	output logic [NUM_OF_PU-1:0] io_ack,
	output logic [WIDTH_NBITS-1:0] io_ack_data[NUM_OF_PU-1:0]
);

integer i;

logic [NUM_OF_PU-1:0] io_req_d1;
io_type io_cmd_d1[NUM_OF_PU-1:0]; 

logic [NUM_OF_PU-1:0] in_fifo_wr;
logic [NUM_OF_PU-1:0] in_fifo_rd;
logic [NUM_OF_PU-1:0] in_fifo_rd_d1;
logic [NUM_OF_PU-1:0] in_fifo_empty;

logic [NUM_OF_PU-1:0] same_addr;
logic [NUM_OF_PU-1:0] same_addr_d1;

logic [`PU_ID_NBITS-1:0] arb_rd_sel_d1;
logic [`PU_ID_NBITS-1:0] arb_rd_sel_d2;
logic [`PU_ID_NBITS-1:0] arb_rd_sel;
logic arb_rd_gnt;

logic [NUM_OF_PU-1:0] ack_rd;
logic [NUM_OF_PU-1:0] ack_wr;
;
logic [`PU_ID_NBITS-1:0] arb_wr_sel;
logic arb_wr_gnt;

wire atomic_rd = io_cmd_d1[arb_rd_sel].atomic&arb_rd_gnt;
logic atomic_rd_d1;
logic atomic_rd_d2;

logic [NUM_OF_PU-1:0] rd_req;
wire [NUM_OF_PU-1:0] arb_rd_req = ~in_fifo_empty&rd_req;

logic [NUM_OF_PU-1:0] wr_req;
wire [NUM_OF_PU-1:0] arb_wr_req = ~in_fifo_empty&wr_req;

wire [DEPTH_NBITS-1:0] ram_raddr = {io_cmd_d1[arb_rd_sel].tid, io_cmd_d1[arb_rd_sel].addr[`TOPIC_PD_NBITS-2-1:0]};
logic [DEPTH_NBITS-1:0] ram_raddr_d1;
logic [DEPTH_NBITS-1:0] ram_raddr_d2;

logic [WIDTH_NBITS-1:0] io_cmd_wdata;

logic [WIDTH_NBITS-1:0] ram_rdata /* synthesis DONT_TOUCH */;
logic [WIDTH_NBITS-1:0] ram_rdata_d1;
logic [WIDTH_NBITS-1:0] mod_ram_rdata;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_ack <= 0;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
        	io_ack_data[0] <= 0;
    end else begin
        io_ack <= in_fifo_rd_d1;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
		io_ack_data[i] <= in_fifo_rd_d1[i]?ram_rdata:0;
    end

always @(*) begin
	if (io_cmd_d1[arb_rd_sel_d2].funct5[4:0]==5'b00001)
		mod_ram_rdata = io_cmd_wdata;
	else 
		case (io_cmd_d1[arb_rd_sel_d2].funct5[4:2])
			3'b000: mod_ram_rdata = io_cmd_wdata+ram_rdata_d1;
			3'b001: mod_ram_rdata = io_cmd_wdata^ram_rdata_d1;
			3'b010: mod_ram_rdata = io_cmd_wdata|ram_rdata_d1;
			3'b011: mod_ram_rdata = io_cmd_wdata&ram_rdata_d1;
			3'b100: mod_ram_rdata = ($signed(io_cmd_wdata)<$signed(ram_rdata_d1))?io_cmd_wdata:ram_rdata_d1;
			3'b101: mod_ram_rdata = ($signed(io_cmd_wdata)<$signed(ram_rdata_d1))?ram_rdata_d1:io_cmd_wdata;
			3'b110: mod_ram_rdata = (io_cmd_wdata<ram_rdata_d1)?io_cmd_wdata:ram_rdata_d1;
			3'b111: mod_ram_rdata = (io_cmd_wdata<ram_rdata_d1)?ram_rdata_d1:io_cmd_wdata;
		endcase

	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin 
		same_addr[i] = {io_cmd_d1[i].tid, io_cmd_d1[i].addr[`TOPIC_PD_NBITS-2-1:0]}==ram_raddr;
		same_addr_d1[i] = {io_cmd_d1[i].tid, io_cmd_d1[i].addr[`TOPIC_PD_NBITS-2-1:0]}==ram_raddr_d1;
		in_fifo_wr[i] = io_req[i]&(io_cmd[i].addr[`PU_MEM_MULTI_DEPTH_RANGE]==`PU_TOPIC_MEM);
        	in_fifo_rd[i] = ack_rd[i]|ack_wr[i];
		rd_req[i] = (io_cmd_d1[i].atomic|~io_cmd_d1[i].wr)&~({(1){atomic_rd}}&same_addr|{(1){atomic_rd_d1}}&same_addr_d1);
		wr_req[i] = ~io_cmd_d1[i].atomic&io_cmd_d1[i].wr&~({(1){atomic_rd}}&same_addr);
	end
end

wire dis_wr_en = atomic_rd_d1;

always @(posedge clk) begin
	io_cmd_wdata <= io_cmd_d1[arb_rd_sel_d1].wdata;
	arb_rd_sel_d1 <= arb_rd_sel;
	arb_rd_sel_d2 <= arb_rd_sel_d1;
	ram_rdata_d1 <= ram_rdata;
	atomic_rd_d1 <= atomic_rd;
	atomic_rd_d2 <= atomic_rd_d1;
	ram_raddr_d1 <= ram_raddr;
	ram_raddr_d2 <= ram_raddr_d1;
	for (i = 0; i < NUM_OF_PU ; i = i + 1)  
		io_cmd_d1[i] <= io_req[i]?io_cmd[i]:io_cmd_d1[i];
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        in_fifo_rd_d1 <= 0;
    end else begin
        in_fifo_rd_d1 <= in_fifo_rd;
    end

wire ram_wr = arb_wr_gnt|atomic_rd_d2;
wire [WIDTH_NBITS-1:0] ram_wdata = atomic_rd_d2?mod_ram_rdata:io_cmd_d1[arb_wr_sel].wdata;
wire [DEPTH_NBITS-1:0] ram_waddr = atomic_rd_d2?ram_raddr_d2:{io_cmd_d1[arb_wr_sel].tid, io_cmd_d1[arb_wr_sel].addr[`TOPIC_PD_NBITS-2-1:0]};

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

	.ack(ack_rd),
	.sel(arb_rd_sel),
	.gnt(arb_rd_gnt)
);

rr_arb20 u_rr_arb_20_1 (
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.en(~dis_wr_en),
	.req(arb_wr_req),

	.ack(ack_wr),
	.sel(arb_wr_sel),
	.gnt(arb_wr_gnt)
);

ram_1r1w_ultra #(WIDTH_NBITS, DEPTH_NBITS) u_ram_1r1w_ultra(
		.clk(clk),
		.wr(ram_wr),
		.raddr(ram_raddr),
		.waddr(ram_waddr),
		.din(ram_wdata),

		.dout(ram_rdata)
);


endmodule            
