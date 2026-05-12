// ============================================================
// 8-bit ALU — Verilog HDL Implementation
// Supports: Addition, Subtraction, AND, OR, Shift Left, Shift Right, Pass A
// ============================================================

// -------------------------------------------------------
// B Input Multiplexer
// Selects between B, ~B, or 0 based on bsel control signal
// -------------------------------------------------------
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

// -------------------------------------------------------
// 8-bit Adder
// Computes A + X + Cin, with carry-out and overflow flags
// -------------------------------------------------------
module ADD(
    input  wire [7:0] a,
    input  wire [7:0] x,
    input  wire       cin,
    output reg  [7:0] cout,
    output reg        co,
    output reg        o
);
    reg [8:0] temp;

    always @(*) begin
        temp = a + x + cin;
        cout = temp[7:0];
        co   = temp[8];
        o    = (a[7] == x[7]) && (cout[7] != a[7]);
    end
endmodule

// -------------------------------------------------------
// Logical Block
// Performs AND or OR based on lop control signal
// -------------------------------------------------------
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

// -------------------------------------------------------
// Shifter Block
// Performs left or right shift with serial input (si)
// Outputs shift-out bit (so)
// -------------------------------------------------------
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
                shifter = {a[6:0], si};   // Left shift
                so      = a[7];
            end
            1'b1: begin
                shifter = {si, a[7:1]};   // Right shift
                so      = a[0];
            end
            default: begin
                shifter = 8'b00000000;
                so      = 1'b0;
            end
        endcase
    end
endmodule

// -------------------------------------------------------
// Control Logic
// Decodes 3-bit opcode into datapath control signals
// OP: 000=ADD, 001=SUB, 011=AND, 100=OR, 101=SHL, 110=SHR, 111=PASS A
// -------------------------------------------------------
module Control(
    input  wire [2:0] OP,
    output reg  [1:0] bsel,
    output reg        cin,
    output reg        lop,
    output reg        sop,
    output reg  [1:0] osel
);
    always @(*) begin
        // Defaults
        bsel = 2'b00;
        cin  = 1'b0;
        lop  = 1'b0;
        sop  = 1'b0;
        osel = 2'b00;

        case (OP)
            3'b000: begin bsel = 2'b00; cin = 1'b0; osel = 2'b00; end  // ADD
            3'b001: begin bsel = 2'b01; cin = 1'b1; osel = 2'b00; end  // SUB
            3'b011: begin bsel = 2'b00; lop = 1'b0; osel = 2'b01; end  // AND
            3'b100: begin bsel = 2'b00; lop = 1'b1; osel = 2'b01; end  // OR
            3'b101: begin sop  = 1'b0;              osel = 2'b10; end  // SHL
            3'b110: begin sop  = 1'b1;              osel = 2'b10; end  // SHR
            3'b111: begin bsel = 2'b10; cin = 1'b0; osel = 2'b00; end  // PASS A
            default: begin end
        endcase
    end
endmodule

// -------------------------------------------------------
// Output Multiplexer
// Selects final output from adder, logic, or shifter
// -------------------------------------------------------
module mux_D(
    input  wire [7:0] cout,
    input  wire [7:0] out,
    input  wire [7:0] shifter,
    input  wire [1:0] osel,
    output reg  [7:0] Y
);
    always @(*) begin
        case (osel)
            2'b00:   Y = cout;
            2'b01:   Y = out;
            2'b10:   Y = shifter;
            default: Y = 8'b00000000;
        endcase
    end
endmodule

// -------------------------------------------------------
// ALU Top-Level Datapath
// Connects all functional blocks
// -------------------------------------------------------
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
    wire [7:0] cout;
    wire [7:0] out;
    wire [7:0] shifter;
    wire [1:0] bsel;
    wire [1:0] osel;
    wire       cin;
    wire       lop;
    wire       sop;

    mux_B   B1 (b,    bsel, x);
    Control C1 (OP,   bsel, cin, lop, sop, osel);
    ADD     A1 (a,    x,    cin, cout, co, o);
    Logic   L1 (a,    x,    lop, out);
    Shift   S1 (a,    si,   sop, shifter, so);
    mux_D   D1 (cout, out,  shifter, osel, Y);

    assign Z = ~Y;
endmodule
