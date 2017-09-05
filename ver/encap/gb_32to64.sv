//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module gb_32to64 #(
parameter DMA_BUS_NBITS = 64,
parameter PBUS_NBITS = 32
) (

input clk_mac, 
input clk_axi, 
input `RESET_SIG,

input [PBUS_NBITS-1:0] tx_axis_tdata,
input [3:0] tx_axis_tkeep,
input tx_axis_tvalid,
input tx_axis_tuser,
input tx_axis_tlast,

output tx_axis_tready,

input s_axis_c2h_tready_x,

output logic s_axis_c2h_tvalid_x,
output logic s_axis_c2h_tlast_x,
output logic [DMA_BUS_NBITS-1:0] s_axis_c2h_tdata_x

);

/***************************** LOCAL VARIABLES *******************************/
logic [PBUS_NBITS-1:0] tx_axis_tdata_sv;

logic out_fifo_empty;
logic out_fifo_full;

logic even;

/***************************** NON REGISTERED OUTPUTS ************************/

assign tx_axis_tready = even|~out_fifo_full;

assign s_axis_c2h_tvalid_x = ~out_fifo_empty;

/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/

logic `RESET_SIG_MAC;
logic `RESET_SIG_AXI;

synchronizer u_synchronizer_0(.clk(clk_mac), .din(`RESET_SIG), .dout(`RESET_SIG_MAC));
synchronizer u_synchronizer_1(.clk(clk_axi), .din(`RESET_SIG), .dout(`RESET_SIG_AXI));

logic out_fifo_rd = s_axis_c2h_tvalid_x&s_axis_c2h_tready_x;

logic wr_en = tx_axis_tvalid&tx_axis_tready;
logic out_fifo_wr = wr_en&(~even|tx_axis_tlast);

always @(posedge clk_mac) 
	tx_axis_tdata_sv <= wr_en&even?tx_axis_tdata:tx_axis_tdata_sv;

always @(`CLK_RST_MAC) 
    if (`ACTIVE_RESET_MAC) begin
		even <= 1'b1;
	end else begin
		even <= ~wr_en?even:tx_axis_tlast?1'b1:~even;
	end

afifo8f #(DMA_BUS_NBITS+1) u_afifo8f(
        .clk_r(clk_axi),
        .reset_r(`ACTIVE_RESET_AXI),

        .clk_w(clk_mac),
        .reset_w(`ACTIVE_RESET_MAC),

        .din({{(even?tx_axis_tdata:tx_axis_tdata_sv), tx_axis_tdata}, tx_axis_tlast}),
        .rd(out_fifo_rd),
        .wr(out_fifo_wr),

        .count_r(),
        .count_w(),
        .full(out_fifo_full),
        .empty(out_fifo_empty),
        .fullm1(),
        .emptyp2(),
	.dout({s_axis_c2h_tdata_x, s_axis_c2h_tlast_x})      
    );

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

