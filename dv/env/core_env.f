+incdir+${UVM_HOME}/src
+incdir+${DV_TOP}/agent/mac
+incdir+${DV_TOP}/agent/dma
+incdir+${DV_TOP}/agent/pio_wr
+incdir+${DV_TOP}/agent/pio_rd
+incdir+${DV_TOP}/env
+incdir+${DV_TOP}/test
+incdir+${RTL_TOP}/include

${DV_TOP}/agent/mac/mac_if.sv
${DV_TOP}/agent/dma/dma_if.sv
${DV_TOP}/agent/pio_wr/pio_wr_if.sv
${DV_TOP}/agent/pio_rd/pio_rd_if.sv

${DV_TOP}/ral/ral_pkg.sv
${DV_TOP}/agent/packet/special_packet_pkg.sv
${DV_TOP}/agent/mac/mac_agent_pkg.sv
${DV_TOP}/agent/dma/dma_agent_pkg.sv
${DV_TOP}/agent/pio_wr/pio_wr_agent_pkg.sv
${DV_TOP}/agent/pio_rd/pio_rd_agent_pkg.sv
${DV_TOP}/env/core_env_pkg.sv
${DV_TOP}/test/core_test_pkg.sv

${DV_TOP}/env/core_tb.sv
-f ${DV_TOP}/env/core_rtl.f
