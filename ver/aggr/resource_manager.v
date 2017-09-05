//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module resource_manager(


input clk,
input `RESET_SIG,

input [3:0] alpha,

input [`NUM_OF_PORTS-1:0] port_get_resource,
input [`NUM_OF_PORTS-1:0] port_return_resource,

output reg [`NUM_OF_PORTS-1:0] port_resource_available

);

/***************************** LOCAL VARIABLES *******************************/

reg [`NUM_OF_PORTS-1:0] port_get_resource_d1;
reg [`NUM_OF_PORTS-1:0] port_return_resource_d1;

reg get_shared;
reg return_shared;

reg [`BUF_PTR_RANGE] resource_use_ctr;
reg [`BUF_PTR_RANGE] port_threshold;

reg [`BUF_PTR_RANGE] port_resource_use_ctr0;
reg [`BUF_PTR_RANGE] port_resource_use_ctr1;
reg [`BUF_PTR_RANGE] port_resource_use_ctr2;
reg [`BUF_PTR_RANGE] port_resource_use_ctr3;
reg [`BUF_PTR_RANGE] port_resource_use_ctr4;
reg [`BUF_PTR_RANGE] port_resource_use_ctr5;
reg [`BUF_PTR_RANGE] port_resource_use_ctr6;

wire [`NUM_OF_PORTS-1:0] port_over_threshold;

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	port_resource_available <= ~port_over_threshold;
end
	
/***************************** PROGRAM BODY **********************************/

assign port_over_threshold[0] = port_resource_use_ctr0>port_threshold;
assign port_over_threshold[1] = port_resource_use_ctr1>port_threshold;
assign port_over_threshold[2] = port_resource_use_ctr2>port_threshold;
assign port_over_threshold[3] = port_resource_use_ctr3>port_threshold;
assign port_over_threshold[4] = port_resource_use_ctr4>port_threshold;
assign port_over_threshold[5] = port_resource_use_ctr5>port_threshold;
assign port_over_threshold[6] = port_resource_use_ctr6>port_threshold;


wire shift_left = ~alpha[3];
wire [2:0] shift_cnt = alpha[2:0];

wire [`BUF_PTR_RANGE] total_minus_used = (~resource_use_ctr+1);

always @(posedge clk) begin
		port_threshold <= shift_left?total_minus_used<<shift_cnt:total_minus_used>>shift_cnt;

		get_shared <= |port_get_resource;
		return_shared <= |port_return_resource;

		port_get_resource_d1 <= port_get_resource;
		port_return_resource_d1 <= port_return_resource;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		resource_use_ctr <= 0;
		port_resource_use_ctr0 <= 0;
		port_resource_use_ctr1 <= 0;
		port_resource_use_ctr2 <= 0;
		port_resource_use_ctr3 <= 0;
		port_resource_use_ctr4 <= 0;
		port_resource_use_ctr5 <= 0;
		port_resource_use_ctr6 <= 0;
    end else begin
		resource_use_ctr <= ~get_shared^return_shared?resource_use_ctr:get_shared?resource_use_ctr+1:resource_use_ctr-1;
		port_resource_use_ctr0 <= ~port_get_resource_d1[0]^port_return_resource_d1[0]?port_resource_use_ctr0:
										port_get_resource_d1[0]?port_resource_use_ctr0+1:port_resource_use_ctr0-1;
		port_resource_use_ctr1 <= ~port_get_resource_d1[1]^port_return_resource_d1[1]?port_resource_use_ctr1:
										port_get_resource_d1[1]?port_resource_use_ctr1+1:port_resource_use_ctr1-1;
		port_resource_use_ctr2 <= ~port_get_resource_d1[2]^port_return_resource_d1[2]?port_resource_use_ctr2:
										port_get_resource_d1[2]?port_resource_use_ctr2+1:port_resource_use_ctr2-1;
		port_resource_use_ctr3 <= ~port_get_resource_d1[3]^port_return_resource_d1[3]?port_resource_use_ctr3:
										port_get_resource_d1[3]?port_resource_use_ctr3+1:port_resource_use_ctr3-1;
		port_resource_use_ctr4 <= ~port_get_resource_d1[4]^port_return_resource_d1[4]?port_resource_use_ctr4:
										port_get_resource_d1[4]?port_resource_use_ctr4+1:port_resource_use_ctr4-1;
		port_resource_use_ctr5 <= ~port_get_resource_d1[5]^port_return_resource_d1[5]?port_resource_use_ctr5:
										port_get_resource_d1[5]?port_resource_use_ctr5+1:port_resource_use_ctr5-1;
		port_resource_use_ctr6 <= ~port_get_resource_d1[6]^port_return_resource_d1[6]?port_resource_use_ctr6:
										port_get_resource_d1[6]?port_resource_use_ctr6+1:port_resource_use_ctr6-1;
    end

 
endmodule
