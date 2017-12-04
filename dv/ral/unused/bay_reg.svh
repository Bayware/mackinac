
virtual class bay_reg extends uvm_reg;

   bit memory;
   int memory_offset;

   extern function new (string name="", int unsigned n_bits, int has_coverage);

endclass : bay_reg

function bay_reg::new (string name="", int unsigned n_bits, int has_coverage);
   super.new(name, n_bits, has_coverage);
   this.memory = 0;
   this.memory_offset = 0;
endfunction
