`ifndef CORE_CONFIG_SVH
`define CORE_CONFIG_SVH

class core_config extends uvm_object;

   bit [31:0] timeout;

   `uvm_object_utils_begin(core_config)
     `uvm_field_int (timeout, UVM_ALL_ON)
   `uvm_object_utils_end

   function new (string name = "core_config");
     super.new (name);
     timeout = 100000000;
   endfunction : new

endclass
`endif
