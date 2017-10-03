//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap_reg (


input clk, 
input `RESET_SIG, 

input clk_div, 

input         reg_bs,
input         reg_rd,
input         reg_wr,
input [`PIO_RANGE] reg_addr,
input [`PIO_RANGE] reg_din,

output reg    pio_ack,
output reg    pio_rvalid,
output reg [`PIO_RANGE] pio_rdata,

output reg [15:0] in_vlan,
output [47:0] in_mac_sa,
output [47:0] in_mac_da,
output [47:0] mac_sa,
output [63:0] ipsec_iv,
output reg [31:0] gre_header,
output reg [23:0] flow_label,
output reg [15:0] identification,
output reg [7:0] ttl,
output reg [7:0] dscp_ecn


);

/***************************** LOCAL VARIABLES *******************************/
reg reg_rd_d1;

reg n_pio_ack;
reg n_pio_rvalid;

reg [31:0] in_mac_da_lsb;
reg [15:0] in_mac_da_msb;
reg [31:0] in_mac_sa_lsb;
reg [15:0] in_mac_sa_msb;
reg [31:0] mac_sa_lsb;
reg [15:0] mac_sa_msb;
reg [31:0] iv_lsb;
reg [31:0] iv_msb;

reg sel_in_vlan;
reg sel_in_mac_da_lsb;
reg sel_in_mac_da_msb;
reg sel_in_mac_sa_lsb;
reg sel_in_mac_sa_msb;
reg sel_mac_sa_lsb;
reg sel_mac_sa_msb;
reg sel_iv_lsb;
reg sel_iv_msb;
reg sel_gre_header;
reg sel_id_ttl_dscp;
reg sel_flow_label;

wire wr_in_vlan = reg_wr&reg_bs&sel_in_vlan;
wire wr_in_mac_da_lsb = reg_wr&reg_bs&sel_in_mac_da_lsb;
wire wr_in_mac_da_msb = reg_wr&reg_bs&sel_in_mac_da_msb;
wire wr_in_mac_sa_lsb = reg_wr&reg_bs&sel_in_mac_sa_lsb;
wire wr_in_mac_sa_msb = reg_wr&reg_bs&sel_in_mac_sa_msb;
wire wr_mac_sa_lsb = reg_wr&reg_bs&sel_mac_sa_lsb;
wire wr_mac_sa_msb = reg_wr&reg_bs&sel_mac_sa_msb;
wire wr_iv_lsb = reg_wr&reg_bs&sel_iv_lsb;
wire wr_iv_msb = reg_wr&reg_bs&sel_iv_msb;
wire wr_gre_header = reg_wr&reg_bs&sel_gre_header;
wire wr_id_ttl_dscp = reg_wr&reg_bs&sel_id_ttl_dscp;
wire wr_flow_label = reg_wr&reg_bs&sel_flow_label;

wire rd_en = reg_rd|reg_rd_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

always @(*) begin
	n_pio_rvalid = 1'b0;
	sel_in_vlan = 1'b0;
	sel_in_mac_da_lsb = 1'b0;
	sel_in_mac_da_msb = 1'b0;
	sel_in_mac_sa_lsb = 1'b0;
	sel_in_mac_sa_msb = 1'b0;
	sel_mac_sa_lsb = 1'b0;
	sel_mac_sa_msb = 1'b0;
	sel_iv_lsb = 1'b0;
	sel_iv_msb = 1'b0;
	sel_gre_header = 1'b0;
	sel_id_ttl_dscp = 1'b0;
	sel_flow_label = 1'b0;
	pio_rdata = {(`PIO_NBITS){1'b0}};

	case(reg_addr[`ENCR_REG_ADDR_RANGE])
		`ENCR_IN_VLAN: begin
			n_pio_rvalid = 1'b1;
			sel_in_vlan = 1'b1;
			pio_rdata = in_vlan;
		end
		`ENCR_IN_MAC_DA_LSB: begin
			n_pio_rvalid = 1'b1;
			sel_in_mac_da_lsb = 1'b1;
			pio_rdata = in_mac_da_lsb;
		end
		`ENCR_IN_MAC_DA_MSB: begin
			n_pio_rvalid = 1'b1;
			sel_in_mac_da_msb = 1'b1;
			pio_rdata = {{(16){1'b0}}, in_mac_da_msb};
		end
		`ENCR_IN_MAC_SA_LSB: begin
			n_pio_rvalid = 1'b1;
			sel_in_mac_sa_lsb = 1'b1;
			pio_rdata = in_mac_sa_lsb;
		end
		`ENCR_IN_MAC_SA_MSB: begin
			n_pio_rvalid = 1'b1;
			sel_in_mac_sa_msb = 1'b1;
			pio_rdata = {{(16){1'b0}}, in_mac_sa_msb};
		end
		`ENCR_MAC_SA_LSB: begin
			n_pio_rvalid = 1'b1;
			sel_mac_sa_lsb = 1'b1;
			pio_rdata = mac_sa_lsb;
		end
		`ENCR_MAC_SA_MSB: begin
			n_pio_rvalid = 1'b1;
			sel_mac_sa_msb = 1'b1;
			pio_rdata = {{(16){1'b0}}, mac_sa_msb};
		end
		`ENCR_IPSEC_IV_LSB: begin
			n_pio_rvalid = 1'b1;
			sel_iv_lsb = 1'b1;
			pio_rdata = iv_lsb;
		end
		`ENCR_IPSEC_IV_MSB: begin
			n_pio_rvalid = 1'b1;
			sel_iv_msb = 1'b1;
			pio_rdata = iv_msb;
		end
		`ENCR_GRE_HEADER: begin
			n_pio_rvalid = 1'b1;
			sel_gre_header = 1'b1;
			pio_rdata = gre_header;
		end
		`ENCR_ID_TTL_DSCP: begin
			n_pio_rvalid = 1'b1;
			sel_id_ttl_dscp = 1'b1;
			pio_rdata = {identification, ttl, dscp_ecn};
		end
		`ENCR_FLOW_LABEL: begin
			n_pio_rvalid = 1'b1;
			sel_flow_label = 1'b1;
			pio_rdata = flow_label;
		end
	endcase
end

/*****************************16'h65516'h6558 OUTPUTS ****************************/

assign in_mac_da = {in_mac_da_msb, in_mac_da_lsb};
assign in_mac_sa = {in_mac_sa_msb, in_mac_sa_lsb};
assign mac_sa = {mac_sa_msb, mac_sa_lsb};
assign ipsec_iv = {iv_msb, iv_lsb};

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		pio_ack <= 1'b0;
		pio_rvalid <= 1'b0;

		in_vlan <= 0;
		gre_header <= 16'h6558;
		flow_label <= 0;
		{identification, ttl, dscp_ecn} <= 0;
	end else begin
		pio_ack <= clk_div?n_pio_ack&~rd_en:pio_ack;
		pio_rvalid <= clk_div?n_pio_rvalid&reg_bs&rd_en&n_pio_ack:pio_rvalid;

		in_vlan <= wr_in_vlan?reg_din:in_vlan;
		gre_header <= wr_gre_header?reg_din:gre_header;
		flow_label <= wr_flow_label?reg_din:flow_label;
		{identification, ttl, dscp_ecn} <= wr_id_ttl_dscp?reg_din:{identification, ttl, dscp_ecn};
	end
end

/***************************** PROGRAM BODY **********************************/

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		n_pio_ack <= 1'b0;
		reg_rd_d1 <= 1'b0;

		in_mac_da_lsb <= 0;
		in_mac_da_msb <= 0;
		in_mac_sa_lsb <= 0;
		in_mac_sa_msb <= 0;
		mac_sa_lsb <= 0;
		mac_sa_msb <= 0;
		iv_lsb <= 0;
		iv_msb <= 0;
	end else begin
		n_pio_ack <= (reg_rd|reg_wr)&reg_bs?1'b1:clk_div?1'b0:n_pio_ack;
		reg_rd_d1 <= reg_rd?reg_bs:pio_rvalid?1'b0:reg_rd_d1;

		in_mac_da_lsb <= wr_in_mac_da_lsb?reg_din:in_mac_da_lsb;
		in_mac_da_msb <= wr_in_mac_da_msb?reg_din:in_mac_da_msb;
		in_mac_sa_lsb <= wr_in_mac_sa_lsb?reg_din:in_mac_sa_lsb;
		in_mac_sa_msb <= wr_in_mac_sa_msb?reg_din:in_mac_sa_msb;
		mac_sa_lsb <= wr_mac_sa_lsb?reg_din:mac_sa_lsb;
		mac_sa_msb <= wr_mac_sa_msb?reg_din:mac_sa_msb;
		iv_lsb <= wr_iv_lsb?reg_din:iv_lsb;
		iv_msb <= wr_iv_msb?reg_din:iv_msb;
	end
end

endmodule

