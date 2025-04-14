interface uart_intf #(parameter DATA_WIDTH =8)
(input tx_clk,rst_n);
 
bit parity_en;
bit parity_type;


// INPUT
bit [DATA_WIDTH-1:0] tx_in_p;
bit tx_in_v;
// OUTPUT
logic tx_out_s;
logic tx_out_busy;


// ASSSERTIONS 
//1) RESET 
property reset_checking;
	@(posedge tx_clk)
	!rst_n |-> tx_out_s==0;
endproperty 
assert property(reset_checking)
	else `uvm_error("ASSERTIONS" ,$sformatf(" RESET STATE IS VIOLATED AT %0t ns",$time));
RESET_CHECKING:cover property(reset_checking);

//2) STARTING BIT 
property starting_bit_checking;
	@(negedge tx_clk) disable iff(!rst_n)
	$rose(tx_in_v) |-> !(tx_out_busy) |=> (tx_out_s==0);
endproperty
assert property (starting_bit_checking)
	else `uvm_error("ASSERTIONS",$sformatf(" STARTING BIT ISNOT EQUAL ZERO"));
STARTING_BIT_CHECKING:cover property (starting_bit_checking);

//3) STOP BIT 
property stop_bit_checking;
	@(negedge tx_clk) disable iff(!rst_n)
	$fell(tx_out_busy) |-> $past(tx_out_s==1);
endproperty
assert property (stop_bit_checking)
	else `uvm_error("ASSERTIONS",$sformatf(" STOP BIT ISNOT EQUAL ONE"));
STOP_BIT_CHECKING:cover property (stop_bit_checking);
  
//**************************WITHOUT PARITY*****************************
//4) BUSY SIGNAL 
property busy_signal_checking_non_par;
	@(negedge tx_clk) disable iff(!rst_n)
  $rose(tx_in_v) |-> (!parity_en && !tx_out_busy) |=> $rose(tx_out_busy) ##1 tx_out_busy[*9]; 
endproperty
assert property(busy_signal_checking_non_par)
	 else `uvm_error("ASSERTIONS",$sformatf(" BUSY SIGNAL IS NOT HIGH FOR 10 CYCLES IN NON PARITY"));
BUSY_SIGNAL_CHECKING_NON_PAR:cover property(busy_signal_checking_non_par);

//**************************WITH PARITY*****************************
//5) BUSY SIGNAL 
property busy_signal_checking_par;
	@(negedge tx_clk) disable iff(!rst_n)
  $rose(tx_in_v) |-> (parity_en && !tx_out_busy) |-> ##1 tx_out_busy[*11]; 
endproperty
assert property(busy_signal_checking_par)
	 else `uvm_error("ASSERTIONS",$sformatf(" BUSY SIGNAL IS NOT HIGH FOR 11 CYCLES IN PARITY"));
BUSY_SIGNAL_CHECKING_PAR:cover property(busy_signal_checking_par);
	


endinterface 

