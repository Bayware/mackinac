`ifndef DMA_AGENT_PKG_SV
`define DMA_AGENT_PKG_SV

package dma_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import special_packet_pkg::*;

  `include "dma_config.svh"
  `include "dma_driver.svh"
  `include "dma_monitor.svh"
  `include "dma_agent.svh"
  `include "dma_sequence.svh"

endpackage

`endif 
