//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module hash #(
parameter KEY_NBITS = `RCI_KEY_NBITS,
parameter HASH_NBITS = 8
) (

input clk, 

input [KEY_NBITS-1:0] key,

output logic [HASH_NBITS-1:0] hash_value

);

/***************************** LOCAL VARIABLES *******************************/

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	hash_value <= hash_eval(key);
end

/***************************** PROGRAM BODY **********************************/

`HASH(hash_eval, KEY_NBITS, HASH_NBITS)

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

