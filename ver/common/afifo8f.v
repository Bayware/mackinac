//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 8-deep async FIFO
//===========================================================================

`include "defines.vh"

module afifo8f #(
parameter WIDTH = 16,
parameter DEPTH_NBITS = 3,
parameter DEPTH = (16'h1  << DEPTH_NBITS),
parameter MAXM1 = {(DEPTH_NBITS){1'b1}}
) (

input clk_w, clk_r,
input reset_w, reset_r,

input [(WIDTH - 1):0] din,
input rd, wr,

output reg [DEPTH_NBITS:0] count_r,
output reg [DEPTH_NBITS:0] count_w,
output reg full, empty, fullm1, emptyp2,

output [(WIDTH - 1):0] dout

);

/***************************** LOCAL VARIABLES *******************************/

reg [(DEPTH_NBITS):0] rptr_bc, wptr_bc;
reg [(DEPTH_NBITS):0] rptr, wptr;
reg rseq, wseq;

wire [(DEPTH_NBITS):0] rptr_w;
wire [(DEPTH_NBITS):0] wptr_r;

genvar k;
generate
   for (k=0; k < DEPTH_NBITS+1; k=k+1)
      begin : generate_rptr
         synchronizer u_synchronizer(.clk(clk_w), .din(rptr[k]), .dout(rptr_w[k]));
      end
endgenerate

genvar j;
generate
   for (j=0; j < DEPTH_NBITS+1; j=j+1)
      begin : generate_wptr
         synchronizer u_synchronizer(.clk(clk_r), .din(wptr[j]), .dout(wptr_r[j]));
      end
endgenerate

wire [(DEPTH_NBITS):0] rptr_w_bin = grey4bin(rptr_w);
wire [(DEPTH_NBITS):0] wptr_r_bin = grey4bin(wptr_r);

wire [(DEPTH_NBITS):0] rptr_bc_p1 = rptr_bc+rd;
wire [(DEPTH_NBITS):0] wptr_bc_p1 = wptr_bc+wr;

wire [(DEPTH_NBITS):0] count_r_p1 = {(wptr_r_bin[DEPTH_NBITS]^rptr_bc_p1[DEPTH_NBITS]),
				wptr_r_bin[DEPTH_NBITS-1:0]}-rptr_bc_p1[DEPTH_NBITS-1:0];

wire [(DEPTH_NBITS):0] count_w_p1 = {(wptr_bc_p1[DEPTH_NBITS]^rptr_w_bin[DEPTH_NBITS]),
				wptr_bc_p1[DEPTH_NBITS-1:0]}-rptr_w_bin[DEPTH_NBITS-1:0];

/***************************** NON REGISTERED OUTPUTS ***********************/

fifo_data #(WIDTH, DEPTH_NBITS) fifo_data_inst(

                // inputs

                .clk                    (clk_w),

                .rptr                   (rptr_bc[DEPTH_NBITS-1:0]),
                .wptr                   (wptr_bc[DEPTH_NBITS-1:0]),
                .wr                     (wr),
                .din                    (din),

                //outputs

                .dout                   (dout)
);

/***************************** REGISTERED OUTPUTS ***************************/

always @(posedge clk_r or posedge reset_r) 
	if (reset_r) begin
		empty <= 1;
		emptyp2 <= 0;
		count_r <= 0;
	end else begin
		empty <= rptr_bc_p1==wptr_r_bin;
		emptyp2 <= (count_r_p1==2);
		count_r <= count_r_p1;
	end

always @(posedge clk_w or posedge reset_w) 
	if (reset_w) begin
		full <= 0;
		fullm1 <= 0;
		count_w <= 0;
	end else begin
		full <= (wptr_bc_p1[DEPTH_NBITS]^rptr_w_bin[DEPTH_NBITS])&
                (wptr_bc_p1[DEPTH_NBITS-1:0]==rptr_w_bin[DEPTH_NBITS-1:0]);
		fullm1 <= (count_w_p1==MAXM1);
		count_w <= count_w_p1;
	end
/***************************** PROGRAM BODY *******************************/

wire [(DEPTH_NBITS):0] wptr_p1 = wr?grey4(wseq, wptr):wptr;
wire [(DEPTH_NBITS):0] rptr_p1 = rd?grey4(rseq, rptr):rptr;

always @(posedge clk_r or posedge reset_r) 

	if (reset_r) begin
		rptr_bc <= 0;
		rptr <= 0;
		rseq <= 0;
	end else begin
		rptr_bc <= rptr_bc_p1;
		rptr <= rptr_p1;
		rseq <= rseq^rd;
	end


always @(posedge clk_w or posedge reset_w) 

	if (reset_w) begin
		wptr_bc <= 0;
		wptr <= 0;
		wseq <= 0;
	end else begin
		wptr_bc <= wptr_bc_p1;
		wptr <= wptr_p1;
		wseq <= wseq^wr;
	end

/******************************** FUNCTION *********************************/

function [3:0] grey4;
input seq;
input[3:0] count;
begin
	grey4[0] = ~seq^count[0];
	grey4[1] = (seq&count[0])^count[1];
	grey4[2] = (seq&count[1]&~count[0])^count[2];
	grey4[3] = (seq&~count[1]&~count[0])^count[3];
end
endfunction

function [3:0] grey4bin;
input[3:0] grey4;
begin

	grey4bin = {	grey4[3], 
			(grey4[3]^grey4[2]), 
			(grey4[3]^grey4[2]^grey4[1]), 
			(grey4[3]^grey4[2]^grey4[1]^grey4[0])};

end
endfunction

/***************************** DIAGNOSTICS *********************************/

// synopsy translate_off 
always @(posedge clk_w) 
	if (~reset_w & wr & full) $display("ERROR: %d %m write when FIFO full", $time);
always @(posedge clk_r) 
	if (~reset_r & rd & empty) $display("ERROR: %d %m read when FIFO empty", $time);
// synopsy translate_on

endmodule

