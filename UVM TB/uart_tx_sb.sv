`uvm_analysis_imp_decl(_MON_IN)
`uvm_analysis_imp_decl(_MON_OUT)
class uart_scoreboard #(parameter DATA_WIDTH = 8 ,parity_data_width = 11,non_parity_data_width =10)extends uvm_scoreboard;
uvm_analysis_imp_MON_IN #(seq_item, uart_scoreboard) item_collect_export_in;
uvm_analysis_imp_MON_OUT #(seq_item, uart_scoreboard) item_collect_export_out;
seq_item item_in[$],item_out[$];
`uvm_component_utils(uart_scoreboard)

function new(string name = "uart_scoreboard", uvm_component parent = null);
	super.new(name, parent);
	item_collect_export_in = new("item_collect_export_in", this);
	item_collect_export_out = new("item_collect_export_out", this);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

function void write_MON_IN(seq_item req);
	item_in.push_back(req);
endfunction
 
function void write_MON_OUT(seq_item req);
	item_out.push_back(req); //busy = 1
endfunction


int cnt_crr,cnt_err; // counter for correct and incorrect outputs
bit  [DATA_WIDTH-1:0]  out_exp_tmp; 
//int parity_data_width = DATA_WIDTH+3; //width of data after adding start bit , parity and stop bit
//int non_parity_data_width = DATA_WIDTH+2; //width of data after adding start bit and stop bit
bit  [parity_data_width-1:0]  out_exp,out_tmp; 
bit  [parity_data_width-1:0]  parity_out_tmp; 
bit  [non_parity_data_width-1:0]  non_parity_out_tmp; 

bit done_processing = 0;	//used to detect that scoreboard processing finished or not to end the phase 


virtual task run_phase (uvm_phase phase);
seq_item sb_item;
forever begin
	tx_scoreboard(sb_item);
	
	$display("----------------------------------------------------------------------------------------------------------");
end
endtask

virtual task tx_scoreboard(seq_item sb_item);
	integer DATA_WIDTH_OUTPUT;
	//EXTRACTING THE INPUT 
	bit [DATA_WIDTH-1:0] p_data_reverse; //used to reverse p_data as in specs its serialized from LSB to MSB
	wait(item_in.size>0);
	done_processing = 0; // to provide end phase function to complete the scoreboard functionlity 
	$display("----------------------------------------------------------------------------------------------------------");
	sb_item = item_in.pop_front();
	out_exp_tmp = sb_item.tx_in_p;
	`uvm_info(get_type_name(), $sformatf(" parallel data before REVERSING is %b ", out_exp_tmp), UVM_MEDIUM)
	//REVERSING DATA
	for (int i = 0; i < 8; i++)
		p_data_reverse[i] = out_exp_tmp[7 - i];
		`uvm_info(get_type_name(), $sformatf(" parallel data after REVERSING is %b ", p_data_reverse), UVM_MEDIUM)
	//GETTING EXPECTED OUTPUT  
	if (sb_item.parity_en) begin // PARITY IS ENABLED OUTPUT EXPECTED TO BE 11 BITS
		if(sb_item.parity_type) 
			out_exp = {1'b0,p_data_reverse,odd_parity_check(out_exp_tmp),1'b1};
		else 
			out_exp = {1'b0,p_data_reverse,even_parity_check(out_exp_tmp),1'b1};
	end 
	else  //PARITY IS DISABLED OUTPUT EXPECTED TO BE 10 BITS
		out_exp = {1'b0,p_data_reverse,1'b1};

	`uvm_info(get_type_name(), $sformatf(" Expected data is %b, ", out_exp), UVM_MEDIUM)
		 
	// ACTUAL OUTPUT 
	DATA_WIDTH_OUTPUT = sb_item.parity_en? parity_data_width : non_parity_data_width; // check that output will be 11 bits or 10 bits according to parity enable
	for (int i=0; i<DATA_WIDTH_OUTPUT; i++) begin
		wait(item_out.size>0);
		sb_item = item_out.pop_front();
		
		if(sb_item.parity_en)
			parity_out_tmp = {parity_out_tmp[parity_data_width-2:0],sb_item.tx_out_s};
		else 
			non_parity_out_tmp = {non_parity_out_tmp[non_parity_data_width-2:0],sb_item.tx_out_s};
			
		`uvm_info(get_type_name(), $sformatf(" Serial output no.[%0d] = %b, ",i, sb_item.tx_out_s),UVM_MEDIUM)
	end 
	
	out_tmp = sb_item.parity_en? parity_out_tmp:non_parity_out_tmp;	// output for the checker 
	
	// CALCULATE SUCCESSFUL AND FAILED TRANSACTIONS
	if (out_exp != out_tmp) begin
		cnt_err++;
		`uvm_error(get_type_name(), $sformatf("Incorrect output, expected is = %b and out is = %b, ", out_exp, out_tmp))
	end
	else begin
		cnt_crr++;
		`uvm_info(get_type_name(), $sformatf("Correct output, expected is = %b and out is = %b, ", out_exp, out_tmp),UVM_LOW)
	end
	done_processing = 1;
endtask 

function bit odd_parity_check(bit [DATA_WIDTH-1:0] x);
bit out;
out = ~(^x);
return out;
endfunction

function bit even_parity_check(bit [DATA_WIDTH-1:0] x);
bit out;
out = (^x);
return out;
endfunction

virtual function void phase_ready_to_end(uvm_phase phase);
	if (!done_processing  ) begin
      `uvm_info(get_type_name(), "Scoreboard not done yet, delaying phase end...", UVM_LOW)
      phase.raise_objection(this, "Waiting for scoreboard to finish...");

      fork	begin
          // Wait for processing to complete
          wait (done_processing == 1);
        `uvm_info(get_type_name(), "Scoreboard done, dropping objection", UVM_LOW)
          phase.drop_objection(this, "Scoreboard finished processing");
	  end
      join_none
    end
endfunction

	
//REPORT PHASE
function void report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info("Report_Phase", $sformatf("Successful checks: %0d", cnt_crr), UVM_LOW)
	`uvm_info("Report_Phase", $sformatf("Unsuccessful checks: %0d", cnt_err), UVM_LOW)
endfunction
endclass