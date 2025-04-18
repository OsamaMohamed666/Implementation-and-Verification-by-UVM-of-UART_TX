module serializer (

  input          clk,
  input          rst,
  input  [7:0]   p_data,
  input          ser_en,
  output reg     ser_done,
  output reg     ser_data  
);

integer N;

reg  [7:0] registers;
reg  [7:0] seed = 8'b0;

reg  [2:0] counter;

always @(posedge clk or negedge rst)
  begin 
   if(!rst)
    begin
	 registers<=seed;
	 counter <=0;
    end 
   else if (!ser_en)
	begin 
	 registers[7:0] <= p_data[7:0];
	 counter <=0;
	end
   else
	begin
     registers <= registers >> 1'b1;
	 counter <= counter +3'b1;
	end	
  end

assign ser_data = registers[0];
assign ser_done = (counter==3'b111)? 1 : 0;
  
endmodule
