`include "mux.v"
`include "parity_calc.v"
`include "Serializer.v"
`include "uart_tx_fsm.v"

module UART_TX  (

 input   wire                 			   CLK,
 input   wire                 			   RST,
 input   wire     [7:0]		               P_DATA,
 input   wire                 		  	   Data_Valid,
 input   wire                 			   parity_enable,
 input   wire                 			   parity_type, 
 output  wire                 			   TX_OUT,
 output  wire                 			   busy

 );

wire ser_en, ser_done, ser_dat, parity;
			
wire  [1:0]   mux_sel ;
  
FSM U0_fsm (
.clk(CLK),
.rst(RST),
.data_valid(Data_Valid), 
.par_en(parity_enable),
.ser_done(ser_done), 
.ser_en(ser_en),
.mux_sel(mux_sel), 
.busy(busy)
);
  
serializer U0_Serializer (
.clk(CLK),
.rst(RST),
.p_data(P_DATA),
.ser_en(ser_en), 
.ser_data(ser_data),
.ser_done(ser_done)
);

mux U0_mux (
.clk(CLK),
.rst(RST),
.start_bit(1'b0),
.stop_bit(1'b1),
.ser_data(ser_data),
.par_bit(parity),
.mux_sel(mux_sel),
.TX_OUT(TX_OUT) 
);
  
parity_calc U0_parity_calc (
.clk(CLK),
.rst(RST),
.par_en(parity_enable),
.par_type(parity_type),
.p_data(P_DATA),
.data_valid(Data_Valid), 
.busy(busy), 
.par_bit(parity)
); 



endmodule
 
