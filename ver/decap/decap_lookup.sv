//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module decap_lookup #(
parameter RING_NBITS = 64,
parameter RCI_NBITS = `RCI_NBITS,
parameter RCI_DEPTH_NBITS = `RCI_HASH_TABLE_DEPTH_NBITS,
parameter RCI_HASH_NBITS = `RCI_HASH_TABLE_DEPTH_NBITS,
parameter RCI_ENTRY_NBITS = `RCI_HASH_ENTRY_NBITS,
parameter RCI_BUCKET_NBITS = `RCI_HASH_BUCKET_NBITS,
parameter RCI_VALUE_NBITS = `RCI_VALUE_NBITS,
parameter RCI_VALUE_DEPTH_NBITS = `RCI_VALUE_DEPTH_NBITS,
parameter RCI_KEY_NBITS = `RCI_KEY_NBITS,
parameter EKEY_NBITS = `ENCRYPTION_KEY_NBITS,
parameter EKEY_DEPTH_NBITS = `EKEY_HASH_TABLE_DEPTH_NBITS,
parameter EKEY_HASH_NBITS = `EKEY_HASH_TABLE_DEPTH_NBITS,
parameter EKEY_ENTRY_NBITS = `EKEY_HASH_ENTRY_NBITS,
parameter EKEY_BUCKET_NBITS = `EKEY_HASH_BUCKET_NBITS,
parameter EKEY_VALUE_NBITS = `EKEY_VALUE_NBITS,
parameter EKEY_VALUE_DEPTH_NBITS = `EKEY_VALUE_DEPTH_NBITS,
parameter EKEY_KEY_NBITS = `EKEY_KEY_NBITS,
parameter EKEY_SN_NBITS = `SEQUENCE_NUMBER_NBITS,
parameter WR_NBITS = EKEY_SN_NBITS+`SPI_NBITS
) (

input clk, 
input `RESET_SIG,

input [RING_NBITS-1:0] decr_ring_in_data,
input decr_ring_in_sof,
input decr_ring_in_sos,

input rci_hash_table0_ack, 
input [RCI_BUCKET_NBITS-1:0] rci_hash_table0_rdata  /* synthesis keep = 1 */,

input rci_hash_table1_ack, 
input [RCI_BUCKET_NBITS-1:0] rci_hash_table1_rdata  /* synthesis keep = 1 */,

input rci_value_ack, 
input [RCI_VALUE_NBITS-1:0] rci_value_rdata, /* synthesis keep = 1 */

input ekey_hash_table0_ack, 
input [EKEY_BUCKET_NBITS-1:0] ekey_hash_table0_rdata  /* synthesis keep = 1 */,

input ekey_hash_table1_ack, 
input [EKEY_BUCKET_NBITS-1:0] ekey_hash_table1_rdata  /* synthesis keep = 1 */,

input ekey_value_ack, 
input [EKEY_VALUE_NBITS-1:0] ekey_value_rdata, /* synthesis keep = 1 */

output logic rci_hash_table0_rd, 
output logic [RCI_DEPTH_NBITS-1:0] rci_hash_table0_raddr,

output logic rci_hash_table1_rd, 
output logic [RCI_DEPTH_NBITS-1:0] rci_hash_table1_raddr,

output logic rci_value_rd, 
output logic [RCI_VALUE_DEPTH_NBITS-1:0] rci_value_raddr,

output logic ekey_hash_table0_rd, 
output logic [EKEY_DEPTH_NBITS-1:0] ekey_hash_table0_raddr,

output logic ekey_hash_table1_rd, 
output logic [EKEY_DEPTH_NBITS-1:0] ekey_hash_table1_raddr,

output logic ekey_value_wr, 
output logic [EKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_waddr,
output logic [WR_NBITS-1:0] ekey_value_wdata,

output logic ekey_value_rd, 
output logic [EKEY_VALUE_DEPTH_NBITS-1:0] ekey_value_raddr,

output logic [RING_NBITS-1:0] decr_ring_out_data,
output logic decr_ring_out_sof,
output logic decr_ring_out_sos

);

/***************************** LOCAL VARIABLES *******************************/
logic [RING_NBITS-1:0] decr_ring_in_data_d1;
logic decr_ring_in_sof_d1;
logic decr_ring_in_sos_d1;

logic [RING_NBITS-1:0] decr_ring_in_data_d2;
logic decr_ring_in_sof_d2;
logic decr_ring_in_sos_d2;

logic [4:1] rci_hash_table0_ack_d;
logic [RCI_BUCKET_NBITS-1:0] rci_hash_table0_rdata_sv;

logic rci_hash_table1_ack_d1;
logic [RCI_BUCKET_NBITS-1:0] rci_hash_table1_rdata_sv;

logic rci_value_ack_d1; 
logic rci_value_ack_d2; 
logic [RCI_VALUE_NBITS-1:0] rci_value_rdata_d1;

logic [4:1] ekey_hash_table0_ack_d;
logic [EKEY_BUCKET_NBITS-1:0] ekey_hash_table0_rdata_sv;

logic ekey_hash_table1_ack_d1;
logic [EKEY_BUCKET_NBITS-1:0] ekey_hash_table1_rdata_sv;

logic ekey_value_ack_d1; 
logic ekey_value_ack_d2; 
logic [EKEY_VALUE_NBITS-1:0] ekey_value_rdata_d1;

logic [2:0] segment_count;
logic [2:0] word_count;
logic last_word_count = word_count==4;
logic last_segment_count = segment_count==5;

logic [4:0] in_frame_count;
logic [2:0] in_segment_count;
logic [2:0] in_segment_count_d1;
logic [2:0] in_word_count;
logic last_in_word_count = in_word_count==4;
logic last_in_segment_count = in_segment_count==5;

logic [RCI_KEY_NBITS-1:0] rci_key;
logic [EKEY_KEY_NBITS-1:0] ekey_key;
logic [EKEY_SN_NBITS-1:0] ekey_sn;

logic in_fifo_empty;
logic [2:0] in_fifo_segment_count;
logic [RCI_KEY_NBITS-1:0] in_fifo_rci_key;
logic [EKEY_KEY_NBITS-1:0] in_fifo_ekey_key;
logic [EKEY_SN_NBITS-1:0] in_fifo_ekey_sn;

logic ring_ready;

logic in_fifo_wr = ring_ready&in_word_count==0;
logic [4:1] in_fifo_rd_d;
logic in_fifo_rd = ~in_fifo_empty&~(|in_fifo_rd_d[4:1]);

logic [RCI_DEPTH_NBITS-1:0] rci_hash0;
logic [RCI_DEPTH_NBITS-1:0] rci_hash1;
logic [EKEY_DEPTH_NBITS-1:0] ekey_hash0;
logic [EKEY_DEPTH_NBITS-1:0] ekey_hash1;

logic [2:0] latency_fifo_segment_count;
logic [RCI_KEY_NBITS-1:0] latency_fifo_rci_key;
logic [EKEY_KEY_NBITS-1:0] latency_fifo_ekey_key;
logic [EKEY_SN_NBITS-1:0] latency_fifo_ekey_sn;

logic rci_hash_compare = latency_fifo_rci_key==rci_value_rdata_d1[`RCI_VALUE_KEY];
logic ekey_hash_compare = latency_fifo_ekey_key==ekey_value_rdata_d1[`EKEY_VALUE_KEY];
logic sn_hash_compare = latency_fifo_ekey_sn==ekey_value_rdata_d1[`EKEY_VALUE_SN];

logic [RCI_NBITS-1:0] rci_lookup_result;
logic [EKEY_NBITS-1:0] ekey_lookup_result;

logic [2:0] pending_fifo_segment_count;
logic [RCI_NBITS-1:0] pending_fifo_rci;
logic [EKEY_NBITS-1:0] pending_fifo_ekey;
logic pending_fifo_rci_valid;
logic pending_fifo_ekey_valid;

logic latency_fifo_rd = rci_value_ack_d2&~rci_value_ack_d1;
logic pending_fifo_wr = latency_fifo_rd;

logic n_segment_count = ~last_word_count?segment_count:last_segment_count?0:segment_count+1;
logic set_enable_out = (pending_fifo_segment_count==n_segment_count)&last_word_count;
logic enable_out;

logic pending_fifo_rd = enable_out&last_word_count;

logic [3:0] rci_hash_valid;

assign rci_hash_valid[0] = rci_hash_table0_rdata_sv[RCI_ENTRY_NBITS*1-1];
assign rci_hash_valid[1] = rci_hash_table0_rdata_sv[RCI_ENTRY_NBITS*2-1];
assign rci_hash_valid[2] = rci_hash_table1_rdata_sv[RCI_ENTRY_NBITS*1-1];
assign rci_hash_valid[3] = rci_hash_table1_rdata_sv[RCI_ENTRY_NBITS*2-1];

logic [3:0] ekey_hash_valid;

assign ekey_hash_valid[0] = ekey_hash_table0_rdata_sv[EKEY_ENTRY_NBITS*1-1];
assign ekey_hash_valid[1] = ekey_hash_table0_rdata_sv[EKEY_ENTRY_NBITS*2-1];
assign ekey_hash_valid[2] = ekey_hash_table1_rdata_sv[EKEY_ENTRY_NBITS*1-1];
assign ekey_hash_valid[3] = ekey_hash_table1_rdata_sv[EKEY_ENTRY_NBITS*2-1];

logic valid_fifo_wr = rci_hash_table0_ack_d[2];
logic [3:0] valid_fifo_rci_valid;
logic [3:0] valid_fifo_ekey_valid;

logic [1:0] rci_value_ack_cnt;

logic rci_lookup_valid;
logic ekey_lookup_valid;

logic valid_fifo_rd = latency_fifo_rd;

logic n_ekey_value_wr = ekey_value_ack_d1&valid_fifo_ekey_valid[rci_value_ack_cnt]&ekey_hash_compare&sn_hash_compare;

logic [`SEQUENCE_NUMBER_NBITS-1:0] ekey_value_sn_p1 = ekey_value_rdata_d1[`EKEY_VALUE_SN]+1;
logic [`SPI_NBITS-1:0] ekey_value_key = ekey_value_rdata_d1[`EKEY_VALUE_KEY];

logic n_ekey_value_rd = |ekey_hash_table0_ack_d;

logic [EKEY_VALUE_DEPTH_NBITS-1:0] n_ekey_value_raddr = ekey_hash_table0_ack_d[1]?
			ekey_hash_table0_rdata_sv[EKEY_ENTRY_NBITS*1-1-1:EKEY_ENTRY_NBITS*0+EKEY_HASH_NBITS]:
				ekey_hash_table0_ack_d[2]?
			ekey_hash_table0_rdata_sv[EKEY_ENTRY_NBITS*2-1-1:EKEY_ENTRY_NBITS*1+EKEY_HASH_NBITS]:
				ekey_hash_table0_ack_d[3]?
			ekey_hash_table1_rdata_sv[EKEY_ENTRY_NBITS*1-1-1:EKEY_ENTRY_NBITS*0+EKEY_HASH_NBITS]:
			ekey_hash_table1_rdata_sv[EKEY_ENTRY_NBITS*2-1-1:EKEY_ENTRY_NBITS*1+EKEY_HASH_NBITS];

logic [EKEY_VALUE_DEPTH_NBITS-1:0] raddr_fifo_data;
logic raddr_fifo_rd = ekey_value_ack_d1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		rci_hash_table0_raddr <= rci_hash0;
		rci_hash_table1_raddr <= rci_hash1;

		rci_value_raddr <= rci_hash_table0_ack_d[1]?
			rci_hash_table0_rdata_sv[RCI_ENTRY_NBITS*1-1-1:RCI_ENTRY_NBITS*0+RCI_HASH_NBITS]:
				rci_hash_table0_ack_d[2]?
			rci_hash_table0_rdata_sv[RCI_ENTRY_NBITS*2-1-1:RCI_ENTRY_NBITS*1+RCI_HASH_NBITS]:
				rci_hash_table0_ack_d[3]?
			rci_hash_table1_rdata_sv[RCI_ENTRY_NBITS*1-1-1:RCI_ENTRY_NBITS*0+RCI_HASH_NBITS]:
			rci_hash_table1_rdata_sv[RCI_ENTRY_NBITS*2-1-1:RCI_ENTRY_NBITS*1+RCI_HASH_NBITS];

		ekey_hash_table0_raddr <= ekey_hash0;
		ekey_hash_table1_raddr <= ekey_hash1;

		ekey_value_raddr <= n_ekey_value_raddr;

		ekey_value_waddr <= raddr_fifo_data;
		ekey_value_wdata <= {ekey_value_key, ekey_value_sn_p1};
end


always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		decr_ring_out_data <= 0;
		decr_ring_out_sof <= 0;
		decr_ring_out_sos <= 0;

		rci_hash_table0_rd <= 1'b0;
		rci_hash_table1_rd <= 1'b0;
		rci_value_rd <= 1'b0;
		ekey_hash_table0_rd <= 1'b0;
		ekey_hash_table1_rd <= 1'b0;
		ekey_value_rd <= 1'b0;
		ekey_value_wr <= 1'b0;

	end else begin
		if (~enable_out) 
			decr_ring_out_data <= 0;
		else
			case (word_count)
				3'd0: decr_ring_out_data <= {pending_fifo_ekey_valid, pending_fifo_rci_valid, pending_fifo_rci};
				3'd1: decr_ring_out_data <= pending_fifo_ekey[RING_NBITS*1-1:RING_NBITS*0];
				3'd2: decr_ring_out_data <= pending_fifo_ekey[RING_NBITS*2-1:RING_NBITS*1];
				3'd3: decr_ring_out_data <= pending_fifo_ekey[RING_NBITS*3-1:RING_NBITS*2];
				default: decr_ring_out_data <= pending_fifo_ekey[RING_NBITS*4-1:RING_NBITS*3];
			endcase

		decr_ring_out_sof <= last_segment_count&last_word_count;
		decr_ring_out_sos <= last_word_count;

		rci_hash_table0_rd <= in_fifo_rd_d[1];
		rci_hash_table1_rd <= in_fifo_rd_d[1];
		rci_value_rd <= |rci_hash_table0_ack_d;
		ekey_hash_table0_rd <= in_fifo_rd_d[1];
		ekey_hash_table1_rd <= in_fifo_rd_d[1];
		ekey_value_rd <= n_ekey_value_rd;
		ekey_value_wr <= ekey_value_ack_d1&valid_fifo_ekey_valid[rci_value_ack_cnt];

	end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin

		decr_ring_in_data_d1 <= decr_ring_in_data;
		decr_ring_in_sof_d1 <= decr_ring_in_sof;
		decr_ring_in_sos_d1 <= decr_ring_in_sos;

		decr_ring_in_data_d2 <= decr_ring_in_data_d1;
		decr_ring_in_sof_d2 <= decr_ring_in_sof_d1;
		decr_ring_in_sos_d2 <= decr_ring_in_sos_d1;

		rci_hash_table0_rdata_sv <= rci_hash_table0_ack?rci_hash_table0_rdata:rci_hash_table0_rdata_sv;
		rci_hash_table1_rdata_sv <= rci_hash_table1_ack?rci_hash_table1_rdata:rci_hash_table1_rdata_sv;

		rci_value_rdata_d1 <= rci_value_rdata;

		ekey_hash_table0_rdata_sv <= ekey_hash_table0_ack?ekey_hash_table0_rdata:ekey_hash_table0_rdata_sv;
		ekey_hash_table1_rdata_sv <= ekey_hash_table1_ack?ekey_hash_table1_rdata:ekey_hash_table1_rdata_sv;

		ekey_value_rdata_d1 <= ekey_value_rdata;

		rci_key[RING_NBITS*1-1:RING_NBITS*0] <= in_word_count==0?decr_ring_in_data_d2:rci_key[RING_NBITS*1-1:RING_NBITS*0];
		rci_key[RING_NBITS*2-1:RING_NBITS*1] <= in_word_count==1?decr_ring_in_data_d2:rci_key[RING_NBITS*2-1:RING_NBITS*1];
		rci_key[RING_NBITS*3-1:RING_NBITS*2] <= in_word_count==2?decr_ring_in_data_d2:rci_key[RING_NBITS*3-1:RING_NBITS*2];
		rci_key[RING_NBITS*4-1:RING_NBITS*3] <= in_word_count==3?decr_ring_in_data_d2:rci_key[RING_NBITS*4-1:RING_NBITS*3];
		ekey_key <= in_word_count==4?decr_ring_in_data_d2[RING_NBITS-1:EKEY_SN_NBITS]:ekey_key;
		ekey_sn <= in_word_count==4?decr_ring_in_data_d2[EKEY_SN_NBITS-1:0]:ekey_sn;
		rci_lookup_result <= rci_value_ack_d1&rci_hash_compare?rci_value_rdata_d1[`RCI_VALUE_PAYLOAD]:rci_lookup_result;
		rci_lookup_valid <= latency_fifo_rd?1'b0:rci_value_ack_d1&valid_fifo_rci_valid[rci_value_ack_cnt]&rci_hash_compare?1'b1:rci_lookup_valid;
		ekey_lookup_result <= ekey_value_ack_d1&ekey_hash_compare&sn_hash_compare?ekey_value_rdata_d1[`EKEY_VALUE_PAYLOAD]:ekey_lookup_result;
		ekey_lookup_valid <= latency_fifo_rd?1'b0:n_ekey_value_wr?1'b1:ekey_lookup_valid;
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		word_count <= 0;
		segment_count <= 0;
		in_word_count <= 0;
		in_segment_count <= 0;
		in_segment_count_d1 <= 0;
		in_frame_count <= 0;
		ring_ready <= 0;
		in_fifo_rd_d <= 0;

		rci_hash_table0_ack_d <= 0;
		rci_hash_table1_ack_d1 <= 0;

		rci_value_ack_d1 <= 0;
		rci_value_ack_d2 <= 0;

		ekey_hash_table0_ack_d <= 0;
		ekey_hash_table1_ack_d1 <= 0;

		ekey_value_ack_d1 <= 0;
		ekey_value_ack_d2 <= 0;

		enable_out <= 0;

		rci_value_ack_cnt <= 0;

    	end else begin
		word_count <= last_word_count?0:word_count+1;
		segment_count <= n_segment_count;
		in_word_count <= decr_ring_in_sos_d1?0:last_in_word_count?0:in_word_count+1;
		in_segment_count <= decr_ring_in_sof_d1?0:!last_in_word_count?in_segment_count:last_in_segment_count?0:in_segment_count+1;
		in_segment_count_d1 <= last_in_word_count?in_segment_count:in_segment_count_d1;
		in_frame_count <= in_frame_count[4]?in_frame_count:last_in_segment_count&last_in_word_count?in_frame_count+1:in_frame_count;
		ring_ready <= in_frame_count[4];
		in_fifo_rd_d <= {in_fifo_rd_d[3:1], in_fifo_rd};

		rci_hash_table0_ack_d <= {rci_hash_table0_ack_d[3:1], rci_hash_table0_ack};
		rci_hash_table1_ack_d1 <= rci_hash_table1_ack;

		rci_value_ack_d1 <= rci_value_ack;
		rci_value_ack_d2 <= rci_value_ack_d1;

		ekey_hash_table0_ack_d <= {ekey_hash_table0_ack_d[3:1], ekey_hash_table0_ack};
		ekey_hash_table1_ack_d1 <= ekey_hash_table1_ack;

		ekey_value_ack_d1 <= ekey_value_ack;
		ekey_value_ack_d2 <= ekey_value_ack_d1;

		enable_out <= set_enable_out?1'b1:enable_out;

		rci_value_ack_cnt <= rci_value_ack_d1?rci_value_ack_cnt+1:rci_value_ack_cnt;
    	end

hash #(RCI_KEY_NBITS, RCI_DEPTH_NBITS) u_hash_0(

	.clk(clk), 
	.key(in_fifo_rci_key), 
	.hash_value(rci_hash0) 

);

logic [RCI_KEY_NBITS-1:0] tp_in_fifo_rci_key;
transpose #(RCI_KEY_NBITS) u_transpose_0(.in(in_fifo_rci_key), .out(tp_in_fifo_rci_key));

hash #(RCI_KEY_NBITS, RCI_DEPTH_NBITS) u_hash_1(

	.clk(clk), 
	.key(tp_in_fifo_rci_key), 
	.hash_value(rci_hash1) 

);

hash #(EKEY_KEY_NBITS, EKEY_DEPTH_NBITS) u_hash_2(

	.clk(clk), 
	.key(in_fifo_ekey_key), 
	.hash_value(ekey_hash0) 

);

logic [EKEY_KEY_NBITS-1:0] tp_in_fifo_ekey_key;
transpose #(EKEY_KEY_NBITS) u_transpose_1(.in(in_fifo_ekey_key), .out(tp_in_fifo_ekey_key));

hash #(EKEY_KEY_NBITS, EKEY_DEPTH_NBITS) u_hash_3(

	.clk(clk), 
	.key(tp_in_fifo_ekey_key), 
	.hash_value(ekey_hash1) 

);

sfifo2f_fo #(3+RCI_KEY_NBITS+EKEY_KEY_NBITS+EKEY_SN_NBITS, 3) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({in_segment_count_d1, rci_key, ekey_key, ekey_sn}),               
        .rd(in_fifo_rd),
        .wr(in_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(in_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({in_fifo_segment_count, in_fifo_rci_key, in_fifo_ekey_key, in_fifo_ekey_sn})
    );

sfifo2f_fo #(3+RCI_KEY_NBITS+EKEY_KEY_NBITS+EKEY_SN_NBITS, 3) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({in_fifo_segment_count, in_fifo_rci_key, in_fifo_ekey_key, in_fifo_ekey_sn}),
        .rd(latency_fifo_rd),
        .wr(in_fifo_rd),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({latency_fifo_segment_count, latency_fifo_rci_key, latency_fifo_ekey_key, latency_fifo_ekey_sn})
    );

sfifo2f_fo #(EKEY_VALUE_DEPTH_NBITS, 3) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({n_ekey_value_raddr}),
        .rd(raddr_fifo_rd),
        .wr(n_ekey_value_rd),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({raddr_fifo_data})
    );

sfifo2f_fo #(4+4, 2) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({rci_hash_valid, ekey_hash_valid}),
        .rd(valid_fifo_rd),
        .wr(valid_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({valid_fifo_rci_valid, valid_fifo_ekey_valid})
    );

sfifo2f_fo #(2+3+RCI_NBITS+EKEY_NBITS, 3) u_sfifo2f_fo_4(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({rci_lookup_valid, ekey_lookup_valid, latency_fifo_segment_count, rci_lookup_result, ekey_lookup_result}),
        .rd(pending_fifo_rd),
        .wr(pending_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({pending_fifo_rci_valid, pending_fifo_ekey_valid, pending_fifo_segment_count, pending_fifo_rci, pending_fifo_ekey})
    );


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

