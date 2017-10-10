//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : buffer release control
//===========================================================================

`include "defines.vh"

module bm_buf_release (


input clk, 
input `RESET_SIG,

input init_read_count_valid, 
input [`BUF_PTR_NBITS-1:0] init_read_count_ptr,

input read_count_valid, 
input [`PORT_ID_NBITS-1:0] read_count_port_id,
input [`BUF_PTR_NBITS-1:0] read_count_buf_ptr,
input [`READ_COUNT_NBITS-1:0] read_count,


input tm_rel_buf_valid,
input [`PORT_ID_NBITS-1:0] tm_rel_buf_port_id,
input [`BUF_PTR_NBITS-1:0] tm_rel_buf_ptr,

output reg rel_buf_valid,
output reg [`PORT_ID_NBITS-1:0] rel_buf_port_id,
output reg [`BUF_PTR_NBITS-1:0] rel_buf_ptr
);

/***************************** LOCAL VARIABLES *******************************/

reg	init_read_count_valid_d1;
reg [`BUF_PTR_NBITS-1:0] init_read_count_ptr_d1;

reg	read_count_valid_d1;
reg [`PORT_ID_NBITS-1:0] read_count_port_id_d1;
reg [`BUF_PTR_NBITS-1:0] read_count_buf_ptr_d1;
reg [`READ_COUNT_NBITS-1:0] read_count_d1;
reg [`READ_COUNT_NBITS-1:0] read_count_set;

reg rel_req_d1;
reg rel_req_d2;
reg rel_req_d3;

reg [`BUF_PTR_NBITS-1:0] rel_ctr_raddr;
reg [`BUF_PTR_NBITS-1:0] rel_ctr_raddr_d1;
reg [`BUF_PTR_NBITS-1:0] rel_ctr_waddr_p1;
reg [`BUF_PTR_NBITS-1:0] rel_ctr_waddr;
reg [`BUF_PTR_NBITS-1:0] rel_ctr_waddr_d1;
reg [`BUF_PTR_NBITS-1:0] rel_ctr_waddr_d2;

reg [`PORT_ID_NBITS-1:0] rel_req_port_id_d1;
reg [`PORT_ID_NBITS-1:0] rel_req_port_id_d2;
reg [`PORT_ID_NBITS-1:0] rel_req_port_id_d3;

reg rel_ctr_wr;
reg rel_ctr_wr_d1;
reg rel_ctr_wr_d2;

reg [`READ_COUNT_NBITS-1:0] rel_ctr_wdata;
reg [`READ_COUNT_NBITS-1:0] rel_ctr_wdata_d1;
reg [`READ_COUNT_NBITS-1:0] rel_ctr_wdata_d2;

reg [`READ_COUNT_NBITS-1:0] rd_cnt_d1;
reg [`READ_COUNT_NBITS-1:0] rel_ctr_rdata_d1;

reg rd_snoop_hit0;
reg rd_snoop_hit12;
reg [`READ_COUNT_NBITS-1:0] mrel_ctr_wdata;

wire [`READ_COUNT_NBITS-1:0] rd_cnt  /* synthesis DONT_TOUCH */;

wire [`READ_COUNT_NBITS-1:0] rel_ctr_rdata  /* synthesis DONT_TOUCH */;

wire [`BUF_PTR_NBITS-1:0] fifo_buf_ptr;
wire [`PORT_ID_NBITS-1:0] fifo_port_id;
wire fifo_empty;

wire [`READ_COUNT_NBITS-1:0] mrel_ctr_rdata;

wire same_value = rd_cnt_d1==mrel_ctr_rdata;

/***************************** NON REGISTERED OUTPUTS ************************/

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
		rel_buf_port_id <= rel_req_port_id_d3;
		rel_buf_ptr <= rel_ctr_waddr_p1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		rel_buf_valid <= 0;
	end else begin
		rel_buf_valid <= rel_req_d3&same_value;
	end

/***************************** PROGRAM BODY **********************************/

wire rel_ctr_wr_p1 = rel_req_d3|init_read_count_valid_d1;

wire [`BUF_PTR_NBITS-1:0] rel_ctr_waddr_p2 = rel_ctr_raddr_d1;

wire[2:0] rd_snoop_hit_p1;
assign rd_snoop_hit_p1[2] = rel_ctr_wr_d1&(rel_ctr_waddr_p2==rel_ctr_waddr_d1);
assign rd_snoop_hit_p1[1] = rel_ctr_wr&(rel_ctr_waddr_p2==rel_ctr_waddr);
assign rd_snoop_hit_p1[0] = rel_ctr_wr_p1&(rel_ctr_waddr_p2==rel_ctr_waddr_p1);

wire [`READ_COUNT_NBITS-1:0] mrel_ctr_wdata_p1 = rd_snoop_hit_p1[1]?rel_ctr_wdata:rel_ctr_wdata_d1;

assign mrel_ctr_rdata =
				rd_snoop_hit0?rel_ctr_wdata:
				rd_snoop_hit12?mrel_ctr_wdata:
				rel_ctr_rdata_d1;

wire [`READ_COUNT_NBITS-1:0] nrel_ctr_wdata = same_value?{(`READ_COUNT_NBITS){1'b1}}:mrel_ctr_rdata;

wire fifo_rd = ~fifo_empty&~tm_rel_buf_valid;

wire rel_req = tm_rel_buf_valid|~fifo_empty;
wire [`BUF_PTR_NBITS-1:0] rel_req_ptr = tm_rel_buf_valid?tm_rel_buf_ptr:fifo_buf_ptr;
wire [`PORT_ID_NBITS-1:0] rel_req_port_id = tm_rel_buf_valid?tm_rel_buf_port_id:fifo_port_id;

always @(posedge clk) begin
		init_read_count_ptr_d1 <= init_read_count_ptr;
		
	    read_count_d1 <= read_count;
		
		read_count_set <= (read_count==0)?0:read_count-1;
		read_count_port_id_d1 <= read_count_port_id;
		read_count_buf_ptr_d1 <= read_count_buf_ptr;

		rel_ctr_raddr <= rel_req_ptr;
		rel_ctr_raddr_d1 <= rel_ctr_raddr;
		rel_ctr_waddr_p1 <= rel_ctr_raddr_d1;
		rel_ctr_waddr <= init_read_count_valid_d1?init_read_count_ptr_d1:rel_ctr_waddr_p1;
		rel_ctr_waddr_d1 <= rel_ctr_waddr;
		rel_ctr_waddr_d2 <= rel_ctr_waddr_d1;

		rel_req_port_id_d1 <= rel_req_port_id;
		rel_req_port_id_d2 <= rel_req_port_id_d1;
		rel_req_port_id_d3 <= rel_req_port_id_d2;

		rel_ctr_wdata <= init_read_count_valid_d1?0:nrel_ctr_wdata+1;
		rel_ctr_wdata_d1 <= rel_ctr_wdata;
		rel_ctr_wdata_d2 <= rel_ctr_wdata_d1;

		rd_cnt_d1 <= rd_cnt;
		rel_ctr_rdata_d1 <= rel_ctr_rdata;

		rd_snoop_hit0 <= rd_snoop_hit_p1[0];
		rd_snoop_hit12 <= |rd_snoop_hit_p1[2:1];
		mrel_ctr_wdata <= mrel_ctr_wdata_p1;
end

always @(`CLK_RST) 
    if (`ACTIVE_RESET) begin
		init_read_count_valid_d1 <= 0;
		read_count_valid_d1 <= 0;
		rel_req_d1 <= 0;
		rel_req_d2 <= 0;
		rel_req_d3 <= 0;
		rel_ctr_wr <= 0;
		rel_ctr_wr_d1 <= 0;
		rel_ctr_wr_d2 <= 0;
	end else begin
		init_read_count_valid_d1 <= init_read_count_valid;
		read_count_valid_d1 <= read_count_valid;
		rel_req_d1 <= rel_req;	
		rel_req_d2 <= rel_req_d1;
		rel_req_d3 <= rel_req_d2;
		rel_ctr_wr <= rel_ctr_wr_p1;
		rel_ctr_wr_d1 <= rel_ctr_wr;
		rel_ctr_wr_d2 <= rel_ctr_wr_d1;
	end

/***************************** FIFO ***************************************/

sfifo2f_fo #(`BUF_PTR_NBITS+`PORT_ID_NBITS, 2) u_sfifo2f_fo(
		.clk(clk),
		.`RESET_SIG(`RESET_SIG),

		.din({read_count_buf_ptr_d1, read_count_port_id_d1}),				
		.rd(fifo_rd),
		.wr(read_count_valid_d1&(read_count_d1==0)),

		.ncount(),
		.count(),
		.full(),
		.empty(fifo_empty),
		.fullm1(),
		.emptyp2(),
		.dout({fifo_buf_ptr, fifo_port_id})       
	);

/***************************** MEMORY ***************************************/
ram_1r1w_ultra #(`READ_COUNT_NBITS, `BUF_PTR_NBITS) u_ram_1r1w_ultra_0(
        .clk(clk),
        .wr(read_count_valid_d1),
        .raddr(rel_ctr_raddr),
		.waddr(read_count_buf_ptr_d1),
        .din(read_count_set),

        .dout(rd_cnt));

ram_1r1w_ultra #(`READ_COUNT_NBITS, `BUF_PTR_NBITS) u_ram_1r1w_ultra_1(
        .clk(clk),
        .wr(rel_ctr_wr),
        .raddr(rel_ctr_raddr),
		.waddr(rel_ctr_waddr),
        .din(rel_ctr_wdata),

        .dout(rel_ctr_rdata));

/***************************** DIAGNOSTICS **********************************/
// synopsys translate_off

// synopsys translate_on

endmodule

