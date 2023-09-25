/*
    This module generates a cosine wave using a ROM lookup table.
    The implementation uses no quartus IP so it can be more easily simulated. 
*/

module osc #(
    parameter FREQ = 10000,
    parameter PHASE = 0, // degrees
    parameter DOUT_W = 16,
    parameter CNT_SZ = 12,
    parameter LUT_RES = 4096,
    parameter PHASE_RES = 360,
    parameter FREQ_RES = 48000
) (
    input logic  mclk,
    input logic  reset,
    input logic  en, // enable signal
    output logic [DOUT_W-1:0] o_sig_data
);

// parameter calculations
// We multiply the desired frequency/phase by 2^12 to get thier values on a 12 bit scale (then divide by 360 for phase and 48000 for frequency)
localparam [CNT_SZ-1:0] start_phase = PHASE * (2 ** CNT_SZ) / PHASE_RES;
localparam [CNT_SZ-1:0] phase_inc = FREQ * (2 ** CNT_SZ) / FREQ_RES;

logic [CNT_SZ-1:0] counter;

// counter
always_ff @(posedge mclk) begin
    if(reset) begin
        counter <= start_phase;
    end
    // increment address on enable
    else if(en) begin
        counter <= counter + phase_inc;
    end else begin 
        counter <= counter;
    end
end

// cosign lut
sp_ROM rom_inst (
    .addr(counter),
    .clk(mclk), //change to mclk
    .o_data(o_sig_data)
);


endmodule