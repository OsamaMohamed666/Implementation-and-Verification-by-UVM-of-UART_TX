module parity_calc (

input           clk,
input           rst,
input           data_valid,
input           par_type,
input           par_en,
input			busy,
input    [7:0]  p_data,
output reg      par_bit

);

reg [7:0] p_data_temp;
wire  even_par , odd_par; 

always @(posedge clk or negedge rst)
  begin
    if(!rst)
	 begin
	  par_bit <= 0;
	  p_data_temp <= 0;
	 end 
	else if (data_valid && !busy)
	 p_data_temp <= p_data;
	else if (par_en)
	 begin 
	  if(par_type)
	   par_bit <= odd_par;
	  else
	   par_bit <= even_par;	
	 end 
  end
   
assign odd_par = (^p_data_temp==0) ? 1 : 0;
assign even_par = (^p_data_temp) ? 1 : 0;
endmodule

