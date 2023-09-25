module clockdiv (
	input logic reset,
    input logic MCLK,
    output logic SCLK,
    output logic LRCLK,

    output next_sclk_rise,
    output next_sclk_fall,
	 
    output next_lrclk_rise,
    output next_lrclk_fall
);

// 8 MCLK cycles per 1 SCLK, 64 SCLK cycles per 1 LRCLK
// S/L = 64

//invert every half cycle of the target clock rate

logic [2:0] counter_4;
logic [8:0] counter_256;

//logic sclk_value = 0;
//logic lrclk_value = 0;


always @ (posedge MCLK) begin
	if (reset) begin
		//Why? 
		//LRCLK = 1'b1; 
		 LRCLK = 1'b0;
		 SCLK = 1'b0;
		//SCLK = 1'b0; 
		counter_4 = 3'd3;
		counter_256 = 9'd255;
	end
	else if (!reset) begin
	if (counter_4 != 3'b0) begin
		//count down
		counter_4 <= counter_4 - 1'b1;
		end
		
	else if (counter_4 == 3'b0) begin
		//SCLK should do something
		//reset counter back to 7
		//sclk_value <= !sclk_value;
		SCLK <= !SCLK;
		counter_4 <= 3'd3;
		end
		
	if (counter_256 != 0) begin
		//count down
		counter_256 <= counter_256 - 1'b1;
		end
	else if (counter_256 == 0) begin
		//LRCLK should do something
		//lrclk_value <= !lrclk_value;
		LRCLK <= !LRCLK;
		//reset counter back to 255
		counter_256 <= 9'd255;
	end
end
end
	
assign next_sclk_rise = ~(SCLK)&&(counter_4 == 1'b0);
assign next_sclk_fall = (SCLK)&&(counter_4 == 1'b0);
assign next_lrclk_rise = ~(LRCLK)&&(counter_256 == 1'b0);
assign next_lrclk_fall = (LRCLK)&&(counter_256 == 1'b0);

endmodule