
import uvm_pkg::*;

`include "xml_report_server.svh"

class bay_test_base extends uvm_test;

  xml_report_server xml_reporter;
  string test_name;

  function new (string name, uvm_component parent = null);
    super.new(name, parent);
    test_name = name;
  endfunction

  extern virtual function void build_phase (uvm_phase phase);
  extern virtual function void end_of_elaboration_phase (uvm_phase phase);

endclass

function void bay_test_base::build_phase (uvm_phase phase);
  super.build_phase (phase);
  xml_reporter = new(test_name);
endfunction

function void bay_test_base::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
  xml_reporter.enable_xml_logging();
endfunction
