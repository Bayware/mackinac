
class mac_config extends uvm_object;

   int             mac_num;
   int             packet_num;

   rand bit [31:0] min_delay;
   rand bit [31:0] max_delay;

   `uvm_object_utils_begin(mac_config)
     `uvm_field_int      (min_delay, UVM_ALL_ON)
     `uvm_field_int      (max_delay, UVM_ALL_ON)
   `uvm_object_utils_end

   constraint default_const {
      min_delay   inside {[6:6]}; 
      max_delay   inside {[6:6]};
   }

   function new (string name = "mac_config");
     super.new (name);
     mac_num = 0;
     packet_num = 1;
   endfunction : new

endclass : mac_config
