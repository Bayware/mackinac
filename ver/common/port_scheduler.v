//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : port 0, 1: 10G; port 2, 3: DMA 0, 1; port 4, 5: DMA 2, 3;
// port 6: OAM   
//===========================================================================

`include "defines.vh"

module port_scheduler (


input clk, 
input `RESET_SIG, 
input en,

output [1:0] rot_cnt,
output reg [`NUM_OF_PORTS-1:0] sel_port,
output reg [`PORT_ID_RANGE] sel_port_id

);

/***************************** LOCAL VARIABLES *******************************/
reg [3:0] dma_cnt;
reg [1:0] cnt_lsb;

reg [`PORT_ID_RANGE] sel_port_id_p1;

wire [1:0] last_cnt_lsb = 3;
wire last_lsb = (cnt_lsb==last_cnt_lsb);

wire [1:0] dma_cnt_lsb = 1;
wire dma = (cnt_lsb==dma_cnt_lsb);

wire [3:0] last_dma_cnt = 9;
wire last_dma = dma_cnt==last_dma_cnt;

wire [`NUM_OF_PORTS-1:0] sel_port_p1;

assign sel_port_p1[0] = (cnt_lsb==0);
assign sel_port_p1[1] = (cnt_lsb==1);
assign sel_port_p1[2] = (cnt_lsb==2)&~dma_cnt[0];
assign sel_port_p1[3] = (cnt_lsb==2)&dma_cnt[0];
assign sel_port_p1[4] = (cnt_lsb==3)&~dma_cnt[0];
assign sel_port_p1[5] = (cnt_lsb==3)&dma_cnt[0]&~dma_cnt[3];
assign sel_port_p1[6] = (cnt_lsb==3)&dma_cnt[0]&dma_cnt[3];

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

assign rot_cnt = cnt_lsb;

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		sel_port <= 0;
		sel_port_id <= 0;
	end else begin
		sel_port <= sel_port_p1;
		sel_port_id <= sel_port_id_p1;
	end

/***************************** PROGRAM BODY **********************************/

always @(*)
	case(cnt_lsb)
		2'b00: sel_port_id_p1 = 3'h0;
		2'b01: sel_port_id_p1 = 3'h1;
		2'b10: sel_port_id_p1 = dma_cnt[0]?3'h3:3'h2;
		default: sel_port_id_p1 = ~dma_cnt[0]?3'h4:dma_cnt[3]?3'h6:3'h5;
	endcase

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		cnt_lsb <= 0;
		dma_cnt <= 0;
	end else begin
		cnt_lsb <= en?(last_lsb?0:cnt_lsb+1):cnt_lsb;
		dma_cnt <= en&dma?(last_dma?0:dma_cnt+1):dma_cnt;
	end

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

