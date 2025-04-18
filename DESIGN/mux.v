module mux (
input       clk,
input       rst,
input       start_bit,
input       stop_bit,
input       ser_data,
input       par_bit,
input [1:0] mux_sel,
output reg  TX_OUT

);

reg TX_OUT_temp;

always@(posedge clk or negedge rst)
 begin
  if(!rst)
   TX_OUT<=0;
  else 
   TX_OUT<=TX_OUT_temp;
 end

always @(*)
 begin
    case (mux_sel)
     2'b00 : TX_OUT_temp=start_bit;
     2'b01 : TX_OUT_temp=ser_data;
     2'b10 : TX_OUT_temp=par_bit;
     2'b11 : TX_OUT_temp=stop_bit;
	 default: TX_OUT_temp=1'b1;
    endcase 
 end


endmodule 
