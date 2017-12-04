create_clock -name clk_mac -period 3.2 [get_ports clk_mac]
create_clock -name clk_axi -period 8 [get_ports clk_axi]
create_clock -name clk -period 3.2 [get_ports clk]

set_clock_groups -asynchronous -group clk_mac -group clk_axi
set_clock_groups -asynchronous -group clk_mac -group clk
set_clock_groups -asynchronous -group clk -group clk_axi

set_input_delay -clock [get_clocks clk_mac] 2.0 [get_ports {rx_axis_tdata*[*]} ]

set_output_delay -clock [get_clocks clk_mac] 1.0 [get_ports {tx_axis_tdata*[*]} ]

set_input_delay -clock [get_clocks clk_axi] 4.0 [get_ports {{m_axil_araddr[*]} {m_axil_awaddr[*]} {m_axil_wdata[*]} m_axil_wstrb m_axil_wvalid m_axil_awvalid m_axil_bready m_axil_rready {m_axis_h2c_tdata_x*[*]} m_axis_h2c_tlast_x0 m_axis_h2c_tlast_x1 m_axis_h2c_tlast_x2 m_axis_h2c_tlast_x3 m_axis_h2c_tvalid_x0 m_axis_h2c_tvalid_x1 m_axis_h2c_tvalid_x2 m_axis_h2c_tvalid_x3 s_axis_c2h_tready_x0 s_axis_c2h_tready_x1 s_axis_c2h_tready_x2 s_axis_c2h_tready_x3}]

set_output_delay -clock [get_clocks clk_axi] 1.0 [get_ports {m_axil_arready m_axil_awready m_axil_bvalid {m_axil_rdata[*]} m_axil_rresp m_axil_rvalid m_axil_wready m_axis_h2c_tready_x* {s_axis_c2h_tdata_x*[*]} s_axis_c2h_tlast_x* s_axis_c2h_tvalid_x*}]

set_multicycle_path -setup -end -from [get_pins {u_*/u_*_pio/pio_rvalid_reg/C u_*/u_*_reg/pio_rvalid_reg/C}] -to [get_pins {u_pio_bus/lat_pio_rvalid_reg*/D}] 1

set_multicycle_path -setup -end -from [get_pins {u_*/u_*_pio/pio_ack_reg/C u_*/u_*_reg/pio_ack_reg/C}] -to [get_pins {u_pio_bus/lat_pio_ack_reg*/D}] 1

set_multicycle_path -setup -end -from [get_pins {{u_*/u_pio_*mem*/app_mem_rdata_reg[*]/C} {u_*/u_*_mem_*/u_pio_*mem*/app_mem_rdata_reg*/C}} ] -to [get_pins {u_pio_bus/lat_pio_rdata_reg*/D}] 4


