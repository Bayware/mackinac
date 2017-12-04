
class encap_mac_sa_msb_reg extends uvm_reg;

   `uvm_object_utils( encap_mac_sa_msb_reg )
 
   rand uvm_reg_field mac_sa_msb;
 
   function new( string name = "encap_mac_sa_msb_reg" );
      super.new( .name( name ), .n_bits( 16 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new
 
   virtual function void build();
      mac_sa_msb = uvm_reg_field::type_id::create("mac_sa_msb");
      mac_sa_msb.configure( .parent            ( this ),
                       .size                   ( 16    ),
                       .lsb_pos                ( 0    ),
                       .access                 ( "RW" ),
                       .volatile               ( 1    ),
                       .reset                  ( 0    ),
                       .has_reset              ( 1    ),
                       .is_rand                ( 1    ),
                       .individually_accessible( 1    ) );
   endfunction
endclass
