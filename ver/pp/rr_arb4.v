//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 4-input round robin arbiter
//===========================================================================

`include "defines.vh"

module rr_arb4 (
	  clk,
      `RESET_SIG,

      req,
      en,

	// outputs

	  sel

);

input clk, `RESET_SIG;

input [3:0] req; 
input en; 

output [1:0] sel; 

/***************************** LOCAL VARIABLES *******************************/

//
reg [1:0] arb;		 

wire [1:0] n_arb;

/***************************** NON REGISTERED OUTPUTS ************************/
assign sel = arb;

/***************************** REGISTERED OUTPUTS ****************************/

/***************************** PROGRAM BODY **********************************/

wire [3:0] rot_req = rot(req, arb); 
wire [1:0] pri_result = pri(rot_req);
assign n_arb = arb+pri_result;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		arb <= 0;
	end else begin
		arb <= en?n_arb:arb;
	end

/***************************** FUNCTION ************************************/
function [3:0] rot;
input[3:0] din;
input[1:0] rot_cnt;

reg[3:0] din0;

begin
	din0 = rot_cnt[1]?{din[1:0], din[3:2]}:din;
	rot = rot_cnt[0]?{din0[0], din0[3:1]}:din0;
end
endfunction

function [1:0] pri;
input[3:0] din;

begin
	case (1'b1)
		din[1]: pri = 1;
		din[2]: pri = 2;
		din[3]: pri = 3;
		default: pri = 0;
	endcase
end
endfunction


endmodule

