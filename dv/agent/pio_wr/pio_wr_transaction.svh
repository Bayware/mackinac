  class pio_wr_transaction extends uvm_sequence_item;
    rand bit[31:0] addr;
    rand bit[31:0] data;

    `uvm_object_utils_begin(pio_wr_transaction)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint pio_wr_default_const {
    }

    function new(string name="pio_wr_transaction");
      super.new(name);
    endfunction

  endclass
