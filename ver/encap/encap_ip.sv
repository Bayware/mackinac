//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap_ip #(
parameter DATA_NBITS = 128,
parameter KEY_NBITS = 256
) (

input clk, 
input `RESET_SIG,

input [DATA_NBITS-1:0] plaintext_data,
input [KEY_NBITS-1:0] key,
input encrypt_request,

output logic [DATA_NBITS-1:0] cybertext_data,
output logic encrypt_complete

);

/***************************** LOCAL VARIABLES *******************************/

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		cybertext_data <= plaintext_data;
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		encrypt_complete <= 1'b0;

	end else begin
		encrypt_complete <= encrypt_request;

	end

/***************************** PROGRAM BODY **********************************/

 

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

