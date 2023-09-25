module i2s_tx #(
	parameter DATA_RES = 24
) (
	input logic mclk, sclk, lrclk,
	input logic [DATA_RES-1:0] i_ldin,i_rdin,
	input next_lrclk_rise,
	input next_lrclk_fall,
	input next_sclk_rise,
    output logic o_sdout,
	input logic reset
);

//Counter to implement the parallel load signal to load in the parallel data on the second s clock after
//LRCLCK Toggles 

logic parallel_load; 
logic count;

logic [DATA_RES-1:0] temp;

always @(posedge mclk) begin 
	
	if (reset) begin
		count <= 0;
		parallel_load <= 1'b0;
		temp <= 24'b0;
		o_sdout<= 0; 
	end
	
	else if (!reset) begin
		count <= 0;
	
		if (parallel_load) begin
			count <= count - 1'b1;
		end 
	
		if(next_lrclk_fall || next_lrclk_rise)begin 
			parallel_load <= 1'b1; 
			count <= 1'b1;
		end 

		else if (!count) begin
			parallel_load <= 1'b0;
		end

		if (!parallel_load && next_sclk_rise) begin
			temp <= temp << 1'b1; 
			o_sdout <= temp[DATA_RES-1]; 
		end
	
		if(parallel_load && lrclk)begin 
			temp <= i_rdin;
		end 
		
		else if(parallel_load && !lrclk)begin 
			temp <= i_ldin; 
		end 

	end
	
end 

//Parallel In Serial Out Shift Register

/*always @(posedge mclk)begin 

end*/ 

endmodule