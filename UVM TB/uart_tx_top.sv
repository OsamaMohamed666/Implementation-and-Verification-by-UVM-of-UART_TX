`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_intf.sv"
`include "uart_test.sv"

module tb_top;
bit tx_clk;
bit rst;
always #5 tx_clk = ~tx_clk;

initial begin
tx_clk = 0;
rst = 0;
#20; 
rst = 1;
end




uart_intf vif (tx_clk,rst);

UART_TX dut(
.RST(rst),
.CLK(tx_clk),
.P_DATA(vif.tx_in_p),
.Data_Valid(vif.tx_in_v),
.TX_OUT(vif.tx_out_s),
.busy(vif.tx_out_busy),
.parity_enable(vif.parity_en),
.parity_type(vif.parity_type)
);
initial begin
//set interface in config_db
uvm_config_db#(virtual uart_intf)::set(uvm_root::get(), "*", "vif", vif);
$dumpfile("dump.vcd");
$dumpvars;
end
initial begin
	run_test("uart_test");
end
endmodule 

