//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module decap_port #(
parameter DECRYPTOR_ID = 0,
parameter RING_NBITS = 64,
parameter PBUS_NBITS = 32,
parameter PBUS_VB_NBITS = 2,
parameter LEN_NBITS = `PACKET_LENGTH_NBITS,
parameter ID_NBITS = `PORT_ID_NBITS,
parameter KEY_NBITS = 256,
parameter STRIP_SIZE = 20
) (

input clk, 
input `RESET_SIG,

input clk_mac, 

input [PBUS_NBITS-1:0] rx_axis_tdata,
input [3:0] rx_axis_tkeep,
input rx_axis_tvalid,
input rx_axis_tuser,
input rx_axis_tlast,

input [RING_NBITS-1:0] decr_ring_in_data,
input decr_ring_in_sof,
input decr_ring_in_sos,

output logic [RING_NBITS-1:0] decr_ring_out_data,
output logic decr_ring_out_sof,
output logic decr_ring_out_sos,

output logic dec_aggr_data_valid,
output logic [PBUS_NBITS-1:0] dec_aggr_packet_data,
output logic dec_aggr_sop,
output logic dec_aggr_eop,
output logic [PBUS_VB_NBITS-1:0] dec_aggr_valid_bytes,    
output logic [`RCI_NBITS-1:0] dec_aggr_rci,    
output logic dec_aggr_error  

);

/***************************** LOCAL VARIABLES *******************************/

localparam REQ_FIFO_DEPTH_NBITS = 4;
localparam OUT_FIFO_DEPTH_NBITS = 4;
localparam PORT_BUS_NBYTES = (1<<PBUS_VB_NBITS);
localparam VLAN_TYPE = 16'h8100;
localparam IPV4_TYPE = 16'h0800;
localparam IPV6_TYPE = 16'h86dd;
localparam IPSEC_ESP_PROTOCOL_NUM = 50;
localparam IPSEC_AH_PROTOCOL_NUM = 51;
localparam GRE_PROTOCOL_NUM = 47;
localparam GRE_PROTOCOL_TYPE_IP = 16'h0800;
localparam GRE_PROTOCOL_TYPE_L2 = 16'h6558;
localparam TYPE_LOC = 12;
localparam IPV4_PROTOCOL_LOC = 14+9-3;
localparam IPV6_PROTOCOL_LOC = 14+6;
localparam IP_SA_LOC = 26-2;
localparam IPV4_AH_LEN_LOC = 14+20-2;
localparam IPV6_AH_LEN_LOC = 14+40-2;
localparam IPV4_SPI_LOC = 14+20+4-2;
localparam IPV6_SPI_LOC = 14+40+4-2;
localparam IPV4_TUNNEL = 14+20+12-2;
localparam IPV6_TUNNEL = 14+40+12-2;
localparam IPV4_GRE_PROTOCOL_LOC = 14+20+2;
localparam IPV6_GRE_PROTOCOL_LOC = 14+40+2;
localparam GRE_HEADER_SIZE = 4;

// (8100) -> 0800/86dd -> 51 -> 47 -> 86dd/6558

logic [RING_NBITS-1:0] decr_ring_in_data_d1;
logic decr_ring_in_sof_d1;
logic decr_ring_in_sos_d1;

logic [RING_NBITS-1:0] decr_ring_in_data_d2;
logic decr_ring_in_sof_d2;
logic decr_ring_in_sos_d2;

logic [ID_NBITS-1:0] segment_cnt;
logic [2:0] word_cnt;

logic [PBUS_NBITS-1:0] rx_axis_tdata_d1;
logic [3:0] rx_axis_tkeep_d1;
logic rx_axis_tvalid_d1;
logic rx_axis_tuser_d1;
logic rx_axis_tlast_d1;

logic [PBUS_VB_NBITS-1:0] rx_axis_valid_bytes;

logic in_fifo_empty;
logic [PBUS_NBITS-1:0] in_fifo_data;
logic [PBUS_VB_NBITS-1:0] in_fifo_valid_bytes;
logic in_fifo_good;
logic in_fifo_eop;
logic in_fifo_sop;

logic [LEN_NBITS-1:0] pkt_len;
logic [LEN_NBITS-1:0] inner_pkt_len;

logic my_segment = (segment_cnt==DECRYPTOR_ID);

logic req_fifo_empty;
logic [RING_NBITS-1:0] req_fifo_rdata;

logic rci_fifo_ipsec;
logic rci_fifo_l2_gre;
logic rci_fifo_valid;
logic [`RCI_NBITS-1:0] rci_fifo_rci;

logic req_pending_fifo_ipsec;
logic req_pending_fifo_l2_gre;

logic vlan_tagged;
logic ipv4;
logic ipv6;
logic ip_en_total;
logic ip_en;
logic spi_en;
logic even;
logic header_en;

logic ipsec;
logic [7:0] ah_len;
logic l2_gre;

logic inner_vlan_tagged;
logic inner_header_en;
logic inner_header_en_d1;

logic [LEN_NBITS-1:0] ipsec_offset = ipsec?(12+(ah_len-1)*4):0;

logic [LEN_NBITS-1:0] ether_type_loc = vlan_tagged?TYPE_LOC+4:TYPE_LOC;
logic [LEN_NBITS-1:0] ip_loc_1st = vlan_tagged?IP_SA_LOC+4:IP_SA_LOC;
logic [LEN_NBITS-1:0] ip_loc_total_lst = ip_loc_1st+32;
logic [LEN_NBITS-1:0] ip_loc_lst = ip_loc_1st+(ipv4?8:32);
logic [LEN_NBITS-1:0] spi_loc = vlan_tagged?(ipv4?IPV4_SPI_LOC+4-4:IPV6_SPI_LOC+4-4):(ipv4?IPV4_SPI_LOC-4:IPV6_SPI_LOC-4);

logic [LEN_NBITS-1:0] header_loc = (vlan_tagged?(ipv4?IPV4_TUNNEL+4:IPV6_TUNNEL+4):(ipv4?IPV4_TUNNEL:IPV6_TUNNEL))+ipsec_offset;
logic [LEN_NBITS-1:0] protocol_loc = vlan_tagged?(ipv4?IPV4_PROTOCOL_LOC+4:IPV6_PROTOCOL_LOC+4):(ipv4?IPV4_PROTOCOL_LOC:IPV6_PROTOCOL_LOC);
logic [LEN_NBITS-1:0] ah_len_loc = vlan_tagged?(ipv4?IPV4_AH_LEN_LOC+4:IPV6_AH_LEN_LOC+4):(ipv4?IPV4_AH_LEN_LOC:IPV6_AH_LEN_LOC);
logic [LEN_NBITS-1:0] gre_protocol_loc = (vlan_tagged?(ipv4?IPV4_GRE_PROTOCOL_LOC+4:IPV6_GRE_PROTOCOL_LOC+4):(ipv4?IPV4_GRE_PROTOCOL_LOC:IPV6_GRE_PROTOCOL_LOC))+ipsec_offset;

logic [LEN_NBITS-1:0] inner_header_loc = rci_fifo_l2_gre?(inner_vlan_tagged?GRE_HEADER_SIZE+14-2+4:GRE_HEADER_SIZE+14-2):(inner_vlan_tagged?GRE_HEADER_SIZE+4-4:GRE_HEADER_SIZE-4);

logic [PBUS_NBITS/2-1:0] in_fifo_data_save;
logic [PBUS_NBITS-1:0] in_fifo_data_ip = {in_fifo_data_save, in_fifo_data[31:16]};
logic [PBUS_NBITS-1:0] in_fifo_data_ip_d1;

logic in_fifo_rd = ~in_fifo_empty;

logic req_ready_fifo_wr = in_fifo_rd&spi_en;

logic en_req_fifo_wr = in_fifo_rd&ip_en_total;
logic req_fifo_wr = in_fifo_rd&(ip_en_total&~even|spi_en);
logic [RING_NBITS-1:0] req_fifo_wdata = req_fifo_wr&(ip_en|spi_en)?{in_fifo_data_ip_d1, in_fifo_data_ip}:{(RING_NBITS){1'b0}};

logic req_ready_fifo_empty;
logic req_fifo_rd = ~req_fifo_empty&~req_ready_fifo_empty&my_segment&(word_cnt<5);
logic req_ready_fifo_rd = req_fifo_rd&(word_cnt==4);
logic req_ready_fifo_ipsec;
logic req_ready_fifo_ipsec_d1;
logic req_ready_fifo_l2_gre;
logic req_ready_fifo_l2_gre_d1;

logic req_ready_fifo_rd_d1;
logic req_pending_fifo_wr = req_ready_fifo_rd_d1;

logic [`RCI_NBITS-1:0] rci;
logic [KEY_NBITS-1:0] key;
logic rci_valid;
logic ekey_valid;

logic en_port_data;
logic req_pending_fifo_empty;
logic set_en_port_data = my_segment&~req_pending_fifo_empty&(word_cnt==0);
logic req_pending_fifo_rd = my_segment&~req_pending_fifo_empty&(word_cnt==4);

logic out_fifo_eop;
logic out_fifo_good;
logic out_fifo_empty;
logic out_fifo_rd = en_port_data&~out_fifo_empty;

logic [PBUS_NBITS-1:0] out_fifo_data;
logic [PBUS_VB_NBITS-1:0] out_fifo_valid_bytes;    
logic out_fifo_error; 

logic out_fifo_wr = in_fifo_rd&~header_en; 

logic rci_fifo_rd = out_fifo_rd&out_fifo_eop;

logic [16-1:0] out_fifo_data_save;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		decr_ring_out_data <= my_segment&(word_cnt<5)?req_fifo_rdata:decr_ring_in_data_d2;
		decr_ring_out_sof <= decr_ring_in_sof_d2;
		decr_ring_out_sos <= decr_ring_in_sos_d2;

		dec_aggr_packet_data <= rci_fifo_l2_gre?{out_fifo_data_save, out_fifo_data[31:16]}:out_fifo_data;
		dec_aggr_sop <= ~inner_header_en&inner_header_en_d1;
		dec_aggr_eop <= out_fifo_eop;
		dec_aggr_valid_bytes <= out_fifo_valid_bytes;
		dec_aggr_rci <= rci_fifo_rci;
		dec_aggr_error <= ~out_fifo_good|~rci_fifo_valid;
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		dec_aggr_data_valid <= 1'b0;

	end else begin
		dec_aggr_data_valid <= out_fifo_rd&~inner_header_en;

	end

/***************************** PROGRAM BODY **********************************/

logic `RESET_SIG_MAC;
synchronizer u_synchronizer(.clk(clk_mac), .din(`RESET_SIG), .dout(`RESET_SIG_MAC));

always @(*) begin
	rx_axis_valid_bytes = 0;
	case (1'b1)
		rx_axis_tkeep_d1[0]: rx_axis_valid_bytes = 0;
		rx_axis_tkeep_d1[1]: rx_axis_valid_bytes = 3;
		rx_axis_tkeep_d1[2]: rx_axis_valid_bytes = 2;
		rx_axis_tkeep_d1[3]: rx_axis_valid_bytes = 1;
	endcase
end

always @(posedge clk_mac) begin
		rx_axis_tdata_d1 <= rx_axis_tdata;
		rx_axis_tuser_d1 <= rx_axis_tuser;
		rx_axis_tlast_d1 <= rx_axis_tlast;
end

always @(posedge clk) begin

		decr_ring_in_data_d1 <= decr_ring_in_data;
		decr_ring_in_sof_d1 <= decr_ring_in_sof;
		decr_ring_in_sos_d1 <= decr_ring_in_sos;

		decr_ring_in_data_d2 <= decr_ring_in_data_d1;
		decr_ring_in_sof_d2 <= decr_ring_in_sof_d1;
		decr_ring_in_sos_d2 <= decr_ring_in_sos_d1;

		in_fifo_data_save <= in_fifo_rd?in_fifo_data[15:0]:in_fifo_data_save;
		in_fifo_data_ip_d1 <= in_fifo_rd?in_fifo_data_ip:in_fifo_data_ip_d1;

		out_fifo_data_save <= out_fifo_rd?out_fifo_data[15:0]:out_fifo_data_save;

		{ekey_valid, rci_valid, rci} <= en_port_data?decr_ring_in_data_d2[33:0]:{ekey_valid, rci_valid, rci};
		key[255:192] <= my_segment&~req_pending_fifo_empty&(word_cnt==1)?decr_ring_in_data_d2:key[255:192];
		key[191:128] <= my_segment&~req_pending_fifo_empty&(word_cnt==2)?decr_ring_in_data_d2:key[191:128];
		key[127:64] <= my_segment&~req_pending_fifo_empty&(word_cnt==3)?decr_ring_in_data_d2:key[127:64];
		key[63:0] <= req_pending_fifo_rd?decr_ring_in_data_d2:key[63:0];
end

always @(`CLK_RST_MAC) 
    if (`ACTIVE_RESET_MAC) begin
		rx_axis_tvalid_d1 <= 1'b0;
	end else begin
		rx_axis_tvalid_d1 <= rx_axis_tvalid;
	end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		in_fifo_sop <= 1'b1;
		segment_cnt <= 0;
		word_cnt <= 0;

		even <= 1'b1;
		pkt_len <= 0;

		vlan_tagged <= 0;
		ipv4 <= 0;
		ipv6 <= 0;

		ip_en <= 0;
		ip_en_total <= 0;
		spi_en <= 0;
		header_en <= 1'b1;

		ipsec <= 1'b0;
		ah_len <= 0;
		l2_gre <= 1'b0;

		req_ready_fifo_rd_d1 <= 1'b0;
		req_ready_fifo_ipsec_d1 <= 1'b0;
		req_ready_fifo_l2_gre_d1 <= 1'b0;

		en_port_data <= 1'b0;

		inner_pkt_len <= 0;
		inner_vlan_tagged <= 0;
		inner_header_en <= 1'b1;
		inner_header_en_d1 <= 1'b1;

	end else begin
		in_fifo_sop <= in_fifo_rd&in_fifo_eop?1'b1:out_fifo_wr?1'b0:in_fifo_sop;
		segment_cnt <= decr_ring_in_sof_d1?0:decr_ring_in_sos_d1?segment_cnt+1:segment_cnt;
		word_cnt <= my_segment?word_cnt+1:0;

		even <= ~en_req_fifo_wr?even:~even;
		pkt_len <= ~in_fifo_rd?pkt_len:pkt_len+PORT_BUS_NBYTES;

		vlan_tagged <= ~in_fifo_rd?vlan_tagged:(pkt_len==TYPE_LOC)&(in_fifo_data[31:16]==VLAN_TYPE)?1'b1:in_fifo_eop?1'b0:vlan_tagged;
		ipv4 <= ~in_fifo_rd?ipv4:(pkt_len==ether_type_loc)&(in_fifo_data[31:16]==IPV4_TYPE)?1'b1:in_fifo_eop?1'b0:ipv4;
		ipv6 <= ~in_fifo_rd?ipv6:(pkt_len==ether_type_loc)&(in_fifo_data[31:16]==IPV6_TYPE)?1'b1:in_fifo_eop?1'b0:ipv6;

		ip_en <= ~in_fifo_rd?ip_en:(pkt_len==ip_loc_1st)?1'b1:(pkt_len==ip_loc_lst)?1'b0:ip_en;
		ip_en_total <= ~in_fifo_rd?ip_en_total:(pkt_len==ip_loc_1st)?1'b1:(pkt_len==ip_loc_total_lst)?1'b0:ip_en_total;
		spi_en <= ~in_fifo_rd?spi_en:(pkt_len==spi_loc)?1'b1:(pkt_len==spi_loc+4)?1'b0:spi_en;
		header_en <= ~in_fifo_rd?header_en:(pkt_len==header_loc)?1'b0:in_fifo_eop?1'b1:header_en;

		ipsec <= ~in_fifo_rd?ipsec:(pkt_len==protocol_loc)&((ipv4?in_fifo_data[7:0]:in_fifo_data[31:24])==IPSEC_AH_PROTOCOL_NUM)?1'b1:in_fifo_eop?1'b0:ipsec;
		ah_len <= ~in_fifo_rd?ah_len:ipsec&(pkt_len==ah_len_loc)?in_fifo_data[7:0]:in_fifo_eop?0:ah_len;
		l2_gre <= ~in_fifo_rd?l2_gre:(pkt_len==gre_protocol_loc)&(in_fifo_data[31:16]==GRE_PROTOCOL_TYPE_L2)?1'b1:in_fifo_eop?1'b0:l2_gre;

		req_ready_fifo_rd_d1 <= req_ready_fifo_rd;
		req_ready_fifo_ipsec_d1 <= req_ready_fifo_ipsec;
		req_ready_fifo_l2_gre_d1 <= req_ready_fifo_l2_gre;

		en_port_data <= set_en_port_data?1'b1:rci_fifo_rd?1'b0:en_port_data;

		inner_pkt_len <= ~out_fifo_rd?inner_pkt_len:inner_pkt_len+PORT_BUS_NBYTES;
		inner_vlan_tagged <= ~out_fifo_rd?inner_vlan_tagged:(inner_pkt_len==TYPE_LOC)&(out_fifo_data[31:16]==VLAN_TYPE)?1'b1:out_fifo_eop?1'b0:inner_vlan_tagged;
		inner_header_en <= ~out_fifo_rd?inner_header_en:(inner_pkt_len==inner_header_loc)?1'b0:out_fifo_eop?1'b1:inner_header_en;
		inner_header_en_d1 <= ~out_fifo_rd?inner_header_en:inner_header_en_d1;

	end

 
decap_ip #(128, KEY_NBITS) u_decap_ip (

	.clk(clk), 
	.`RESET_SIG(`RESET_SIG),

	.cybertext_data({(128){1'b0}}),
	.key(key),
	.decrypt_request(1'b0),

	.plaintext_data(),
	.decrypt_complete(decrypt_complete)

);


afifo16f #(PBUS_NBITS+PBUS_VB_NBITS+2) u_afifo16f(
        .clk_r(clk),
        .reset_r(`ACTIVE_RESET),

        .clk_w(clk_mac),
        .reset_w(`ACTIVE_RESET_MAC),

        .din({rx_axis_tdata_d1, rx_axis_valid_bytes, rx_axis_tuser_d1, rx_axis_tlast_d1}),               
        .rd(in_fifo_rd),
        .wr(rx_axis_tvalid_d1),

        .count_r(),
        .count_w(),
        .full(),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({in_fifo_data, in_fifo_valid_bytes, in_fifo_good, in_fifo_eop})       
    );


sfifo2f_fo #(RING_NBITS, REQ_FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
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

sfifo2f1 #(2) u_sfifo2f1_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({ipsec, l2_gre}),               
        .rd(req_ready_fifo_rd),
        .wr(req_ready_fifo_wr),

        .count(),
        .full(),
        .empty(req_ready_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({req_ready_fifo_ipsec, req_ready_fifo_l2_gre})       
    );


sfifo2f1 #(2) u_sfifo2f1_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({req_ready_fifo_ipsec_d1, req_ready_fifo_l2_gre_d1}),               
        .rd(req_pending_fifo_rd),
        .wr(req_pending_fifo_wr),

        .count(),
        .full(),
        .empty(req_pending_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({req_pending_fifo_ipsec, req_pending_fifo_l2_gre})       
    );

sfifo2f1 #(3+`RCI_NBITS) u_sfifo2f1_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({req_pending_fifo_ipsec, req_pending_fifo_l2_gre, ((~req_pending_fifo_ipsec|ekey_valid)&rci_valid), rci}),               
        .rd(rci_fifo_rd),
        .wr(req_pending_fifo_rd),

        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({rci_fifo_ipsec, rci_fifo_l2_gre, rci_fifo_valid, rci_fifo_rci})       
    );

sfifo2f_fo #(PBUS_NBITS+PBUS_VB_NBITS+2, OUT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

	.din({in_fifo_data_ip, in_fifo_valid_bytes, in_fifo_good, in_fifo_eop}),      
        .rd(out_fifo_rd),
        .wr(out_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(out_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({out_fifo_data, out_fifo_valid_bytes, out_fifo_good, out_fifo_eop})       
    );


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

