 module top(	
	//////////// CLOCK 1: 3.3-V LVTTL //////////
	input 		          		MAX10_CLK1_50,
	//////////// SEG7: 3.3-V LVTTL //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,
	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
	input 		     [1:0]		KEY,
	//////////// LED: 3.3-V LVTTL //////////
	output		     [9:0]		LEDR,

	//////////// SW: 3.3-V LVTTL //////////
	input 		     [9:0]		SW,

	//////////// Arduino: 3.3-V LVTTL //////////
	inout 		    [15:0]		ARDUINO_IO,

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
	inout 		    [35:0]		GPIO
);

/////// PIN ASSIGNMENTS ////////
/*
PMOD 1 = GPIO 17 = MCLK
PMOD 2 = GPIO 15 = LRCLK
PMOD 3 = GPIO 13 = SCLK
PMOD 4 = GPIO 25 = SDIN (line out serial data input) serial input to DAC
PMOD 5 = GPIO pin 12 = GND
PMOD 6 = GPIO 29 = VCC
PMOD 7 = GPIO 19 = MCLK
PMOD 8 = GPIO 21 = LRCLK
PMOD 9 = GPIO 23 = SCLK
PMOD 10 = GPIO 11 = SDOUT (line in serial data output) serial output from ADC
PMOD 11 = GPIO pin 30 = GND
PMOD 12 = GPIO 29 = VCC

According to Digilent manual, ADOUT_SDIN should be driven by the ADIN_SDOUT signal
Green is 

*/
wire next_sclk_rise, next_sclk_fall, next_lrclk_rise, next_lrclk_fall;
wire [23:0] i_ldin, i_rdin;
wire mclk, sclk, lrclk;

assign GPIO[19] = GPIO[17];//mclk 
assign GPIO[21] = GPIO[15];//lrclk
assign GPIO[23] = GPIO[13];//sclk

assign LEDR[3] = GPIO[17]; //mclk 
assign LEDR[2] = GPIO[13]; //sclk 
assign LEDR[0] = GPIO[15]; //lrclk 

assign LEDR[9] = GPIO[11]; //sd_in;
assign LEDR[8] = GPIO[25]; //sd_out; 

wire [23:0] rx_out_left; 
wire [23:0] rx_out_right; 
//
//wire [23:0] fir_out_left; 
//wire [23:0] fir_out_right;
//
//wire [23:0] add_out; 
//wire [23:0] sub_out; 

wire [23:0] downconverter_out_left;
wire [23:0] downconverter_out_right;

wire [23:0] am_out_left; 
wire [23:0] am_out_right; 

wire [23:0] ssb_out; 

wire [23:0] tx_in_left; 
wire [23:0] tx_in_right; 

assign GPIO[17]=  mclk; 
assign GPIO[13] = sclk; 
assign GPIO[15]=  lrclk; 

wire [1:0] switches; 
assign switches = {SW[1], SW[0]}; 

//SW[0] for AM, SW[1] for SSB 
//
always @(*) begin 
	case (switches) 
		2'b01: begin //AM
			tx_in_left = am_out_left; //only output in phase
			tx_in_right = am_out_right; 
		end 
		2'b10: begin //SSB
			tx_in_left = ssb_out; 
			tx_in_right = ssb_out; 
		end 
		2'b11: begin
			//downconverter output for testing
			tx_in_left = downconverter_out_left; //only output in phase
			tx_in_right = downconverter_out_right; 
		end
		default: begin
			tx_in_left = 24'b0;
			tx_in_right = 24'b0;
		end
	endcase 
end 

//logic signed [15:0]lpf_coeffs[50:0] = 
//'{16'hFE17, 16'h004A, 16'h0074, 16'h00AF, 16'h00EC, 16'h0117, 16'h011F, 16'h00F5, 16'h0095, 16'h0000, 
//16'hFF45, 16'hFE7D, 16'hFDC8, 16'hFD4D, 16'hFD31, 16'hFD92, 16'hFE86, 16'h000F, 16'h021F, 16'h0497, 
//16'h0745, 16'h09F1, 16'h0C59, 16'h0E44, 16'h0F80, 
//16'h0FED, 
//16'h0F80, 16'h0E44, 16'h0C59, 16'h09F1, 16'h0745, 
//16'h0497, 16'h021F, 16'h000F, 16'hFE86, 16'hFD92, 16'hFD31, 16'hFD4D, 16'hFDC8, 16'hFE7D, 16'hFF45, 
//16'h0000, 16'h0095, 16'h00F5, 16'h011F, 16'h0117, 16'h00EC, 16'h00AF, 16'h0074, 16'h004A, 16'hFE17}; 

//28 tap lpf
/*
logic signed [15:0] lpf_coeffs[27:0] = '{
-16'd1372,
-16'd1810,
-16'd2506,
-16'd2837,
-16'd2451,
-16'd1006,
16'd1731,
16'd5814,
16'd11061,
16'd17046,
16'd23142,
16'd28615,
16'd32749,
16'd34974,
16'd34974,
16'd32749,
16'd28615,
16'd23142,
16'd17046,
16'd11061,
16'd5814,
16'd1731,
-16'd1006,
-16'd2451,
-16'd2837,
-16'd2506,
-16'd1810,
-16'd1372};*/


/*logic signed [15:0] lpf_coeffs[50:0] = 
'{-16'd3911, 16'd588, 16'd927, 16'd1403, 16'd1886, 16'd2229, 16'd2292, 16'd1963, 16'd1192, 16'd2, 
	-16'd1493, -16'd3096, -16'd4541, -16'd5527, -16'd5754, -16'd4973, -16'd3026, 16'd116, 16'd4343, 16'd9396, 
	16'd14890, 16'd20355, 16'd25290, 16'd29217, 16'd31745, 
	16'd32617, 
	16'd31745, 16'd29217, 16'd25290, 16'd20355, 16'd14890, 
	16'd9396, 16'd4343, 16'd116, -16'd3026, -16'd4973, -16'd5754, -16'd5527, -16'd4541, -16'd3096, -16'd1493, 
	16'd2, 16'd1192, 16'd1963,  16'd2292, 16'd2229, 16'd1886, 16'd1403, 16'd927, 16'd588, -16'd3911}; */

//order 40, cut off 2000hz, stop edge is 5000hz, 80 dB attenuation
/*logic signed [15:0] lpf_coeffs[40:0] = '{
-16'd83,
-16'd230,
-16'd506,
-16'd937,
-16'd1528,
-16'd2247,
-16'd3006,
-16'd3664,
-16'd4026,
-16'd3867,
-16'd2968,
-16'd1152,
16'd1669,
16'd5463,
16'd10054,
16'd15127,
16'd20255,
16'd24950,
16'd28729,
16'd31180,
16'd32029,
16'd31180,
16'd28729,
16'd24950,
16'd20255,
16'd15127,
16'd10054,
16'd5463,
16'd1669,
-16'd1152,
-16'd2968,
-16'd3867,
-16'd4026,
-16'd3664,
-16'd3006,
-16'd2247,
-16'd1528,
-16'd937,
-16'd506,
-16'd230,
-16'd83
};*/

/*
logic signed [15:0] lpf_coeffs[44:0] = '{

-16'd21,
-16'd66,
-16'd157,
-16'd311,
-16'd540,
-16'd842,
-16'd1192,
-16'd1538,
-16'd1789,
-16'd1829,
-16'd1515,
-16'd701,
16'd739,
16'd2890,
16'd5766,
16'd9294,
16'd13307,
16'd17551,
16'd21708,
16'd25428,
16'd28374,
16'd30267,
16'd30919,
16'd30267,
16'd28374,
16'd25428,
16'd21708,
16'd17551,
16'd13307,
16'd9294,
16'd5766,
16'd2890,
16'd739,
-16'd701,
-16'd1515,
-16'd1829,
-16'd1789,
-16'd1538,
-16'd1192,
-16'd842,
-16'd540,
-16'd311,
-16'd157,
-16'd66,
-16'd21};*/

/*logic signed [15:0] lpf_coeffs[30:0] = '{
16'd13,
16'd140,
16'd376,
16'd833,
16'd1586,
16'd2715,
16'd4277,
16'd6286,
16'd8703,
16'd11428,
16'd14300,
16'd17110,
16'd19627,
16'd21622,
16'd22904,
16'd23347,
16'd22904,
16'd21622,
16'd19627,
16'd17110,
16'd14300,
16'd11428,
16'd8703,
16'd6286,
16'd4277,
16'd2715,
16'd1586,
16'd833,
16'd376,
16'd140,
16'd13
};*/

//lpf order 40 passband 2000Hz 80 dB attenuation, using 2^15 scaling
logic signed [15:0] lpf_coeffs[40:0] = '{
	16'hFFF6,
    16'hFFE3,
    16'hFFC1,
    16'hFF8B,
    16'hFF41,
    16'hFEE7,
    16'hFE88,
    16'hFE36,
    16'hFE09,
    16'hFE1D,
    16'hFE8D,
    16'hFF70,
    16'h00D1,
    16'h02AB,
    16'h04E9,
    16'h0763,
    16'h09E4,
    16'h0C2F,
    16'h0E07,
    16'h0F3A,
    16'h0FA4,
    16'h0F3A,
    16'h0E07,
    16'h0C2F,
    16'h09E4,
    16'h0763,
    16'h04E9,
    16'h02AB,
    16'h00D1,
    16'hFF70,
    16'hFE8D,
    16'hFE1D,
    16'hFE09,
    16'hFE36,
    16'hFE88,
    16'hFEE7,
    16'hFF41,
    16'hFF8B,
    16'hFFC1,
    16'hFFE3,
    16'hFFF6
};

logic signed [15:0] hilbert_coeffs[50:0] = 
'{-16'd502, -16'd331, -16'd578, -16'd325, -16'd671, -16'd316, -16'd788, -16'd302, -16'd933, -16'd283,
  -16'd1118, -16'd260, -16'd1357, -16'd232, -16'd1679, -16'd200, -16'd2134, -16'd165, -16'd2833, -16'd126, 
  -16'd4065, -16'd85, -16'd6888, -16'd43, -16'd20838,
   16'd0, 
   16'd20838, 16'd43, 16'd6888, 16'd85, 16'd4065, 
	16'd126, 16'd2833, 16'd165, 16'd2134, 16'd200, 16'd1679, 16'd232, 16'd1357, 16'd260, 16'd1118, 
	16'd283, 16'd933, 16'd302, 16'd788, 16'd316, 16'd671, 16'd325, 16'd578, 16'd331, 16'd502}; 
	
logic signed [15:0] delay_coeffs[50:0] = 
'{16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 
  16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 
  16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 
  16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 
  16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 
  16'b1};
  
pll pll_inst (
	.inclk0(MAX10_CLK1_50),
	.c0(mclk)  //Connect the output of c0 to MCLK. 
	);
	
	
clockdiv clk0(
	.reset(SW[9]),
	.MCLK(mclk), 
	.SCLK(sclk), 
	.LRCLK(lrclk), 
	.next_sclk_rise(next_sclk_rise), 
	.next_sclk_fall(next_sclk_fall), 
	.next_lrclk_rise(next_lrclk_rise),
	.next_lrclk_fall(next_lrclk_fall)
	); 
	
	
i2s_rx r0(
	.mclk(mclk), 
	.sclk(sclk), 
	.lrclk(lrclk), 
	.i_sdata(GPIO[11]), //serial data from ADC
	.next_lrclk_fall(next_lrclk_fall), 
	.next_lrclk_rise(next_lrclk_rise), 
	.next_sclk_rise(next_sclk_rise),
	.next_sclk_fall(next_sclk_fall),
	.o_left(rx_out_left), 
	.o_right(rx_out_right),
	.reset(SW[9])
	); 
		
downconverter d0 (
    .i_signal_left(rx_out_left),
	.i_signal_right(rx_out_right),
    .mclk(mclk),
    .reset(SW[9]),
    .i_ready(next_lrclk_fall),
    .i_valid(next_lrclk_fall),
	.next_lrclk_fall(next_lrclk_fall),
    .o_converted_left(downconverter_out_left),
	.o_converted_right(downconverter_out_right)
);

//fir lpf_left(
//	.x_in(rx_out_left), 
//	.y_out(fir_out_left), 
//	.b(lpf_coeffs), 
//	.clk(GPIO[17]), 
//	.ena(1), 
//	.next_lrclk_fall(next_lrclk_fall), 
//	.rst(SW[9])
//); 
//
//fir lpf_right(
//	.x_in(rx_out_right), 
//	.y_out(fir_out_right), 
//	.b(lpf_coeffs), 
//	.clk(GPIO[17]), 
//	.ena(1), 
//	.next_lrclk_fall(next_lrclk_fall), 
//	.rst(SW[9])
//); 
//
//adder a0(
//	.clk(GPIO[17]), 
//	.reset(SW[9]), 
//	.next_lrclk_fall(next_lrclk_fall),
//	.a(fir_out_left), 
//	.b(fir_out_right), 
//	.o_c(add_out)
//); 

am am0(
	.i(downconverter_out_left), 
	.q(downconverter_out_right), 
	.b(lpf_coeffs), 
	.clk(mclk), 
	.ena(1), 
	.next_lrclk_fall(next_lrclk_fall), 
	.rst(SW[9]), 
	.i_out(am_out_left), 
	.q_out(am_out_right) //outputs LPF signals
); 

ssb ssb0(
	.i(am_out_left), 
	.q(am_out_right), //connect LPF outputs
	.h(hilbert_coeffs), 
	.d(delay_coeffs), 
	.clk(mclk), 
	.ena(1), 
	.next_lrclk_fall(next_lrclk_fall), 
	.rst(SW[9]), 
	.usb(SW[3]), 
	.ssb_out(ssb_out)
); 

i2s_tx t0(
	.mclk(mclk), 
	.sclk(sclk), 
	.lrclk(lrclk), 
	.i_ldin(tx_in_left), 
	.i_rdin(tx_in_right),  
	.next_lrclk_rise(next_lrclk_rise), 
	.next_lrclk_fall(next_lrclk_fall), 
	.next_sclk_rise(next_sclk_rise),
	.o_sdout(GPIO[25]), //serial data delivered to DAC
	.reset(SW[9])
	); 
	
		
//hex display
always@(*) begin
	HEX1 = ~7'b0; 
	HEX2 = ~7'b0;
	HEX3 = ~7'b0;
	HEX4 = ~7'b0;
	HEX5 = ~7'b0;
	if (SW[0] & !SW[1]) begin
	//AM
		HEX0 = ~7'b1110111;
	end
	else if (!SW[0] & SW[1] & SW[3]) begin
	//USB
		HEX0 = ~7'b0111110;
	end
	else if (!SW[0] & SW[1] & !SW[3]) begin
	//LSB
		HEX0 = ~7'b0111000;
	end
	else begin
		HEX0 = ~7'b0;
	end
end

endmodule