# Comprehensive Makefile for MPI Research Project
CC = mpicc
CFLAGS = -Wall -O2 -std=c99
LDFLAGS = -lm

# Directories
BASIC_DIR = examples/basic
INTERMEDIATE_DIR = examples/intermediate
ADVANCED_DIR = examples/advanced
BENCHMARK_DIR = benchmarks

# Basic examples
BASIC_SOURCES = $(wildcard $(BASIC_DIR)/*.c)
BASIC_TARGETS = $(BASIC_SOURCES:.c=)

# Intermediate examples  
INTERMEDIATE_SOURCES = $(wildcard $(INTERMEDIATE_DIR)/*.c)
INTERMEDIATE_TARGETS = $(INTERMEDIATE_SOURCES:.c=)

# Advanced examples
ADVANCED_SOURCES = $(wildcard $(ADVANCED_DIR)/*.c)
ADVANCED_TARGETS = $(ADVANCED_SOURCES:.c=)

# All targets
ALL_TARGETS = $(BASIC_TARGETS) $(INTERMEDIATE_TARGETS) $(ADVANCED_TARGETS)

.PHONY: all basic intermediate advanced clean help test benchmark demo install-deps

# Default target
all: basic intermediate advanced

# Compile basic examples
basic: $(BASIC_TARGETS)

# Compile intermediate examples
intermediate: $(INTERMEDIATE_TARGETS)

# Compile advanced examples
advanced: $(ADVANCED_TARGETS)

# Generic compilation rule
%: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

# Install dependencies (for macOS)
install-deps:
	@echo "Installing MPI and Python dependencies..."
	@if ! command -v mpirun &> /dev/null; then \
		echo "Installing Open MPI..."; \
		brew install open-mpi; \
	else \
		echo "Open MPI already installed"; \
	fi
	@if ! python3 -c "import mpi4py" &> /dev/null; then \
		echo "Installing mpi4py..."; \
		pip3 install mpi4py; \
	else \
		echo "mpi4py already installed"; \
	fi
	@echo "Dependencies installation complete!"

# Quick demonstration runs
demo: basic intermediate
	@echo "=== MPI Research Project Demonstration ==="
	@echo "1. Hello World (4 processes)"
	@mpirun -np 4 $(BASIC_DIR)/hello_world_mpi
	@echo ""
	@echo "2. Parallel Sum (4 processes)"  
	@mpirun -np 4 $(BASIC_DIR)/parallel_sum_mpi
	@echo ""
	@echo "3. Monte Carlo Pi (4 processes, 1M samples)"
	@mpirun -np 4 $(INTERMEDIATE_DIR)/monte_carlo_pi_mpi 1000000
	@echo ""
	@echo "Demo complete! Use 'make benchmark' for comprehensive testing."

# Quick tests
test: basic intermediate
	@echo "=== Running Quick Tests ==="
	@echo "Testing basic examples..."
	@mpirun -np 2 $(BASIC_DIR)/hello_world_mpi
	@mpirun -np 2 $(BASIC_DIR)/parallel_sum_mpi
	@echo "Testing intermediate examples..."
	@mpirun -np 2 $(INTERMEDIATE_DIR)/monte_carlo_pi_mpi 1000000
	@if [ -f $(INTERMEDIATE_DIR)/matrix_multiply_mpi ]; then \
		echo "Testing matrix multiplication..."; \
		timeout 30 mpirun -np 2 $(INTERMEDIATE_DIR)/matrix_multiply_mpi || echo "Matrix test skipped (timeout)"; \
	fi
	@echo "Quick tests complete!"

# Run comprehensive benchmarks
benchmark: all
	@echo "=== Running Comprehensive Benchmarks ==="
	@./$(BENCHMARK_DIR)/performance_test.sh
	@echo "Benchmark complete! Check benchmarks/results/ for detailed results."

# Performance comparison
compare: intermediate
	@echo "=== Performance Comparison (Matrix Multiplication) ==="
	@echo "Testing with 1, 2, 4, 8 processes..."
	@for np in 1 2 4 8; do \
		echo "--- $$np processes ---"; \
		timeout 60 mpirun -np $$np $(INTERMEDIATE_DIR)/matrix_multiply_mpi || echo "Timeout"; \
		echo ""; \
	done

# Individual run targets
run-hello: $(BASIC_DIR)/hello_world_mpi
	@echo "=== Hello World MPI (4 processes) ==="
	@mpirun -np 4 $<

run-sum: $(BASIC_DIR)/parallel_sum_mpi  
	@echo "=== Parallel Sum (4 processes) ==="
	@mpirun -np 4 $<

run-matrix: $(INTERMEDIATE_DIR)/matrix_multiply_mpi
	@echo "=== Matrix Multiplication (4 processes) ==="
	@mpirun -np 4 $<

run-monte-carlo: $(INTERMEDIATE_DIR)/monte_carlo_pi_mpi
	@echo "=== Monte Carlo Pi Estimation (4 processes, 10M samples) ==="
	@mpirun -np 4 $< 10000000

run-python:
	@echo "=== Python MPI Example (4 processes) ==="
	@mpirun -np 4 python3 $(BASIC_DIR)/hello_world_mpi.py

# Scalability tests
scale-test: intermediate
	@echo "=== Scalability Test: Monte Carlo Pi ==="
	@for np in 1 2 4 8; do \
		echo "--- $$np processes ---"; \
		mpirun -np $$np $(INTERMEDIATE_DIR)/monte_carlo_pi_mpi 10000000; \
		echo ""; \
	done

# Clean compiled files
clean:
	@echo "Cleaning compiled files..."
	@rm -f $(ALL_TARGETS)
	@rm -rf $(BENCHMARK_DIR)/results/
	@echo "Clean complete!"

# Project status
status:
	@echo "=== MPI Research Project Status ==="
	@echo "Project directory: $(PWD)"
	@echo ""
	@echo "Available source files:"
	@find examples -name "*.c" -exec basename {} \; | sort
	@echo ""
	@echo "Compiled programs:"
	@find examples -perm +111 -type f ! -name "*.c" ! -name "*.py" -exec basename {} \; 2>/dev/null | sort || echo "None compiled yet"
	@echo ""
	@echo "MPI Installation:"
	@which mpirun || echo "MPI not found"
	@echo ""
	@echo "Python MPI:"
	@python3 -c "import mpi4py; print('mpi4py available')" 2>/dev/null || echo "mpi4py not available"

# Help target
help:
	@echo "=== MPI Research Project Makefile ==="
	@echo ""
	@echo "COMPILATION TARGETS:"
	@echo "  all           - Compile all examples"
	@echo "  basic         - Compile basic examples only"
	@echo "  intermediate  - Compile intermediate examples only"
	@echo "  advanced      - Compile advanced examples only"
	@echo ""
	@echo "EXECUTION TARGETS:"
	@echo "  demo          - Quick demonstration of key programs"
	@echo "  test          - Run quick functionality tests"
	@echo "  benchmark     - Run comprehensive performance benchmarks"
	@echo "  compare       - Performance comparison with different process counts"
	@echo ""
	@echo "INDIVIDUAL RUN TARGETS:"
	@echo "  run-hello     - Run hello world example"
	@echo "  run-sum       - Run parallel sum example"
	@echo "  run-matrix    - Run matrix multiplication example"
	@echo "  run-monte-carlo - Run Monte Carlo pi estimation"
	@echo "  run-python    - Run Python MPI example"
	@echo ""
	@echo "UTILITY TARGETS:"
	@echo "  install-deps  - Install MPI and Python dependencies"
	@echo "  scale-test    - Test scalability with different process counts"
	@echo "  status        - Show project status and installation info"
	@echo "  clean         - Remove compiled files and results"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "EXAMPLES:"
	@echo "  make demo                    # Quick demonstration"
	@echo "  make benchmark              # Comprehensive performance testing"
	@echo "  make run-matrix            # Run matrix multiplication"
	@echo "  mpirun -np 8 examples/intermediate/monte_carlo_pi_mpi 50000000"
