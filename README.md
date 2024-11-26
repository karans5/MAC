# MAC (Multiply-Accumulate) Unit Design

This repository contains the implementation of a Multiply-Accumulate (MAC) unit in Bluespec SystemVerilog (BSV). The MAC unit is designed to support both integer and floating-point operations, with a focus on performance and accuracy.

## Project Structure

```
.
├── src/                    # Source files
│   ├── mac.bsv            # Top-level MAC implementation
│   ├── mac_fp.bsv         # Floating-point MAC implementation
│   ├── mac_int.bsv        # Integer MAC implementation
│   ├── adder_fp.bsv       # Floating-point adder
│   ├── adder_int.bsv      # Integer adder
│   ├── multiplier_fp.bsv  # Floating-point multiplier
│   └── multiplier_int.bsv # Integer multiplier
├── mac_verif/             # Verification framework
├── verilog/               # Generated Verilog files
└── intermediate/          # Build intermediate files
```

## Features

- Support for both integer and floating-point operations
- Pipelined architecture for improved throughput
- Configurable data width
- Comprehensive verification framework
- Automated build system using Make

## Prerequisites

- Bluespec Compiler (bsc)
- Verilator (for simulation)
- Python 3.x (for verification)
- Make

## Build Instructions

1. Generate Verilog:
```bash
make generate_verilog
```

2. Run simulation:
```bash
make simulate
```

3. Clean build artifacts:
```bash
make clean_build
```

## Available Make Commands

- `make all`: Generates Verilog and runs simulation
- `make generate_verilog`: Generates Verilog code from BSV sources
- `make simulate`: Runs simulation using Verilator
- `make clean_build`: Removes all generated files and build artifacts

## Implementation Details

The MAC unit implements the operation: `accumulator += multiplicand × multiplier`

- Integer MAC: Supports signed/unsigned integer multiplication and accumulation
- Floating-point MAC: Implements IEEE-754 compliant operations
- Pipelined architecture for improved performance

## License

This project is part of the CS6230 course work.

## Assignment 1:

1. int32 :
- a. pipelined design: code - not-completed, verification - not-completed
- b. unpipeined design : code - completed, verification -completed

2. bfloat16:
- a. pipelined design: code - not-completed, verification - not-completed
- b. unpipeined design : code - completed, verification - completed
