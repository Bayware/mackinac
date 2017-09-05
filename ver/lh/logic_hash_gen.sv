//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::irl_lh_meta_type;

module logic_hash_gen (

input clk,
input `RESET_SIG,

input irl_lh_valid,
input [`DATA_PATH_RANGE] irl_lh_hdr_data,
input irl_lh_meta_type   irl_lh_meta_data,
input irl_lh_sop,
input irl_lh_eop,


    // outputs
  
output logic lh_valid,
output logic [`LOGIC_HASH_NBITS-1:0] lh_data

);


/***************************** LOCAL VARIABLES *******************************/


/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

	lh_data <= {(`LOGIC_HASH_NBITS){1'b0}};
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin

		lh_valid <= 1'b0;

    end else begin

		lh_valid <= irl_lh_valid&irl_lh_eop;
    end

/***************************** PROGRAM BODY **********************************/

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

