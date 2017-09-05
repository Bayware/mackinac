//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : tdm scheduler to select the port 
//===========================================================================

`include "defines.vh"

`define NO_CIR

module tm_port_scheduler (
	clk,
    reset,
    en,


	// outputs

	sel_port,
	sel_port_id

);

input clk, reset, en;

output [`NUM_OF_ACTUAL_PORTS-1:0] sel_port;
output [`ACTUAL_PORT_BITS-1:0] sel_port_id;


/***************************** LOCAL VARIABLES *******************************/
reg [2:0] port_10g_arb;
reg [2:0] tdm_arb_msb;
reg [4:0] tdm_arb_lsb;


reg [`NUM_OF_ACTUAL_PORTS-1:0] sel_port;
reg [`ACTUAL_PORT_BITS-1:0] sel_port_id;

`ifdef NO_CIR
wire [4:0] last_tdm_arb_lsb_count = 16;
wire [2:0] last_port_10g_arb_count = 3;
`else
wire [4:0] last_tdm_arb_lsb_count = 20;
wire [2:0] last_port_10g_arb_count = 4;
`endif
wire last_lsb = (tdm_arb_lsb==last_tdm_arb_lsb_count);

wire [2:0] last_tdm_arb_msb_count = 4;
wire last_msb = (tdm_arb_msb==last_tdm_arb_msb_count);

wire last_port_10g_arb = (port_10g_arb==last_port_10g_arb_count);

wire [`NUM_OF_ACTUAL_PORTS-1:0] sel_port_p1;

assign sel_port_p1[0] = (port_10g_arb==0)&~last_lsb;
assign sel_port_p1[1] = (port_10g_arb==1)&~last_lsb;
assign sel_port_p1[2] = (port_10g_arb==2)&~last_lsb;
assign sel_port_p1[3] = (port_10g_arb==3)&~last_lsb;
assign sel_port_p1[4] = (port_10g_arb==4)&~last_lsb;

assign sel_port_p1[5] = (tdm_arb_msb==0|tdm_arb_msb==3)&last_lsb;
assign sel_port_p1[6] = (tdm_arb_msb==1|tdm_arb_msb==4)&last_lsb;
assign sel_port_p1[7] = (tdm_arb_msb==2)&last_lsb;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) 
    if (reset) begin
		sel_port <= 0;
		sel_port_id <= 0;
	end else begin
		sel_port <= sel_port_p1;
		sel_port_id <= last_lsb?(tdm_arb_msb<3?tdm_arb_msb+5:tdm_arb_msb-3+5):port_10g_arb;
	end

/***************************** PROGRAM BODY **********************************/

	always @(`CLK_RST) 
		if (reset) begin
		port_10g_arb <= 0;
		tdm_arb_msb <= 0;
		tdm_arb_lsb <= 0;
	end else begin
		port_10g_arb <= en&~last_lsb?(last_port_10g_arb?0:port_10g_arb+1):port_10g_arb;
		tdm_arb_msb <= en&last_lsb?(last_msb?0:tdm_arb_msb+1):tdm_arb_msb;
		tdm_arb_lsb <= en?(last_lsb?0:tdm_arb_lsb+1):tdm_arb_lsb;
	end

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

