// 8-bit ALU - Verilog HDL
// Operations: ADD, SUB, AND, OR, SHL, SHR, PASS B

// =====================
// Multiplexer B
// =====================
module mux_B(
    input  wire [7:0] b,
    input  wire [1:0] bsel,
    output reg  [7:0] x
);
    wire [7:0] bn;
    assign bn = ~b;

    always @(*) begin
        case (bsel)
            2'b00:   x = b;
            2'b01:   x = bn;
            2'b10:   x = 8'b00000000;
            default: x = 8'b00000000;
        endcase
    end
endmodule

// =====================
// 8-bit Adder
// =====================
module ADD(
    input  wire [7:0] a,
    input  wire [7:0] x,
    input  wire       cin,
    output reg  [7:0] sum,
    output reg        co,
    output reg        o
);
    reg [8:0] temp;

    always @(*) begin
        temp = {1'b0, a} + {1'b0, x} + {8'b0, cin};
        sum  = temp[7:0];
        co   = temp[8];
        o    = (a[7] == x[7]) && (sum[7] != a[7]);
    end
endmodule

// =====================
// Logical Unit
// =====================
module Logic(
    input  wire [7:0] a,
    input  wire [7:0] x,
    input  wire       lop,
    output reg  [7:0] out
);
    always @(*) begin
        case (lop)
            1'b0:    out = a & x;
            1'b1:    out = a | x;
            default: out = 8'b00000000;
        endcase
    end
endmodule

// =====================
// Shifter
// =====================
module Shift(
    input  wire [7:0] a,
    input  wire       si,
    input  wire       sop,
    output reg  [7:0] shifter,
    output reg        so
);
    always @(*) begin
        case (sop)
            1'b0: begin
                shifter = {a[6:0], si};
                so      = a[7];
            end
            1'b1: begin
                shifter = {si, a[7:1]};
                so      = a[0];
            end
            default: begin
                shifter = 8'b00000000;
                so      = 1'b0;
            end
        endcase
    end
endmodule

// =====================
// Control Unit
// OP: 000=ADD 001=SUB 011=AND 100=OR 101=SHL 110=SHR 111=PASS B
// =====================
module Control(
    input  wire [2:0] OP,
    output reg  [1:0] bsel,
    output reg        cin,
    output reg        lop,
    output reg        sop,
    output reg  [1:0] osel
);
    always @(*) begin
        bsel = 2'b00;
        cin  = 1'b0;
        lop  = 1'b0;
        sop  = 1'b0;
        osel = 2'b00;

        case (OP)
            3'b000: begin bsel = 2'b00; cin = 1'b0; osel = 2'b00; end
            3'b001: begin bsel = 2'b01; cin = 1'b1; osel = 2'b00; end
            3'b011: begin lop  = 1'b0;              osel = 2'b01; end
            3'b100: begin lop  = 1'b1;              osel = 2'b01; end
            3'b101: begin sop  = 1'b0;              osel = 2'b10; end
            3'b110: begin sop  = 1'b1;              osel = 2'b10; end
            3'b111: begin bsel = 2'b10; cin = 1'b0; osel = 2'b00; end
            default: osel = 2'b00;
        endcase
    end
endmodule

// =====================
// Output Multiplexer
// =====================
module mux_D(
    input  wire [7:0] sum,
    input  wire [7:0] out,
    input  wire [7:0] shifter,
    input  wire [1:0] osel,
    output reg  [7:0] Y
);
    always @(*) begin
        case (osel)
            2'b00:   Y = sum;
            2'b01:   Y = out;
            2'b10:   Y = shifter;
            default: Y = 8'b00000000;
        endcase
    end
endmodule

// =====================
// ALU Top-Level
// =====================
module alu_path(
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] OP,
    input  wire       si,
    output wire [7:0] Y,
    output wire [7:0] Z,
    output wire       co,
    output wire       o,
    output wire       so
);
    wire [7:0] x;
    wire [7:0] sum;
    wire [7:0] out;
    wire [7:0] shifter;
    wire [1:0] bsel;
    wire [1:0] osel;
    wire       cin;
    wire       lop;
    wire       sop;

    mux_B   B1 (b,   bsel, x);
    Control C1 (OP,  bsel, cin, lop, sop, osel);
    ADD     A1 (a,   x,   cin,  sum, co,  o);
    Logic   L1 (a,   x,   lop,  out);
    Shift   S1 (a,   si,  sop,  shifter, so);
    mux_D   D1 (sum, out, shifter, osel, Y);

    assign Z = ~Y;

endmodule
