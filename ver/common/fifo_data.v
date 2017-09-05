//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : parameterized synchronous FIFO data
//===========================================================================

`define ONE_DIMENSION

module fifo_data (

	// inputs

	clk,

	rptr,
	wptr,
	wr,
	din,

	//outputs

	dout 

	);

parameter WIDTH = 16;
parameter DEPTH_BITS = 3;
parameter DEPTH = (16'h1  << DEPTH_BITS);
parameter TOTAL_BITS = WIDTH*DEPTH;


input clk;

input [(DEPTH_BITS - 1):0] rptr, wptr;
input wr;
input [(WIDTH - 1):0] din;

output [(WIDTH - 1):0] dout;


`ifdef ONE_DIMENSION /*****************************************************/

reg [(TOTAL_BITS - 1):0] fifod;
reg [(DEPTH - 1):0] fd;
reg [(WIDTH - 1):0] dout;

reg [(DEPTH - 1):0] wren;

integer r, j, i, l, k;


always @(fifod or rptr) 
	for (r = 0; r < WIDTH; r = r + 1) begin
		for (j = 0; j < DEPTH; j = j + 1) 
			fd[j] = fifod[j*WIDTH+r];
		dout[r] = fd[rptr];		
	end

always @(wptr or wr) 
	for (i = 0; i < DEPTH; i = i + 1) 
		wren[i] = wr & (wptr == i);

always @(posedge clk) 
	for (l = 0; l < WIDTH; l = l + 1) 
		for (k = 0; k < DEPTH; k = k + 1) 
			fifod[WIDTH*k+l] <= wren[k]?din[l]:fifod[WIDTH*k+l];
	
`else /*******************************************************************/

reg[WIDTH-1:0] fifod [DEPTH-1:0] /* synthesis ramstyle = "M20K, no_rw_check" */;

assign dout = fifod[rptr];       // distributed RAM only - Xilinx

always @(posedge clk) if (wr) fifod[wptr] <= din;

`endif /*******************************************************************/

endmodule

