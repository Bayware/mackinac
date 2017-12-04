
class encap_tunnel_hash_table_mem extends uvm_vreg;

   `uvm_object_utils( encap_tunnel_hash_table_mem )
 
   rand uvm_vreg_field valid;
   rand uvm_vreg_field hash_idx0;
   rand uvm_vreg_field value_ptr0;
   rand uvm_vreg_field hash_idx1;
   rand uvm_vreg_field value_ptr1;
 
   function new( string name = "encap_tunnel_hash_table_mem" );
      super.new( .name( name ), .n_bits( `TUNNEL_HASH_BUCKET_NBITS ));
   endfunction: new
 
   virtual function void build();

      valid = uvm_vreg_field::type_id::create("valid");
      valid.configure( .parent            ( this ),
                       .size                   ( 1    ),
                       .lsb_pos                ( 0    ) );
   
      hash_idx0 = uvm_vreg_field::type_id::create("hash_idx0");
      hash_idx0.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_HASH_TABLE_DEPTH_NBITS    ),
                       .lsb_pos                ( 1    ) );
   
      value_ptr0 = uvm_vreg_field::type_id::create("value_ptr0");
      value_ptr0.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_DEPTH_NBITS    ),
                       .lsb_pos                ( 1+`TUNNEL_HASH_TABLE_DEPTH_NBITS    ) );
   
      hash_idx1 = uvm_vreg_field::type_id::create("hash_idx1");
      hash_idx1.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_HASH_TABLE_DEPTH_NBITS    ),
                       .lsb_pos                ( 1+`TUNNEL_HASH_TABLE_DEPTH_NBITS+`TUNNEL_VALUE_DEPTH_NBITS    ) );
   
      value_ptr1 = uvm_vreg_field::type_id::create("value_ptr1");
      value_ptr1.configure( .parent            ( this ),
                       .size                   ( `TUNNEL_VALUE_DEPTH_NBITS    ),
                       .lsb_pos                ( 1+`TUNNEL_HASH_TABLE_DEPTH_NBITS+`TUNNEL_VALUE_DEPTH_NBITS+`TUNNEL_HASH_TABLE_DEPTH_NBITS    ) );
   endfunction
endclass
