//===========================================================================
// ===========================================================================================
// $File:$
// $Revision:$
// DESCRIPTION : 
//===========================================================================

`include "defines.vh"

package table_package; 

typedef struct { 

	logic valid;
	logic [`RCI_VALUE_DEPTH_NBITS-1:0] value_ptr;
	logic [`RCI_HASH_TABLE_DEPTH_NBITS-1:0] hash_idx;

} rci_hash_entry; 

typedef struct { 

	rci_hash_entry entry0;
	rci_hash_entry entry1;

} rci_hash_bucket; 


typedef struct { 

	logic [`RCI_KEY_NBITS-1:0] key;
	logic [`RCI_NBITS-1:0] rci;

} rci_value_entry; 


endpackage
