//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module encap_lookup #(
parameter RING_NBITS = 128,
parameter TUNNEL_DEPTH_NBITS = `TUNNEL_HASH_TABLE_DEPTH_NBITS,
parameter TUNNEL_HASH_NBITS = `TUNNEL_HASH_TABLE_DEPTH_NBITS,
parameter TUNNEL_ENTRY_NBITS = `TUNNEL_HASH_ENTRY_NBITS,
parameter TUNNEL_BUCKET_NBITS = `TUNNEL_HASH_BUCKET_NBITS,
parameter TUNNEL_VALUE_NBITS = `TUNNEL_VALUE_NBITS,
parameter TUNNEL_VALUE_PAYLOAD_NBITS = `TUNNEL_VALUE_PAYLOAD_NBITS,
parameter TUNNEL_VALUE_DEPTH_NBITS = `TUNNEL_VALUE_DEPTH_NBITS,
parameter TUNNEL_KEY_NBITS = `TUNNEL_KEY_NBITS,
parameter EEKEY_DEPTH_NBITS = `EEKEY_HASH_TABLE_DEPTH_NBITS,
parameter EEKEY_HASH_NBITS = `EEKEY_HASH_TABLE_DEPTH_NBITS,
parameter EEKEY_ENTRY_NBITS = `EEKEY_HASH_ENTRY_NBITS,
parameter EEKEY_BUCKET_NBITS = `EEKEY_HASH_BUCKET_NBITS,
parameter EEKEY_VALUE_NBITS = `EEKEY_VALUE_NBITS,
parameter EEKEY_VALUE_PAYLOAD_NBITS = `EEKEY_VALUE_PAYLOAD_NBITS,
parameter EEKEY_VALUE_DEPTH_NBITS = `EEKEY_VALUE_DEPTH_NBITS,
parameter EEKEY_KEY_NBITS = `EEKEY_KEY_NBITS,
parameter EEKEY_SN_NBITS = `SEQUENCE_NUMBER_NBITS,
parameter WR_NBITS = EEKEY_SN_NBITS+`SPI_NBITS
) (

input clk, 
input `RESET_SIG,

input [RING_NBITS-1:0] encr_ring_in_data,
input encr_ring_in_sof,
input encr_ring_in_sos,
input encr_ring_in_valid,

input tunnel_hash_table0_ack, 
input [TUNNEL_BUCKET_NBITS-1:0] tunnel_hash_table0_rdata,

input tunnel_hash_table1_ack, 
input [TUNNEL_BUCKET_NBITS-1:0] tunnel_hash_table1_rdata,

input tunnel_value_ack, 
input [TUNNEL_VALUE_NBITS-1:0] tunnel_value_rdata,

input ekey_hash_table0_ack, 
input [EEKEY_BUCKET_NBITS-1:0] ekey_hash_table0_rdata,

input ekey_hash_table1_ack, 
input [EEKEY_BUCKET_NBITS-1:0] ekey_hash_table1_rdata,

input ekey_value_ack, 
input [EEKEY_VALUE_NBITS-1:0] ekey_value_rdata,

output logic tunnel_hash_table0_rd, 
output logic [TUNNEL_DEPTH_NBITS-1:0] tunnel_hash_table0_raddr,

output logic tunnel_hash_table1_rd, 
output logic [TUNNEL_DEPTH_NBITS-1:0] tunnel_hash_table1_raddr,

output logic tunnel_value_rd, 
output logic [TUNNEL_VALUE_DEPTH_NBITS-1:0] tunnel_value_raddr,

output logic ekey_hash_table0_rd, 
output logic [EEKEY_DEPTH_NBITS-1:0] ekey_hash_table0_raddr,

output logic ekey_hash_table1_rd, 
output logic [EEKEY_DEPTH_NBITS-1:0] ekey_hash_table1_raddr,

output logic ekey_value_rd, 
output logic [EEKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_raddr,

output logic ekey_value_wr, 
output logic [EEKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_waddr,
output logic [WR_NBITS-1:0] ekey_value_wdata,

output logic [RING_NBITS-1:0] encr_ring_out_data,
output logic encr_ring_out_sof,
output logic encr_ring_out_sos,
output logic encr_ring_out_valid

);

/***************************** LOCAL VARIABLES *******************************/
logic [RING_NBITS-1:0] encr_ring_in_data_d1;
logic encr_ring_in_sof_d1;
logic encr_ring_in_sos_d1;
logic encr_ring_in_valid_d1;

logic [RING_NBITS-1:0] encr_ring_in_data_d2;
logic encr_ring_in_sof_d2;
logic encr_ring_in_sos_d2;
logic encr_ring_in_valid_d2;

logic [4:1] tunnel_hash_table0_ack_d;
logic [TUNNEL_BUCKET_NBITS-1:0] tunnel_hash_table0_rdata_d1;

logic tunnel_hash_table1_ack_d1;
logic [TUNNEL_BUCKET_NBITS-1:0] tunnel_hash_table1_rdata_d1;

logic tunnel_value_ack_d1; 
logic tunnel_value_ack_d2; 
logic [TUNNEL_VALUE_NBITS-1:0] tunnel_value_rdata_d1;

logic [4:1] ekey_hash_table0_ack_d;
logic [EEKEY_BUCKET_NBITS-1:0] ekey_hash_table0_rdata_d1;

logic ekey_hash_table1_ack_d1;
logic [EEKEY_BUCKET_NBITS-1:0] ekey_hash_table1_rdata_d1;

logic ekey_value_ack_d1; 
logic ekey_value_ack_d2; 
logic [EEKEY_VALUE_NBITS-1:0] ekey_value_rdata_d1;

logic [2:0] segment_count;
logic [2:0] word_count;
wire last_word_count = word_count==4;
wire last_word_count_m1 = word_count==3;
wire last_segment_count = segment_count==5;

logic [4:0] in_frame_count;
logic [2:0] in_segment_count;
logic [2:0] in_word_count;
wire last_in_word_count = in_word_count==4;
wire last_in_segment_count = in_segment_count==5;

wire [TUNNEL_KEY_NBITS-1:0] tunnel_key = encr_ring_in_data_d2;
wire tunnel_key_valid = encr_ring_in_valid_d2;

logic in_fifo_empty;
logic [2:0] in_fifo_segment_count;
logic [TUNNEL_KEY_NBITS-1:0] in_fifo_tunnel_key;
logic in_fifo_tunnel_key_valid;

logic ring_ready;

wire in_fifo_wr = ring_ready&in_word_count==0&encr_ring_in_valid_d2;
logic [4:1] in_fifo_rd_d;
wire in_fifo_rd = ~in_fifo_empty&~(|in_fifo_rd_d[4:1]);

logic [TUNNEL_DEPTH_NBITS-1:0] tunnel_hash0;
logic [TUNNEL_DEPTH_NBITS-1:0] tunnel_hash1;
logic [EEKEY_DEPTH_NBITS-1:0] ekey_hash0;
logic [EEKEY_DEPTH_NBITS-1:0] ekey_hash1;

logic [2:0] latency_fifo_segment_count;
logic [TUNNEL_KEY_NBITS-1:0] latency_fifo_tunnel_key;
logic latency_fifo_tunnel_key_valid;

logic [2:0] ekey_latency_fifo_segment_count;
logic ekey_latency_fifo_tunnel_lookup_valid;
logic ekey_latency_fifo_tunnel_key_valid;
logic [TUNNEL_VALUE_PAYLOAD_NBITS-1:0] ekey_latency_fifo_tunnel_lookup_result;

logic [1:0] tunnel_value_ack_cnt;
logic [1:0] ekey_value_ack_cnt;

logic [3:0] tunnel_hash_valid;
logic [3:0] ekey_hash_valid;

wire tunnel_hash_compare = tunnel_hash_valid[tunnel_value_ack_cnt]&(latency_fifo_tunnel_key==tunnel_value_rdata_d1[`TUNNEL_VALUE_KEY]);

wire [`SPI_NBITS-1:0] ekey_latency_fifo_ekey_key = ekey_latency_fifo_tunnel_lookup_result[`TUNNEL_VALUE_SPI];
wire [`SPI_NBITS-1:0] ekey_value_key = ekey_value_rdata_d1[`EEKEY_VALUE_KEY];
wire ekey_hash_compare = ekey_hash_valid[ekey_value_ack_cnt]&(ekey_latency_fifo_ekey_key==ekey_value_key);

logic tunnel_lookup_valid;
logic ekey_lookup_valid;

logic [TUNNEL_VALUE_PAYLOAD_NBITS-1:0] tunnel_lookup_result;
logic [EEKEY_VALUE_PAYLOAD_NBITS-1:0] ekey_lookup_result;

logic [2:0] pending_fifo_segment_count;
logic pending_fifo_tunnel_key_valid;
logic pending_fifo_tunnel_valid;
logic [TUNNEL_VALUE_PAYLOAD_NBITS-1:0] pending_fifo_tunnel_result;
logic pending_fifo_ekey_valid;
logic [EEKEY_VALUE_PAYLOAD_NBITS-1:0] pending_fifo_ekey_result;

logic latency_fifo_rd_d1;
logic valid_fifo_empty;
logic latency_fifo_empty;
wire latency_fifo_rd = ~valid_fifo_empty&~latency_fifo_empty&tunnel_value_ack_d2&~tunnel_value_ack_d1;
logic ekey_latency_fifo_empty;
logic ekey_valid_fifo_empty;
wire ekey_latency_fifo_rd = ~ekey_valid_fifo_empty&~ekey_latency_fifo_empty&ekey_value_ack_d2&~ekey_value_ack_d1;
wire pending_fifo_wr = ekey_latency_fifo_rd;

logic pending_fifo_empty;

wire [2:0] n_segment_count = !last_word_count?segment_count:last_segment_count?0:segment_count+1;
wire en_out = ~pending_fifo_empty&(pending_fifo_segment_count==n_segment_count);
wire set_enable_out = en_out&last_word_count;
logic enable_out;

wire pending_fifo_rd = en_out&last_word_count_m1;

assign tunnel_hash_valid[0] = tunnel_hash_table0_rdata_d1[TUNNEL_ENTRY_NBITS*1-1];
assign tunnel_hash_valid[1] = tunnel_hash_table0_rdata_d1[TUNNEL_ENTRY_NBITS*2-1];
assign tunnel_hash_valid[2] = tunnel_hash_table1_rdata_d1[TUNNEL_ENTRY_NBITS*1-1];
assign tunnel_hash_valid[3] = tunnel_hash_table1_rdata_d1[TUNNEL_ENTRY_NBITS*2-1];

assign ekey_hash_valid[0] = ekey_hash_table0_rdata_d1[EEKEY_ENTRY_NBITS*1-1];
assign ekey_hash_valid[1] = ekey_hash_table0_rdata_d1[EEKEY_ENTRY_NBITS*2-1];
assign ekey_hash_valid[2] = ekey_hash_table1_rdata_d1[EEKEY_ENTRY_NBITS*1-1];
assign ekey_hash_valid[3] = ekey_hash_table1_rdata_d1[EEKEY_ENTRY_NBITS*2-1];

wire valid_fifo_wr = tunnel_hash_table0_ack_d[2];
logic [3:0] valid_fifo_tunnel_valid;
wire ekey_valid_fifo_wr = ekey_hash_table0_ack_d[2];
logic [3:0] ekey_valid_fifo_ekey_valid;

wire valid_fifo_rd = latency_fifo_rd;
wire ekey_valid_fifo_rd = ekey_latency_fifo_rd;

wire ekey_latency_fifo_wr = latency_fifo_rd;

wire n_ekey_value_wr = ekey_value_ack_d1&ekey_valid_fifo_ekey_valid[ekey_value_ack_cnt]&ekey_hash_compare;

wire [`SEQUENCE_NUMBER_NBITS-1:0] ekey_value_sn_p1 = ekey_value_rdata_d1[`EEKEY_VALUE_SN]+1;

wire n_ekey_value_rd = |ekey_hash_table0_ack_d;

wire [EEKEY_VALUE_DEPTH_NBITS-1:0] n_ekey_value_raddr = ekey_hash_table0_ack_d[1]?
			ekey_hash_table0_rdata_d1[EEKEY_ENTRY_NBITS*1-1-1:EEKEY_ENTRY_NBITS*0+EEKEY_HASH_NBITS]:
				ekey_hash_table0_ack_d[2]?
			ekey_hash_table0_rdata_d1[EEKEY_ENTRY_NBITS*2-1-1:EEKEY_ENTRY_NBITS*1+EEKEY_HASH_NBITS]:
				ekey_hash_table0_ack_d[3]?
			ekey_hash_table1_rdata_d1[EEKEY_ENTRY_NBITS*1-1-1:EEKEY_ENTRY_NBITS*0+EEKEY_HASH_NBITS]:
			ekey_hash_table1_rdata_d1[EEKEY_ENTRY_NBITS*2-1-1:EEKEY_ENTRY_NBITS*1+EEKEY_HASH_NBITS];

logic [EEKEY_VALUE_DEPTH_NBITS-1:0] raddr_fifo_data;
logic raddr_fifo_empty;
wire raddr_fifo_rd = ~raddr_fifo_empty&ekey_value_ack_d1;

wire [EEKEY_KEY_NBITS-1:0] ekey_key = tunnel_lookup_result[`TUNNEL_VALUE_SPI];

//wire [EEKEY_KEY_NBITS-1:0] pending_fifo_ekey_result_ekey = pending_fifo_ekey_result[`EEKEY_VALUE_EKEY];

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		if (~enable_out) 
			encr_ring_out_data <= 0;
		else
			case (word_count)
				3'd4: encr_ring_out_data <= pending_fifo_ekey_valid?pending_fifo_ekey_result[RING_NBITS*1-1:RING_NBITS*0]:128'b0;
				3'd0: encr_ring_out_data <= pending_fifo_ekey_valid?pending_fifo_ekey_result[RING_NBITS*2-1:RING_NBITS]:128'b0;
				3'd1: encr_ring_out_data <= pending_fifo_tunnel_valid?pending_fifo_tunnel_result[`TUNNEL_VALUE_IP_SA]:128'b0;
				3'd2: encr_ring_out_data <= pending_fifo_tunnel_valid?pending_fifo_tunnel_result[`TUNNEL_VALUE_IP_DA]:128'b0;
				default: encr_ring_out_data <= {(pending_fifo_tunnel_valid?pending_fifo_tunnel_result[`TUNNEL_VALUE_MAC]:48'b0), 
								(pending_fifo_tunnel_valid?pending_fifo_tunnel_result[`TUNNEL_VALUE_VLAN]:16'b0), 
								(pending_fifo_tunnel_valid?pending_fifo_tunnel_result[`TUNNEL_VALUE_SPI]:32'b0), 
								(pending_fifo_ekey_valid?pending_fifo_ekey_result[`EEKEY_VALUE_SN]:32'b0)};
			endcase

		tunnel_hash_table0_raddr <= tunnel_hash0;
		tunnel_hash_table1_raddr <= tunnel_hash1;

		tunnel_value_raddr <= tunnel_hash_table0_ack_d[1]?
			tunnel_hash_table0_rdata_d1[TUNNEL_ENTRY_NBITS*1-1-1:TUNNEL_ENTRY_NBITS*0+TUNNEL_HASH_NBITS]:
				tunnel_hash_table0_ack_d[2]?
			tunnel_hash_table0_rdata_d1[TUNNEL_ENTRY_NBITS*2-1-1:TUNNEL_ENTRY_NBITS*1+TUNNEL_HASH_NBITS]:
				tunnel_hash_table0_ack_d[3]?
			tunnel_hash_table1_rdata_d1[TUNNEL_ENTRY_NBITS*1-1-1:TUNNEL_ENTRY_NBITS*0+TUNNEL_HASH_NBITS]:
			tunnel_hash_table1_rdata_d1[TUNNEL_ENTRY_NBITS*2-1-1:TUNNEL_ENTRY_NBITS*1+TUNNEL_HASH_NBITS];

		ekey_hash_table0_raddr <= ekey_hash0;
		ekey_hash_table1_raddr <= ekey_hash1;

		ekey_value_raddr <= n_ekey_value_raddr;

		ekey_value_waddr <= raddr_fifo_data;
		ekey_value_wdata <= {ekey_value_sn_p1, ekey_value_key};
end


always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		encr_ring_out_sof <= 0;
		encr_ring_out_sos <= 0;
		encr_ring_out_valid <= 0;

		tunnel_hash_table0_rd <= 1'b0;
		tunnel_hash_table1_rd <= 1'b0;
		tunnel_value_rd <= 1'b0;

		ekey_hash_table0_rd <= 1'b0;
		ekey_hash_table1_rd <= 1'b0;
		ekey_value_rd <= 1'b0;
		ekey_value_wr <= 1'b0;

	end else begin

		encr_ring_out_sof <= last_segment_count&last_word_count;
		encr_ring_out_sos <= last_word_count;
		encr_ring_out_valid <= en_out&pending_fifo_tunnel_key_valid;

		tunnel_hash_table0_rd <= in_fifo_rd_d[1];
		tunnel_hash_table1_rd <= in_fifo_rd_d[1];
		tunnel_value_rd <= |tunnel_hash_table0_ack_d;

		ekey_hash_table0_rd <= latency_fifo_rd_d1;
		ekey_hash_table1_rd <= latency_fifo_rd_d1;
		ekey_value_rd <= n_ekey_value_rd;
		ekey_value_wr <= ekey_value_ack_d1&ekey_valid_fifo_ekey_valid[ekey_value_ack_cnt];

	end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin

		encr_ring_in_data_d1 <= encr_ring_in_data;
		encr_ring_in_sof_d1 <= encr_ring_in_sof;
		encr_ring_in_sos_d1 <= encr_ring_in_sos;
		encr_ring_in_valid_d1 <= encr_ring_in_valid;

		encr_ring_in_data_d2 <= encr_ring_in_data_d1;
		encr_ring_in_sof_d2 <= encr_ring_in_sof_d1;
		encr_ring_in_sos_d2 <= encr_ring_in_sos_d1;
		encr_ring_in_valid_d2 <= encr_ring_in_valid_d1;

		tunnel_hash_table0_rdata_d1 <= tunnel_hash_table0_ack?tunnel_hash_table0_rdata:tunnel_hash_table0_rdata_d1;
		tunnel_hash_table1_rdata_d1 <= tunnel_hash_table1_ack?tunnel_hash_table1_rdata:tunnel_hash_table1_rdata_d1;

		tunnel_value_rdata_d1 <= tunnel_value_rdata;

		ekey_hash_table0_rdata_d1 <= ekey_hash_table0_ack?ekey_hash_table0_rdata:ekey_hash_table0_rdata_d1;
		ekey_hash_table1_rdata_d1 <= ekey_hash_table1_ack?ekey_hash_table1_rdata:ekey_hash_table1_rdata_d1;

		ekey_value_rdata_d1 <= ekey_value_rdata;

		tunnel_lookup_result <= tunnel_value_ack_d1&tunnel_hash_compare?tunnel_value_rdata_d1[`TUNNEL_VALUE_PAYLOAD]:tunnel_lookup_result;
		tunnel_lookup_valid <= latency_fifo_rd?1'b0:tunnel_value_ack_d1&valid_fifo_tunnel_valid[tunnel_value_ack_cnt]&tunnel_hash_compare?1'b1:tunnel_lookup_valid;
		ekey_lookup_result <= ekey_value_ack_d1&ekey_hash_compare?ekey_value_rdata_d1[`EEKEY_VALUE_PAYLOAD]:ekey_lookup_result;
		ekey_lookup_valid <= ekey_latency_fifo_rd?1'b0:n_ekey_value_wr?1'b1:ekey_lookup_valid;
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		word_count <= 0;
		segment_count <= 0;
		in_word_count <= 0;
		in_segment_count <= 0;
		in_frame_count <= 0;
		ring_ready <= 0;
		in_fifo_rd_d <= 0;
		latency_fifo_rd_d1 <= 0;

		tunnel_hash_table0_ack_d <= 0;
		tunnel_hash_table1_ack_d1 <= 0;

		tunnel_value_ack_d1 <= 0;
		tunnel_value_ack_d2 <= 0;

		ekey_hash_table0_ack_d <= 0;
		ekey_hash_table1_ack_d1 <= 0;

		ekey_value_ack_d1 <= 0;
		ekey_value_ack_d2 <= 0;

		enable_out <= 0;

		tunnel_value_ack_cnt <= 0;
		ekey_value_ack_cnt <= 0;

    	end else begin
		word_count <= last_word_count?0:word_count+1;
		segment_count <= n_segment_count;
		in_word_count <= encr_ring_in_sos_d1?0:last_in_word_count?0:in_word_count+1;
		in_segment_count <= encr_ring_in_sof_d1?0:!last_in_word_count?in_segment_count:last_in_segment_count?0:in_segment_count+1;
		in_frame_count <= in_frame_count[4]?in_frame_count:last_in_segment_count&last_in_word_count?in_frame_count+1:in_frame_count;
		ring_ready <= in_frame_count[4];
		in_fifo_rd_d <= {in_fifo_rd_d[3:1], in_fifo_rd};
		latency_fifo_rd_d1 <= latency_fifo_rd;

		tunnel_hash_table0_ack_d <= {tunnel_hash_table0_ack_d[3:1], tunnel_hash_table0_ack};
		tunnel_hash_table1_ack_d1 <= tunnel_hash_table1_ack;

		tunnel_value_ack_d1 <= tunnel_value_ack;
		tunnel_value_ack_d2 <= tunnel_value_ack_d1;

		ekey_hash_table0_ack_d <= {ekey_hash_table0_ack_d[3:1], ekey_hash_table0_ack};
		ekey_hash_table1_ack_d1 <= ekey_hash_table1_ack;

		ekey_value_ack_d1 <= ekey_value_ack;
		ekey_value_ack_d2 <= ekey_value_ack_d1;

		enable_out <= set_enable_out?1'b1:enable_out;

		tunnel_value_ack_cnt <= tunnel_value_ack_d1?tunnel_value_ack_cnt+1:tunnel_value_ack_cnt;
		ekey_value_ack_cnt <= ekey_value_ack_d1?ekey_value_ack_cnt+1:ekey_value_ack_cnt;
    	end

hash #(TUNNEL_KEY_NBITS, TUNNEL_DEPTH_NBITS) u_hash_0(

	.clk(clk), 
	.key(in_fifo_tunnel_key), 
	.hash_value(tunnel_hash0) 
);

logic [TUNNEL_KEY_NBITS-1:0] tp_in_fifo_tunnel_key;
transpose #(TUNNEL_KEY_NBITS) u_transpose_0(.in(in_fifo_tunnel_key), .out(tp_in_fifo_tunnel_key));

hash #(TUNNEL_KEY_NBITS, TUNNEL_DEPTH_NBITS) u_hash_1(

	.clk(clk), 
	.key(tp_in_fifo_tunnel_key), 
	.hash_value(tunnel_hash1) 
);

hash #(EEKEY_KEY_NBITS, EEKEY_DEPTH_NBITS) u_hash_2(

	.clk(clk), 
	.key(ekey_key), 
	.hash_value(ekey_hash0) 
);

logic [EEKEY_KEY_NBITS-1:0] tp_ekey_key;
transpose #(EEKEY_KEY_NBITS) u_transpose_1(.in(ekey_key), .out(tp_ekey_key));

hash #(EEKEY_KEY_NBITS, EEKEY_DEPTH_NBITS) u_hash_3(

	.clk(clk), 
	.key(tp_ekey_key), 
	.hash_value(ekey_hash1) 
);

sfifo2f_fo #(3+TUNNEL_KEY_NBITS+1, 3) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({in_segment_count, tunnel_key, tunnel_key_valid}),               
        .rd(in_fifo_rd),
        .wr(in_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({in_fifo_segment_count, in_fifo_tunnel_key, in_fifo_tunnel_key_valid})
    );

sfifo2f_fo #(3+TUNNEL_KEY_NBITS+1, 3) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({in_fifo_segment_count, in_fifo_tunnel_key, in_fifo_tunnel_key_valid}),
        .rd(latency_fifo_rd),
        .wr(in_fifo_rd),

        .ncount(),
        .count(),
        .full(),
        .empty(latency_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({latency_fifo_segment_count, latency_fifo_tunnel_key, latency_fifo_tunnel_key_valid})
    );

sfifo2f_fo #(4, 2) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({tunnel_hash_valid}),
        .rd(valid_fifo_rd),
        .wr(valid_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(valid_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({valid_fifo_tunnel_valid})
    );

sfifo2f_fo #(EEKEY_VALUE_DEPTH_NBITS, 3) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({n_ekey_value_raddr}),
        .rd(raddr_fifo_rd),
        .wr(n_ekey_value_rd),

        .ncount(),
        .count(),
        .full(),
        .empty(raddr_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({raddr_fifo_data})
    );

sfifo2f_fo #(3+1+1+TUNNEL_VALUE_PAYLOAD_NBITS, 3) u_sfifo2f_fo_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({latency_fifo_segment_count, latency_fifo_tunnel_key_valid, tunnel_lookup_valid, tunnel_lookup_result}),
        .rd(ekey_latency_fifo_rd),
        .wr(ekey_latency_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(ekey_latency_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({ekey_latency_fifo_segment_count, ekey_latency_fifo_tunnel_key_valid, ekey_latency_fifo_tunnel_lookup_valid, ekey_latency_fifo_tunnel_lookup_result})
    );

sfifo2f_fo #(4, 2) u_sfifo2f_fo_5(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({ekey_hash_valid}),
        .rd(ekey_valid_fifo_rd),
        .wr(ekey_valid_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(ekey_valid_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({ekey_valid_fifo_ekey_valid})
    );

sfifo2f_fo #(3+1+1+TUNNEL_VALUE_PAYLOAD_NBITS+1+EEKEY_VALUE_PAYLOAD_NBITS, 3) u_sfifo2f_fo_6(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({ekey_latency_fifo_segment_count, ekey_latency_fifo_tunnel_key_valid, ekey_latency_fifo_tunnel_lookup_valid, ekey_latency_fifo_tunnel_lookup_result, ekey_lookup_valid, ekey_lookup_result}),
        .rd(pending_fifo_rd),
        .wr(pending_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(pending_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({pending_fifo_segment_count, pending_fifo_tunnel_key_valid, pending_fifo_tunnel_valid, pending_fifo_tunnel_result, pending_fifo_ekey_valid, pending_fifo_ekey_result})
    );



/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

