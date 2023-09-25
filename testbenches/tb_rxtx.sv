`timescale 1ns/1ps

module tb_rxtx ();

localparam MCLK_HALF_PERIOD = 20;
localparam DATA_RES = 24;
localparam NUM_FRAMES = 30;

// module wires
// The master clock signal, which will be used to generate the SCLK and LRCLK signals
logic MCLK;
// These are optional control signals asserting on the cycle previous to the rise and fall of the SCLK and LRCLK signals
// They can be used in the testbench or in downstream modules to indicate valid L or R data coming from the i2s_rx module

// The reason I say these signals are optional is that there is more than one way to create a control signal to determine the end of a frame
// and that is the only mantadory control signal required for the functionality of Subsystem B

// With respect to this individual testbench, all of the below control signals can be considered optional
logic next_lrclk_fall;
logic next_lrclk_rise;
logic next_sclk_fall;
logic next_sclk_rise;
// input serial data coming from the producer module 
//    (in the case of real hardware this signal will be coming from the PMOD ADC device using the timing parameters specified in the datasheet)
logic i_sdata;
logic signed [DATA_RES-1:0] ldata, o_right, o_dc_left;
logic signed [DATA_RES-1:0] rdata, o_left, o_dc_right;
logic SCLK;
logic LRCLK;

logic reset;

// module instantiation
// This is where you instantiate the i2s_rx module you are testing
// Your module could have the same or different inputs based on the way
// you designed your control signals.
i2s_rx rx0(
    .mclk(MCLK),
    .sclk(SCLK),
    .lrclk(LRCLK),
    .i_sdata(i_sdata),
    .o_left(ldata),
    .o_right(rdata),
    .next_lrclk_fall(next_lrclk_fall),
    .next_sclk_rise(next_sclk_rise),
    .next_sclk_fall(next_sclk_fall),
    .next_lrclk_rise(next_lrclk_rise),
    .reset(reset)
);

downconverter dut (
    .i_signal_left(ldata),
    .i_signal_right(rdata),
    .mclk(MCLK),
    .reset(reset),
    .i_ready(next_lrclk_fall),
    .i_valid(next_lrclk_fall),
    .o_converted_left(o_dc_left),
    .o_converted_right(o_dc_right)
);

i2s_tx tx0(
    .mclk(MCLK),
    .sclk(SCLK),
    .lrclk(LRCLK),
    .i_ldin(o_dc_left),
    .i_rdin(o_dc_right),
    .next_lrclk_rise(next_lrclk_rise),
	.next_lrclk_fall(next_lrclk_fall),
    .o_sdout(o_sdout),
    .next_sclk_rise(next_sclk_rise),
    .reset(reset)
);

i2s_rx consumer(
    .mclk(MCLK),
    .sclk(SCLK),
    .lrclk(LRCLK),
    .i_sdata(o_sdout),
    .o_left(o_left),
    .o_right(o_right),
    .next_lrclk_fall(next_lrclk_fall),
    .next_sclk_rise(next_sclk_rise),
    .next_sclk_fall(next_sclk_fall),
    .next_lrclk_rise(next_lrclk_rise),
    .reset(reset)
);

// 25 MHz Clock
always begin
    MCLK = 'b1;
    #(MCLK_HALF_PERIOD);
    MCLK = 'b0;
    #(MCLK_HALF_PERIOD);
end

// clock divider
clockdiv clock_div(
    .reset(reset),
    .MCLK(MCLK),
    .SCLK(SCLK),
    .LRCLK(LRCLK),
    // In this example the clock divider generates the previously mentioned optional control signals
    .next_lrclk_fall(next_lrclk_fall),
    .next_lrclk_rise(next_lrclk_rise),
    .next_sclk_fall(next_sclk_fall),
    .next_sclk_rise(next_sclk_rise)
);

// These are arrays of golden values that will be compared to the output of the i2s_rx module (one for each channel)
logic signed [NUM_FRAMES-1:0][DATA_RES-1:0] l_golden;
logic signed [NUM_FRAMES-1:0][DATA_RES-1:0] r_golden;

// This signal will determine if the module passed or failed the testbench
logic fail;

// Producer block
initial begin
    // These signals are used to generate random values to be sent to the i2s_rx module
    logic signed [DATA_RES-1:0] l_gen;
    logic signed [DATA_RES-1:0] r_gen;
    i_sdata = 'b0;
    reset = 1'b1;
    @(posedge MCLK);
    @(negedge MCLK);
    reset = 1'b0;
    // First wait for the LR clock to change (the left channel will start on negative edge and be sent first)
    @(posedge LRCLK);
    @(negedge LRCLK);
    for (int i = 0; i < NUM_FRAMES; i = i + 1) begin
        // Put random values into inputs signals
        l_gen = $urandom_range(2**DATA_RES);
        r_gen = $urandom_range(2**DATA_RES);
        // Put the generated values into the golden array to compare in consumer module
        l_golden[i] = l_gen;
        r_golden[i] = r_gen;
        // Wait a single cycle of SCLK before sending data, then send on negedge of SCLK
        for(int b = DATA_RES-1; b >= 0; b = b - 1)begin
            // Send data a single bit at a time (from MSB to LSB) on L channel
            @(posedge SCLK); i_sdata = l_gen[b];
        end
        // Wait until the next posedge of LRCLK before sending data on R channel
        @(posedge LRCLK);
        for(int b = DATA_RES-1; b >= 0; b = b - 1)begin
            // Send data a single bit at a time (from MSB to LSB) on R channel
            @(posedge SCLK); i_sdata = r_gen[b];
        end
        // After the next negedge of LRCLK the next frame will start, and new values will be injected on the next FRAME iteration
        @(negedge LRCLK);
    end
    $stop(0);
end

endmodule
