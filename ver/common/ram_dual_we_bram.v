//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : dual port memory model
//===========================================================================

module ram_dual_we_bram
             ( clk1, wr1, we1, raddr1, waddr1, din1, dout1, clk2, wr2, we2, raddr2, waddr2, din2, dout2);

parameter WIDTH = 32,
	      DEPTH_NBITS = 4,
	      DEPTH = 16'h1<<DEPTH_NBITS;

output  [WIDTH-1:0] dout1;

input    clk1, wr1;  
input   [3:0] we1;
input   [DEPTH_NBITS-1:0] raddr1, waddr1;
input   [WIDTH-1:0] din1;

output  [WIDTH-1:0] dout2;

input    clk2, wr2;  
input   [3:0] we2;
input   [DEPTH_NBITS-1:0] raddr2, waddr2;
input   [WIDTH-1:0] din2;

reg [WIDTH-1:0] dout1;
reg [WIDTH-1:0] dout2;
(* ram_style = "block" *)
reg [WIDTH-1:0] mem_d[DEPTH-1:0];

always @(posedge clk1) begin
	if(wr1&we1[0]) mem_d[waddr1][7:0] <= din1[7:0];
	if(wr1&we1[1]) mem_d[waddr1][15:8] <= din1[15:8];
	if(wr1&we1[2]) mem_d[waddr1][23:16] <= din1[23:16];
	if(wr1&we1[3]) mem_d[waddr1][31:24] <= din1[31:24];
end


always @(posedge clk1) begin
	dout1 <= mem_d[raddr1];
end

always @(posedge clk2) begin
	if(wr2&we2[0]) mem_d[waddr2][7:0] <= din2[7:0];
	if(wr2&we2[1]) mem_d[waddr2][15:8] <= din2[15:8];
	if(wr2&we2[2]) mem_d[waddr2][23:16] <= din2[23:16];
	if(wr2&we2[3]) mem_d[waddr2][31:24] <= din2[31:24];
end


always @(posedge clk2) begin
	dout2 <= mem_d[raddr2];
end

endmodule            
