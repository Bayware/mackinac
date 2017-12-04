`ifndef RAL_PKG_SV
`define RAL_PKG_SV

package ral_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "defines.vh"
  `include "encap_flow_label_reg.svh"
  `include "encap_mac_sa_lsb_reg.svh"
  `include "encap_mac_sa_msb_reg.svh"
  `include "encap_traffic_class_reg.svh"
  `include "encap_reg_block.svh"
  `include "encap_mem_block.svh"
  `include "decap_mem_block.svh"
  `include "irl_mem_block.svh"
  `include "class_mem_block.svh"
  `include "asa_mem_block.svh"
  `include "tm_mem_block.svh"

endpackage

`endif
