class pio_wr_config extends uvm_object;

   virtual pio_wr_if pio_wr_0;

   rand bit [31:0]  min_delay;
   rand bit [31:0]  max_delay;

   `uvm_object_utils_begin(pio_wr_config)
     `uvm_field_int      (min_delay, UVM_ALL_ON)
     `uvm_field_int      (max_delay, UVM_ALL_ON)
   `uvm_object_utils_end

   constraint default_const {
      min_delay   inside {[0:4]};
      max_delay   inside {[4:8]};
      max_delay > min_delay;
   }

   function new (string name = "pio_wr_config");
     super.new (name);
   endfunction : new

endclass
