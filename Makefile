# Top-level BSV file containing the MAC implementation
TOPFILE=src/mac.bsv

# Include paths for BSV compiler
# . : Current directory
# ./src : Source files directory
# %/Libraries : System BSV libraries
BSVINCDIR=.:./src:%/Libraries

# BSV compiler defines
BSCDEFINES=RV64

# Output directories
VERILOGDIR=verilog/     # Directory for generated Verilog files
BUILDDIR=intermediate/  # Directory for intermediate build files

# Include verification makefile
include mac_verif/Makefile.verif

# Default target: generates Verilog and runs simulation
.PHONY: all
all: generate_verilog simulate

# Run simulation using Verilator
.PHONY: simulate
simulate: 
	@make SIM=verilator

# Generate Verilog code from BSV source files
# Flags explanation:
# -u: Generate Verilog
# -verilog: Generate Verilog (redundant with -u, but explicit)
# -elab: Elaborate the design
# -vdir: Directory for Verilog output
# -bdir: Directory for intermediate files
# -info-dir: Directory for info files
# +RTS -K4000M: Increase GHC runtime stack size
# -check-assert: Enable assertion checking
# -keep-fires: Preserve fire signals
# -opt-undetermined-vals: Optimize undetermined values
# -remove-false/empty/starved-rules: Optimization flags
# -unspecified-to X: Set unspecified values to X
# -show-schedule: Show scheduling information
# -show-module-use: Show module usage information
.PHONY: generate_verilog
generate_verilog:
	@mkdir -p $(VERILOGDIR) $(BUILDDIR)
	@bsc -u -verilog -elab -vdir ./verilog -bdir ./intermediate -info-dir ./intermediate +RTS -K4000M -RTS -check-assert  -keep-fires -opt-undetermined-vals -remove-false-rules -remove-empty-rules -remove-starved-rules -remove-dollar -unspecified-to X -show-schedule -show-module-use  -suppress-warnings G0010:T0054:G0020:G0024:G0023:G0096:G0036:G0117:G0015 -D $(BSCDEFINES) -p $(BSVINCDIR) $(TOPFILE)

# Clean all generated files and build artifacts
# Removes:
# - Verilog directory
# - Build intermediate directory
# - Python cache files
# - Test results and coverage files
# - VCD waveform files
.PHONY: clean_build
clean_build:
	@make clean
	@rm -rf $(VERILOGDIR) $(BUILDDIR)
	@rm -rf mac_verif/__pycache__
	@rm -rf results.xml cov*.yml
	@rm -rf *.vcd results.xml sim_build
	@echo "Cleaned"

# Display help message with available make commands
.PHONY: help
help:
	@echo "Available make commands:"
	@echo "  all              - Generate Verilog, simulate, and run verification"
	@echo "  generate_verilog - Generate Verilog files from BSV sources"
	@echo "  simulate         - Run simulation using Verilator"
	@echo "  verify          - Run verification tests"
	@echo "  lint            - Check BSV syntax"
	@echo "  clean_build     - Clean all generated files"
	@echo "  help            - Show this help message"
