class uart_monitor_in extends uvm_monitor;
`uvm_component_utils(uart_monitor_in)
uvm_analysis_port #(seq_item) item_collect_port;
uart_config cfg;
seq_item mon_in_item;
virtual uart_intf vif;

function new(string name = "uart_monitor_in", uvm_component parent = null);
	super.new(name, parent);
	item_collect_port = new("item_collect_port", this);
	mon_in_item = new();
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
		mon_in_item.parity_type = cfg.parity_type;
		mon_in_item.parity_en = cfg.parity_en;
		tx_monitor_in();
	end
endtask

task tx_monitor_in();
	//wait (vif.tx_in_v && !vif.tx_out_busy);
	//		`uvm_info(get_type_name(), $sformatf(" 11parallel data is %b when busy = %0b and data valid = %0d",vif.tx_in_p,vif.tx_out_busy,vif.tx_in_v), UVM_MEDIUM)

  @(negedge vif.tx_clk iff (vif.tx_in_v && !vif.tx_out_busy));
		mon_in_item.tx_in_p = vif.tx_in_p;
		mon_in_item.tx_in_v = vif.tx_in_v;
		`uvm_info(get_type_name(), $sformatf(" parallel data is %b when busy = %0b and data valid = %0d",mon_in_item.tx_in_p,vif.tx_out_busy,mon_in_item.tx_in_v), UVM_MEDIUM)
		item_collect_port.write(mon_in_item);
endtask


endclass
