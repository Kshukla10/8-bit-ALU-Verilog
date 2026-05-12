# 8-bit ALU — Verilog HDL

A fully functional 8-bit Arithmetic Logic Unit (ALU) designed and implemented in Verilog HDL. The ALU supports arithmetic, logical, and shift operations through a modular datapath architecture with a dedicated control unit. Functionality was verified using ModelSim with a custom testbench.

---

## Supported Operations

| OP Code | Operation     | Description                        |
|---------|---------------|------------------------------------|
| `000`   | ADD           | A + B                              |
| `001`   | SUB           | A - B (2's complement)             |
| `011`   | AND           | A & B (bitwise)                    |
| `100`   | OR            | A \| B (bitwise)                   |
| `101`   | Shift Left    | A << 1, serial input shifted in    |
| `110`   | Shift Right   | A >> 1, serial input shifted in    |
| `111`   | Pass A        | Y = A                              |

---

**Modules:**
- `mux_B` — Selects B, ~B, or 0 as the second operand based on `bsel`
- `ADD` — 8-bit adder with carry-out (`co`) and overflow (`o`) flags
- `Logic` — Bitwise AND / OR operations
- `Shift` — Left / right shift with serial input (`si`) and shift-out (`so`)
- `Control` — Decodes 3-bit opcode into datapath control signals
- `mux_D` — Selects final output from adder, logic unit, or shifter
- `alu_path` — Top-level module connecting all blocks

---

## Status Flags

| Flag | Description                                      |
|------|--------------------------------------------------|
| `co` | Carry-out from adder                             |
| `o`  | Overflow — set when signed result is incorrect   |
| `so` | Shift-out — MSB (left shift) or LSB (right shift)|

---

## Repository Structure

```
8-bit-ALU-Verilog/
├── src/
│   └── alu.v          # Full ALU source — all modules
├── sim/
│   └── alu_tb.v       # Testbench with multiple test cases
└── README.md
```

---

## Simulation

Tested using **ModelSim**. To simulate:

1. Open ModelSim and create a new project
2. Add `src/alu.v` and `sim/alu_tb.v` to the project
3. Compile both files
4. Simulate `alu_test` (testbench top module)
5. Add signals to the waveform window and run

---

## Tools & Languages

- **Language:** Verilog HDL
- **Simulation:** ModelSim
- **Verification:** Custom testbench with `$monitor` and `$display`

---

## Key Concepts Demonstrated

- Modular RTL design with clearly separated functional blocks
- Datapath and control unit architecture
- 2's complement subtraction via B inversion and carry-in
- Signed overflow detection
- Serial shift operations with shift-out flag
- Functional verification through simulation and testbench development
