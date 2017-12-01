`ifndef CORE_TEST_BASE_SVH
`define CORE_TEST_BASE_SVH

import uvm_pkg::*;
import core_env_pkg::*;

class core_test_base extends bay_test_base;

  core_env env;

  `uvm_component_utils_begin(core_test_base)
  `uvm_component_utils_end

  function new (string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  extern virtual function void build_phase (uvm_phase phase);
  extern virtual task reset_phase (uvm_phase phase);
  extern virtual task configure_phase (uvm_phase phase);
  extern virtual task post_main_phase (uvm_phase phase);

endclass

function void core_test_base::build_phase (uvm_phase phase);

  super.build_phase (phase);
  env = core_env::type_id::create("env", this);
  uvm_top.print_topology();

endfunction

task core_test_base::reset_phase (uvm_phase phase);

  super.reset_phase (phase);
  phase.raise_objection (this);

  #10ns;

  phase.drop_objection (this);

endtask

task core_test_base::configure_phase (uvm_phase phase);

  super.configure_phase (phase);
  phase.raise_objection (this);

  #10ns;

  phase.drop_objection (this);

endtask
task core_test_base::post_main_phase (uvm_phase phase);

  super.post_main_phase (phase);
  phase.raise_objection (this);

  #10ns;
  
  phase.drop_objection (this);

endtask
`endif
