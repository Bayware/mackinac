//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module gb_64to32 #(
parameter DMA_BUS_NBITS = 64,
parameter PBUS_NBITS = 32
) (

input clk_mac, 
input clk_axi, 
input `RESET_SIG,

input m_axis_h2c_tvalid_x,
input m_axis_h2c_tlast_x,
input [DMA_BUS_NBITS-1:0] m_axis_h2c_tdata_x,

output m_axis_h2c_tready_x,

output logic [PBUS_NBITS-1:0] rx_axis_tdata,
output logic [3:0] rx_axis_tkeep,
output logic rx_axis_tvalid,
output logic rx_axis_tuser,
output logic rx_axis_tlast

);

/***************************** LOCAL VARIABLES *******************************/

logic `RESET_SIG_MAC;
logic `RESET_SIG_AXI;

logic in_fifo_empty;
logic in_fifo_full;
logic in_fifo_eop;
logic [DMA_BUS_NBITS-1:0] in_fifo_data;

logic even;

logic in_fifo_wr = m_axis_h2c_tvalid_x&m_axis_h2c_tready_x;

logic rx_axis_tvalid_p1 = ~in_fifo_empty;

logic in_fifo_rd = rx_axis_tvalid_p1&~even;

/***************************** NON REGISTERED OUTPUTS ************************/

assign m_axis_h2c_tready_x = ~in_fifo_full;

/***************************** REGISTERED OUTPUTS ****************************/


always @(posedge clk_mac) begin

		rx_axis_tdata <= even?in_fifo_data[63:32]:in_fifo_data[31:0];
		rx_axis_tkeep <= 4'hf;
		rx_axis_tuser <= 1'b1;
		rx_axis_tlast <= in_fifo_eop&~even;
end


always @(`CLK_RST_MAC) 
    if (`ACTIVE_RESET) begin
		rx_axis_tvalid <= 1'b1;
	end else begin
		rx_axis_tvalid <= rx_axis_tvalid_p1;
	end

/***************************** PROGRAM BODY **********************************/

synchronizer u_synchronizer_0(.clk(clk_mac), .din(`RESET_SIG), .dout(`RESET_SIG_MAC));
synchronizer u_synchronizer_1(.clk(clk_axi), .din(`RESET_SIG), .dout(`RESET_SIG_AXI));

always @(`CLK_RST_MAC) 
    if (`ACTIVE_RESET_MAC) begin
		even <= 1'b1;

	end else begin
		even <= rx_axis_tvalid_p1^even;

	end

afifo8f #(DMA_BUS_NBITS+1) u_afifo8f(
        .clk_r(clk_mac),
        .reset_r(`ACTIVE_RESET_MAC),

        .clk_w(clk_axi),
        .reset_w(`ACTIVE_RESET_AXI),

	.din({m_axis_h2c_tdata_x, m_axis_h2c_tlast_x}),      
        .rd(in_fifo_rd),
        .wr(in_fifo_wr),

        .count_r(),
        .count_w(),
        .full(in_fifo_full),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({in_fifo_data, in_fifo_eop})       
    );

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

