class uart_driver extends uvm_driver#(seq_item);
`uvm_component_utils(uart_driver)
uart_config cfg;
virtual uart_intf vif;

function new(string name = "uart_driver", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(uart_config)::get(this, "", "uart_cfg", cfg))
      `uvm_fatal(get_type_name(), "Failed to get uart_cfg from config DB")

endfunction

function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
	vif = cfg.vif;
endfunction 

task run_phase (uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		// CONFIGUERED SIGNALS
		req.parity_en <= cfg.parity_en;
		req.parity_type <= cfg.parity_type;
		//DRIVING SIGNALS
		vif.parity_en <= req.parity_en;
		vif.parity_type <= req.parity_type;
		tx_drive();
		seq_item_port.item_done();
	end
endtask

task tx_drive();
	@(negedge vif.tx_clk) 
	//DRIVING INPUTS
		vif.tx_in_p <= req.tx_in_p;
		vif.tx_in_v <= req.tx_in_v;
	//DRIVING OUTPUTS
	@(negedge vif.tx_clk )
		req.tx_out_busy <= vif.tx_out_busy ;
		req.tx_out_s <= vif.tx_out_s;

endtask 
endclass

