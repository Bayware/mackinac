`ifndef MAC_AGENT_PKG_SV
`define MAC_AGENT_PKG_SV

package mac_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import special_packet_pkg::*;

  `include "mac_config.svh"
  `include "mac_driver.svh"
  `include "mac_monitor.svh"
  `include "mac_agent.svh"
  `include "mac_sequence.svh"

endpackage

`endif
