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

/***************************** NON REGISTERED OUTPUTS ************************/

assign out = transpose_func(in);

/***************************** REGISTERED OUTPUTS ****************************/

/***************************** PROGRAM BODY **********************************/

`TRANSPOSE(transpose_func, KEY_NBITS)

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

