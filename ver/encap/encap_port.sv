//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap_port #(
parameter ENCRYPTOR_ID = 0,
parameter RING_NBITS = 128,
parameter PBUS_NBITS = `PORT_BUS_NBITS,
parameter PBUS_VB_NBITS = 2,
parameter LEN_NBITS = `PACKET_LENGTH_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS,
parameter KEY_NBITS = 256,
parameter CI_NBITS = `RCI_NBITS
) (

input clk, 
input `RESET_SIG,

input clk_mac, 

input dstr_enc_data_valid,
input [PBUS_NBITS-1:0] dstr_enc_packet_data,
input dstr_enc_sop,
input dstr_enc_eop,
input [PBUS_VB_NBITS-1:0] dstr_enc_valid_bytes,    

input [RING_NBITS-1:0] encr_ring_in_data,
input encr_ring_in_sof,
input encr_ring_in_sos,
input encr_ring_in_valid,

input [15:0] in_vlan,
input [47:0] in_mac_sa,
input [47:0] in_mac_da,
input [47:0] mac_sa,
input [63:0] ipsec_iv,
input [31:0] gre_header,
input [19:0] flow_label,
input [15:0] identification,
input [7:0] ttl,
input [7:0] dscp_ecn,

input tx_axis_tready,

output logic port_dstr_bp,

output logic [RING_NBITS-1:0] encr_ring_out_data,
output logic encr_ring_out_sof,
output logic encr_ring_out_sos,
output logic encr_ring_out_valid,

output logic [PBUS_NBITS-1:0] tx_axis_tdata,
output logic [3:0] tx_axis_tkeep,
output logic tx_axis_tvalid,
output logic tx_axis_tuser,
output logic tx_axis_tlast

);

/***************************** LOCAL VARIABLES *******************************/

localparam IN_FIFO_DEPTH_NBITS = 6;
localparam XON_LEVEL = 16;
localparam XOFF_LEVEL = ((1<<IN_FIFO_DEPTH_NBITS)-XON_LEVEL);
localparam REQ_FIFO_DEPTH_NBITS = 2;
localparam OUT_FIFO_DEPTH_NBITS = 8;
localparam VLAN_TYPE = 16'h8100;
localparam IPV4_TYPE = 16'h0800;
localparam IPV6_TYPE = 16'h86dd;
localparam IPV4_PROTOCOL_LOC = 24;
localparam IPV6_PROTOCOL_LOC = 20;
localparam IPSEC_PROTOCOL_NUM = 8'd50;
localparam GRE_PROTOCOL_NUM = 8'd47;
localparam GRE_PROTOCOL_TYPE_IP = 16'h0800;
localparam GRE_PROTOCOL_TYPE_L2 = 16'h6558;

logic dstr_enc_data_valid_d1;
logic [PBUS_NBITS-1:0] dstr_enc_packet_data_d1;
logic dstr_enc_sop_d1;
logic dstr_enc_eop_d1;
logic [PBUS_VB_NBITS-1:0] dstr_enc_valid_bytes_d1;    

logic l2_gre;
logic in_vlan_tagged;

logic [RING_NBITS-1:0] encr_ring_in_data_d1;
logic encr_ring_in_sof_d1;
logic encr_ring_in_sos_d1;
logic encr_ring_in_valid_d1;

logic [RING_NBITS-1:0] encr_ring_in_data_d2;
logic encr_ring_in_sof_d2;
logic encr_ring_in_sos_d2;
logic encr_ring_in_valid_d2;

logic [ID_NBITS-1:0] segment_cnt;
logic [2:0] word_cnt;

logic [IN_FIFO_DEPTH_NBITS:0] in_fifo_count;
logic in_fifo_empty;
logic [PBUS_NBITS-1:0] in_fifo_data;
logic [PBUS_VB_NBITS-1:0] in_fifo_valid_bytes;
logic in_fifo_good;
logic in_fifo_eop;
logic in_fifo_sop;
logic in_fifo_sop_d1;

(* max_fanout = 100 *) logic [LEN_NBITS-1:0] pkt_len;

wire vlan_tagged = |encr_ring_in_data_d2[127-48:64];
wire ipsec = |encr_ring_in_data_d2[63:0];
wire ipv4_cond = ~|encr_ring_in_data_d2[127:32];
logic ipv4_cond_d1;
wire ipv4 = ipv4_cond_d1&ipv4_cond;
logic ipv4_d1;

wire out_fifo_wr = ~in_fifo_empty&~in_fifo_sop; 

logic [2:0] result_fifo_count;
wire result_fifo_full = result_fifo_count==4;
wire req_fifo_wr = ~in_fifo_empty&in_fifo_sop&~result_fifo_full;
wire [LEN_NBITS+CI_NBITS-1:0] req_fifo_wdata = in_fifo_data;

wire in_fifo_rd = out_fifo_wr|req_fifo_wr;

logic req_fifo_empty;
logic [LEN_NBITS+CI_NBITS-1:0] req_fifo_rdata;
wire my_segment = (segment_cnt==ENCRYPTOR_ID);
wire en_req = my_segment&(word_cnt==0);
wire req_fifo_rd = ~req_fifo_empty&en_req;
wire req_pending_fifo_wr = req_fifo_rd;

logic [LEN_NBITS-1:0] req_pending_fifo_data;
logic req_pending_fifo_empty;
wire req_pending_fifo_rd = my_segment&~req_pending_fifo_empty&(word_cnt==4)&encr_ring_in_valid_d2;

wire key_fifo_wr = encr_ring_in_valid_d2&my_segment&~req_pending_fifo_empty&((word_cnt==0)|(word_cnt==1));
logic key_fifo_empty;
logic key_fifo_rd = ~key_fifo_empty;
logic ip_sa_fifo_rd;
logic ip_da_fifo_rd;
logic [KEY_NBITS/2-1:0] key_fifo_data;
wire ip_sa_fifo_wr = encr_ring_in_valid_d2&my_segment&~req_pending_fifo_empty&(word_cnt==2);
wire ip_da_fifo_wr = encr_ring_in_valid_d2&my_segment&~req_pending_fifo_empty&(word_cnt==3);
logic [RING_NBITS-1:0] ip_sa_fifo_data;
logic [RING_NBITS-1:0] ip_da_fifo_data;
(* max_fanout = 50 *) logic result_fifo_empty;
wire result_fifo_wr = encr_ring_in_valid_d2&my_segment&~req_pending_fifo_empty&(word_cnt==4);
logic result_fifo_ipv4;
logic result_fifo_ipsec;
logic result_fifo_vlan_tagged;
logic [15:0] result_fifo_vlan;
logic [47:0] result_fifo_mac_da;
logic [31:0] result_fifo_spi;
logic [31:0] result_fifo_sn;
logic [LEN_NBITS-1:0] result_fifo_pkt_len;

logic [15:0] cs00, cs01, cs02, cs03, cs10, cs11, cs2, checksum;

logic [15:0] out_fifo_data_lsb_sv;

logic p_tx_fifo_empty;
logic p_tx_fifo_full;
logic [PBUS_NBITS-1:0] p_tx_fifo_in_data;
logic p_tx_fifo_in_sop;
logic p_tx_fifo_in_eop;
logic [PBUS_VB_NBITS-1:0] p_tx_fifo_in_valid_bytes;    
logic p_tx_fifo_wr;

logic tx_fifo_in_full;
logic tx_fifo_in_empty;
logic [PBUS_NBITS-1:0] tx_fifo_in_data;
logic tx_fifo_in_sop;
logic tx_fifo_in_eop;
logic [PBUS_VB_NBITS-1:0] tx_fifo_in_valid_bytes;    
logic [4-1:0] tx_fifo_in_tkeep;    

logic tx_fifo_full;
logic tx_fifo_empty;
logic [PBUS_NBITS-1:0] tx_fifo_data;
logic tx_fifo_sop;
logic tx_fifo_eop;
logic [4-1:0] tx_fifo_tkeep;    

logic out_fifo_empty;
logic [PBUS_NBITS-1:0] out_fifo_data;
logic out_fifo_sop;
logic out_fifo_eop;
logic [PBUS_VB_NBITS-1:0] out_fifo_valid_bytes;    

logic en_pkt_len;
wire set_en_pkt_len = ~result_fifo_empty&pkt_len==0;
wire reset_en_pkt_len = p_tx_fifo_wr&p_tx_fifo_in_eop;
wire result_fifo_rd = reset_en_pkt_len;

logic out_fifo_eop_d1;
logic [PBUS_VB_NBITS-1:0] mout_fifo_valid_bytes_d1;    

logic out_fifo_rd;
wire [2:0] mout_fifo_valid_bytes = {~|out_fifo_valid_bytes, out_fifo_valid_bytes};
wire one_more_tx = out_fifo_rd&out_fifo_eop&mout_fifo_valid_bytes>2;

wire p_tx_fifo_rd = ~p_tx_fifo_empty&~tx_fifo_full;
wire p_tx_fifo_nav = p_tx_fifo_full&~p_tx_fifo_rd;

wire tx_fifo_rd = tx_axis_tvalid&tx_axis_tready;

/***************************** NON REGISTERED OUTPUTS ************************/

assign tx_axis_tvalid = ~tx_fifo_empty;

/***************************** REGISTERED OUTPUTS ****************************/

assign tx_axis_tdata = tx_fifo_data;
assign tx_axis_tkeep = tx_fifo_tkeep;
assign tx_axis_tlast = tx_fifo_eop;
assign tx_axis_tuser = 1'b0;

always @(posedge clk) begin

		encr_ring_out_data <= en_req?req_fifo_rdata[CI_NBITS-1:0]:encr_ring_in_data_d2;
		encr_ring_out_sof <= encr_ring_in_sof_d2;
		encr_ring_out_sos <= encr_ring_in_sos_d2;
		encr_ring_out_valid <= en_req?req_fifo_rd:encr_ring_in_valid_d2;

end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		port_dstr_bp <= 1'b0;
	end else begin
		port_dstr_bp <= in_fifo_count<XON_LEVEL?1'b0:in_fifo_count>XOFF_LEVEL?1'b1:port_dstr_bp;

	end

/***************************** PROGRAM BODY **********************************/

logic `RESET_SIG_MAC;

synchronizer u_synchronizer(.clk(clk_mac), .din(`RESET_SIG), .dout(`RESET_SIG_MAC));

wire [15:0] payload_length = result_fifo_pkt_len+4+
				(l2_gre?14:0)+
				(in_vlan_tagged?4:0)+
				(result_fifo_ipsec?20:0);
wire [15:0] total_length = payload_length+(result_fifo_ipv4?20:40);

wire [15:0] ipv4_1st_word = {8'h45, dscp_ecn};
wire [15:0] fragment = 16'h0;

wire [7:0] protocol = result_fifo_ipsec?IPSEC_PROTOCOL_NUM:GRE_PROTOCOL_NUM;

wire [15:0] ipv6_1st_word = {4'h6, dscp_ecn, flow_label};

wire [15:0] etype = result_fifo_vlan_tagged?VLAN_TYPE:result_fifo_ipv4?IPV4_TYPE:IPV6_TYPE;
wire [15:0] vlan_2bytes = result_fifo_vlan_tagged?result_fifo_vlan:result_fifo_ipv4?IPV4_TYPE:IPV6_TYPE;

wire [47:0] mac_da = result_fifo_mac_da;
wire [127:0] ip_sa = ip_sa_fifo_data;
wire [127:0] ip_da = ip_da_fifo_data;

(* max_fanout = 50 *) wire result_ipv6 = ~(~result_fifo_empty&result_fifo_ipv4); 
(* max_fanout = 50 *) wire result_vlan_tagged = ~result_fifo_empty&result_fifo_vlan_tagged;

always @(*) begin
	out_fifo_rd = 1'b0;
	ip_sa_fifo_rd = 1'b0;
	ip_da_fifo_rd = 1'b0;
	p_tx_fifo_in_data = 0;
	p_tx_fifo_in_valid_bytes = 0;
	p_tx_fifo_in_sop = 1'b0;
	p_tx_fifo_in_eop = 1'b0;      
	p_tx_fifo_wr = en_pkt_len&~out_fifo_empty&~p_tx_fifo_nav;
	case ({/*result_fifo_ipsec*/ 1'b0, in_vlan_tagged, l2_gre, result_ipv6, result_vlan_tagged}) 
		5'h00: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				5: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				6: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				8: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h01: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: 
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				2: 
					p_tx_fifo_in_data = mac_sa[31:0];
				3: 
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				4: 
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				5: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				6: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				7: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h02: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				5: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				6: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				14: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h03: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				6: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				10: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				14: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				15: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h04: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				5: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				6: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				8: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				10: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				11: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				12: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h05: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				6: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				7: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				11: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				12: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				13: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h06: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				5: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				6: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				14: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				15: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				16: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				17: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h07: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				6: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				10: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				14: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				15: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				16: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				17: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				18: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h08: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				5: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				6: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				8: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h09: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				6: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				7: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h0a: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				5: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				6: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				14: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h0b: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				6: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				10: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				14: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				15: begin
					p_tx_fifo_in_data = {gre_header[15:0], out_fifo_data[31:16]};
					out_fifo_rd = p_tx_fifo_wr;
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data_lsb_sv, out_fifo_data[31:16]};
					p_tx_fifo_in_valid_bytes = out_fifo_eop_d1?mout_fifo_valid_bytes_d1:~out_fifo_eop?0:one_more_tx?0:out_fifo_valid_bytes+2;
					p_tx_fifo_in_eop = out_fifo_eop_d1?1'b1:~out_fifo_eop?1'b0:mout_fifo_valid_bytes<3;      
					p_tx_fifo_wr = out_fifo_eop_d1?~p_tx_fifo_nav:~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = ~out_fifo_eop_d1&~out_fifo_empty&~p_tx_fifo_nav;
				end
			endcase
		5'h0c: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				5: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				6: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				8: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				10: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				11: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				12: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], VLAN_TYPE};
				end
				13: begin
					p_tx_fifo_in_data = {in_vlan[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h0d: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV4_TYPE, ipv4_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {total_length, identification};
				end
				6: begin
					p_tx_fifo_in_data = {fragment, ttl, GRE_PROTOCOL_NUM};
				end
				7: begin
					p_tx_fifo_in_data = {~checksum, ip_sa[31:16]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[31:16]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				9: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				11: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				12: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				13: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], VLAN_TYPE};
				end
				14: begin
					p_tx_fifo_in_data = {in_vlan[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h0e: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				4: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				5: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				6: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				10: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				14: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				15: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				16: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				17: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], VLAN_TYPE};
				end
				18: begin
					p_tx_fifo_in_data = {in_vlan[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		5'h0f: 
			case (pkt_len[LEN_NBITS-1:2])
				0: begin
					p_tx_fifo_in_data = mac_da[47:16];
					p_tx_fifo_in_sop = 1'b1;
				end
				1: begin
					p_tx_fifo_in_data = {mac_da[15:0], mac_sa[47:32]};
				end
				2: begin
					p_tx_fifo_in_data = mac_sa[31:0];
				end
				3: begin
					p_tx_fifo_in_data = {VLAN_TYPE, result_fifo_vlan};
				end
				4: begin
					p_tx_fifo_in_data = {IPV6_TYPE, ipv6_1st_word};
				end
				5: begin
					p_tx_fifo_in_data = {flow_label[15:0], payload_length};
				end
				6: begin
					p_tx_fifo_in_data = {GRE_PROTOCOL_NUM, ttl, ip_sa[127:112]};
				end
				7: begin
					p_tx_fifo_in_data = {ip_sa[111:80]};
				end
				8: begin
					p_tx_fifo_in_data = {ip_sa[79:48]};
				end
				9: begin
					p_tx_fifo_in_data = {ip_sa[47:16]};
				end
				10: begin
					p_tx_fifo_in_data = {ip_sa[15:0], ip_da[127:112]};
					ip_sa_fifo_rd = p_tx_fifo_wr;
				end
				11: begin
					p_tx_fifo_in_data = {ip_da[111:80]};
				end
				12: begin
					p_tx_fifo_in_data = {ip_da[79:48]};
				end
				13: begin
					p_tx_fifo_in_data = {ip_da[47:16]};
				end
				14: begin
					p_tx_fifo_in_data = {ip_da[15:0], gre_header[31:16]};
					ip_da_fifo_rd = p_tx_fifo_wr;
				end
				15: begin
					p_tx_fifo_in_data = {gre_header[15:0], in_mac_da[47:32]};
				end
				16: begin
					p_tx_fifo_in_data = {in_mac_da[31:0]};
				end
				17: begin
					p_tx_fifo_in_data = {in_mac_sa[47:32]};
				end
				18: begin
					p_tx_fifo_in_data = {in_mac_sa[15:0], VLAN_TYPE};
				end
				19: begin
					p_tx_fifo_in_data = {in_vlan[15:0], IPV6_TYPE};
				end
				default: begin
					p_tx_fifo_in_data = {out_fifo_data[31:0]};
					p_tx_fifo_in_valid_bytes = out_fifo_valid_bytes;
					p_tx_fifo_in_eop = out_fifo_eop;
					p_tx_fifo_wr = ~out_fifo_empty&~p_tx_fifo_nav;
					out_fifo_rd = p_tx_fifo_wr;
				end
			endcase
		default: 
					p_tx_fifo_wr = 0;
	endcase
end

always @(posedge clk) begin

		encr_ring_in_data_d1 <= encr_ring_in_data;
		encr_ring_in_sof_d1 <= encr_ring_in_sof;
		encr_ring_in_sos_d1 <= encr_ring_in_sos;
		encr_ring_in_valid_d1 <= encr_ring_in_valid;

		encr_ring_in_data_d2 <= encr_ring_in_data_d1;
		encr_ring_in_sof_d2 <= encr_ring_in_sof_d1;
		encr_ring_in_sos_d2 <= encr_ring_in_sos_d1;
		encr_ring_in_valid_d2 <= encr_ring_in_valid_d1;

		dstr_enc_packet_data_d1 <= dstr_enc_packet_data;
		dstr_enc_valid_bytes_d1 <= dstr_enc_valid_bytes;
		dstr_enc_sop_d1 <= dstr_enc_sop;
		dstr_enc_eop_d1 <= dstr_enc_eop;

		l2_gre <= gre_header==GRE_PROTOCOL_TYPE_L2;
		in_vlan_tagged <= (in_vlan!=0)&(gre_header==GRE_PROTOCOL_TYPE_L2);

		ipv4_cond_d1 <= ipv4_cond;
		ipv4_d1 <= ipv4;

		cs00 <= ones_add(ipv4_1st_word, {ttl, protocol});
		cs01 <= ones_add(identification, fragment);
		cs02 <= ones_add(ip_sa_fifo_data[31:16], ip_sa_fifo_data[15:0]);
		cs03 <= ones_add(ip_da_fifo_data[31:16], ip_da_fifo_data[15:0]);
		cs10 <= ones_add(cs00, cs01);
		cs11 <= ones_add(cs02, cs03);
		cs2 <= ones_add(cs10, cs11);
		checksum <= ones_add(total_length, cs2);

		out_fifo_data_lsb_sv <= out_fifo_rd?out_fifo_data[15:0]:out_fifo_data_lsb_sv;

		mout_fifo_valid_bytes_d1 <= one_more_tx?mout_fifo_valid_bytes-2:0;
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		dstr_enc_data_valid_d1 <= 1'b0;
		segment_cnt <= 0;
		word_cnt <= 0;
		en_pkt_len <= 1'b0;
		pkt_len <= 0;

		in_fifo_sop_d1 <= 0;

		result_fifo_count <= 0;

		out_fifo_eop_d1 <= 1'b0;

	end else begin
		dstr_enc_data_valid_d1 <= dstr_enc_data_valid;
		segment_cnt <= encr_ring_in_sof_d1?0:encr_ring_in_sos_d1?segment_cnt+1:segment_cnt;
		word_cnt <= my_segment?word_cnt+1:0;
		en_pkt_len <= set_en_pkt_len?1'b1:reset_en_pkt_len?1'b0:en_pkt_len;
		pkt_len <= reset_en_pkt_len?0:p_tx_fifo_wr?pkt_len+`PORT_BUS_NBYTES:pkt_len;

		result_fifo_count <= ~req_fifo_wr^result_fifo_rd?result_fifo_count:req_fifo_wr?result_fifo_count+1:result_fifo_count-1;

		in_fifo_sop_d1 <= in_fifo_rd?in_fifo_sop:in_fifo_sop_d1;;

		out_fifo_eop_d1 <= one_more_tx?1'b1:p_tx_fifo_wr&out_fifo_eop_d1?1'b0:out_fifo_eop_d1;
	end

 
encap_ip u_encap_ip (

	.clk(clk), 
	.`RESET_SIG(`RESET_SIG),

	.plaintext_data({(128){1'b0}}),
	.key({(256){1'b0}}),
	.encrypt_request(1'b0),

	.cybertext_data(),
	.encrypt_complete(encrypt_complete)

);


sfifo2f_bram_pf #(PBUS_NBITS+PBUS_VB_NBITS+2, IN_FIFO_DEPTH_NBITS) u_sfifo2f_bram_pf_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({dstr_enc_packet_data_d1, dstr_enc_valid_bytes_d1, dstr_enc_sop_d1, dstr_enc_eop_d1}),               
        .rd(in_fifo_rd),
        .wr(dstr_enc_data_valid_d1),

        .count(in_fifo_count),
        .full(),
        .empty(in_fifo_empty),
        .dout({in_fifo_data, in_fifo_valid_bytes, in_fifo_sop, in_fifo_eop})       
    );


sfifo2f_fo #(LEN_NBITS+CI_NBITS, REQ_FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(req_fifo_wdata),               
        .rd(req_fifo_rd),
        .wr(req_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(req_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(req_fifo_rdata)       
    );

sfifo2f_fo #(LEN_NBITS, 2) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({req_fifo_rdata[LEN_NBITS+CI_NBITS-1:CI_NBITS]}),               
        .rd(req_pending_fifo_rd),
        .wr(req_pending_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(req_pending_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({req_pending_fifo_data})       
    );

sfifo2f_fo #(RING_NBITS, 4) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({encr_ring_in_data_d2}),               
        .rd(key_fifo_rd),
        .wr(key_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(key_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({key_fifo_data})       
    );

sfifo2f1 #(RING_NBITS, 4) u_sfifo2f1_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({encr_ring_in_data_d2}),               
        .rd(ip_sa_fifo_rd),
        .wr(ip_sa_fifo_wr),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({ip_sa_fifo_data})       
    );

sfifo2f1 #(RING_NBITS, 4) u_sfifo2f1_5(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({encr_ring_in_data_d2}),               
        .rd(ip_da_fifo_rd),
        .wr(ip_da_fifo_wr),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({ip_da_fifo_data})       
    );

sfifo2f_fo #(LEN_NBITS+3+RING_NBITS) u_sfifo2f_fo_6(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({req_pending_fifo_data, ipv4_d1, ipsec, vlan_tagged, encr_ring_in_data_d2}),               
        .rd(result_fifo_rd),
        .wr(result_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(result_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({result_fifo_pkt_len, result_fifo_ipv4, result_fifo_ipsec, result_fifo_vlan_tagged, result_fifo_mac_da, result_fifo_vlan, result_fifo_spi, result_fifo_sn})       
    );

sfifo2f_bram_pf #(PBUS_NBITS+PBUS_VB_NBITS+2, OUT_FIFO_DEPTH_NBITS) u_sfifo2f_bram_pf_7(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.din({in_fifo_data, in_fifo_valid_bytes, in_fifo_sop_d1, in_fifo_eop}),      
        .rd(out_fifo_rd),
        .wr(out_fifo_wr),

        .count(),
        .full(),
        .empty(out_fifo_empty),
        .dout({out_fifo_data, out_fifo_valid_bytes, out_fifo_sop, out_fifo_eop})       
    );

sfifo1f #(PBUS_NBITS+PBUS_VB_NBITS+2) u_sfifo1f(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.din({p_tx_fifo_in_data, p_tx_fifo_in_valid_bytes, p_tx_fifo_in_sop, p_tx_fifo_in_eop}),      
        .rd(p_tx_fifo_rd),
        .wr(p_tx_fifo_wr),

        .full(p_tx_fifo_full),
        .empty(p_tx_fifo_empty),
	.dout({tx_fifo_in_data, tx_fifo_in_valid_bytes, tx_fifo_in_sop, tx_fifo_in_eop})      
    );

always @(*)
	case (tx_fifo_in_valid_bytes)
		0: tx_fifo_in_tkeep = 4'hf;
		1: tx_fifo_in_tkeep = 4'h8;
		2: tx_fifo_in_tkeep = 4'hc;
		default: tx_fifo_in_tkeep = 4'he;
	endcase

afifo16f #(PBUS_NBITS+4+2) u_afifo16f(
        .clk_r(clk_mac),
        .reset_r(`ACTIVE_RESET_MAC),

        .clk_w(clk),
        .reset_w(`ACTIVE_RESET),

	.din({tx_fifo_in_data, tx_fifo_in_tkeep, tx_fifo_in_sop, tx_fifo_in_eop}),      
        .rd(tx_fifo_rd),
        .wr(p_tx_fifo_rd),

        .count_r(),
        .count_w(),
        .full(tx_fifo_full),
        .empty(tx_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({tx_fifo_data, tx_fifo_tkeep, tx_fifo_sop, tx_fifo_eop})       
    );

function [15:0] ones_add;
input[15:0] din0;
input[15:0] din1;

reg [16:0] result;

begin
	result = {1'b0, din0} + {1'b0, din1};
	ones_add = result[15:0] + {15'b0, result[16]};
end
endfunction


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

