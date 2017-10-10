//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module ecdsa_mem #(
parameter DEPTH_NBITS = `TID_NBITS,
parameter ITEM_NBITS = `TOPIC_POLICY_ROLE_NBITS,
parameter VALUE_NBITS = `TOPIC_POLICY_NBITS
) (


input clk, `RESET_SIG,

input clk_div,

input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,
input reg_rd,
input reg_wr,
input reg_ms_topic_policy,

output reg topic_policy_mem_ack,
output reg [`PIO_RANGE] topic_policy_mem_rdata,

input topic_policy_rd, 
input [DEPTH_NBITS-1:0] topic_policy_raddr,

output topic_policy_ack, 
output [VALUE_NBITS-1:0] topic_policy_rdata

);

/***************************** LOCAL VARIABLES *******************************/

wire topic_policy0_mem_ack;
wire [`PIO_RANGE] topic_policy0_mem_rdata;

wire topic_policy1_mem_ack;
wire [`PIO_RANGE] topic_policy1_mem_rdata;

wire topic_policy2_mem_ack;
wire [`PIO_RANGE] topic_policy2_mem_rdata;

wire topic_policy3_mem_ack;
wire [`PIO_RANGE] topic_policy3_mem_rdata;

wire [`PIO_ADDR_MSB-2:0] reg_addr_dw = reg_addr[`PIO_ADDR_MSB:2];

wire reg_ms_topic_policy0 = reg_ms_topic_policy&reg_addr_dw[1:0]==0;
wire reg_ms_topic_policy1 = reg_ms_topic_policy&reg_addr_dw[1:0]==1;
wire reg_ms_topic_policy2 = reg_ms_topic_policy&reg_addr_dw[1:0]==2;
wire reg_ms_topic_policy3 = reg_ms_topic_policy&reg_addr_dw[1:0]==3;

wire [`PIO_RANGE] topic_policy_reg_addr = {reg_addr[`PIO_ADDR_MSB:0+4], reg_addr[1:0]};

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	case (reg_addr_dw[1:0])
		3'h0: begin
			topic_policy_mem_ack = topic_policy0_mem_ack;
			topic_policy_mem_rdata = topic_policy0_mem_rdata;
		end
		3'h1: begin
			topic_policy_mem_ack = topic_policy1_mem_ack;
			topic_policy_mem_rdata = topic_policy1_mem_rdata;
		end
		3'h2: begin
			topic_policy_mem_ack = topic_policy2_mem_ack;
			topic_policy_mem_rdata = topic_policy2_mem_rdata;
		end
		default: begin
			topic_policy_mem_ack = topic_policy3_mem_ack;
			topic_policy_mem_rdata = topic_policy3_mem_rdata;
		end
	endcase
end
	
/***************************** REGISTERED OUTPUTS ****************************/


/***************************** PROGRAM BODY **********************************/


pio_mem_bram #(ITEM_NBITS, DEPTH_NBITS) u_pio_mem_bram0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(topic_policy_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_policy0),

		.app_mem_rd(topic_policy_rd),
		.app_mem_raddr(topic_policy_raddr),

        	.mem_ack(topic_policy0_mem_ack),
        	.mem_rdata(topic_policy0_mem_rdata),

		.app_mem_ack(topic_policy_ack),
		.app_mem_rdata(topic_policy_rdata[ITEM_NBITS*1-1:ITEM_NBITS*0])
);

pio_mem_bram #(ITEM_NBITS, DEPTH_NBITS) u_pio_mem_bram1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(topic_policy_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_policy1),

		.app_mem_rd(topic_policy_rd),
		.app_mem_raddr(topic_policy_raddr),

        	.mem_ack(topic_policy1_mem_ack),
        	.mem_rdata(topic_policy1_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(topic_policy_rdata[ITEM_NBITS*2-1:ITEM_NBITS*1])
);

pio_mem_bram #(ITEM_NBITS, DEPTH_NBITS) u_pio_mem_bram2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(topic_policy_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_policy2),

		.app_mem_rd(topic_policy_rd),
		.app_mem_raddr(topic_policy_raddr),

        	.mem_ack(topic_policy2_mem_ack),
        	.mem_rdata(topic_policy2_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(topic_policy_rdata[ITEM_NBITS*3-1:ITEM_NBITS*2])
);

pio_mem_bram #(ITEM_NBITS, DEPTH_NBITS) u_pio_mem_bram3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.clk_div(clk_div),

	        .reg_addr(topic_policy_reg_addr),
       	 	.reg_din(reg_din),
        	.reg_rd(reg_rd),
        	.reg_wr(reg_wr),
        	.reg_ms(reg_ms_topic_policy3),

		.app_mem_rd(topic_policy_rd),
		.app_mem_raddr(topic_policy_raddr),

        	.mem_ack(topic_policy3_mem_ack),
        	.mem_rdata(topic_policy3_mem_rdata),

		.app_mem_ack(),
		.app_mem_rdata(topic_policy_rdata[ITEM_NBITS*4-1:ITEM_NBITS*3])
);


/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off


// synopsys translate_on

endmodule

