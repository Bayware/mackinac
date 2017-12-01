`ifndef CORE_PORT_QUEUE_SVH
`define CORE_PORT_QUEUE_SVH

class core_port_queue extends uvm_object;

   special_packet port_queue [`NUM_OF_PORTS] [$];

endclass

`endif
