//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

module piarb_tcam # (
parameter ID_NBITS = `PU_ID_NBITS, // log2(`NUM_OF_PU);
parameter QUEUE_ENTRIES_NBITS = `PU_QUEUE_ENTRIES_NBITS,
parameter QUEUE_DEPTH = `NUM_OF_PU

) (

input clk, `RESET_SIG,

input fid_lookup_req,
input [`FID_NBITS-1:0] fid_lookup_fid,

input wr_fid_req,
input [`FID_NBITS-1:0] wr_fid,
input [QUEUE_DEPTH-1:0] wr_fid_sel_id,
input wr_fid_sel,

input enq_req, 
input [ID_NBITS-1:0] enq_qid,
input enq_fid_sel,

input pu_fid_done, 
input [ID_NBITS-1:0] pu_id,
input pu_fid_sel,

output logic fid_lookup_ack,
output logic [1:0] fid_lookup_fid_valid[QUEUE_DEPTH-1:0],
output logic [1:0] fid_lookup_fid_hit[QUEUE_DEPTH-1:0]

);

/***************************** LOCAL VARIABLES *******************************/

localparam PU_DONE_FIFO_DEPTH_NBITS = 5;

typedef struct {
	logic [`FID_NBITS-1:0] fid0;
	logic [`FID_NBITS-1:0] fid1;
	logic [QUEUE_ENTRIES_NBITS-1:0] fid0_cnt;
	logic [QUEUE_ENTRIES_NBITS-1:0] fid1_cnt;
} tcam_entry;

tcam_entry tcam[QUEUE_DEPTH-1:0];

logic [1:0] n_fid_lookup_fid_valid[QUEUE_DEPTH-1:0];
logic [1:0] n_fid_lookup_fid_hit[QUEUE_DEPTH-1:0];
logic [1:0] wr_fid_valid[QUEUE_DEPTH-1:0];
logic [1:0] wr_fid_hit[QUEUE_DEPTH-1:0];

logic pu_fid_done_d1; 
logic [ID_NBITS-1:0] pu_id_d1;
logic pu_fid_sel_d1;

logic lat_fifo_empty;
logic [ID_NBITS-1:0] lat_fifo_pu_id;
logic lat_fifo_pu_fid_sel;

integer i;

wire wr0 = enq_req&~enq_fid_sel;
wire wr1 = enq_req&enq_fid_sel;

wire pu_wr0 = ~wr0&~lat_fifo_empty&~lat_fifo_pu_fid_sel;
wire pu_wr1 = ~wr1&~lat_fifo_empty&lat_fifo_pu_fid_sel;

wire fid0_wr = wr0|pu_wr0;
wire fid1_wr = wr1|pu_wr1;
wire [ID_NBITS-1:0] fid_waddr0 = wr0?enq_fid_sel:lat_fifo_pu_id;
wire [ID_NBITS-1:0] fid_waddr1 = wr1?enq_fid_sel:lat_fifo_pu_id;
wire [`FID_NBITS-1:0] fid_wdata0 = wr0?tcam[fid_waddr0].fid0_cnt+1:tcam[fid_waddr0].fid0_cnt-1;
wire [`FID_NBITS-1:0] fid_wdata1 = wr0?tcam[fid_waddr1].fid1_cnt+1:tcam[fid_waddr1].fid1_cnt-1;

wire lat_fifo_rd = pu_wr0|pu_wr1;

/***************************** NON REGISTERED OUTPUTS ************************/


/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
	for(i=0; i<QUEUE_DEPTH; i++) begin
		tcam[i].fid0_cnt <= fid0_wr&(fid_waddr0==i)?fid_wdata0:tcam[i].fid0_cnt;
		tcam[i].fid1_cnt <= fid1_wr&(fid_waddr1==i)?fid_wdata1:tcam[i].fid1_cnt;
		tcam[i].fid0 <= wr_fid_req&~wr_fid_sel&(wr_fid_sel_id==i)?wr_fid:tcam[i].fid0;
		tcam[i].fid1 <= wr_fid_req&wr_fid_sel&(wr_fid_sel_id==i)?wr_fid:tcam[i].fid1;
	end
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin

		fid_lookup_ack <= 0;
		for(i=0; i<QUEUE_DEPTH; i++) begin
			fid_lookup_fid_valid[i] <= 0;
			fid_lookup_fid_hit[i] <= 0;
		end

	end else begin

		fid_lookup_ack <= fid_lookup_req;
		for(i=0; i<QUEUE_DEPTH; i++) begin
			fid_lookup_fid_valid[i] <= n_fid_lookup_fid_valid[i]|wr_fid_valid[i];
			fid_lookup_fid_hit[i] <= n_fid_lookup_fid_hit[i]|wr_fid_hit[i];
		end

	end

/***************************** PROGRAM BODY **********************************/

always @* begin
	for(i=0; i<QUEUE_DEPTH; i++) begin
		n_fid_lookup_fid_valid[i][0] = tcam[i].fid0_cnt>0;	
		n_fid_lookup_fid_valid[i][1] = tcam[i].fid1_cnt>0;	
		n_fid_lookup_fid_hit[i][0] = n_fid_lookup_fid_valid[i][0]&(tcam[i].fid0==fid_lookup_fid);	
		n_fid_lookup_fid_hit[i][1]= n_fid_lookup_fid_valid[i][1]&(tcam[i].fid1==fid_lookup_fid);	
		wr_fid_valid[i][0] = wr_fid_req&(wr_fid_sel_id==i)&~wr_fid_sel;
		wr_fid_valid[i][1] = wr_fid_req&(wr_fid_sel_id==i)&wr_fid_sel;
		wr_fid_hit[i][0] = wr_fid_valid[i][0]&(wr_fid==fid_lookup_fid);	
		wr_fid_hit[i][1] = wr_fid_valid[i][1]&(wr_fid==fid_lookup_fid);	
	end
end

always @(posedge clk) begin
		pu_id_d1 <= 0;
		pu_fid_sel_d1 <= 0;
end

always @(`CLK_RST) 
    	if (`ACTIVE_RESET) begin
		pu_fid_done_d1 <= 0;
	end else begin
		pu_fid_done_d1 <= pu_fid_done;
	end

/***************************** FIFO ***************************************/
sfifo2f_fo #(ID_NBITS+1, PU_DONE_FIFO_DEPTH_NBITS) u_sfifo2f_fo_0(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({pu_id_d1, pu_fid_sel_d1}),				
		.rd(lat_fifo_rd),
		.wr(pu_fid_done_d1),

		.ncount(),
		.count(),
		.full(),
		.empty(lat_fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({lat_fifo_pu_id, lat_fifo_pu_fid_sel})       
	);

/***************************** DIAGNOSTICS **********************************/

	// synopsys translate_off

	// synopsys translate_on

endmodule

