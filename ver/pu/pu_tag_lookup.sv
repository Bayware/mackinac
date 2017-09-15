//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module pu_tag_lookup #(
parameter TAG_NBITS = `TAG_NBITS,
parameter TAG_DEPTH_NBITS = `TAG_HASH_TABLE_DEPTH_NBITS,
parameter TAG_HASH_NBITS = `TAG_HASH_TABLE_DEPTH_NBITS,
parameter TAG_ENTRY_NBITS = `TAG_HASH_ENTRY_NBITS,
parameter TAG_BUCKET_NBITS = `TAG_HASH_BUCKET_NBITS,
parameter TAG_VALUE_NBITS = `TAG_VALUE_NBITS,
parameter TAG_VALUE_PAYLOAD_NBITS = `TAG_VALUE_PAYLOAD_NBITS,
parameter TAG_VALUE_DEPTH_NBITS = `TAG_VALUE_DEPTH_NBITS,
parameter TAG_KEY_NBITS = `TAG_KEY_NBITS
) (

input clk, 
input `RESET_SIG,

input tag_key_valid, 
input [TAG_KEY_NBITS-1:0] tag_key,
input [`PU_ID_NBITS-1:0] tag_pid,

input tag_hash_table0_ack, 
input [TAG_BUCKET_NBITS-1:0] tag_hash_table0_rdata  /* synthesis keep = 1 */,

input tag_hash_table1_ack, 
input [TAG_BUCKET_NBITS-1:0] tag_hash_table1_rdata  /* synthesis keep = 1 */,

input tag_value_ack, 
input [TAG_VALUE_NBITS-1:0] tag_value_rdata, /* synthesis keep = 1 */

output logic tag_lookup_valid,
output logic [`RCI_NBITS-1:0] tag_lookup_result,
output logic [`PU_ID_NBITS-1:0] tag_lookup_result_pid,
output logic [2:0] tag_lookup_result_num,

output logic tag_lookup_status_valid,
output logic [3:0] tag_lookup_status,
output logic [`PU_ID_NBITS-1:0] tag_lookup_status_pid,

output logic tag_hash_table0_rd, 
output logic [TAG_DEPTH_NBITS-1:0] tag_hash_table0_raddr,

output logic tag_hash_table1_rd, 
output logic [TAG_DEPTH_NBITS-1:0] tag_hash_table1_raddr,

output logic tag_value_rd, 
output logic [TAG_VALUE_DEPTH_NBITS-1:0] tag_value_raddr

);

/***************************** LOCAL VARIABLES *******************************/

logic tag_key_valid_d1;

logic tag_value_ack_d1; 
logic [TAG_VALUE_NBITS-1:0] tag_value_rdata_d1;

logic [5:0] tag_hash0;
logic [5:0] tag_hash1;

logic [TAG_BUCKET_NBITS-1:0] tag_hash_table0_rdata_sv;
logic [TAG_BUCKET_NBITS-1:0] tag_hash_table1_rdata_sv;

logic [2:0] tag_value_rd_cnt;
wire last_tag_value_rd_cnt = &tag_value_rd_cnt;

logic ht_fifo_empty;
wire tag_value_rd_p1 = ~ht_fifo_empty;
wire ht_fifo_rd = tag_value_rd_p1&last_tag_value_rd_cnt;

logic [2:0] tag_value_ack_cnt;
wire last_tag_value_ack_cnt = &tag_value_ack_cnt;

logic [`PU_ID_NBITS-1:0] latency_fifo_tag_pid;
logic [TAG_KEY_NBITS-1:0] latency_fifo_tag_key;

wire tag_hash_compare = latency_fifo_tag_key==tag_value_rdata_d1[`TAG_VALUE_KEY];

wire tag_lookup_valid_p1 = tag_value_ack_d1&tag_hash_compare&(tag_value_rdata_d1[`TAG_VALUE_PAYLOAD]!=0);
wire tag_lookup_status_valid_p1 = tag_value_ack_d1&last_tag_value_ack_cnt;

wire latency_fifo_rd = tag_lookup_status_valid_p1;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin

		tag_hash_table0_raddr <= tag_hash0[TAG_DEPTH_NBITS-1:0];
		tag_hash_table1_raddr <= tag_hash1[TAG_DEPTH_NBITS-1:0];

		case (tag_value_rd_cnt)
			3'b000: tag_value_raddr <= tag_hash_table0_rdata_sv[TAG_ENTRY_NBITS*1-1:TAG_ENTRY_NBITS*0+TAG_HASH_NBITS];
			3'b001: tag_value_raddr <= tag_hash_table0_rdata_sv[TAG_ENTRY_NBITS*2-1:TAG_ENTRY_NBITS*1+TAG_HASH_NBITS];
			3'b010: tag_value_raddr <= tag_hash_table0_rdata_sv[TAG_ENTRY_NBITS*3-1:TAG_ENTRY_NBITS*2+TAG_HASH_NBITS];
			3'b011: tag_value_raddr <= tag_hash_table0_rdata_sv[TAG_ENTRY_NBITS*4-1:TAG_ENTRY_NBITS*3+TAG_HASH_NBITS];
			3'b100: tag_value_raddr <= tag_hash_table1_rdata_sv[TAG_ENTRY_NBITS*1-1:TAG_ENTRY_NBITS*0+TAG_HASH_NBITS];
			3'b101: tag_value_raddr <= tag_hash_table1_rdata_sv[TAG_ENTRY_NBITS*2-1:TAG_ENTRY_NBITS*1+TAG_HASH_NBITS];
			3'b110: tag_value_raddr <= tag_hash_table1_rdata_sv[TAG_ENTRY_NBITS*3-1:TAG_ENTRY_NBITS*2+TAG_HASH_NBITS];
			3'b111: tag_value_raddr <= tag_hash_table1_rdata_sv[TAG_ENTRY_NBITS*4-1:TAG_ENTRY_NBITS*3+TAG_HASH_NBITS];
		endcase

		tag_lookup_result <= tag_value_rdata_d1[`TAG_VALUE_PAYLOAD];
		tag_lookup_result_pid <= latency_fifo_tag_pid;
		tag_lookup_status <= tag_lookup_status_valid_p1&tag_lookup_valid_p1?tag_lookup_result_num+1:tag_lookup_result_num;
		tag_lookup_status_pid <= tag_lookup_status_valid_p1&tag_lookup_valid_p1?latency_fifo_tag_pid:tag_lookup_status_pid;
end


always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		tag_hash_table0_rd <= 1'b0;
		tag_hash_table1_rd <= 1'b0;
		tag_value_rd <= 1'b0;

		tag_lookup_valid <= 1'b0;
		tag_lookup_result_num <= 0;

		tag_lookup_status_valid <= 1'b0;

	end else begin

		tag_hash_table0_rd <= tag_key_valid_d1;
		tag_hash_table1_rd <= tag_key_valid_d1;
		tag_value_rd <= tag_value_rd_p1;

		tag_lookup_valid <= tag_lookup_valid_p1;
		tag_lookup_result_num <= tag_lookup_status_valid_p1?0:tag_lookup_valid_p1?tag_lookup_result_num+1:tag_lookup_result_num;

		tag_lookup_status_valid <= tag_lookup_status_valid_p1;
	end

/***************************** PROGRAM BODY **********************************/


always @(posedge clk) begin

		tag_value_rdata_d1 <= tag_value_rdata;

end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		tag_key_valid_d1 <= 0;

		tag_value_rd_cnt <= 0;

		tag_value_ack_d1 <= 0;

		tag_value_ack_cnt <= 0;

    	end else begin
		tag_key_valid_d1 <= tag_key_valid;

		tag_value_rd_cnt <= ~tag_value_rd_p1?tag_value_rd_cnt:tag_value_rd_cnt+1;

		tag_value_ack_d1 <= tag_value_ack;

		tag_value_ack_cnt <= tag_value_ack_d1?tag_value_ack_cnt+1:tag_value_ack_cnt;
    	end

hash #(`TAG_NBITS, 6) u_hash_0(

	.clk(clk), 
	.key(tag_key), 
	.hash_value(tag_hash0) 

);

logic [TAG_KEY_NBITS-1:0] tp_tag_key;
transpose #(`TAG_NBITS) u_transpose(.in(tag_key), .out(tp_tag_key));

hash #(`TAG_NBITS, 6) u_hash_1(

	.clk(clk), 
	.key(tp_tag_key), 
	.hash_value(tag_hash1) 

);

sfifo2f_fo #(`PU_ID_NBITS+TAG_KEY_NBITS, 4) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({tag_pid, tag_key}),
        .rd(latency_fifo_rd),
        .wr(tag_key_valid),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({latency_fifo_tag_pid, latency_fifo_tag_key})
    );

sfifo2f_fo #(TAG_BUCKET_NBITS*2, 1) u_sfifo2f_fo_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({tag_hash_table0_rdata, tag_hash_table1_rdata}),
        .rd(ht_fifo_rd),
        .wr(tag_hash_table0_ack),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({tag_hash_table0_rdata_sv, tag_hash_table1_rdata_sv})
    );


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

