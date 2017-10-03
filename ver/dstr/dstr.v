//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : distributor
//===========================================================================

`include "defines.vh"

module dstr(

input clk, 
input `RESET_SIG,

input ed_dstr_data_valid,
input [`DATA_PATH_RANGE] ed_dstr_packet_data,
input [`PORT_ID_RANGE] ed_dstr_port_id,
input ed_dstr_sop,
input ed_dstr_eop,
input [`RCI_NBITS-1:0] ed_dstr_rci,	
input [`PACKET_LENGTH_NBITS-1:0] ed_dstr_pkt_len,	
input [`DATA_PATH_VB_RANGE] ed_dstr_valid_bytes,	

input [`NUM_OF_PORTS-1:0] port_dstr_bp,


output reg [`NUM_OF_PORTS-1:0] dstr_ed_bp,

output reg dstr_enc_data_valid0,
output reg [`PORT_BUS_RANGE] dstr_enc_packet_data0,
output reg dstr_enc_sop0,
output reg dstr_enc_eop0,
output reg [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes0,	

output reg dstr_enc_data_valid1,
output reg [`PORT_BUS_RANGE] dstr_enc_packet_data1,
output reg dstr_enc_sop1,
output reg dstr_enc_eop1,
output reg [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes1,	

output reg dstr_enc_data_valid2,
output reg [`PORT_BUS_RANGE] dstr_enc_packet_data2,
output reg dstr_enc_sop2,
output reg dstr_enc_eop2,
output reg [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes2,	
output reg dstr_enc_port_id2,

output reg dstr_enc_data_valid3,
output reg [`PORT_BUS_RANGE] dstr_enc_packet_data3,
output reg dstr_enc_sop3,
output reg dstr_enc_eop3,
output reg [`PORT_BUS_VB_RANGE] dstr_enc_valid_bytes3,	
output reg [1:0] dstr_enc_port_id3

);

/***************************** LOCAL VARIABLES *******************************/
localparam EVENT_FIFO_DEPTH_NBITS = 3;
localparam XOFF_LEVEL = 5;
localparam XON_LEVEL = 3;
localparam PORT_BUS_NBYTES_CEILING = `PORT_BUS_NBYTES+1;

reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes0_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes0_p1;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes1_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes1_p1;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes2_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes2_p1;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes3_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes3_p1;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes4_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes4_p1;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes5_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes5_p1;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes6_p2;	
reg [`DATA_PATH_VB_RANGE] dstr_enc_valid_bytes6_p1;	


reg [`NUM_OF_PORTS-1:0] port_dstr_bp_d1;

reg ed_dstr_data_valid_d1;
reg [`DATA_PATH_RANGE] ed_dstr_packet_data_d1;
reg [`PORT_ID_RANGE] ed_dstr_port_id_d1;
reg ed_dstr_sop_d1;
reg ed_dstr_eop_d1;
reg [`RCI_NBITS-1:0] ed_dstr_rci_d1;
reg [`DATA_PATH_VB_RANGE] ed_dstr_valid_bytes_d1;	

reg [`NUM_OF_PORTS-1:0] wr_reg_file;

reg [`NUM_OF_PORTS-1:0] event_fifo_rd;
reg [`NUM_OF_PORTS-1:0] rd_st_set;
reg [`NUM_OF_PORTS-1:0] rd_st_clr;
reg [`NUM_OF_PORTS-1:0] rd_st;
reg [`NUM_OF_PORTS-1:0] en_rd_port;
reg [`NUM_OF_PORTS-1:0] rd_port_en;
reg [`NUM_OF_PORTS-1:0] rd_port_en_d1;
reg [`NUM_OF_PORTS-1:0] rd_port_en_d2;


// per port

reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr0;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr1;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr2;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr3;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr4;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr5;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] wr_port_ctr6;

reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr0;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr1;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr2;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr3;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr4;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr5;
reg [EVENT_FIFO_DEPTH_NBITS-1:0] rd_port_ctr6;

reg [2:0] rd_port_seq0;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes0;

reg [2:0] rd_port_seq1;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes1;

reg [2:0] rd_port_seq2;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes2;

reg [2:0] rd_port_seq3;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes3;

reg [2:0] rd_port_seq4;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes4;

reg [2:0] rd_port_seq5;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes5;

reg [2:0] rd_port_seq6;
reg [`DATA_PATH_VB_RANGE] rd_port_valid_bytes6;


reg [`NUM_OF_PORTS-1:0] rd_port_sop;
reg [`NUM_OF_PORTS-1:0] rd_port_sop_d1;
reg [`NUM_OF_PORTS-1:0] rd_port_sop_d2;

reg [`NUM_OF_PORTS-1:0] rd_port_eop_d1;
reg [`NUM_OF_PORTS-1:0] rd_port_eop_d2;

reg [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr0_d1;
reg [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr1_d1;
reg [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr2_d1;
reg [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr3_d1;

reg [`DATA_PATH_RANGE] rot_data;

reg [1:0] rot_cnt_d1;
reg [`NUM_OF_PORTS-1:0] sel_port_d1;
reg [2:0] sel_port_id_d1;

reg [1:0] rot_cnt_d2;
reg [`NUM_OF_PORTS-1:0] sel_port_d2;
reg [2:0] sel_port_id_d2;

reg [1:0] rot_cnt_d3;

reg p_dstr_enc_data_valid0;
reg [`PORT_BUS_RANGE] p_dstr_enc_packet_data0;
reg p_dstr_enc_sop0;
reg p_dstr_enc_eop0;
reg [`PORT_BUS_VB_RANGE] p_dstr_enc_valid_bytes0;	

reg p_dstr_enc_data_valid1;
reg [`PORT_BUS_RANGE] p_dstr_enc_packet_data1;
reg p_dstr_enc_sop1;
reg p_dstr_enc_eop1;
reg [`PORT_BUS_VB_RANGE] p_dstr_enc_valid_bytes1;	

reg p_dstr_enc_data_valid2;
reg [`PORT_BUS_RANGE] p_dstr_enc_packet_data2;
reg p_dstr_enc_sop2;
reg p_dstr_enc_eop2;
reg [`PORT_BUS_VB_RANGE] p_dstr_enc_valid_bytes2;	
reg p_dstr_enc_port_id2;

reg p_dstr_enc_data_valid3;
reg [`PORT_BUS_RANGE] p_dstr_enc_packet_data3;
reg p_dstr_enc_sop3;
reg p_dstr_enc_eop3;
reg [`PORT_BUS_VB_RANGE] p_dstr_enc_valid_bytes3;	
reg [1:0] p_dstr_enc_port_id3;

reg [`NUM_OF_PORTS-1:0] disable_rci;

integer i;

wire [3:0] hold_fifo_empty;
wire [3:0] hold_fifo_rd;

wire [`PORT_BUS_RANGE] hold_fifo_packet_data0;
wire [3:0] hold_fifo_sop;
wire [3:0] hold_fifo_eop;
wire [`PORT_BUS_VB_RANGE] hold_fifo_valid_bytes0;	

wire [`PORT_BUS_RANGE] hold_fifo_packet_data1;
wire [`PORT_BUS_VB_RANGE] hold_fifo_valid_bytes1;	

wire [`PORT_BUS_RANGE] hold_fifo_packet_data2;
wire [`PORT_BUS_VB_RANGE] hold_fifo_valid_bytes2;	
wire hold_fifo_port_id2;

wire [`PORT_BUS_RANGE] hold_fifo_packet_data3;
wire [`PORT_BUS_VB_RANGE] hold_fifo_valid_bytes3;	
wire [1:0] hold_fifo_port_id3;


wire [1:0] rot_cnt;
wire [`NUM_OF_PORTS-1:0] sel_port;
wire [`PORT_ID_RANGE] sel_port_id;


wire [EVENT_FIFO_DEPTH_NBITS:0] event_fifo_depth[`NUM_OF_PORTS-1:0];

wire [EVENT_FIFO_DEPTH_NBITS:0] nevent_fifo_depth[`NUM_OF_PORTS-1:0];

wire [`NUM_OF_PORTS-1:0] event_fifo_empty;
wire [`NUM_OF_PORTS-1:0] event_fifo_sop;
wire [`NUM_OF_PORTS-1:0] event_fifo_eop;

wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes0;
wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes1;
wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes2;
wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes3;
wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes4;
wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes5;
wire [`DATA_PATH_VB_RANGE] event_fifo_valid_bytes6;

wire [`RCI_NBITS-1:0] event_fifo_rci0;
wire [`RCI_NBITS-1:0] event_fifo_rci1;
wire [`RCI_NBITS-1:0] event_fifo_rci2;
wire [`RCI_NBITS-1:0] event_fifo_rci3;
wire [`RCI_NBITS-1:0] event_fifo_rci4;
wire [`RCI_NBITS-1:0] event_fifo_rci5;
wire [`RCI_NBITS-1:0] event_fifo_rci6;

wire [`RCI_NBITS-1:0] latency_fifo_rci0;
wire [`RCI_NBITS-1:0] latency_fifo_rci1;
wire [`RCI_NBITS-1:0] latency_fifo_rci2;
wire [`RCI_NBITS-1:0] latency_fifo_rci3;
wire [`RCI_NBITS-1:0] latency_fifo_rci4;
wire [`RCI_NBITS-1:0] latency_fifo_rci5;
wire [`RCI_NBITS-1:0] latency_fifo_rci6;

wire [`DATA_PATH_RANGE] hold_register_rdata;

wire [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr0 = {sel_port_id_d2, rd_port_ctr};
wire [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr1 = hold_register_raddr0_d1;
wire [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr2 = hold_register_raddr1_d1;
wire [(`PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS)-1:0] hold_register_raddr3 = hold_register_raddr2_d1;

wire [`NUM_OF_PORTS-1:0] event_fifo_lt_ceiling;
wire [`NUM_OF_PORTS-1:0] rd_port_lt_ceiling;

assign event_fifo_lt_ceiling[0] = (event_fifo_valid_bytes0<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[0] = (rd_port_valid_bytes0<PORT_BUS_NBYTES_CEILING);
assign event_fifo_lt_ceiling[1] = (event_fifo_valid_bytes1<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[1] = (rd_port_valid_bytes1<PORT_BUS_NBYTES_CEILING);
assign event_fifo_lt_ceiling[2] = (event_fifo_valid_bytes2<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[2] = (rd_port_valid_bytes2<PORT_BUS_NBYTES_CEILING);
assign event_fifo_lt_ceiling[3] = (event_fifo_valid_bytes3<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[3] = (rd_port_valid_bytes3<PORT_BUS_NBYTES_CEILING);
assign event_fifo_lt_ceiling[4] = (event_fifo_valid_bytes4<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[4] = (rd_port_valid_bytes4<PORT_BUS_NBYTES_CEILING);
assign event_fifo_lt_ceiling[5] = (event_fifo_valid_bytes5<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[5] = (rd_port_valid_bytes5<PORT_BUS_NBYTES_CEILING);
assign event_fifo_lt_ceiling[6] = (event_fifo_valid_bytes6<PORT_BUS_NBYTES_CEILING);
assign rd_port_lt_ceiling[6] = (rd_port_valid_bytes6<PORT_BUS_NBYTES_CEILING);

wire [`NUM_OF_PORTS-1:0] set_en_rci;
assign set_en_rci[0] = ~hold_fifo_empty[0]&hold_fifo_sop[0]&~disable_rci[0];
assign set_en_rci[1] = ~hold_fifo_empty[1]&hold_fifo_sop[1]&~disable_rci[1];
assign set_en_rci[2] = ~hold_fifo_empty[2]&hold_fifo_sop[2]&~hold_fifo_port_id2&~disable_rci[2];
assign set_en_rci[3] = ~hold_fifo_empty[2]&hold_fifo_sop[2]&hold_fifo_port_id2&~disable_rci[3];
assign set_en_rci[4] = ~hold_fifo_empty[3]&hold_fifo_sop[3]&(hold_fifo_port_id3==0)&~disable_rci[4];
assign set_en_rci[5] = ~hold_fifo_empty[3]&hold_fifo_sop[3]&(hold_fifo_port_id3==1)&~disable_rci[5];
assign set_en_rci[6] = ~hold_fifo_empty[3]&hold_fifo_sop[3]&(hold_fifo_port_id3==2)&~disable_rci[6];
assign hold_fifo_rd[0] = ~hold_fifo_empty[0]&disable_rci[0];
assign hold_fifo_rd[1] = ~hold_fifo_empty[1]&disable_rci[1];
assign hold_fifo_rd[2] = ~hold_fifo_empty[2]&(hold_fifo_port_id2?disable_rci[3]:disable_rci[2]);
assign hold_fifo_rd[3] = ~hold_fifo_empty[3]&(hold_fifo_port_id3==0?disable_rci[4]:hold_fifo_port_id3==1?disable_rci[5]:disable_rci[6]);

wire [`NUM_OF_PORTS-1:0] latency_fifo_rd = set_en_rci;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		dstr_enc_packet_data0 <= set_en_rci[0]?latency_fifo_rci0:hold_fifo_packet_data0;
		dstr_enc_sop0 <= hold_fifo_sop[0]&~disable_rci[0];
		dstr_enc_eop0 <= hold_fifo_eop[0];
		dstr_enc_valid_bytes0 <= hold_fifo_valid_bytes0;

		dstr_enc_packet_data1 <= set_en_rci[1]?latency_fifo_rci1:hold_fifo_packet_data1;
		dstr_enc_sop1 <= hold_fifo_sop[1]&~disable_rci[1];
		dstr_enc_eop1 <= hold_fifo_eop[1];
		dstr_enc_valid_bytes1 <= hold_fifo_valid_bytes1;

		dstr_enc_packet_data2 <= set_en_rci[2]?latency_fifo_rci2:set_en_rci[3]?latency_fifo_rci3:hold_fifo_packet_data2;
		dstr_enc_sop2 <= hold_fifo_sop[2]&(hold_fifo_port_id2?~disable_rci[3]:~disable_rci[2]);
		dstr_enc_eop2 <= hold_fifo_eop[2];
		dstr_enc_valid_bytes2 <= hold_fifo_valid_bytes2;

		dstr_enc_packet_data3 <= set_en_rci[4]?latency_fifo_rci4:set_en_rci[5]?latency_fifo_rci5:set_en_rci[6]?latency_fifo_rci6:hold_fifo_packet_data3;
		dstr_enc_sop3 <= hold_fifo_sop[3]&(hold_fifo_port_id3==0?~disable_rci[4]:hold_fifo_port_id3==1?~disable_rci[5]:~disable_rci[6]);
		dstr_enc_eop3 <= hold_fifo_eop[3];
		dstr_enc_valid_bytes3 <= hold_fifo_valid_bytes3;

end

always @(`CLK_RST) 
        if (`ACTIVE_RESET) begin
		dstr_ed_bp <= {(`NUM_OF_PORTS){1'b0}};

		dstr_enc_data_valid0 <= 0;
		dstr_enc_data_valid1 <= 0;
		dstr_enc_data_valid2 <= 0;
		dstr_enc_data_valid3 <= 0;
	end else begin
		for (i = 0; i < `NUM_OF_PORTS; i = i+1)
			dstr_ed_bp[i] <= nevent_fifo_depth[i]<XON_LEVEL?1'b0:nevent_fifo_depth[i]>XOFF_LEVEL?1'b1:dstr_ed_bp[i];

		dstr_enc_data_valid0 <= set_en_rci[0]|~hold_fifo_empty[0];
		dstr_enc_data_valid1 <= set_en_rci[1]|~hold_fifo_empty[1];
		dstr_enc_data_valid2 <= |set_en_rci[3:2]|~hold_fifo_empty[2];
		dstr_enc_data_valid3 <= |set_en_rci[6:4]|~hold_fifo_empty[3];
	end
/***************************** PROGRAM BODY **********************************/

always @(posedge clk) begin

		p_dstr_enc_packet_data0 <= transpose(rot_data[(`PORT_BUS_NBITS*4)-1:(`PORT_BUS_NBITS*3)]);
		p_dstr_enc_sop0 <= rd_port_sop_d2[0];
		p_dstr_enc_eop0 <= rd_port_eop_d2[0];
		p_dstr_enc_valid_bytes0 <= dstr_enc_valid_bytes0_p1;

		p_dstr_enc_packet_data1 <= transpose(rot_data[(`PORT_BUS_NBITS*3)-1:(`PORT_BUS_NBITS*2)]);
		p_dstr_enc_sop1 <= rd_port_sop_d2[1];
		p_dstr_enc_eop1 <= rd_port_eop_d2[1];
		p_dstr_enc_valid_bytes1 <= dstr_enc_valid_bytes1_p1;

		p_dstr_enc_packet_data2 <= transpose(rot_data[(`PORT_BUS_NBITS*2)-1:(`PORT_BUS_NBITS*1)]);
		p_dstr_enc_sop2 <= rd_port_en_d2[2]?rd_port_sop_d2[2]:rd_port_sop_d2[3];
		p_dstr_enc_eop2 <= rd_port_en_d2[2]?rd_port_eop_d2[2]:rd_port_eop_d2[3];
		p_dstr_enc_valid_bytes2 <= rd_port_en_d2[2]?dstr_enc_valid_bytes2_p1:dstr_enc_valid_bytes3_p1;
		p_dstr_enc_port_id2 <= ~rd_port_en_d2[2];

		p_dstr_enc_packet_data3 <= transpose(rot_data[(`PORT_BUS_NBITS*1)-1:(`PORT_BUS_NBITS*0)]);
		p_dstr_enc_sop3 <= rd_port_en_d2[4]?rd_port_sop_d2[4]:rd_port_en_d2[5]?rd_port_sop_d2[5]:rd_port_sop_d2[6];
		p_dstr_enc_eop3 <= rd_port_en_d2[4]?rd_port_eop_d2[4]:rd_port_en_d2[5]?rd_port_eop_d2[5]:rd_port_eop_d2[6];
		p_dstr_enc_valid_bytes3 <= rd_port_en_d2[4]?dstr_enc_valid_bytes4_p1:rd_port_en_d2[5]?dstr_enc_valid_bytes5_p1:dstr_enc_valid_bytes6_p1;
		p_dstr_enc_port_id3 <= rd_port_en_d2[4]?2'b00:rd_port_en_d2[5]?2'b01:2'b10;
end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		p_dstr_enc_data_valid0 <= 0;
		p_dstr_enc_data_valid1 <= 0;
		p_dstr_enc_data_valid2 <= 0;
		p_dstr_enc_data_valid3 <= 0;

	end else begin
		p_dstr_enc_data_valid0 <= rd_port_en_d2[0];
		p_dstr_enc_data_valid1 <= rd_port_en_d2[1];
		p_dstr_enc_data_valid2 <= rd_port_en_d2[2]|rd_port_en_d2[3];
		p_dstr_enc_data_valid3 <= rd_port_en_d2[4]|rd_port_en_d2[5]|rd_port_en_d2[6];

	end

wire [`NUM_OF_PORTS-1:0] rd_port_sos;

assign rd_port_sos[0] = (rd_port_seq0==0);
assign rd_port_sos[1] = (rd_port_seq1==0);
assign rd_port_sos[2] = (rd_port_seq2==0);
assign rd_port_sos[3] = (rd_port_seq3==0);
assign rd_port_sos[4] = (rd_port_seq4==0);
assign rd_port_sos[5] = (rd_port_seq5==0);
assign rd_port_sos[6] = (rd_port_seq6==0);

wire [`NUM_OF_PORTS-1:0] rd_port_eop;

assign rd_port_eop[0] = rd_port_sos[0]?event_fifo_eop[0]&event_fifo_lt_ceiling[0]:event_fifo_eop[0]&rd_port_lt_ceiling[0];

assign rd_port_eop[1] = rd_port_sos[1]?event_fifo_eop[1]&event_fifo_lt_ceiling[1]:event_fifo_eop[1]&rd_port_lt_ceiling[1];

assign rd_port_eop[2] = rd_port_sos[2]?event_fifo_eop[2]&event_fifo_lt_ceiling[2]:event_fifo_eop[2]&rd_port_lt_ceiling[2];

assign rd_port_eop[3] = rd_port_sos[3]?event_fifo_eop[3]&event_fifo_lt_ceiling[3]:event_fifo_eop[3]&rd_port_lt_ceiling[3];

assign rd_port_eop[4] = rd_port_sos[4]?event_fifo_eop[4]&event_fifo_lt_ceiling[4]:event_fifo_eop[4]&rd_port_lt_ceiling[4];

assign rd_port_eop[5] = rd_port_sos[5]?event_fifo_eop[5]&event_fifo_lt_ceiling[5]:event_fifo_eop[5]&rd_port_lt_ceiling[5];

assign rd_port_eop[6] = rd_port_sos[6]?event_fifo_eop[6]&event_fifo_lt_ceiling[6]:event_fifo_eop[6]&rd_port_lt_ceiling[6];


wire [`NUM_OF_PORTS-1:0] rd_port_last;

assign rd_port_last[0] = (rd_port_seq0==`DATA_PATH_PORT_BUS_RATIO-1);
assign rd_port_last[1] = (rd_port_seq1==`DATA_PATH_PORT_BUS_RATIO-1);
assign rd_port_last[2] = (rd_port_seq2==`DATA_PATH_PORT_BUS_RATIO-1);
assign rd_port_last[3] = (rd_port_seq3==`DATA_PATH_PORT_BUS_RATIO-1);
assign rd_port_last[4] = (rd_port_seq4==`DATA_PATH_PORT_BUS_RATIO-1);
assign rd_port_last[5] = (rd_port_seq5==`DATA_PATH_PORT_BUS_RATIO-1);
assign rd_port_last[6] = (rd_port_seq6==`DATA_PATH_PORT_BUS_RATIO-1);

wire [`NUM_OF_PORTS-1:0] rd_port_eos = rd_port_eop|rd_port_last;

always @(*) begin
	for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
		wr_reg_file[i] = ed_dstr_data_valid_d1&(ed_dstr_port_id_d1==i);
	end

	for (i = 0; i < `PORT_BUS_NBITS; i = i+1)
		{rot_data[`PORT_BUS_NBITS*3+i],
		rot_data[`PORT_BUS_NBITS*2+i],
		rot_data[`PORT_BUS_NBITS+i],
		rot_data[i]} = dstr_rot({
						hold_register_rdata[`PORT_BUS_NBITS*3+i], 
						hold_register_rdata[`PORT_BUS_NBITS*2+i], 
						hold_register_rdata[`PORT_BUS_NBITS+i], 
						hold_register_rdata[i]}, rot_cnt_d3);

	for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
		rd_port_sop[i] = rd_port_sos[i]&event_fifo_sop[i];
		rd_st_set[i] = ~event_fifo_empty[i]&event_fifo_sop[i]&sel_port[i];
		rd_port_en[i] = rd_st[i]&~event_fifo_empty[i]&en_rd_port[i];
		event_fifo_rd[i] = rd_port_en[i]&rd_port_eos[i];
		rd_st_clr[i] = rd_port_en[i]&rd_port_eop[i];
	end

end

always @(posedge clk) begin
		port_dstr_bp_d1 <= port_dstr_bp;

	    	ed_dstr_packet_data_d1 <= transpose16bytes(ed_dstr_packet_data);
		ed_dstr_port_id_d1 <= ed_dstr_port_id;
		ed_dstr_sop_d1 <= ed_dstr_sop;
		ed_dstr_eop_d1 <= ed_dstr_eop;
		ed_dstr_rci_d1 <= {ed_dstr_rci};
		ed_dstr_valid_bytes_d1 <= ed_dstr_valid_bytes;

		case (ed_dstr_port_id)
			0: wr_port_ctr <= wr_port_ctr0;
			1: wr_port_ctr <= wr_port_ctr1;
			2: wr_port_ctr <= wr_port_ctr2;
			3: wr_port_ctr <= wr_port_ctr3;
			4: wr_port_ctr <= wr_port_ctr4;
			5: wr_port_ctr <= wr_port_ctr5;
			default: wr_port_ctr <= wr_port_ctr6;
		endcase

		hold_register_raddr0_d1 <= hold_register_raddr0;
		hold_register_raddr1_d1 <= hold_register_raddr1;
		hold_register_raddr2_d1 <= hold_register_raddr2;
		hold_register_raddr3_d1 <= hold_register_raddr3;

		rot_cnt_d1 <= rot_cnt;
		rot_cnt_d2 <= rot_cnt_d1;
		rot_cnt_d3 <= rot_cnt_d2;
		sel_port_d1 <= sel_port;
		sel_port_d2 <= sel_port_d1;
		sel_port_id_d1 <= sel_port_id;
		sel_port_id_d2 <= sel_port_id_d1;

		rd_port_en_d1 <= rd_port_en;
		rd_port_en_d2 <= rd_port_en_d1;

		rd_port_sop_d1 <= rd_port_sop;
		rd_port_sop_d2 <= rd_port_sop_d1;

		rd_port_eop_d1 <= rd_port_eop;
		rd_port_eop_d2 <= rd_port_eop_d1;

		case (sel_port_id_d1)
			0: rd_port_ctr <= rd_port_ctr0;
			1: rd_port_ctr <= rd_port_ctr1;
			2: rd_port_ctr <= rd_port_ctr2;
			3: rd_port_ctr <= rd_port_ctr3;
			4: rd_port_ctr <= rd_port_ctr4;
			5: rd_port_ctr <= rd_port_ctr5;
			default: rd_port_ctr <= rd_port_ctr6;
		endcase

		rd_port_valid_bytes0 <= rd_port_sos[0]?event_fifo_valid_bytes0-`PORT_BUS_NBYTES:
							rd_port_en[0]?rd_port_valid_bytes0-`PORT_BUS_NBYTES:rd_port_valid_bytes0;
		rd_port_valid_bytes1 <= rd_port_sos[1]?event_fifo_valid_bytes1-`PORT_BUS_NBYTES:
							rd_port_en[1]?rd_port_valid_bytes1-`PORT_BUS_NBYTES:rd_port_valid_bytes1;
		rd_port_valid_bytes2 <= rd_port_sos[2]?event_fifo_valid_bytes2-`PORT_BUS_NBYTES:
							rd_port_en[2]?rd_port_valid_bytes2-`PORT_BUS_NBYTES:rd_port_valid_bytes2;
		rd_port_valid_bytes3 <= rd_port_sos[3]?event_fifo_valid_bytes3-`PORT_BUS_NBYTES:
							rd_port_en[3]?rd_port_valid_bytes3-`PORT_BUS_NBYTES:rd_port_valid_bytes3;
		rd_port_valid_bytes4 <= rd_port_sos[4]?event_fifo_valid_bytes4-`PORT_BUS_NBYTES:
							rd_port_en[4]?rd_port_valid_bytes4-`PORT_BUS_NBYTES:rd_port_valid_bytes4;
		rd_port_valid_bytes5 <= rd_port_sos[5]?event_fifo_valid_bytes5-`PORT_BUS_NBYTES:
							rd_port_en[5]?rd_port_valid_bytes5-`PORT_BUS_NBYTES:rd_port_valid_bytes5;
		rd_port_valid_bytes6 <= rd_port_sos[6]?event_fifo_valid_bytes6-`PORT_BUS_NBYTES:
							rd_port_en[6]?rd_port_valid_bytes6-`PORT_BUS_NBYTES:rd_port_valid_bytes6;

		dstr_enc_valid_bytes0_p2 <= rd_port_sos[0]?(event_fifo_lt_ceiling[0]?event_fifo_valid_bytes0[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[0]?rd_port_valid_bytes0[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);
		dstr_enc_valid_bytes1_p2 <= rd_port_sos[1]?(event_fifo_lt_ceiling[1]?event_fifo_valid_bytes1[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[1]?rd_port_valid_bytes1[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);
		dstr_enc_valid_bytes2_p2 <= rd_port_sos[2]?(event_fifo_lt_ceiling[2]?event_fifo_valid_bytes2[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[2]?rd_port_valid_bytes2[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);
		dstr_enc_valid_bytes3_p2 <= rd_port_sos[3]?(event_fifo_lt_ceiling[3]?event_fifo_valid_bytes3[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[3]?rd_port_valid_bytes3[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);
		dstr_enc_valid_bytes4_p2 <= rd_port_sos[4]?(event_fifo_lt_ceiling[4]?event_fifo_valid_bytes4[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[4]?rd_port_valid_bytes4[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);
		dstr_enc_valid_bytes5_p2 <= rd_port_sos[5]?(event_fifo_lt_ceiling[5]?event_fifo_valid_bytes5[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[5]?rd_port_valid_bytes5[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);
		dstr_enc_valid_bytes6_p2 <= rd_port_sos[6]?(event_fifo_lt_ceiling[6]?event_fifo_valid_bytes6[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES):
								(rd_port_lt_ceiling[6]?rd_port_valid_bytes6[`DATA_PATH_VB_RANGE]:`PORT_BUS_NBYTES);

		dstr_enc_valid_bytes0_p1 <= dstr_enc_valid_bytes0_p2;
		dstr_enc_valid_bytes1_p1 <= dstr_enc_valid_bytes1_p2;
		dstr_enc_valid_bytes2_p1 <= dstr_enc_valid_bytes2_p2;
		dstr_enc_valid_bytes3_p1 <= dstr_enc_valid_bytes3_p2;
		dstr_enc_valid_bytes4_p1 <= dstr_enc_valid_bytes4_p2;
		dstr_enc_valid_bytes5_p1 <= dstr_enc_valid_bytes5_p2;
		dstr_enc_valid_bytes6_p1 <= dstr_enc_valid_bytes6_p2;

end


always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		ed_dstr_data_valid_d1 <= 0;
		wr_port_ctr0 <= 0;
		wr_port_ctr1 <= 0;
		wr_port_ctr2 <= 0;
		wr_port_ctr3 <= 0;
		wr_port_ctr4 <= 0;
		wr_port_ctr5 <= 0;
		wr_port_ctr6 <= 0;
		rd_port_ctr0 <= 0;
		rd_port_ctr1 <= 0;
		rd_port_ctr2 <= 0;
		rd_port_ctr3 <= 0;
		rd_port_ctr4 <= 0;
		rd_port_ctr5 <= 0;
		rd_port_ctr6 <= 0;
		rd_st <= 0;
		en_rd_port <= 0;
		rd_port_seq0 <= 0;
		rd_port_seq1 <= 0;
		rd_port_seq2 <= 0;
		rd_port_seq3 <= 0;
		rd_port_seq4 <= 0;
		rd_port_seq5 <= 0;
		rd_port_seq6 <= 0;

		disable_rci <= 0;

	end else begin
		ed_dstr_data_valid_d1 <= ed_dstr_data_valid;

		wr_port_ctr0 <= wr_reg_file[0]?wr_port_ctr0+1:wr_port_ctr0;
		wr_port_ctr1 <= wr_reg_file[1]?wr_port_ctr1+1:wr_port_ctr1;
		wr_port_ctr2 <= wr_reg_file[2]?wr_port_ctr2+1:wr_port_ctr2;
		wr_port_ctr3 <= wr_reg_file[3]?wr_port_ctr3+1:wr_port_ctr3;
		wr_port_ctr4 <= wr_reg_file[4]?wr_port_ctr4+1:wr_port_ctr4;
		wr_port_ctr5 <= wr_reg_file[5]?wr_port_ctr5+1:wr_port_ctr5;
		wr_port_ctr6 <= wr_reg_file[6]?wr_port_ctr6+1:wr_port_ctr6;

		for (i = 0; i < `NUM_OF_PORTS; i = i+1) begin
			rd_st[i] <= rd_st_set[i]?1:rd_st_clr[i]?0:rd_st[i];
			en_rd_port[i] <= sel_port[i]?~port_dstr_bp_d1[i]&(event_fifo_rd[i]?(event_fifo_depth[i]>1):~event_fifo_empty[i]):event_fifo_rd[i]?0:en_rd_port[i];
		end

		rd_port_ctr0 <= event_fifo_rd[0]?rd_port_ctr0+1:rd_port_ctr0;
		rd_port_ctr1 <= event_fifo_rd[1]?rd_port_ctr1+1:rd_port_ctr1;
		rd_port_ctr2 <= event_fifo_rd[2]?rd_port_ctr2+1:rd_port_ctr2;
		rd_port_ctr3 <= event_fifo_rd[3]?rd_port_ctr3+1:rd_port_ctr3;
		rd_port_ctr4 <= event_fifo_rd[4]?rd_port_ctr4+1:rd_port_ctr4;
		rd_port_ctr5 <= event_fifo_rd[5]?rd_port_ctr5+1:rd_port_ctr5;
		rd_port_ctr6 <= event_fifo_rd[6]?rd_port_ctr6+1:rd_port_ctr6;

		rd_port_seq0 <= rd_port_en[0]?(rd_port_eos[0]?0:rd_port_seq0+1):rd_port_seq0;
		rd_port_seq1 <= rd_port_en[1]?(rd_port_eos[1]?0:rd_port_seq1+1):rd_port_seq1;
		rd_port_seq2 <= rd_port_en[2]?(rd_port_eos[2]?0:rd_port_seq2+1):rd_port_seq2;
		rd_port_seq3 <= rd_port_en[3]?(rd_port_eos[3]?0:rd_port_seq3+1):rd_port_seq3;
		rd_port_seq4 <= rd_port_en[4]?(rd_port_eos[4]?0:rd_port_seq4+1):rd_port_seq4;
		rd_port_seq5 <= rd_port_en[5]?(rd_port_eos[5]?0:rd_port_seq5+1):rd_port_seq5;
		rd_port_seq6 <= rd_port_en[6]?(rd_port_eos[6]?0:rd_port_seq6+1):rd_port_seq6;

		disable_rci[0] <= set_en_rci[0]?1'b1:hold_fifo_rd[0]&hold_fifo_eop[0]?1'b0:disable_rci[0];
		disable_rci[1] <= set_en_rci[1]?1'b1:hold_fifo_rd[1]&hold_fifo_eop[1]?1'b0:disable_rci[1];
		disable_rci[2] <= set_en_rci[2]?1'b1:hold_fifo_rd[2]&hold_fifo_eop[2]&~hold_fifo_port_id2?1'b0:disable_rci[2];
		disable_rci[3] <= set_en_rci[3]?1'b1:hold_fifo_rd[2]&hold_fifo_eop[2]&hold_fifo_port_id2?1'b0:disable_rci[3];
		disable_rci[4] <= set_en_rci[4]?1'b1:hold_fifo_rd[3]&hold_fifo_eop[3]&(hold_fifo_port_id3==0)?1'b0:disable_rci[4];
		disable_rci[5] <= set_en_rci[5]?1'b1:hold_fifo_rd[3]&hold_fifo_eop[3]&(hold_fifo_port_id3==1)?1'b0:disable_rci[5];
		disable_rci[6] <= set_en_rci[6]?1'b1:hold_fifo_rd[3]&hold_fifo_eop[3]&(hold_fifo_port_id3==2)?1'b0:disable_rci[6];

	end
 
/***************************** Port Scheduler ***************************************/

port_scheduler u_port_scheduler(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),
		.en(1'b1),

		// outputs

		.rot_cnt(rot_cnt),
		.sel_port(sel_port),
		.sel_port_id(sel_port_id)

	);
/***************************** FIFO ***************************************/

sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[0]),
		.wr(wr_reg_file[0]),

		.ncount(nevent_fifo_depth[0]),
		.count(event_fifo_depth[0]),
		.full(),
		.empty(event_fifo_empty[0]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci0, event_fifo_valid_bytes0, event_fifo_eop[0], event_fifo_sop[0]})       
	);
sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_1(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[1]),
		.wr(wr_reg_file[1]),

		.ncount(nevent_fifo_depth[1]),
		.count(event_fifo_depth[1]),
		.full(),
		.empty(event_fifo_empty[1]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci1, event_fifo_valid_bytes1, event_fifo_eop[1], event_fifo_sop[1]})       
	);
sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_2(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[2]),
		.wr(wr_reg_file[2]),

		.ncount(nevent_fifo_depth[2]),
		.count(event_fifo_depth[2]),
		.full(),
		.empty(event_fifo_empty[2]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci2, event_fifo_valid_bytes2, event_fifo_eop[2], event_fifo_sop[2]})       
	);
sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_3(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[3]),
		.wr(wr_reg_file[3]),

		.ncount(nevent_fifo_depth[3]),
		.count(event_fifo_depth[3]),
		.full(),
		.empty(event_fifo_empty[3]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci3, event_fifo_valid_bytes3, event_fifo_eop[3], event_fifo_sop[3]})       
	);
sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_4(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[4]),
		.wr(wr_reg_file[4]),

		.ncount(nevent_fifo_depth[4]),
		.count(event_fifo_depth[4]),
		.full(),
		.empty(event_fifo_empty[4]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci4, event_fifo_valid_bytes4, event_fifo_eop[4], event_fifo_sop[4]})       
	);
sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_5(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[5]),
		.wr(wr_reg_file[5]),

		.ncount(nevent_fifo_depth[5]),
		.count(event_fifo_depth[5]),
		.full(),
		.empty(event_fifo_empty[5]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci5, event_fifo_valid_bytes5, event_fifo_eop[5], event_fifo_sop[5]})       
	);
sfifo2f_fo #(`RCI_NBITS+`DATA_PATH_VB_NBITS+2,  EVENT_FIFO_DEPTH_NBITS) u_sfifo2f_fo_6(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({ed_dstr_rci_d1, ed_dstr_valid_bytes_d1, ed_dstr_eop_d1, ed_dstr_sop_d1}),				
		.rd(event_fifo_rd[6]),
		.wr(wr_reg_file[6]),

		.ncount(nevent_fifo_depth[6]),
		.count(event_fifo_depth[6]),
		.full(),
		.empty(event_fifo_empty[6]),
		.fullm1(),
		.emptyp2(),
		.dout({event_fifo_rci6, event_fifo_valid_bytes6, event_fifo_eop[6], event_fifo_sop[6]})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_70(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci0}),				
		.rd(latency_fifo_rd[0]),
		.wr(event_fifo_rd[0]&event_fifo_sop[0]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci0})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_71(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci1}),				
		.rd(latency_fifo_rd[1]),
		.wr(event_fifo_rd[1]&event_fifo_sop[1]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci1})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_72(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci2}),				
		.rd(latency_fifo_rd[2]),
		.wr(event_fifo_rd[2]&event_fifo_sop[2]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci2})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_73(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci3}),				
		.rd(latency_fifo_rd[3]),
		.wr(event_fifo_rd[3]&event_fifo_sop[3]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci3})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_74(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci4}),				
		.rd(latency_fifo_rd[4]),
		.wr(event_fifo_rd[4]&event_fifo_sop[4]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci4})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_75(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci5}),				
		.rd(latency_fifo_rd[5]),
		.wr(event_fifo_rd[5]&event_fifo_sop[5]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci5})       
	);

sfifo2f1 #(`RCI_NBITS, 2) u_sfifo2f1_76(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({event_fifo_rci6}),				
		.rd(latency_fifo_rd[6]),
		.wr(event_fifo_rd[6]&event_fifo_sop[6]),

		.count(),
		.full(),
		.empty(),
		.fullm1(),
		.emptyp2(),
		.dout({latency_fifo_rci6})       
	);

sfifo2f_fo #(`PORT_BUS_NBITS+`PORT_BUS_VB_NBITS+2, 2) u_sfifo2f_fo_00(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({p_dstr_enc_packet_data0, p_dstr_enc_valid_bytes0, p_dstr_enc_eop0, p_dstr_enc_sop0}),				
		.rd(hold_fifo_rd[0]),
		.wr(p_dstr_enc_data_valid0),

		.ncount(),
		.count(),
		.full(),
		.empty(hold_fifo_empty[0]),
		.fullm1(),
		.emptyp2(),
		.dout({hold_fifo_packet_data0, hold_fifo_valid_bytes0, hold_fifo_eop[0], hold_fifo_sop[0]})       
	);

sfifo2f_fo #(`PORT_BUS_NBITS+`PORT_BUS_VB_NBITS+2, 2) u_sfifo2f_fo_01(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({p_dstr_enc_packet_data1, p_dstr_enc_valid_bytes1, p_dstr_enc_eop1, p_dstr_enc_sop1}),				
		.rd(hold_fifo_rd[1]),
		.wr(p_dstr_enc_data_valid1),

		.ncount(),
		.count(),
		.full(),
		.empty(hold_fifo_empty[1]),
		.fullm1(),
		.emptyp2(),
		.dout({hold_fifo_packet_data1, hold_fifo_valid_bytes1, hold_fifo_eop[1], hold_fifo_sop[1]})       
	);

sfifo2f_fo #(`PORT_BUS_NBITS+`PORT_BUS_VB_NBITS+2+1, 2) u_sfifo2f_fo_02(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({p_dstr_enc_packet_data2, p_dstr_enc_valid_bytes2, p_dstr_enc_eop2, p_dstr_enc_sop2, p_dstr_enc_port_id2}),				
		.rd(hold_fifo_rd[2]),
		.wr(p_dstr_enc_data_valid2),

		.ncount(),
		.count(),
		.full(),
		.empty(hold_fifo_empty[2]),
		.fullm1(),
		.emptyp2(),
		.dout({hold_fifo_packet_data2, hold_fifo_valid_bytes2, hold_fifo_eop[2], hold_fifo_sop[2], hold_fifo_port_id2})       
	);

sfifo2f_fo #(`PORT_BUS_NBITS+`PORT_BUS_VB_NBITS+2+2, 2) u_sfifo2f_fo_03(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({p_dstr_enc_packet_data3, p_dstr_enc_valid_bytes3, p_dstr_enc_eop3, p_dstr_enc_sop3, p_dstr_enc_port_id3}),				
		.rd(hold_fifo_rd[3]),
		.wr(p_dstr_enc_data_valid3),

		.ncount(),
		.count(),
		.full(),
		.empty(hold_fifo_empty[3]),
		.fullm1(),
		.emptyp2(),
		.dout({hold_fifo_packet_data3, hold_fifo_valid_bytes3, hold_fifo_eop[3], hold_fifo_sop[3], hold_fifo_port_id3})       
	);

/***************************** MEMORY ***************************************/
register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS) u_register_file_0(
		.clk(clk),
		.wr(ed_dstr_data_valid_d1),
		.raddr(hold_register_raddr0),
		.waddr({ed_dstr_port_id_d1, wr_port_ctr}),
		.din(ed_dstr_packet_data_d1[(`PORT_BUS_NBITS*1)-1:(`PORT_BUS_NBITS*0)]),

		.dout(hold_register_rdata[(`PORT_BUS_NBITS*1)-1:(`PORT_BUS_NBITS*0)]));

register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS) u_register_file_1(
		.clk(clk),
		.wr(ed_dstr_data_valid_d1),
		.raddr(hold_register_raddr1),
		.waddr({ed_dstr_port_id_d1, wr_port_ctr}),
		.din(ed_dstr_packet_data_d1[(`PORT_BUS_NBITS*2)-1:(`PORT_BUS_NBITS*1)]),

		.dout(hold_register_rdata[(`PORT_BUS_NBITS*2)-1:(`PORT_BUS_NBITS*1)]));

register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS) u_register_file_2(
		.clk(clk),
		.wr(ed_dstr_data_valid_d1),
		.raddr(hold_register_raddr2),
		.waddr({ed_dstr_port_id_d1, wr_port_ctr}),
		.din(ed_dstr_packet_data_d1[(`PORT_BUS_NBITS*3)-1:(`PORT_BUS_NBITS*2)]),

		.dout(hold_register_rdata[(`PORT_BUS_NBITS*3)-1:(`PORT_BUS_NBITS*2)]));

register_file #(`PORT_BUS_NBITS, `PORT_ID_NBITS+EVENT_FIFO_DEPTH_NBITS) u_register_file_3(
		.clk(clk),
		.wr(ed_dstr_data_valid_d1),
		.raddr(hold_register_raddr3),
		.waddr({ed_dstr_port_id_d1, wr_port_ctr}),
		.din(ed_dstr_packet_data_d1[(`PORT_BUS_NBITS*4)-1:(`PORT_BUS_NBITS*3)]),

		.dout(hold_register_rdata[(`PORT_BUS_NBITS*4)-1:(`PORT_BUS_NBITS*3)]));


/***************************** FUNCTION ************************************/
function [3:0] dstr_rot;
input[3:0] din;
input[1:0] rot_cnt;

reg[3:0] din0;

begin
	din0 = rot_cnt[1]?{din[1:0], din[3:2]}:din;
	dstr_rot = rot_cnt[0]?{din0[0], din0[3:1]}:din0;
end
endfunction

function [`DATA_PATH_RANGE] transpose16bytes;
input[`DATA_PATH_RANGE] din;

integer i, j;

begin

	for (i = 0; i < `DATA_PATH_NBITS; i = i+8)
		for (j = 0; j < 8; j = j+1)
			transpose16bytes[i+j] = din[`DATA_PATH_NBITS-1-7-i+j];

end
endfunction

function [31:0] transpose;
input[31:0] din;

begin
	transpose = {din[7:0], din[15:8], din[23:16], din[31:24]};
end
endfunction

/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

