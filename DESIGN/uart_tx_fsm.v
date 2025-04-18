module FSM (

input            clk, 
input            rst,
input            data_valid,
input            ser_done,
input            par_en,
output reg [1:0] mux_sel,
output reg       busy,
output reg       ser_en

);

localparam   idle  = 3'b000,
             start  = 3'b001,
             serial = 3'b010,
			 parity = 3'b011,
			 stop   = 3'b100;
			 
reg [2:0]  current_state , next_state;

reg busy_tmp;

always @(posedge clk or negedge rst)
  begin
    if(!rst)
      begin
        current_state<=idle;
		busy <= busy_tmp;
      end
    else 
      begin 
	   busy <= busy_tmp;
	   current_state<=next_state;
      end
   end


//NEXT STATE LOGIC & OUTPUT LOGIC
always@(*)
  begin
    ser_en = 1'b0;
	mux_sel = 2'b00;
	busy_tmp = 0;
    case(current_state)
    idle : begin
			mux_sel=2'b11;
			if (data_valid)
			 next_state = start;
			else 
			 next_state = current_state;
    	   end

    start : begin
			 busy_tmp=1'b1;
			 next_state= serial;
			end
       
	serial :begin
			 ser_en =1'b1;
	         mux_sel=2'b01;
             busy_tmp=1'b1;
			 if(ser_done) 
			  begin
			   ser_en=1'b0;
			   if(par_en)
				next_state=parity;
			   else 
			    next_state = stop;
			  end 
			 else
			  next_state=current_state;
			end
                
	parity :begin
            mux_sel=2'b10;
            busy_tmp=1'b1;
			next_state=stop;
			end
	stop :  begin
	        mux_sel=2'b11;
            busy_tmp=1'b1;
			next_state=idle;
			end
	default : next_state=idle;	
	endcase
  end
			
          	
endmodule
