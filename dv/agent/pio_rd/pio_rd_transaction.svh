  class pio_rd_transaction extends uvm_sequence_item;
    rand bit[31:0] addr;
    rand bit[31:0] data;

    `uvm_object_utils_begin(pio_rd_transaction)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint pio_rd_default_const {
    }

    function new(string name="pio_rd_transaction");
      super.new(name);
    endfunction

  endclass
