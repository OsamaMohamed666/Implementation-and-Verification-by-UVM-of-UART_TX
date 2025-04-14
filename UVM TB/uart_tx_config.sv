class uart_config extends uvm_object;
  `uvm_object_utils(uart_config)

  bit parity_en;
  bit parity_type;
  virtual uart_intf vif;

  function new(string name = "uart_config");
    super.new(name);
  endfunction
endclass