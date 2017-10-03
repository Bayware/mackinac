//===========================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

import meta_package::*;

module asa_front_end #(
parameter LEN_NBITS = `PD_CHUNK_DEPTH_NBITS  
)(
input clk, 
input `RESET_SIG, 

input         pu_asa_start,
input         pu_asa_valid,
input [`PU_ASA_NBITS-1:0] pu_asa_data,				
input         pu_asa_eop,
input [`PU_ID_NBITS-1:0] pu_asa_pu_id,				

input         em_asa_valid,
input [`EM_BUF_PTR_NBITS-1:0] em_asa_buf_ptr,				
input [`PU_ID_NBITS-1:0] em_asa_pu_id,				
input [LEN_NBITS-1:0] em_asa_len,	
input         em_asa_discard,

input         piarb_asa_valid,
input         piarb_asa_type3,
input [`PU_ID_NBITS-1:0] piarb_asa_pu_id,				
input piarb_asa_meta_type piarb_asa_meta_data,				

input rci2sci_table_ack,
input [`SCI_NBITS*2-1:0] rci2sci_table_rdata,

input [`SCI_NBITS-1:0] ram_rdata,

output logic [`RCI_NBITS-1:0] ram_raddr,

output logic rci2sci_table_rd,
output logic [`RCI_NBITS*2-1:0] rci2sci_table_raddr,

output logic asa_proc_valid,
output logic asa_proc_type3,
output asa_proc_meta_type asa_proc_meta,
output logic [`RAS_NBITS-1:0] asa_proc_ras

);

/***************************** LOCAL VARIABLES *******************************/

localparam TYPE3_FIFO_DEPTH_NBITS = 2;
localparam FIFO_DEPTH_NBITS = 2;
localparam FIFO_DEPTH = (1<<FIFO_DEPTH_NBITS);
localparam RAM_DEPTH_NBITS = `PU_ID_NBITS+FIFO_DEPTH_NBITS;
localparam RAM_DEPTH = `NUM_OF_PU*FIFO_DEPTH;
localparam RAS_WIDTH = (`RAS_FLAG_NBITS+(1+`SCI_NBITS)*9);

integer i, j;

logic         pu_asa_start_d1;
logic         pu_asa_valid_d1;
logic [`PU_ASA_NBITS-1:0] pu_asa_data_d1;				
logic         pu_asa_eop_d1;
logic [`PU_ID_NBITS-1:0] pu_asa_pu_id_d1;				

logic         pu_asa_start_d2;

localparam RAS_FLAG_UP_NBITS = 16 + `RAS_FLAG_NFASCF_NBITS;
wire [RAS_FLAG_UP_NBITS-1:0] lat_fifo_din1 = {pu_asa_data_d1[31:16], pu_asa_data_d1[`RAS_FLAG_NFASCF_NBITS-1+8*0:8*0]};
localparam RAS_FLAG_LOW_NBITS = `RAS_FLAG_UPPD_NBITS+`RAS_FLAG_UPPP_NBITS+`RAS_FLAG_UFDAST_NBITS+`RAS_FLAG_EAST_NBITS;
logic [RAS_FLAG_LOW_NBITS-1:0] lat_fifo_din0_d1;
wire [RAS_FLAG_LOW_NBITS-1:0] lat_fifo_din0 = { pu_asa_data_d1[`RAS_FLAG_EAST_NBITS-1+8*3:8*3],
						pu_asa_data_d1[`RAS_FLAG_UFDAST_NBITS-1+8*2:8*2], 
						pu_asa_data_d1[`RAS_FLAG_UPPP_NBITS-1+8*1:8*1],
						pu_asa_data_d1[`RAS_FLAG_UPPD_NBITS-1+8*0:8*0]};

logic [1:0] lat_fifo_invalid_rci;
logic         lat_fifo_pu_asa_eop;
logic [`PU_ID_NBITS-1:0] lat_fifo_pu_asa_pu_id;				
logic [`RAS_FLAG_NBITS-1:0] lat_fifo_ras_flag;


logic         em_asa_valid_d1;
logic [`EM_BUF_PTR_NBITS-1:0] em_asa_buf_ptr_d1;				
logic [`PU_ID_NBITS-1:0] em_asa_pu_id_d1;				
logic [LEN_NBITS-1:0] em_asa_len_d1;	
logic         em_asa_discard_d1;

logic         piarb_asa_valid_d1;
logic         piarb_asa_type3_d1;
logic [`PU_ID_NBITS-1:0] piarb_asa_pu_id_d1;				
piarb_asa_meta_type piarb_asa_meta_data_d1;	

logic         piarb_asa_valid_d2;
logic         piarb_asa_type3_d2;
logic [`PU_ID_NBITS-1:0] piarb_asa_pu_id_d2;				
piarb_asa_meta_type piarb_asa_meta_data_d2;	


logic [`PU_ASA_TS_NBITS-1:0] ras_wr_cnt;

logic [`NUM_OF_PU-1:0] ras_empty;
logic [FIFO_DEPTH_NBITS:0] ras_wptr[`NUM_OF_PU-1:0];
logic [FIFO_DEPTH_NBITS:0] ras_rptr[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] meta_empty;
logic [FIFO_DEPTH_NBITS:0] meta_wptr[`NUM_OF_PU-1:0];
logic [FIFO_DEPTH_NBITS:0] meta_rptr[`NUM_OF_PU-1:0];

logic [`NUM_OF_PU-1:0] buf_ptr_empty;
logic [FIFO_DEPTH_NBITS:0] buf_ptr_wptr[`NUM_OF_PU-1:0];
logic [FIFO_DEPTH_NBITS:0] buf_ptr_rptr[`NUM_OF_PU-1:0];

wire lat_fifo_rd_1st = rci2sci_table_ack&(ras_wr_cnt==1);

wire lat_fifo_rd = rci2sci_table_ack&(ras_wr_cnt>1);

wire ras_wr_one = rci2sci_table_ack;

wire ras_wr = ras_wr_one&lat_fifo_pu_asa_eop;
logic [`RAS_FLAG_NBITS-1:0] ras_wdata0;
logic [(1+`SCI_NBITS)*9-1:0] ras_wdata51;
logic [(1+`SCI_NBITS)*9-1:0] ras_wdata51_d1;
wire [FIFO_DEPTH_NBITS-1:0] ras_wptr_sel = ras_wptr[lat_fifo_pu_asa_pu_id];
wire [RAM_DEPTH_NBITS-1:0] ras_waddr = {lat_fifo_pu_asa_pu_id, ras_wptr_sel};

wire buf_ptr_wr = em_asa_valid_d1;
wire [`EM_BUF_PTR_NBITS-1:0] buf_ptr_wdata = em_asa_buf_ptr_d1;
wire [FIFO_DEPTH_NBITS-1:0] buf_ptr_wptr_sel = buf_ptr_wptr[em_asa_pu_id_d1];
wire [RAM_DEPTH_NBITS-1:0] buf_ptr_waddr = {em_asa_pu_id_d1, buf_ptr_wptr_sel};

wire meta_wr = piarb_asa_valid_d2&~piarb_asa_type3_d2;
localparam META_MEM_NBITS = `CHUNK_LEN_NBITS*2;
piarb_asa_meta_type mpiarb_asa_meta_data_d2;
always @* begin
	mpiarb_asa_meta_data_d2 = piarb_asa_meta_data_d2;
	mpiarb_asa_meta_data_d2.rci = {{(`RCI_NBITS-`SCI_NBITS){1'b0}}, ram_rdata};
end

wire [FIFO_DEPTH_NBITS-1:0] meta_wptr_sel = meta_wptr[piarb_asa_pu_id_d2];
wire [RAM_DEPTH_NBITS-1:0] meta_waddr = {piarb_asa_pu_id_d2, meta_wptr_sel};

wire type3_fifo_wr = piarb_asa_valid_d2&piarb_asa_type3_d2;
piarb_asa_meta_type type3_fifo_wdata;
assign type3_fifo_wdata = mpiarb_asa_meta_data_d2;

piarb_asa_meta_type type3_fifo_rdata;
piarb_asa_meta_type type3_fifo_rdata_d1;
logic type3_fifo_empty;

logic event_fifo_empty;
logic sel_type3_d1;
wire sel_type3 = sel_type3_d1?event_fifo_empty&~type3_fifo_empty:~type3_fifo_empty;

wire type3_fifo_rd = sel_type3&~type3_fifo_empty;

wire event_fifo_rd = ~sel_type3&~event_fifo_empty;
logic event_fifo_rd_d1;
logic [`PU_ID_NBITS-1:0] event_fifo_rdata;
logic [`PU_ID_NBITS-1:0] event_fifo_rdata_d1;
wire event_fifo_wr1 = ras_wr&ras_empty[pu_asa_pu_id_d1];
wire event_fifo_wr = event_fifo_wr1|event_fifo_rd_d1&~ras_empty[event_fifo_rdata_d1];
wire [`PU_ID_NBITS-1:0] event_fifo_wdata = event_fifo_wr1?lat_fifo_pu_asa_pu_id:event_fifo_rdata_d1;

wire ras_rd = event_fifo_rd&~buf_ptr_empty[event_fifo_rdata];
wire buf_ptr_rd = ras_rd;
wire meta_rd = ras_rd;
wire [FIFO_DEPTH_NBITS-1:0] ras_rptr_sel = ras_rptr[event_fifo_rdata];
wire [RAM_DEPTH_NBITS-1:0] ras_raddr = {event_fifo_rdata, ras_rptr_sel};
wire [FIFO_DEPTH_NBITS-1:0] buf_ptr_rptr_sel = buf_ptr_rptr[event_fifo_rdata];
wire [RAM_DEPTH_NBITS-1:0] buf_ptr_raddr = {event_fifo_rdata, buf_ptr_rptr_sel};
wire [FIFO_DEPTH_NBITS-1:0] meta_rptr_sel = meta_rptr[event_fifo_rdata];
wire [RAM_DEPTH_NBITS-1:0] meta_raddr = {event_fifo_rdata, meta_rptr_sel};
logic [RAS_WIDTH-1:0] ras_rdata;
logic [`EM_BUF_PTR_NBITS-1:0] buf_ptr_rdata;
logic [LEN_NBITS-1:0] buf_ptr_len;
logic buf_ptr_discard;
logic [META_MEM_NBITS-1:0] meta_rdata;
piarb_asa_meta_type meta_rdata_struct;	

wire asa_proc_valid_p1 = type3_fifo_rd|ras_rd; 

wire [RAS_WIDTH-1:0] ras_wdata = {ras_wdata51, ras_wdata0};

wire [1:0] invalid_rci = {pu_asa_data_d1[31:16]==0, pu_asa_data_d1[15:0]==0};

piarb_asa_meta_type sel_meta;
assign sel_meta= sel_type3_d1?type3_fifo_rdata_d1:meta_rdata_struct;

enq_ed_cmd_type meta_ed_cmd;
assign meta_ed_cmd.ptr_update = 1'b0;
assign meta_ed_cmd.cur_ptr = ras_rdata[`RAS_FLAG_PTR];
assign meta_ed_cmd.ptr_loc = sel_meta.ptr_loc;
assign meta_ed_cmd.pd_update = 1'b0;
assign meta_ed_cmd.pd_len = sel_meta.pd_len;
assign meta_ed_cmd.pd_loc = sel_meta.pd_loc;
assign meta_ed_cmd.pd_buf_ptr = buf_ptr_rdata;
assign meta_ed_cmd.out_rci = 0;
assign meta_ed_cmd.len = sel_meta.len;

/***************************** NON-REGISTERED OUTPUTS ****************************/

assign asa_proc_meta.ed_cmd = meta_ed_cmd;
assign asa_proc_meta.buf_ptr = sel_meta.buf_ptr;
assign asa_proc_meta.fid = sel_meta.fid;
assign asa_proc_meta.tid = sel_meta.tid;
assign asa_proc_meta.type1 = sel_meta.type1;
assign asa_proc_meta.src_port = sel_meta.port;
assign asa_proc_meta.dst_port = 0;
assign asa_proc_meta.rci = sel_meta.rci;
assign asa_proc_meta.domain_id = sel_meta.domain_id;
assign asa_proc_meta.creation_time = sel_meta.creation_time;
assign asa_proc_meta.discard = ~sel_type3_d1&buf_ptr_discard|sel_meta.discard;
assign asa_proc_ras = ras_rdata;

/***************************** REGISTERED OUTPUTS ****************************/

assign rci2sci_table_rd = pu_asa_valid_d1;

assign rci2sci_table_raddr = {pu_asa_data_d1[`RCI_NBITS-1+16:16], pu_asa_data_d1[`RCI_NBITS-1:0]};

assign ram_raddr = piarb_asa_meta_data_d1.rci;

assign asa_proc_type3 = sel_type3_d1;

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		asa_proc_valid <= 0;
	end else begin
		asa_proc_valid <= asa_proc_valid_p1;
	end

/***************************** PROGRAM BODY **********************************/

wire [(1+`SCI_NBITS)*2-1:0] n_wdata = {lat_fifo_invalid_rci[1], rci2sci_table_rdata[`SCI_NBITS*2-1:`SCI_NBITS], lat_fifo_invalid_rci[0], rci2sci_table_rdata[`SCI_NBITS-1:0]};

always @(*) begin
	ras_wdata51[(`PU_ASA_TS-3)*(1+`SCI_NBITS)*2+(1+`SCI_NBITS)-1:(`PU_ASA_TS-3)*(1+`SCI_NBITS)*2] = ras_wr_one&(ras_wr_cnt==`PU_ASA_TS-1)?{lat_fifo_invalid_rci, rci2sci_table_rdata[`SCI_NBITS-1:0]}:ras_wdata51_d1[(`PU_ASA_TS-3)*(1+`SCI_NBITS)*2+(1+`SCI_NBITS)-1:(`PU_ASA_TS-3)*(1+`SCI_NBITS)*2];
	for(i=0; i<`PU_ASA_TS-3; i++)
		for(j=0; j<(`SCI_NBITS+1)*2; j++)
			ras_wdata51[i*(1+`SCI_NBITS)*2+j] = ras_wr_one&(ras_wr_cnt==i+2)?n_wdata[j]:ras_wdata51_d1[i*(1+`SCI_NBITS)*2+j];
	for(i=0; i<`NUM_OF_PU; i++) begin
		ras_empty[i] = ras_wptr[i]==ras_rptr[i];
		meta_empty[i] = meta_wptr[i]==meta_rptr[i];
		buf_ptr_empty[i] = buf_ptr_wptr[i]==buf_ptr_rptr[i];
	end
end

always @(posedge clk) begin
		pu_asa_data_d1 <= pu_asa_data;
		pu_asa_eop_d1 <= pu_asa_eop;
		pu_asa_pu_id_d1 <= pu_asa_pu_id;
		em_asa_buf_ptr_d1 <= em_asa_buf_ptr;
		em_asa_pu_id_d1 <= em_asa_pu_id;
		em_asa_len_d1 <= em_asa_len;
		em_asa_discard_d1 <= em_asa_discard;
		piarb_asa_meta_data_d1 <= piarb_asa_meta_data;
		piarb_asa_type3_d1 <= piarb_asa_type3;
		piarb_asa_pu_id_d1 <= piarb_asa_pu_id;
		piarb_asa_meta_data_d2 <= piarb_asa_meta_data_d1;
		piarb_asa_type3_d2 <= piarb_asa_type3_d1;
		piarb_asa_pu_id_d2 <= piarb_asa_pu_id_d1;

		pu_asa_start_d2 <= pu_asa_valid_d1?pu_asa_start_d1:pu_asa_start_d2;
		lat_fifo_din0_d1 <= pu_asa_start_d1&pu_asa_valid_d1?lat_fifo_din0:lat_fifo_din0_d1;
		ras_wdata51_d1 <= ras_wdata51;
		ras_wdata0 <= lat_fifo_rd_1st?lat_fifo_ras_flag:ras_wdata0;
		event_fifo_rdata_d1 <= event_fifo_rdata;

		type3_fifo_rdata_d1 <= type3_fifo_rdata;
end

always @(`CLK_RST) 
	if (`ACTIVE_RESET) begin
		pu_asa_start_d1 <= 1'b0;
		pu_asa_valid_d1 <= 1'b0;
		em_asa_valid_d1 <= 0;
		piarb_asa_valid_d1 <= 0;
		piarb_asa_valid_d2 <= 0;
		ras_wr_cnt <= 0;
		for(i=0; i<`NUM_OF_PU; i++) begin
			ras_wptr[i] <= 0;
			buf_ptr_wptr[i] <= 0;
			meta_wptr[i] <= 0;
			ras_rptr[i] <= 0;
			buf_ptr_rptr[i] <= 0;
			meta_rptr[i] <= 0;
		end
		event_fifo_rd_d1 <= 0;
		sel_type3_d1 <= 0;
	end else begin
		pu_asa_start_d1 <= pu_asa_start;
		pu_asa_valid_d1 <= pu_asa_valid;
		em_asa_valid_d1 <= em_asa_valid;
		piarb_asa_valid_d1 <= piarb_asa_valid;
		piarb_asa_valid_d2 <= piarb_asa_valid_d1;
		ras_wr_cnt <= ~ras_wr_one?ras_wr_cnt:lat_fifo_pu_asa_eop?0:ras_wr_cnt+1;
		for(i=0; i<`NUM_OF_PU; i++) begin
			ras_wptr[i] <= ras_wr&(lat_fifo_pu_asa_pu_id==i)?ras_wptr[i]+1:ras_wptr[i];
			buf_ptr_wptr[i] <= buf_ptr_wr&(em_asa_pu_id_d1==i)?buf_ptr_wptr[i]+1:buf_ptr_wptr[i];
			meta_wptr[i] <= meta_wr&(piarb_asa_pu_id_d2==i)?meta_wptr[i]+1:meta_wptr[i];
			ras_rptr[i] <= ras_rd&(event_fifo_rdata==i)?ras_rptr[i]+1:ras_rptr[i];
			buf_ptr_rptr[i] <= buf_ptr_rd&(event_fifo_rdata==i)?buf_ptr_rptr[i]+1:buf_ptr_rptr[i];
			meta_rptr[i] <= meta_rd&(event_fifo_rdata==i)?meta_rptr[i]+1:meta_rptr[i];
		end
		event_fifo_rd_d1 <= event_fifo_rd;
		sel_type3_d1 <= sel_type3;
	end

/***************************** FIFO ***************************************/


sfifo2f_fo #(`PU_ID_NBITS, `PU_ID_NBITS, `NUM_OF_PU) u_sfifo2f_fo_0(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({event_fifo_wdata}),               
        .rd(event_fifo_rd),
        .wr(event_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(event_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout({event_fifo_rdata})       
    );

sfifo_piarb_asa #(TYPE3_FIFO_DEPTH_NBITS) u_sfifo_piarb_asa_1(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din(type3_fifo_wdata),               
        .rd(type3_fifo_rd),
        .wr(type3_fifo_wr),

        .ncount(),
        .count(),
        .full(),
        .empty(type3_fifo_empty),
        .fullm1(),
        .emptyp2(),
        .dout(type3_fifo_rdata)       
    );

sfifo2f_fo #(`RAS_FLAG_NBITS, 1) u_sfifo2f_fo_2(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({lat_fifo_din1, lat_fifo_din0_d1}),               
        .rd(lat_fifo_rd_1st),
        .wr(pu_asa_valid_d1&~pu_asa_start_d1&pu_asa_start_d2),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({lat_fifo_ras_flag})               
    );

sfifo2f_fo #(2+1+`PU_ID_NBITS, 2) u_sfifo2f_fo_3(
        .clk(clk),
        .`RESET_SIG(`RESET_SIG),

        .din({invalid_rci, pu_asa_eop_d1, pu_asa_pu_id_d1}),               
        .rd(lat_fifo_rd),
        .wr(pu_asa_valid_d1&~pu_asa_start_d1&~pu_asa_start_d2),

        .ncount(),
        .count(),
        .full(),
        .empty(),
        .fullm1(),
        .emptyp2(),
        .dout({lat_fifo_invalid_rci, lat_fifo_pu_asa_eop, lat_fifo_pu_asa_pu_id})               
    );

/***************************** MEMORY ***************************************/

register_file #(RAS_WIDTH, RAM_DEPTH_NBITS, RAM_DEPTH) u_register_file_0(
		.clk(clk),
		.wr(ras_wr),
		.raddr(ras_raddr),
		.waddr(ras_waddr),
		.din(ras_wdata),

		.dout(ras_rdata));

register_file_piarb_asa #(RAM_DEPTH_NBITS, RAM_DEPTH) u_register_file_piarb_asa_1(
		.clk(clk),
		.wr(meta_wr),
		.raddr(meta_raddr),
		.waddr(meta_waddr),
		.din(mpiarb_asa_meta_data_d2),

		.dout(meta_rdata_struct));

register_file #(`EM_BUF_PTR_NBITS+1+LEN_NBITS, RAM_DEPTH_NBITS, RAM_DEPTH) u_register_file_2(
		.clk(clk),
		.wr(buf_ptr_wr),
		.raddr(buf_ptr_raddr),
		.waddr(buf_ptr_waddr),
		.din({em_asa_discard_d1, em_asa_len_d1, buf_ptr_wdata}),

		.dout({buf_ptr_discard, buf_ptr_len, buf_ptr_rdata}));


/***************************** DIAGNOSTICS **********************************/

// synopsys translate_off


// synopsys translate_on

endmodule

