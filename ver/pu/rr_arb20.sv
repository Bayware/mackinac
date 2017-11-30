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
output logic [INPUT_NBITS-1:0] sel, /* synthesis KEEP */
output logic gnt

);
/***************************** LOCAL VARIABLES *******************************/
integer i;
//
reg [INPUT_NBITS-1:0] arb; /* synthesis KEEP */

reg [INPUT_NBITS:0] n_arb;
reg [NUM_OF_INPUT-1:0] n_ack;

wire [NUM_OF_INPUT-1:0] rot_req = rot(req, arb); 
wire [INPUT_NBITS-1:0] pri_result = pri(rot_req);
always @* begin
	n_arb = {1'b0, arb}+pri_result;
	n_arb = n_arb>=NUM_OF_INPUT?n_arb-NUM_OF_INPUT:n_arb;
	for(i=0; i<NUM_OF_INPUT; i=i+1)
		n_ack[i] = en&req[i]&(n_arb==i);
end

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		ack <= 0;
		sel <= 0;
		gnt <= 1'b0;
	end else begin
		ack <= n_ack;
		sel <= en?n_arb:sel;
		gnt <= en&(|req);
	end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		arb <= 0;
	end else begin
		arb <= en?n_arb:arb;
	end

/***************************** FUNCTION ************************************/
function [NUM_OF_INPUT-1:0] rot;
input[NUM_OF_INPUT-1:0] din;
input[INPUT_NBITS-1:0] rot_cnt;

reg[NUM_OF_INPUT-1:0] din0, din1, din2, din3;

begin
	din0 = rot_cnt[4]?{din[15:0], din[19:16]}:din;
	din1 = rot_cnt[3]?{din0[7:0], din0[19:8]}:din0;
	din2 = rot_cnt[2]?{din1[3:0], din1[19:4]}:din1;
	din3 = rot_cnt[1]?{din2[1:0], din2[19:2]}:din2;
	rot = rot_cnt[0]?{din3[0], din3[19:1]}:din3;
end
endfunction

function [INPUT_NBITS-1:0] pri;
input[NUM_OF_INPUT-1:0] din;

begin
	case (1'b1)
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
		din[19]: pri = 19;
		default: pri = 0;
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

