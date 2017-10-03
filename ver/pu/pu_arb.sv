//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pu_arb #(
parameter NUM_OF_PU = `NUM_OF_PU
) ( 
	input clk,
	input `RESET_SIG,

	input [NUM_OF_PU-1:0] pu_req, 

	output logic start,
	output logic [NUM_OF_PU-1:0] pu_gnt
);

localparam CLK_NUM = 4;
localparam CLK_NUM_NBITS = 2;

integer i;

logic [NUM_OF_PU-1:0] pu_req_d1;
logic [CLK_NUM_NBITS-1:0]  clk_div;
logic [2:0]  clk_div1;

logic [NUM_OF_PU-1:0] in_fifo_empty;
logic [NUM_OF_PU-1:0] in_fifo_rd;

logic [NUM_OF_PU-1:0] arb_req;
logic [`PU_ID_NBITS-1:0] arb_sel;
logic arb_gnt;

wire last_clk_div = clk_div==CLK_NUM-1;
wire last_clk_div1 = clk_div1==`PU_ASA_TS-1;
logic en;
logic en_d1;

assign pu_gnt = in_fifo_rd;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
	start <= 1'b0;
        pu_req_d1 <= 0;
        clk_div <= 0;
        clk_div1 <= 0;
        en <= 0;
        en_d1 <= 0;
        arb_req <= 0;
        in_fifo_rd <= 0;
    end else begin
	start <= last_clk_div1;
        pu_req_d1 <= pu_req;
        clk_div <= last_clk_div?0:clk_div+1;
        clk_div1 <= last_clk_div1?0:clk_div1+1;
        en <= last_clk_div;
        en_d1 <= en;
        arb_req <= en?~in_fifo_empty:arb_req;
	for (i = 0; i < NUM_OF_PU ; i = i + 1) 
        	in_fifo_rd[i] <= en_d1?~in_fifo_empty[i]&(i==arb_sel)&arb_gnt:1'b0;
    end

genvar gi;

generate
for (gi = 0; gi < NUM_OF_PU ; gi = gi + 1) begin 
	sfifo2f1 #(1) u_sfifo2f1(.clk(clk), .`RESET_SIG(`RESET_SIG), .wr(pu_req_d1[gi]), .din(1'b1), .dout(), .rd(in_fifo_rd[gi]), .full(), .empty(in_fifo_empty[gi]), .count(), .fullm1(), .emptyp2());

end
endgenerate

rr_arb20 u_rr_arb_20 (
	.clk(clk),
	.`RESET_SIG(`RESET_SIG),

	.en(en),
	.req(arb_req),

	.sel(arb_sel),
	.gnt(arb_gnt)
);

endmodule            
