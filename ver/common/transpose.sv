//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module transpose #(
parameter KEY_NBITS = `RCI_KEY_NBITS
) (

input [KEY_NBITS-1:0] in,

output logic [KEY_NBITS-1:0] out

);

/***************************** LOCAL VARIABLES *******************************/

integer i;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(*)
	for (i=0; i<KEY_NBITS+1; i++)
		out[i] = in[KEY_NBITS-1-i];

/***************************** PROGRAM BODY **********************************/

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

