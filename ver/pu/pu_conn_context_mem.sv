//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import type_package::*;

module pu_conn_context_mem #(
parameter NUM_OF_PU = `NUM_OF_PU,
parameter WIDTH_NBITS = `PU_WIDTH_NBITS,
parameter DEPTH_NBITS = `SCI_NBITS+`CONNECTION_CONTEXT_DEPTH_NBITS
) ( 
	input clk,
	input `RESET_SIG,

	input clk_div,
	
	input [`PIO_RANGE] reg_addr,
	input [`PIO_RANGE] reg_din,
	input reg_rd,
	input reg_wr,
	input reg_ms_conn_context,
	
	output reg conn_context_mem_ack,
	output reg [`PIO_RANGE] conn_context_mem_rdata,

	input   asa_pu_table_wr,
	input [`RCI_NBITS-1:0] asa_pu_table_waddr,
	input [`SCI_NBITS-1:0] asa_pu_table_wdata,

	input [NUM_OF_PU-1:0] io_req, 
	input io_type io_cmd[NUM_OF_PU-1:0], 

	output logic [NUM_OF_PU-1:0] io_ack,
	output logic [WIDTH_NBITS-1:0] io_ack_data[NUM_OF_PU-1:0]
);

integer i;

logic   asa_pu_table_wr_d1;
logic [`RCI_NBITS-1:0] asa_pu_table_waddr_d1;
logic [`SCI_NBITS-1:0] asa_pu_table_wdata_d1;

io_type io_cmd_d1[NUM_OF_PU-1:0]; 

logic [NUM_OF_PU-1:0] in_fifo_wr;
logic [NUM_OF_PU-1:0] in_fifo_rd;
logic [NUM_OF_PU-1:0] in_fifo_empty;

wire [NUM_OF_PU-1:0] arb_rd_req = ~in_fifo_empty&~in_fifo_rd;
logic [`PU_ID_NBITS-1:0] arb_rd_sel;
logic [`PU_ID_NBITS-1:0] arb_rd_sel_d1;
logic arb_rd_gnt;
logic arb_rd_gnt_d1;

logic [`PU_ID_NBITS-1:0] fifo_arb_sel;

logic conn_context_ack;
logic [WIDTH_NBITS-1:0] conn_context_rdata;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
        io_ack <= 0;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
		io_ack_data[i] <= 0;
    end else begin
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin 
        	io_ack[i] <= conn_context_ack&(fifo_arb_sel==i);
		io_ack_data[i] <= conn_context_ack&(fifo_arb_sel==i)?conn_context_rdata:0;
	end
    end

always @(*)
	for (i = 0; i < NUM_OF_PU ; i = i + 1) begin  
		in_fifo_wr[i] = io_req[i]&(io_cmd[i].addr[`PU_MEM_DEPTH_MSB_RANGE]==`PU_CONNECTION_CONTEXT_MEM);
        	in_fifo_rd[i] = ~in_fifo_empty[i]&(i==arb_rd_sel)&arb_rd_gnt;
	end

always @(posedge clk) begin
	asa_pu_table_wr_d1 <= asa_pu_table_wr;
	asa_pu_table_waddr_d1 <= asa_pu_table_waddr;
	asa_pu_table_wdata_d1 <= asa_pu_table_wdata;

	arb_rd_sel_d1 <= arb_rd_sel;
	arb_rd_gnt_d1 <= arb_rd_gnt;

	for (i = 0; i < NUM_OF_PU ; i = i + 1)  
		io_cmd_d1[i] <= io_req[i]?io_cmd[i]:io_cmd_d1[i];
end

wire [`RCI_NBITS-1:0] ram_raddr = io_cmd_d1[arb_rd_sel].addr[`RCI_NBITS-1+`CONNECTION_CONTEXT_DEPTH_NBITS:`CONNECTION_CONTEXT_DEPTH_NBITS];
logic [`SCI_NBITS-1:0] ram_rdata;

wire conn_context_rd = arb_rd_gnt_d1;
wire [DEPTH_NBITS-1:0] conn_context_raddr = {ram_rdata, io_cmd_d1[arb_rd_sel_d1].addr[`CONNECTION_CONTEXT_DEPTH_NBITS-1:0]};

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

ram_1r1w #(`SCI_NBITS, `RCI_NBITS) u_ram_1r1w(
		.clk(clk),
		.wr(asa_pu_table_wr_d1),
		.raddr(ram_raddr),
		.waddr(asa_pu_table_waddr_d1),
		.din(asa_pu_table_wdata_d1),

		.dout(ram_rdata)
);

sfifo2f_fo #(`PU_ID_NBITS, 2) u_sfifo2f_fo(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din(arb_rd_sel),
		.rd(conn_context_ack),
		.wr(arb_rd_gnt),
		.ncount(),
		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout(fifo_arb_sel)
);

pio_mem #(WIDTH_NBITS, DEPTH_NBITS) u_pio_mem(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_conn_context),

		.app_mem_rd(conn_context_rd),
		.app_mem_raddr(conn_context_raddr),

        	.mem_ack(conn_context_mem_ack),
        	.mem_rdata(conn_context_mem_rdata),

		.app_mem_ack(conn_context_ack),
		.app_mem_rdata(conn_context_rdata)
);

endmodule            
