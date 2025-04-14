class uart_env extends uvm_env;
`uvm_component_utils(uart_env)
uart_agent agt;
uart_scoreboard sb;
//uart_coverage cov;
 
function new(string name = "uart_env", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
	agt = uart_agent::type_id::create("agt", this);
  sb = uart_scoreboard#(8,11,10)::type_id::create("sb", this);
	//cov = uart_coverage::type_id::create("cov", this);
endfunction

function void connect_phase(uvm_phase phase);
	agt.mon_in.item_collect_port.connect(sb.item_collect_export_in);
	agt.mon_out.item_collect_port_out.connect(sb.item_collect_export_out);
	//agt.mon_in.item_collect_port.connect(cov.item_collect_export_in);
	//agt.mon_out.item_collect_port_out.connect(cov.item_collect_export_out);
endfunction
endclass