
class dma_config extends uvm_object;

   int             dma_num;
   int             packet_num;

   rand bit [31:0] min_delay;
   rand bit [31:0] max_delay;

   `uvm_object_utils_begin(dma_config)
     `uvm_field_int      (min_delay, UVM_ALL_ON)
     `uvm_field_int      (max_delay, UVM_ALL_ON)
   `uvm_object_utils_end

   constraint default_const {
      min_delay   inside {[4:4]}; 
      max_delay   inside {[4:4]};
   }

   function new (string name = "dma_config");
     super.new (name);
     dma_num = 0;
     packet_num = 1;
   endfunction : new

endclass
