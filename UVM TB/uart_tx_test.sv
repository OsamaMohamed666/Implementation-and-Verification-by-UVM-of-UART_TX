`include "uart_package.sv"
class uart_test extends uvm_test;
uart_env env;
base_seq bseq;
//direct_seq dseq;
uart_config cfg;
`uvm_component_utils(uart_test)

function new(string name = "uart_test", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = uart_env::type_id::create("env", this);
	cfg = uart_config::type_id::create("cfg");
	cfg.parity_en = 1'b1;  // Initially enabled
	cfg.parity_type = 1'b1;    // Initially odd parity
	if (!uvm_config_db#(virtual uart_intf)::get(this, "", "vif", cfg.vif))
      `uvm_fatal(get_type_name(), "Failed to get vif from config DB")
    // Store config object in config_db
      uvm_config_db#(uart_config)::set(null, "*", "uart_cfg", cfg);
endfunction

task run_phase(uvm_phase phase);
	phase.raise_objection(this);
	bseq = base_seq::type_id::create("bseq");
	
	// First stimuls without  parity 
	cfg.parity_en = 1'b0; 
  `uvm_info(get_type_name(), "Starting test without parity", UVM_LOW)
	bseq.no_stimuls =50;
	bseq.start(env.agt.seqr);
	#100 // delay for scoreboard to finish its calculation
	
	// new stimuls with odd parity 
	$display("----------------------------------------------------------------------------------------------------------");
	$display("----------------------------------------------------------------------------------------------------------");
	
	cfg.parity_en = 1'b1; 
  `uvm_info(get_type_name(), "Starting test with parity_type = 1 (Odd)", UVM_LOW)
	bseq.no_stimuls =150;
	bseq.start(env.agt.seqr);
	#100	
	
	// new stimuls with even parity 
	$display("----------------------------------------------------------------------------------------------------------");
	$display("----------------------------------------------------------------------------------------------------------");
	cfg.parity_type = 1'b0; 
  `uvm_info(get_type_name(), "Starting test with parity_type = 0 (even)", UVM_LOW)
	bseq.no_stimuls =150;
	bseq.start(env.agt.seqr);
	phase.drop_objection(this);
endtask

//END OF ELABORATION PHASE
virtual function void end_of_elaboration();
uvm_top.print_topology();
endfunction

//REPORT PHASE 
virtual function void report_phase(uvm_phase phase);
	uvm_report_server svr;
	super.report_phase(phase);
 
	svr = uvm_report_server::get_server();
	if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
		`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
		`uvm_info("Report_Phase", "----TEST FAIL----", UVM_NONE)
    	`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
	end
	else begin
		`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
		`uvm_info("Report_Phase", "---- TEST PASS ----", UVM_NONE)
		`uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
	end
endfunction 
endclass