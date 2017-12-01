`ifndef CORETB_SV_DEF
`define CORETB_SV_DEF

`include "defines.vh"

module core_tb;

  import uvm_pkg::*;

  import mac_agent_pkg::*;
  import dma_agent_pkg::*;
  import pio_wr_agent_pkg::*;
  import pio_rd_agent_pkg::*;

  import core_env_pkg::*;
  import core_test_pkg::*;

  mac_if mac0_rx_if ();
  mac_if mac1_rx_if ();
  dma_if dma0_rx_if ();
  dma_if dma1_rx_if ();
  dma_if dma2_rx_if ();
  dma_if dma3_rx_if ();

  mac_if mac0_tx_if ();
  mac_if mac1_tx_if ();
  dma_if dma0_tx_if ();
  dma_if dma1_tx_if ();
  dma_if dma2_tx_if ();
  dma_if dma3_tx_if ();

  pio_wr_if  core_pio_wr_if();
  pio_rd_if  core_pio_rd_if();

  reg clk, `RESET_SIG;

  reg clk_mac, clk_axi;


  initial begin
    clk = 1;
    forever #1.6ns clk = ~clk;
  end

  initial begin
    clk_mac = 0;
    forever #1.6ns clk_mac = ~clk_mac;
  end

  initial begin
    clk_axi = 0;
    forever #4ns clk_axi = ~clk_axi;
  end

  initial begin
    `RESET_SIG = `ACTIVE_RESET_LEVEL;
    $display ("<%0d>: assert reset signal",$time);
    repeat (50) @ (posedge clk);
    $display ("<%0d>: de-assert reset signal",$time);
    `RESET_SIG = `INACTIVE_RESET_LEVEL;
  end

  assign mac0_rx_if.reset_n = `RESET_SIG;
  assign mac0_rx_if.clk = clk_mac;
  assign mac0_rx_if.ready = 1'b1;
  assign mac1_rx_if.reset_n = `RESET_SIG;
  assign mac1_rx_if.clk = clk_mac;
  assign mac1_rx_if.ready = 1'b1;
  assign dma0_rx_if.reset_n = `RESET_SIG;
  assign dma0_rx_if.clk = clk_axi;
  assign dma1_rx_if.reset_n = `RESET_SIG;
  assign dma1_rx_if.clk = clk_axi;
  assign dma2_rx_if.reset_n = `RESET_SIG;
  assign dma2_rx_if.clk = clk_axi;
  assign dma3_rx_if.reset_n = `RESET_SIG;
  assign dma3_rx_if.clk = clk_axi;

  assign mac0_tx_if.reset_n = `RESET_SIG;
  assign mac0_tx_if.clk = clk_mac;
  assign mac0_tx_if.ready = 1'b1;
  assign mac1_tx_if.reset_n = `RESET_SIG;
  assign mac1_tx_if.clk = clk_mac;
  assign mac1_tx_if.ready = 1'b1;
  assign dma0_tx_if.reset_n = `RESET_SIG;
  assign dma0_tx_if.clk = clk_axi;
  assign dma0_tx_if.ready = 1'b1;
  assign dma1_tx_if.reset_n = `RESET_SIG;
  assign dma1_tx_if.clk = clk_axi;
  assign dma1_tx_if.ready = 1'b1;
  assign dma2_tx_if.reset_n = `RESET_SIG;
  assign dma2_tx_if.clk = clk_axi;
  assign dma2_tx_if.ready = 1'b1;
  assign dma3_tx_if.reset_n = `RESET_SIG;
  assign dma3_tx_if.clk = clk_axi;
  assign dma3_tx_if.ready = 1'b1;

  assign core_pio_wr_if.reset_n = `RESET_SIG;
  assign core_pio_wr_if.clk = clk_axi;
  assign core_pio_rd_if.reset_n = `RESET_SIG;
  assign core_pio_rd_if.clk = clk_axi;


  mackinac_bw u_mackinac_bw (
    .clk(clk), 
    .`RESET_SIG(`RESET_SIG), 

    .clk_mac(clk_mac), 
    .clk_axi(clk_axi), 

    .rx_axis_tdata0(mac0_rx_if.data),
    .rx_axis_tkeep0(mac0_rx_if.keep),
    .rx_axis_tvalid0(mac0_rx_if.valid),
    .rx_axis_tuser0(mac0_rx_if.user),
    .rx_axis_tlast0(mac0_rx_if.last),

    .rx_axis_tdata1(mac1_rx_if.data),
    .rx_axis_tkeep1(mac1_rx_if.keep),
    .rx_axis_tvalid1(mac1_rx_if.valid),
    .rx_axis_tuser1(mac1_rx_if.user),
    .rx_axis_tlast1(mac1_rx_if.last),

    .m_axis_h2c_tvalid_x0(dma0_rx_if.valid),
    .m_axis_h2c_tlast_x0(dma0_rx_if.last),
    .m_axis_h2c_tdata_x0(dma0_rx_if.data),

    .m_axis_h2c_tready_x0(dma0_rx_if.ready),

    .m_axis_h2c_tvalid_x1(dma1_rx_if.valid),
    .m_axis_h2c_tlast_x1(dma1_rx_if.last),
    .m_axis_h2c_tdata_x1(dma1_rx_if.data),

    .m_axis_h2c_tready_x1(dma1_rx_if.ready),

    .m_axis_h2c_tvalid_x2(dma2_rx_if.valid),
    .m_axis_h2c_tlast_x2(dma2_rx_if.last),
    .m_axis_h2c_tdata_x2(dma2_rx_if.data),

    .m_axis_h2c_tready_x2(dma2_rx_if.ready),

    .m_axis_h2c_tvalid_x3(dma3_rx_if.valid),
    .m_axis_h2c_tlast_x3(dma3_rx_if.last),
    .m_axis_h2c_tdata_x3(dma3_rx_if.data),

    .m_axis_h2c_tready_x3(dma3_rx_if.ready),

    .tx_axis_tdata0(mac0_tx_if.data),
    .tx_axis_tkeep0(mac0_tx_if.keep),
    .tx_axis_tvalid0(mac0_tx_if.valid),
    .tx_axis_tuser0(mac0_tx_if.user),
    .tx_axis_tlast0(mac0_tx_if.last),

    .tx_axis_tready0(mac0_tx_if.ready),

    .tx_axis_tdata1(mac1_tx_if.data),
    .tx_axis_tkeep1(mac1_tx_if.keep),
    .tx_axis_tvalid1(mac1_tx_if.valid),
    .tx_axis_tuser1(mac1_tx_if.user),
    .tx_axis_tlast1(mac1_tx_if.last),

    .tx_axis_tready1(mac1_tx_if.ready),

    .s_axis_c2h_tvalid_x0(dma0_tx_if.valid),
    .s_axis_c2h_tlast_x0(dma0_tx_if.last),
    .s_axis_c2h_tdata_x0(dma0_tx_if.data),
    .s_axis_c2h_tready_x0(dma0_tx_if.ready),

    .s_axis_c2h_tvalid_x1(dma1_tx_if.valid),
    .s_axis_c2h_tlast_x1(dma1_tx_if.last),
    .s_axis_c2h_tdata_x1(dma1_tx_if.data),
    .s_axis_c2h_tready_x1(dma1_tx_if.ready),

    .s_axis_c2h_tvalid_x2(dma2_tx_if.valid),
    .s_axis_c2h_tlast_x2(dma2_tx_if.last),
    .s_axis_c2h_tdata_x2(dma2_tx_if.data),
    .s_axis_c2h_tready_x2(dma2_tx_if.ready),

    .s_axis_c2h_tvalid_x3(dma3_tx_if.valid),
    .s_axis_c2h_tlast_x3(dma3_tx_if.last),
    .s_axis_c2h_tdata_x3(dma3_tx_if.data),
    .s_axis_c2h_tready_x3(dma3_tx_if.ready),

    .m_axil_awaddr(core_pio_wr_if.addr),
    .m_axil_awvalid(core_pio_wr_if.avalid),
    .m_axil_awready(core_pio_wr_if.aready),

    .m_axil_wdata(core_pio_wr_if.data),
    .m_axil_wstrb(core_pio_wr_if.strb),
    .m_axil_wvalid(core_pio_wr_if.dvalid),
    .m_axil_wready(core_pio_wr_if.dready),

    .m_axil_bvalid(core_pio_wr_if.bvalid),
    .m_axil_bready(core_pio_wr_if.bready),

    .m_axil_araddr(core_pio_rd_if.addr),
    .m_axil_arvalid(core_pio_rd_if.avalid),
    .m_axil_arready(core_pio_rd_if.aready),

    .m_axil_rdata(core_pio_rd_if.data),
    .m_axil_rresp(core_pio_rd_if.resp),
    .m_axil_rvalid(core_pio_rd_if.dvalid),
    .m_axil_rready(core_pio_rd_if.dready)

);

  initial begin
     uvm_config_db#(virtual mac_if)::set(null, "uvm_test_top*env.mac0_rx_agt", "mac_if", mac0_rx_if);
     uvm_config_db#(virtual mac_if)::set(null, "uvm_test_top*env.mac1_rx_agt", "mac_if", mac1_rx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma0_rx_agt", "dma_if", dma0_rx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma1_rx_agt", "dma_if", dma1_rx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma2_rx_agt", "dma_if", dma2_rx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma3_rx_agt", "dma_if", dma3_rx_if);

     uvm_config_db#(virtual mac_if)::set(null, "uvm_test_top*env.mac0_tx_agt", "mac_if", mac0_tx_if);
     uvm_config_db#(virtual mac_if)::set(null, "uvm_test_top*env.mac1_tx_agt", "mac_if", mac1_tx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma0_tx_agt", "dma_if", dma0_tx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma1_tx_agt", "dma_if", dma1_tx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma2_tx_agt", "dma_if", dma2_tx_if);
     uvm_config_db#(virtual dma_if)::set(null, "uvm_test_top*env.dma3_tx_agt", "dma_if", dma3_tx_if);

     uvm_config_db#(virtual pio_wr_if)::set(null, "uvm_test_top*env.core_pio_wr_agt", "pio_wr_if", core_pio_wr_if);
     uvm_config_db#(virtual pio_rd_if)::set(null, "uvm_test_top*env.core_pio_rd_agt", "pio_rd_if", core_pio_rd_if);

     run_test();
  end

endmodule

`endif
