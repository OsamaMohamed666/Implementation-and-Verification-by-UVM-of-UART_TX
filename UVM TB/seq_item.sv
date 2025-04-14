class seq_item # (parameter DATA_WIDTH=8) extends uvm_sequence_item;
  

//FOR BOTH 
 bit parity_en;
 bit parity_type;


// for TX
randc bit [DATA_WIDTH-1:0] tx_in_p;
rand bit tx_in_v;
// OUTPUT
logic tx_out_s;
logic tx_out_busy;

function new(string name = "seq_item");
    super.new(name);
endfunction

// UTILITY AND FIELD MACROS 
`uvm_object_utils_begin(seq_item)  
	`uvm_field_int(parity_en,UVM_ALL_ON)
	`uvm_field_int(parity_type,UVM_ALL_ON)
	`uvm_field_int(tx_in_p,UVM_ALL_ON)
	`uvm_field_int(tx_in_v,UVM_ALL_ON)
`uvm_object_utils_end 
	

//******************CONSTRAINTS****************

// FIRST constraint for tx input valid to be one for one clock cycle as SPECS
static bit prev_sig; //used to track previous value of valid  
constraint one_cycle_high {prev_sig == 1 -> tx_in_v == 0;}  // Ensure signal goes high only if it was low

function void post_randomize();
	prev_sig = tx_in_v;  // Update the previous state after randomization
endfunction

// SECOND using weighting technique as most of time i don't care when valid is one as tx is busy
//  constraint tx_input_valid_randomization { tx_in_v dist {1:=10 , 0:=90};}
  constraint tx_input_valid_randomization { !parity_en -> tx_in_v dist {1:=5 , 0:=95};}




endclass