module i2s_rx #(
	parameter DATA_RES = 24
) (
	input logic mclk, sclk, lrclk, i_sdata, next_lrclk_fall, next_lrclk_rise, next_sclk_fall, next_sclk_rise,
	output logic [DATA_RES-1:0] o_left, o_right,
	input logic reset
);

//Counter to implement the shift_enable signal that signifies to start shifting 
//Data received from i_sdata into the paralell data, temp
//goes high on second SCLK after lrclk toggles,
//stays high for 24 SCLKS then goes low. 
logic shift_enable; 
logic [4:0] counter_32; 
logic [DATA_RES-1:0] temp_left;
logic [DATA_RES-1:0] temp_right;
logic count;
logic [DATA_RES-1:0] temp;

initial begin 
	counter_32 = 5'd31;
end 

/*always @(posedge sclk) begin 
	if(counter_32 != 1'b0)begin 
		counter_32 <= counter_32-1'b1; 
	end 

	else if (counter_32 == 5'b0)begin
		counter_32 <= 5'd31;  
	end 
end */

always @(posedge mclk) begin
	if (reset) begin
		counter_32 <= 5'd31;
		temp <= 24'b0;
		o_left <= 24'b0;
		o_right <= 24'b0;
		temp_left <= 24'b0;
	end

else if (!reset) begin
	if (count) begin
		if(counter_32 != 1'b0)begin 
			counter_32 <= counter_32-1'b1; 
		end 
		else if (counter_32 == 5'b0)begin
			counter_32 <= 5'd31;  
		end
	end

	if (shift_enable) begin
		temp <= temp << 1;
		temp[0] <= i_sdata;
	end
	if (next_lrclk_rise) begin
			temp_left <= temp; 
	end
	if (next_lrclk_fall) begin	
			o_right <= temp;
			o_left <= temp_left;
	end
end
end

assign shift_enable = (((counter_32 <= 5'd30) && (counter_32 >= 5'd7)) && next_sclk_fall) ? 1'b1: 1'b0; 
assign count = (next_sclk_rise) ? 1 : 0;

//Counter to iplement the control signal valid, that will tell us to output our left and right data on the 
//very last MLCK cycle at the end of a frame. 
//logic valid;  

/*
always @(posedge mclk) begin 
	if (next_lrclk_fall) begin
		o_left <= temp_left;
		o_right <= temp_right;
	end
end 
*/


/*always @(posedge sclk) begin
	if (shift_enable) begin
		temp <= temp << 1;
		temp[0] <= i_sdata;
	end
	if (done) begin
		if (!lrclk) begin
			o_left <= temp;
		end
		else begin	
			o_right <= temp;
		end
	end
end*/



endmodule