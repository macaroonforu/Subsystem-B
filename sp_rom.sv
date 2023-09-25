module sp_ROM
 #(
    parameter int unsigned width = 16,
    parameter int unsigned depth = 4096,
    //parameter string init_file = "D:/Users/Joyce/Documents/ECE295/downconverter/coswheel4096.mif",
    parameter int unsigned addr_w = $clog2(depth)
)
(
    input logic clk,
    input logic [addr_w-1:0] addr,
    output logic [width-1:0] o_data
);
    logic [width-1:0] rom [0:depth-1];
    // initialise ROM contents
    initial begin
        $readmemh("D:/Users/Joyce/Documents/ECE295/downconverter/coswheel4096.mif",rom);
    end
    always_ff @ (posedge clk)
    begin
        o_data <= rom[addr];
    end
endmodule : sp_ROM