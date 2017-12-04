//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module rr_arb20 #(
parameter NUM_OF_INPUT = 20,
parameter INPUT_NBITS = 5
) (


input clk, `RESET_SIG,

input [NUM_OF_INPUT-1:0] req, 
input en, 

output logic [NUM_OF_INPUT-1:0] ack, 
(* keep = "true" *) output logic [INPUT_NBITS-1:0] sel, 
output logic gnt

);
/***************************** LOCAL VARIABLES *******************************/
integer i;
//
(* keep = "true" *) reg [INPUT_NBITS-1:0] arb;
(* keep = "true" *) reg [INPUT_NBITS-1:0] arb1;
(* keep = "true" *) reg [INPUT_NBITS-1:0] arb2;
(* keep = "true" *) reg gnt1;

wire [NUM_OF_INPUT-1:0] lreq = req&rmask(arb1); 
wire [NUM_OF_INPUT-1:0] rreq = req&lmask(arb2, gnt1); 
wire [INPUT_NBITS-1:0] lpri = pri(lreq);
wire [INPUT_NBITS-1:0] rpri = pri(rreq);
wire [INPUT_NBITS-1:0] n_arb = |lreq?lpri:rpri;
wire n_gnt = en&(|lreq)|(|rreq);

/***************************** NON REGISTERED OUTPUTS ************************/

always @* 
	for(i=0; i<NUM_OF_INPUT; i=i+1)
		ack[i] = gnt&(arb==i);

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		sel <= 0;
		gnt <= 1'b0;
	end else begin
		sel <= en?n_arb:sel;
		gnt <= n_gnt;
	end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		arb <= 0;
		arb1 <= 0;
		arb2 <= 0;
		gnt1 <= 1'b0;
	end else begin
		arb <= en?n_arb:arb;
		arb1 <= en?n_arb:arb1;
		arb2 <= en?n_arb:arb2;
		gnt1 <= n_gnt;
	end

/***************************** FUNCTION ************************************/
function [NUM_OF_INPUT-1:0] lmask;
input[INPUT_NBITS-1:0] cnt;
input gnt;

begin
	for(i=0; i<NUM_OF_INPUT; i=i+1)
		lmask[i] = (cnt>i)?1'b0:(cnt==i)?~gnt:1'b1;
end
endfunction

function [NUM_OF_INPUT-1:0] rmask;
input[INPUT_NBITS-1:0] cnt;

begin
	for(i=0; i<NUM_OF_INPUT; i=i+1)
		rmask[i] = (cnt>i);
end
endfunction

/*
function [NUM_OF_INPUT-1:0] lmask;
input[INPUT_NBITS-1:0] cnt;
input gnt;

reg[NUM_OF_INPUT-1:0] din, din0, din1, din2, din3;

begin
	din = {{(NUM_OF_INPUT-1){1'b0}}, ~gnt};
	din0 = cnt[4]?{din[3:0], 16'hffff}:din;
	din1 = cnt[3]?{din0[11:0], 8'hff}:din0;
	din2 = cnt[2]?{din1[15:0], 4'hf}:din1;
	din3 = cnt[1]?{din2[17:0], 2'b11}:din2;
	lmask = cnt[0]?{din3[18:0], 1'b1}:din3;
end
endfunction

function [NUM_OF_INPUT-1:0] rmask;
input[INPUT_NBITS-1:0] cnt;

reg[NUM_OF_INPUT-1:0] din, din0, din1, din2, din3;

begin
	din = {{(NUM_OF_INPUT-1){1'b1}}, 1'b0};
	din0 = cnt[4]?{din[3:0], 16'b0}:din;
	din1 = cnt[3]?{din0[11:0], 8'b0}:din0;
	din2 = cnt[2]?{din1[15:0], 4'b0}:din1;
	din3 = cnt[1]?{din2[17:0], 2'b0}:din2;
	rmask = cnt[0]?{din3[18:0], 1'b0}:din3;
end
endfunction
*/

function [INPUT_NBITS-1:0] pri;
input[NUM_OF_INPUT-1:0] din;

begin
	case (1'b1)
		din[0]: pri = 0;
		din[1]: pri = 1;
		din[2]: pri = 2;
		din[3]: pri = 3;
		din[4]: pri = 4;
		din[5]: pri = 5;
		din[6]: pri = 6;
		din[7]: pri = 7;
		din[8]: pri = 8;
		din[9]: pri = 9;
		din[10]: pri = 10;
		din[11]: pri = 11;
		din[12]: pri = 12;
		din[13]: pri = 13;
		din[14]: pri = 14;
		din[15]: pri = 15;
		din[16]: pri = 16;
		din[17]: pri = 17;
		din[18]: pri = 18;
		default: pri = 19;
	endcase
end
endfunction

/*
function [INPUT_NBITS-1:0] pri;
input[NUM_OF_INPUT-1:0] din;
reg[NUM_OF_INPUT-1:0] din0;
reg [INPUT_NBITS:0] pe2_0, pe2_1;
begin
	din0 = {din[0], din[NUM_OF_INPUT-1:1]};
	pe2_0 = pri_enc_2(din0[NUM_OF_INPUT-1:NUM_OF_INPUT/2]);
	pe2_1 = pri_enc_2(din0[NUM_OF_INPUT/2-1:0]);
	pri = pe2_1!=0?pe2_1:pe2_0!=0?pe2_0+(NUM_OF_INPUT/2):0;
end
endfunction

function [INPUT_NBITS:0] pri_enc_2;
input[NUM_OF_INPUT/2-1:0] din;
reg [INPUT_NBITS:0] pe2_0, pe2_1;
begin
	pe2_0 = pri_enc_4(din[NUM_OF_INPUT/2-1:NUM_OF_INPUT/4]);
	pe2_1 = pri_enc_4(din[NUM_OF_INPUT/4-1:0]);
	pri_enc_2 = pe2_1!=0?pe2_1:pe2_0!=0?pe2_0+(NUM_OF_INPUT/4):0;
end
endfunction

function [INPUT_NBITS-1:0] pri_enc_4;
input[NUM_OF_INPUT/4-1:0] din;

begin
	case (1'b1)
		din[0]: pri_enc_4 = 1;
		din[1]: pri_enc_4 = 2;
		din[2]: pri_enc_4 = 3;
		din[3]: pri_enc_4 = 4;
		din[4]: pri_enc_4 = 5;
		default: pri_enc_4 = 0;
	endcase
end
endfunction
*/

endmodule

