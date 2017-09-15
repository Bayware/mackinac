//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION :
//===========================================================================

`include "defines.vh"

module pio_bus (

input clk, 
input `RESET_SIG, 

input clk_axi, 

input [`PIO_RANGE] m_axil_awaddr,
input m_axil_awvalid,
output m_axil_awready,

input [`PIO_RANGE] m_axil_wdata,
input m_axil_wstrb,
input m_axil_wvalid,
output m_axil_wready,

output m_axil_bvalid,
input m_axil_bready,

input [`PIO_RANGE] m_axil_araddr,
input m_axil_arvalid,
output m_axil_arready,

output [`PIO_RANGE] m_axil_rdata,
output m_axil_rresp,
output m_axil_rvalid,
input m_axil_rready,

input [`NUM_OF_PIO-1:0] clk_div, 
input [`NUM_OF_PIO-1:0] pio_ack, 
input [`NUM_OF_PIO-1:0] pio_rvalid, 
input [`PIO_RANGE] pio_rdata[`NUM_OF_PIO-1:0],

output logic         pio_start,
output logic         pio_rw,
output logic [`PIO_RANGE] pio_addr_wdata,

output logic [`REAL_TIME_NBITS-1:0] current_time
);

/***************************** LOCAL VARIABLES *******************************/

integer i, j;

logic [`TIME_BASE_NBITS-1:0] time_base;

logic `RESET_SIG_AXI;

logic         pio_start_axi;
logic         pio_rw_axi;
logic [`PIO_RANGE] pio_addr_axi;
logic [`PIO_RANGE] pio_wdata_axi;

logic [3:0] sel_ack[`NUM_OF_PIO:0]; 
logic [3:0] sel_id[`NUM_OF_PIO:0]; 

logic [`PIO_RANGE] lat_pio_rdata[`NUM_OF_PIO-1:0];
logic [`NUM_OF_PIO-1:0] lat_pio_ack;
logic [`NUM_OF_PIO-1:0] lat_pio_rvalid; 

logic [`PIO_RANGE] latch_pio_rdata;
logic latch_pio_ack;
logic latch_pio_rvalid; 

logic l_pio_ack_d1; 
logic l_pio_rvalid_d1; 

logic waddr_fifo_full;
logic waddr_fifo_empty;
logic [`PIO_RANGE] waddr_fifo_data;

wire waddr_fifo_wr = m_axil_awvalid&m_axil_awready;

logic wdata_fifo_full;
logic wdata_fifo_empty;
logic [`PIO_RANGE] wdata_fifo_data;

wire wdata_fifo_wr = m_axil_wstrb&m_axil_wvalid&m_axil_wready;

logic raddr_fifo_full;
logic raddr_fifo_empty;
logic [`PIO_RANGE] raddr_fifo_data;

wire raddr_fifo_wr = m_axil_arvalid&m_axil_arready;

logic wr_start;

wire rd_start = ~raddr_fifo_empty&~wr_start;

wire raddr_fifo_rd = rd_start;

assign wr_start = ~waddr_fifo_empty&~wdata_fifo_empty&~rd_start;

wire waddr_fifo_rd = wr_start;
wire wdata_fifo_rd = wr_start;

logic rdata_fifo_full;
logic rdata_fifo_empty;
logic [`PIO_RANGE] rdata_fifo_data;

wire rdata_fifo_wr_clk = latch_pio_rvalid|l_pio_rvalid_d1;
logic pio_rvalid_axi;
logic pio_rvalid_axi_d1;
wire rdata_fifo_wr = pio_rvalid_axi&~pio_rvalid_axi_d1;

wire rdata_fifo_rd = m_axil_rvalid&m_axil_rready;

logic wresp_fifo_full;
logic wresp_fifo_empty;

wire wresp_fifo_wr_clk = latch_pio_ack|l_pio_ack_d1;
logic pio_ack_axi;
logic pio_ack_axi_d1;
wire wresp_fifo_wr = pio_ack_axi&~pio_ack_axi_d1;

wire wresp_fifo_rd = m_axil_bvalid&m_axil_bready;

logic start;
logic start_d1;
logic start_d2;

wire pio_start1_p1 = start&~start_d1;
wire pio_start1_p2 = start_d1&~start_d2&pio_rw_axi;

/***************************** NON REGISTERED OUTPUTS ************************/

assign m_axil_awready = ~waddr_fifo_full;
assign m_axil_wready = ~wdata_fifo_full;
assign m_axil_arready = ~raddr_fifo_full;
assign m_axil_rresp = rdata_fifo_rd;
assign m_axil_rvalid = ~rdata_fifo_empty;
assign m_axil_bvalid = ~wresp_fifo_empty;

/***************************** REGISTERED OUTPUTS ****************************/

always @(posedge clk) begin
  pio_rw <= pio_rw_axi;
  pio_addr_wdata <= pio_start1_p1?pio_addr_axi:pio_wdata_axi;
end

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
	  pio_start <= 1'b0;
	  current_time <= 0;
	end else begin
	  pio_start <= pio_start1_p1|pio_start1_p2;
	  current_time <= current_time+(&time_base);
	end
end

/***************************** PROGRAM BODY **********************************/

synchronizer u_synchronizer_0(.clk(clk_axi), .din(`RESET_SIG), .dout(`RESET_SIG_AXI));
synchronizer u_synchronizer_1(.clk(clk_axi), .din(rdata_fifo_wr_clk), .dout(pio_rvalid_axi));
synchronizer u_synchronizer_2(.clk(clk_axi), .din(wresp_fifo_wr_clk), .dout(pio_ack_axi));
synchronizer u_synchronizer_3(.clk(clk), .din(pio_start_axi), .dout(start));


always @(*) begin
	sel_ack[0] = 0;
	sel_id[0] = 0;
	for(i=0; i<`NUM_OF_PIO; i++) begin
		sel_ack[i+1] = lat_pio_ack[i]?i:sel_ack[i];
		sel_id[i+1] = lat_pio_rvalid[i]?i:sel_id[i];
	end
end

always @(posedge clk) begin

	for(i=0; i<`NUM_OF_PIO; i++) 
		lat_pio_rdata[i] <= clk_div[i]&pio_rvalid[i]?pio_rdata[i]:lat_pio_rdata[i];
	latch_pio_rdata <= lat_pio_rvalid[sel_id[`NUM_OF_PIO]]?lat_pio_rdata[sel_id[`NUM_OF_PIO]]:latch_pio_rdata;
end

always @(`CLK_RST) begin
	if(`ACTIVE_RESET) begin
		lat_pio_ack <= 0;
		lat_pio_rvalid <= 0;
		time_base <= 0;
		latch_pio_ack <= 0;
		l_pio_ack_d1 <= 0;
		latch_pio_rvalid <= 0;
		l_pio_rvalid_d1 <= 0;
		start_d1 <= 0;
		start_d2 <= 0;
	end else begin
		for(i=0; i<`NUM_OF_PIO; i++) begin
			lat_pio_ack[i] <= clk_div[i]?pio_ack[i]:lat_pio_ack[i];
			lat_pio_rvalid[i] <= clk_div[i]?pio_rvalid[i]:lat_pio_rvalid[i];
		end
		time_base <= time_base+1;
		latch_pio_ack <= lat_pio_ack[sel_ack[`NUM_OF_PIO]];
		l_pio_ack_d1 <= latch_pio_ack;
		latch_pio_rvalid <= lat_pio_rvalid[sel_id[`NUM_OF_PIO]];
		l_pio_rvalid_d1 <= latch_pio_rvalid;
		start_d1 <= start;
		start_d2 <= start_d1;
	end
end

always @(posedge clk_axi) begin
  pio_rw_axi <= rd_start|wr_start?wr_start:pio_rw_axi;
  pio_addr_axi <= rd_start?raddr_fifo_data:wr_start?waddr_fifo_data:pio_addr_axi;
  pio_wdata_axi <= wr_start?wdata_fifo_data:pio_wdata_axi;
end

always @(`CLK_RST_AXI) begin
	if(`ACTIVE_RESET_AXI) begin
  		pio_start_axi <= 1'b0;
  		pio_rvalid_axi_d1 <= 1'b0;
  		pio_ack_axi_d1 <= 1'b0;
	end else begin
  		pio_start_axi <= rd_start|wr_start;
  		pio_rvalid_axi_d1 <= pio_rvalid_axi;
  		pio_ack_axi_d1 <= pio_ack_axi;
	end
end

sfifo1f #(`PIO_NBITS) u_sfifo1f_0(
        .clk(clk_axi),
        .`RESET_SIG(`RESET_SIG_AXI),

        .din({m_axil_awaddr}),
        .rd(waddr_fifo_rd),
        .wr(waddr_fifo_wr),

        .full(waddr_fifo_full),
        .empty(waddr_fifo_empty),
        .dout({waddr_fifo_data})
);

sfifo1f #(`PIO_NBITS) u_sfifo1f_1(
        .clk(clk_axi),
        .`RESET_SIG(`RESET_SIG_AXI),

        .din({m_axil_wdata}),
        .rd(wdata_fifo_rd),
        .wr(wdata_fifo_wr),

        .full(wdata_fifo_full),
        .empty(wdata_fifo_empty),
        .dout({wdata_fifo_data})
);

sfifo1f #(`PIO_NBITS) u_sfifo1f_2(
        .clk(clk_axi),
        .`RESET_SIG(`RESET_SIG_AXI),

        .din({m_axil_araddr}),
        .rd(raddr_fifo_rd),
        .wr(raddr_fifo_wr),

        .full(raddr_fifo_full),
        .empty(raddr_fifo_empty),
        .dout({raddr_fifo_data})
);

sfifo1f #(`PIO_NBITS) u_sfifo1f_3(
        .clk(clk_axi),
        .`RESET_SIG(`RESET_SIG_AXI),

        .din({latch_pio_rdata}),
        .rd(rdata_fifo_rd),
        .wr(rdata_fifo_wr),

        .full(rdata_fifo_full),
        .empty(rdata_fifo_empty),
        .dout({m_axil_rdata})
);

sfifo1f #(1) u_sfifo1f_4(
        .clk(clk_axi),
        .`RESET_SIG(`RESET_SIG_AXI),

        .din({pio_ack_axi}),
        .rd(wresp_fifo_rd),
        .wr(wresp_fifo_wr),

        .full(wresp_fifo_full),
        .empty(wresp_fifo_empty),
        .dout()
);

endmodule

