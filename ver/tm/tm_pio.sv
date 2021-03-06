//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module tm_pio(


input clk, 
input `RESET_SIG, 

input clk_div,

input         reg_bs,
input         reg_wr,
input         reg_rd,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,

input queue_association_mem_ack,
input [3:0] queue_profile_mem_ack,
input [3:0] wdrr_quantum_mem_ack,
input [3:0] shaping_profile_cir_mem_ack,
input [3:0] shaping_profile_eir_mem_ack,
input [3:0] wdrr_sch_ctrl_mem_ack,
input [3:0] fill_tb_dst_mem_ack,
input [7:0] pri_sch_ctrl_mem_ack0,
input [7:0] pri_sch_ctrl_mem_ack1,
input [7:0] pri_sch_ctrl_mem_ack2,
input [7:0] pri_sch_ctrl_mem_ack3,

input [`PIO_RANGE] queue_association_mem_rdata,
input [`PIO_RANGE] queue_profile_mem_rdata0,
input [`PIO_RANGE] queue_profile_mem_rdata1,
input [`PIO_RANGE] queue_profile_mem_rdata2,
input [`PIO_RANGE] queue_profile_mem_rdata3,
input [`PIO_RANGE] wdrr_quantum_mem_rdata0,
input [`PIO_RANGE] wdrr_quantum_mem_rdata1,
input [`PIO_RANGE] wdrr_quantum_mem_rdata2,
input [`PIO_RANGE] wdrr_quantum_mem_rdata3,
input [`PIO_RANGE] shaping_profile_cir_mem_rdata0,
input [`PIO_RANGE] shaping_profile_cir_mem_rdata1,
input [`PIO_RANGE] shaping_profile_cir_mem_rdata2,
input [`PIO_RANGE] shaping_profile_cir_mem_rdata3,
input [`PIO_RANGE] shaping_profile_eir_mem_rdata0,
input [`PIO_RANGE] shaping_profile_eir_mem_rdata1,
input [`PIO_RANGE] shaping_profile_eir_mem_rdata2,
input [`PIO_RANGE] shaping_profile_eir_mem_rdata3,
input [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata0,
input [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata1,
input [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata2,
input [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata3,
input [`PIO_RANGE] fill_tb_dst_mem_rdata0,
input [`PIO_RANGE] fill_tb_dst_mem_rdata1,
input [`PIO_RANGE] fill_tb_dst_mem_rdata2,
input [`PIO_RANGE] fill_tb_dst_mem_rdata3,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata00,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata01,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata02,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata03,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata04,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata05,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata06,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata07,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata10,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata11,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata12,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata13,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata14,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata15,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata16,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata17,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata20,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata21,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata22,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata23,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata24,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata25,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata26,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata27,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata30,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata31,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata32,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata33,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata34,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata35,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata36,
input [`PIO_RANGE] pri_sch_ctrl_mem_rdata37,

output reg reg_ms_queue_association,
output reg [3:0] reg_ms_queue_profile,
output reg [3:0] reg_ms_wdrr_quantum,
output reg [3:0] reg_ms_shaping_profile_cir,
output reg [3:0] reg_ms_shaping_profile_eir,
output reg [3:0] reg_ms_wdrr_sch_ctrl,
output reg [3:0] reg_ms_fill_tb_dst,
output [7:0] reg_ms_pri_sch_ctrl0,
output [7:0] reg_ms_pri_sch_ctrl1,
output [7:0] reg_ms_pri_sch_ctrl2,
output [7:0] reg_ms_pri_sch_ctrl3,


output reg    pio_ack,
output reg    pio_rvalid,
output reg [`PIO_RANGE] pio_rdata

);

/***************************** LOCAL VARIABLES *******************************/
logic [7:0] pri_sch_ctrl_mem_ack[3:0];
assign pri_sch_ctrl_mem_ack[0] = pri_sch_ctrl_mem_ack0;
assign pri_sch_ctrl_mem_ack[1] = pri_sch_ctrl_mem_ack1;
assign pri_sch_ctrl_mem_ack[2] = pri_sch_ctrl_mem_ack2;
assign pri_sch_ctrl_mem_ack[3] = pri_sch_ctrl_mem_ack3;

logic [`PIO_RANGE] queue_profile_mem_rdata[3:0];
assign queue_profile_mem_rdata[0] = queue_profile_mem_rdata0;
assign queue_profile_mem_rdata[1] = queue_profile_mem_rdata1;
assign queue_profile_mem_rdata[2] = queue_profile_mem_rdata2;
assign queue_profile_mem_rdata[3] = queue_profile_mem_rdata3;

logic [`PIO_RANGE] wdrr_quantum_mem_rdata[3:0];
assign wdrr_quantum_mem_rdata[0] = wdrr_quantum_mem_rdata0;
assign wdrr_quantum_mem_rdata[1] = wdrr_quantum_mem_rdata1;
assign wdrr_quantum_mem_rdata[2] = wdrr_quantum_mem_rdata2;
assign wdrr_quantum_mem_rdata[3] = wdrr_quantum_mem_rdata3;

logic [`PIO_RANGE] shaping_profile_cir_mem_rdata[3:0];
assign shaping_profile_cir_mem_rdata[0] = shaping_profile_cir_mem_rdata0;
assign shaping_profile_cir_mem_rdata[1] = shaping_profile_cir_mem_rdata1;
assign shaping_profile_cir_mem_rdata[2] = shaping_profile_cir_mem_rdata2;
assign shaping_profile_cir_mem_rdata[3] = shaping_profile_cir_mem_rdata3;

logic [`PIO_RANGE] shaping_profile_eir_mem_rdata[3:0];
assign shaping_profile_eir_mem_rdata[0] = shaping_profile_eir_mem_rdata0;
assign shaping_profile_eir_mem_rdata[1] = shaping_profile_eir_mem_rdata1;
assign shaping_profile_eir_mem_rdata[2] = shaping_profile_eir_mem_rdata2;
assign shaping_profile_eir_mem_rdata[3] = shaping_profile_eir_mem_rdata3;

logic [`PIO_RANGE] wdrr_sch_ctrl_mem_rdata[3:0];
assign wdrr_sch_ctrl_mem_rdata[0] = wdrr_sch_ctrl_mem_rdata0;
assign wdrr_sch_ctrl_mem_rdata[1] = wdrr_sch_ctrl_mem_rdata1;
assign wdrr_sch_ctrl_mem_rdata[2] = wdrr_sch_ctrl_mem_rdata2;
assign wdrr_sch_ctrl_mem_rdata[3] = wdrr_sch_ctrl_mem_rdata3;

logic [`PIO_RANGE] fill_tb_dst_mem_rdata[3:0];
assign fill_tb_dst_mem_rdata[0] = fill_tb_dst_mem_rdata0;
assign fill_tb_dst_mem_rdata[1] = fill_tb_dst_mem_rdata1;
assign fill_tb_dst_mem_rdata[2] = fill_tb_dst_mem_rdata2;
assign fill_tb_dst_mem_rdata[3] = fill_tb_dst_mem_rdata3;

logic [`PIO_RANGE] pri_sch_ctrl_mem_rdata[3:0][7:0];
assign pri_sch_ctrl_mem_rdata[0][0] = pri_sch_ctrl_mem_rdata00;
assign pri_sch_ctrl_mem_rdata[1][0] = pri_sch_ctrl_mem_rdata10;
assign pri_sch_ctrl_mem_rdata[2][0] = pri_sch_ctrl_mem_rdata20;
assign pri_sch_ctrl_mem_rdata[3][0] = pri_sch_ctrl_mem_rdata30;
assign pri_sch_ctrl_mem_rdata[0][1] = pri_sch_ctrl_mem_rdata01;
assign pri_sch_ctrl_mem_rdata[1][1] = pri_sch_ctrl_mem_rdata11;
assign pri_sch_ctrl_mem_rdata[2][1] = pri_sch_ctrl_mem_rdata21;
assign pri_sch_ctrl_mem_rdata[3][1] = pri_sch_ctrl_mem_rdata31;
assign pri_sch_ctrl_mem_rdata[0][2] = pri_sch_ctrl_mem_rdata02;
assign pri_sch_ctrl_mem_rdata[1][2] = pri_sch_ctrl_mem_rdata12;
assign pri_sch_ctrl_mem_rdata[2][2] = pri_sch_ctrl_mem_rdata22;
assign pri_sch_ctrl_mem_rdata[3][2] = pri_sch_ctrl_mem_rdata32;
assign pri_sch_ctrl_mem_rdata[0][3] = pri_sch_ctrl_mem_rdata03;
assign pri_sch_ctrl_mem_rdata[1][3] = pri_sch_ctrl_mem_rdata13;
assign pri_sch_ctrl_mem_rdata[2][3] = pri_sch_ctrl_mem_rdata23;
assign pri_sch_ctrl_mem_rdata[3][3] = pri_sch_ctrl_mem_rdata33;
assign pri_sch_ctrl_mem_rdata[0][4] = pri_sch_ctrl_mem_rdata04;
assign pri_sch_ctrl_mem_rdata[1][4] = pri_sch_ctrl_mem_rdata14;
assign pri_sch_ctrl_mem_rdata[2][4] = pri_sch_ctrl_mem_rdata24;
assign pri_sch_ctrl_mem_rdata[3][4] = pri_sch_ctrl_mem_rdata34;
assign pri_sch_ctrl_mem_rdata[0][5] = pri_sch_ctrl_mem_rdata05;
assign pri_sch_ctrl_mem_rdata[1][5] = pri_sch_ctrl_mem_rdata15;
assign pri_sch_ctrl_mem_rdata[2][5] = pri_sch_ctrl_mem_rdata25;
assign pri_sch_ctrl_mem_rdata[3][5] = pri_sch_ctrl_mem_rdata35;
assign pri_sch_ctrl_mem_rdata[0][6] = pri_sch_ctrl_mem_rdata06;
assign pri_sch_ctrl_mem_rdata[1][6] = pri_sch_ctrl_mem_rdata16;
assign pri_sch_ctrl_mem_rdata[2][6] = pri_sch_ctrl_mem_rdata26;
assign pri_sch_ctrl_mem_rdata[3][6] = pri_sch_ctrl_mem_rdata36;
assign pri_sch_ctrl_mem_rdata[0][7] = pri_sch_ctrl_mem_rdata07;
assign pri_sch_ctrl_mem_rdata[1][7] = pri_sch_ctrl_mem_rdata17;
assign pri_sch_ctrl_mem_rdata[2][7] = pri_sch_ctrl_mem_rdata27;
assign pri_sch_ctrl_mem_rdata[3][7] = pri_sch_ctrl_mem_rdata37;

logic [7:0] reg_ms_pri_sch_ctrl[3:0];
assign reg_ms_pri_sch_ctrl0 = reg_ms_pri_sch_ctrl[0];
assign reg_ms_pri_sch_ctrl1 = reg_ms_pri_sch_ctrl[1];
assign reg_ms_pri_sch_ctrl2 = reg_ms_pri_sch_ctrl[2];
assign reg_ms_pri_sch_ctrl3 = reg_ms_pri_sch_ctrl[3];

reg reg_rd_d1;

reg n_pio_ack, n_pio_rvalid;

reg n_none_selected_ack;
reg none_selected_ack;

wire rd_en = reg_rd|reg_rd_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_ack = 1'b0;
	n_pio_rvalid = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};
	reg_ms_queue_association = 1'b0;
	reg_ms_queue_profile = 4'b0;
	reg_ms_wdrr_quantum = 4'b0;
	reg_ms_shaping_profile_cir = 4'b0;
	reg_ms_shaping_profile_eir = 4'b0;
	reg_ms_wdrr_sch_ctrl = 4'b0;
	reg_ms_fill_tb_dst = 4'b0;
	reg_ms_pri_sch_ctrl[0] = 8'b0;
	reg_ms_pri_sch_ctrl[1] = 8'b0;
	reg_ms_pri_sch_ctrl[2] = 8'b0;
	reg_ms_pri_sch_ctrl[3] = 8'b0;

	case(reg_addr[`TM_MEM_ADDR_RANGE])
            `TM_QUEUE_ASSOCIATION: begin
		n_pio_ack = queue_association_mem_ack;
		n_pio_rvalid = reg_bs;
		pio_rdata = queue_association_mem_rdata;
		reg_ms_queue_association = reg_bs;
	    end
            `TM_QUEUE_PROFILE0: begin
		n_pio_ack = queue_profile_mem_ack[0];
		n_pio_rvalid = reg_bs;
		pio_rdata = queue_profile_mem_rdata[0];
		reg_ms_queue_profile[0] = reg_bs;
	    end
            `TM_WDRR_QUANTUM0: begin
		n_pio_ack = wdrr_quantum_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_quantum_mem_rdata[1];
		reg_ms_wdrr_quantum[1] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_CIR0: begin
		n_pio_ack = shaping_profile_cir_mem_ack[0];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_cir_mem_rdata[0];
		reg_ms_shaping_profile_cir[0] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_EIR0: begin
		n_pio_ack = shaping_profile_eir_mem_ack[0];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_eir_mem_rdata[0];
		reg_ms_shaping_profile_eir[0] = reg_bs;
	    end
            `TM_WDRR_SCH_CTRL0: begin
		n_pio_ack = wdrr_sch_ctrl_mem_ack[0];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_sch_ctrl_mem_rdata[0];
		reg_ms_wdrr_sch_ctrl[0] = reg_bs;
	    end
            `TM_FILL_TB_DST0: begin
		n_pio_ack = fill_tb_dst_mem_ack[0];
		n_pio_rvalid = reg_bs;
		pio_rdata = fill_tb_dst_mem_rdata[0];
		reg_ms_fill_tb_dst[0] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL00: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][0];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][0];
		reg_ms_pri_sch_ctrl[0][0] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL01: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][1];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][1];
		reg_ms_pri_sch_ctrl[0][1] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL02: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][2];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][2];
		reg_ms_pri_sch_ctrl[0][2] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL03: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][3];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][3];
		reg_ms_pri_sch_ctrl[0][3] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL04: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][4];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][4];
		reg_ms_pri_sch_ctrl[0][4] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL05: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][5];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][5];
		reg_ms_pri_sch_ctrl[0][5] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL06: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][6];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][6];
		reg_ms_pri_sch_ctrl[0][6] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL07: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[0][7];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[0][7];
		reg_ms_pri_sch_ctrl[0][7] = reg_bs;
	    end
            `TM_QUEUE_PROFILE1: begin
		n_pio_ack = queue_profile_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = queue_profile_mem_rdata[1];
		reg_ms_queue_profile[1] = reg_bs;
	    end
            `TM_WDRR_QUANTUM1: begin
		n_pio_ack = wdrr_quantum_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_quantum_mem_rdata[1];
		reg_ms_wdrr_quantum[1] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_CIR1: begin
		n_pio_ack = shaping_profile_cir_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_cir_mem_rdata[1];
		reg_ms_shaping_profile_cir[1] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_EIR1: begin
		n_pio_ack = shaping_profile_eir_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_eir_mem_rdata[1];
		reg_ms_shaping_profile_eir[1] = reg_bs;
	    end
            `TM_WDRR_SCH_CTRL1: begin
		n_pio_ack = wdrr_sch_ctrl_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_sch_ctrl_mem_rdata[1];
		reg_ms_wdrr_sch_ctrl[1] = reg_bs;
	    end
            `TM_FILL_TB_DST1: begin
		n_pio_ack = fill_tb_dst_mem_ack[1];
		n_pio_rvalid = reg_bs;
		pio_rdata = fill_tb_dst_mem_rdata[1];
		reg_ms_fill_tb_dst[1] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL10: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][0];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][0];
		reg_ms_pri_sch_ctrl[1][0] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL11: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][1];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][1];
		reg_ms_pri_sch_ctrl[1][1] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL12: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][2];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][2];
		reg_ms_pri_sch_ctrl[1][2] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL13: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][3];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][3];
		reg_ms_pri_sch_ctrl[1][3] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL14: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][4];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][4];
		reg_ms_pri_sch_ctrl[1][4] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL15: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][5];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][5];
		reg_ms_pri_sch_ctrl[1][5] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL16: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][6];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][6];
		reg_ms_pri_sch_ctrl[1][6] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL17: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[1][7];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[1][7];
		reg_ms_pri_sch_ctrl[1][7] = reg_bs;
	    end
            `TM_QUEUE_PROFILE2: begin
		n_pio_ack = queue_profile_mem_ack[2];
		n_pio_rvalid = reg_bs;
		pio_rdata = queue_profile_mem_rdata[2];
		reg_ms_queue_profile[2] = reg_bs;
	    end
            `TM_WDRR_QUANTUM2: begin
		n_pio_ack = wdrr_quantum_mem_ack[2];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_quantum_mem_rdata[2];
		reg_ms_wdrr_quantum[2] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_CIR2: begin
		n_pio_ack = shaping_profile_cir_mem_ack[2];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_cir_mem_rdata[2];
		reg_ms_shaping_profile_cir[2] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_EIR2: begin
		n_pio_ack = shaping_profile_eir_mem_ack[2];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_eir_mem_rdata[2];
		reg_ms_shaping_profile_eir[2] = reg_bs;
	    end
            `TM_WDRR_SCH_CTRL2: begin
		n_pio_ack = wdrr_sch_ctrl_mem_ack[2];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_sch_ctrl_mem_rdata[2];
		reg_ms_wdrr_sch_ctrl[2] = reg_bs;
	    end
            `TM_FILL_TB_DST2: begin
		n_pio_ack = fill_tb_dst_mem_ack[2];
		n_pio_rvalid = reg_bs;
		pio_rdata = fill_tb_dst_mem_rdata[2];
		reg_ms_fill_tb_dst[2] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL20: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][0];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][0];
		reg_ms_pri_sch_ctrl[2][0] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL21: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][1];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][1];
		reg_ms_pri_sch_ctrl[2][1] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL22: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][2];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][2];
		reg_ms_pri_sch_ctrl[2][2] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL23: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][3];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][3];
		reg_ms_pri_sch_ctrl[2][3] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL24: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][4];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][4];
		reg_ms_pri_sch_ctrl[2][4] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL25: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][5];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][5];
		reg_ms_pri_sch_ctrl[2][5] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL26: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][6];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][6];
		reg_ms_pri_sch_ctrl[2][6] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL27: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[2][7];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[2][7];
		reg_ms_pri_sch_ctrl[2][7] = reg_bs;
	    end
            `TM_QUEUE_PROFILE3: begin
		n_pio_ack = queue_profile_mem_ack[3];
		n_pio_rvalid = reg_bs;
		pio_rdata = queue_profile_mem_rdata[3];
		reg_ms_queue_profile[3] = reg_bs;
	    end
            `TM_WDRR_QUANTUM3: begin
		n_pio_ack = wdrr_quantum_mem_ack[3];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_quantum_mem_rdata[3];
		reg_ms_wdrr_quantum[3] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_CIR3: begin
		n_pio_ack = shaping_profile_cir_mem_ack[3];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_cir_mem_rdata[3];
		reg_ms_shaping_profile_cir[3] = reg_bs;
	    end
            `TM_SHAPING_PROFILE_EIR3: begin
		n_pio_ack = shaping_profile_eir_mem_ack[3];
		n_pio_rvalid = reg_bs;
		pio_rdata = shaping_profile_eir_mem_rdata[3];
		reg_ms_shaping_profile_eir[3] = reg_bs;
	    end
            `TM_WDRR_SCH_CTRL3: begin
		n_pio_ack = wdrr_sch_ctrl_mem_ack[3];
		n_pio_rvalid = reg_bs;
		pio_rdata = wdrr_sch_ctrl_mem_rdata[3];
		reg_ms_wdrr_sch_ctrl[3] = reg_bs;
	    end
            `TM_FILL_TB_DST3: begin
		n_pio_ack = fill_tb_dst_mem_ack[3];
		n_pio_rvalid = reg_bs;
		pio_rdata = fill_tb_dst_mem_rdata[3];
		reg_ms_fill_tb_dst[3] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL30: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][0];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][0];
		reg_ms_pri_sch_ctrl[3][0] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL31: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][1];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][1];
		reg_ms_pri_sch_ctrl[3][1] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL32: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][2];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][2];
		reg_ms_pri_sch_ctrl[3][2] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL33: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][3];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][3];
		reg_ms_pri_sch_ctrl[3][3] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL34: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][4];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][4];
		reg_ms_pri_sch_ctrl[3][4] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL35: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][5];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][5];
		reg_ms_pri_sch_ctrl[3][5] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL36: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][6];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][6];
		reg_ms_pri_sch_ctrl[3][6] = reg_bs;
	    end
            `TM_PRI_SCH_CTRL37: begin
		n_pio_ack = pri_sch_ctrl_mem_ack[3][7];
		n_pio_rvalid = reg_bs;
		pio_rdata = pri_sch_ctrl_mem_rdata[3][7];
		reg_ms_pri_sch_ctrl[3][7] = reg_bs;
	    end
            default: begin
		n_pio_ack = none_selected_ack;
	    end
		
	endcase
end

/***************************** REGISTERED OUTPUTS ****************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		pio_ack <= 1'b0;
		pio_rvalid <= 1'b0;
		n_none_selected_ack <= 1'b0;
		none_selected_ack <= 1'b0;
	end else begin
		pio_ack <= clk_div?n_pio_ack&~rd_en:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid&reg_bs&rd_en&n_pio_ack:pio_rvalid;
		n_none_selected_ack <= (reg_rd|reg_wr)&reg_bs?1'b1:clk_div?1'b0:n_none_selected_ack;
		none_selected_ack <= clk_div?n_none_selected_ack:none_selected_ack;
	end
end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) 
	if(`ACTIVE_RESET) begin
		reg_rd_d1 <= 1'b0;
	end else begin
		reg_rd_d1 <= reg_rd?reg_bs:pio_rvalid?1'b0:reg_rd_d1;
	end


endmodule

