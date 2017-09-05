//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module ecdsa_ip_core (

input clk,
input `RESET_SIG,

input in_valid,
input [`DATA_PATH_RANGE] in_hdr_data,
input lh_ecdsa_meta_type in_meta_data,
input in_sop,
input in_eop,


    // outputs
  
output logic signature_valid,
output logic signature_verified

);


/***************************** LOCAL VARIABLES *******************************/


/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

	signature_verified <= 1'b1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		signature_valid <= 1'b0;

    end else begin

		signature_valid <= in_valid&in_eop;
    end

/***************************** PROGRAM BODY **********************************/

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

