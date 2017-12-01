
class encap_traffic_class_reg extends uvm_reg;

   `uvm_object_utils( encap_traffic_class_reg )
 
   rand uvm_reg_field id;
   rand uvm_reg_field ttl;
   rand uvm_reg_field traffic_class;
 
   function new( string name = "encap_traffic_class_reg" );
      super.new( .name( name ), .n_bits( 32 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      traffic_class = uvm_reg_field::type_id::create("traffic_class");
      traffic_class.configure( .parent            ( this ),
                       .size                   ( 8    ),
                       .lsb_pos                ( 0    ),
                       .access                 ( "RW" ),
                       .volatile               ( 1    ),
                       .reset                  ( 0    ),
                       .has_reset              ( 1    ),
                       .is_rand                ( 1    ),
                       .individually_accessible( 0    ) );
   
   
      ttl = uvm_reg_field::type_id::create("ttl");
      ttl.configure( .parent            ( this ),
                       .size                   ( 8    ),
                       .lsb_pos                ( 8    ),
                       .access                 ( "RW" ),
                       .volatile               ( 1    ),
                       .reset                  ( 0    ),
                       .has_reset              ( 1    ),
                       .is_rand                ( 1    ),
                       .individually_accessible( 0    ) );
   
   
      id = uvm_reg_field::type_id::create("id");
      id.configure( .parent            ( this ),
                       .size                   ( 16    ),
                       .lsb_pos                ( 16    ),
                       .access                 ( "RW" ),
                       .volatile               ( 1    ),
                       .reset                  ( 0    ),
                       .has_reset              ( 1    ),
                       .is_rand                ( 1    ),
                       .individually_accessible( 0    ) );
   endfunction
endclass
