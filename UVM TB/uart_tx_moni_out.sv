class uart_monitor_out extends uvm_monitor;
`uvm_component_utils(uart_monitor_out)
uvm_analysis_port #(seq_item) item_collect_port_out;
uart_config cfg;
seq_item mon_out_item;
virtual uart_intf vif;

function new(string name = "uart_monitor_out", uvm_component parent = null);
	super.new(name, parent);
	item_collect_port_out = new("item_collect_port_out", this);
	mon_out_item = new();
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(uart_config) :: get(this, "", "uart_cfg", cfg))
	`uvm_fatal(get_type_name(), "Failed to get uart_cfg from config DB");
endfunction

function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	vif=cfg.vif;
endfunction  

task run_phase (uvm_phase phase);
	forever begin
		wait(vif.rst_n);
		tx_monitor_out();
	end
endtask

task tx_monitor_out();
	@(negedge vif.tx_clk iff(vif.tx_out_busy))
		mon_out_item.tx_out_s = vif.tx_out_s;
		mon_out_item.tx_out_busy = vif.tx_out_busy;
		`uvm_info(get_type_name(), $sformatf(" serial data is %0b when busy = %b",mon_out_item.tx_out_s,mon_out_item.tx_out_busy), UVM_MEDIUM)
		item_collect_port_out.write(mon_out_item);
endtask


endclass

