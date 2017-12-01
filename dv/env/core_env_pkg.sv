`ifndef CORE_ENV_PKG_SV
`define CORE_ENV_PKG_SV

package core_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import ral_pkg::*;
  import special_packet_pkg::*;
  import mac_agent_pkg::*;
  import dma_agent_pkg::*;
  import pio_wr_agent_pkg::*;
  import pio_rd_agent_pkg::*;

  `include "defines.vh"
  `include "core_config.svh"
  `include "core_port_queue.svh"
  `include "core_scoreboard.svh"
  `include "core_env.svh"

endpackage

`endif
