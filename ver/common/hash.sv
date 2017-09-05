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

always @(posedge clk) 
	hash_value <= hash_function(key);

/***************************** PROGRAM BODY **********************************/

function [HASH_NBITS-1:0] hash_function;
input[KEY_NBITS-1:0] din;

integer i, j;
begin
	hash_function = 0;

	for (i=0; i<HASH_NBITS; i++)
		for (j=0; j<KEY_NBITS/HASH_NBITS+1; j++)
			hash_function[i] = hash_function[i]^din[j*HASH_NBITS+i];
end
endfunction

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

