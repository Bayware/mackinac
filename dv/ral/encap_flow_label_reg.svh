
class encap_flow_label_reg extends uvm_reg;

   `uvm_object_utils( encap_flow_label_reg )
 
   rand uvm_reg_field flow_label;
 
   function new( string name = "encap_flow_label_reg" );
      super.new( .name( name ), .n_bits( 20 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      flow_label = uvm_reg_field::type_id::create("flow_label");
      flow_label.configure( .parent            ( this ),
                       .size                   ( 20    ),
                       .lsb_pos                ( 0    ),
                       .access                 ( "RW" ),
                       .volatile               ( 1    ),
                       .reset                  ( 0    ),
                       .has_reset              ( 1    ),
                       .is_rand                ( 1    ),
                       .individually_accessible( 1    ) );
   endfunction
endclass
