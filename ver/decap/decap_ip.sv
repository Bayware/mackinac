//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module decap_ip #(
parameter DATA_NBITS = 128,
parameter KEY_NBITS = 128
) (

input clk, 
input `RESET_SIG,

input [DATA_NBITS-1:0] cybertext_data,
input [KEY_NBITS-1:0] key,
input decrypt_request,

output logic [DATA_NBITS-1:0] plaintext_data,
output logic decrypt_complete

);

/***************************** LOCAL VARIABLES *******************************/

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		plaintext_data <= cybertext_data;
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		decrypt_complete <= 1'b0;

	end else begin
		decrypt_complete <= decrypt_request;

	end

/***************************** PROGRAM BODY **********************************/

 

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

