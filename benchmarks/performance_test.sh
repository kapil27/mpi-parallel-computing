#!/bin/bash

# MPI Performance Benchmarking Script
# Tests various MPI programs with different process counts

# Configuration
MAX_PROCESSES=8
RESULTS_DIR="results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="${RESULTS_DIR}/benchmark_${TIMESTAMP}.txt"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "=== MPI Performance Benchmarking Suite ===" | tee "$RESULTS_FILE"
echo "Date: $(date)" | tee -a "$RESULTS_FILE"
echo "Host: $(hostname)" | tee -a "$RESULTS_FILE"
echo "CPU Info: $(sysctl -n machdep.cpu.brand_string)" | tee -a "$RESULTS_FILE"
echo "CPU Cores: $(sysctl -n hw.ncpu)" | tee -a "$RESULTS_FILE"
echo "Memory: $(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)" GB"}')" | tee -a "$RESULTS_FILE"
echo "MPI Version: $(mpirun --version | head -1)" | tee -a "$RESULTS_FILE"
echo "=======================================" | tee -a "$RESULTS_FILE"

# Function to run benchmark with error handling
run_benchmark() {
    local program=$1
    local processes=$2
    local description=$3
    local extra_args=$4
    
    echo "" | tee -a "$RESULTS_FILE"
    echo "Running: $description ($processes processes)" | tee -a "$RESULTS_FILE"
    echo "Command: mpirun -np $processes $program $extra_args" | tee -a "$RESULTS_FILE"
    echo "---" | tee -a "$RESULTS_FILE"
    
    if [ -f "$program" ]; then
        timeout 300 mpirun -np "$processes" "$program" $extra_args 2>&1 | tee -a "$RESULTS_FILE"
        if [ $? -eq 124 ]; then
            echo "TIMEOUT: Execution exceeded 5 minutes" | tee -a "$RESULTS_FILE"
        fi
    else
        echo "ERROR: Program $program not found" | tee -a "$RESULTS_FILE"
    fi
    
    echo "---" | tee -a "$RESULTS_FILE"
}

# Compile all programs
echo "" | tee -a "$RESULTS_FILE"
echo "=== COMPILATION ===" | tee -a "$RESULTS_FILE"
echo "Compiling MPI programs..." | tee -a "$RESULTS_FILE"

cd "$(dirname "$0")/.."

# Compile basic examples
echo "Compiling basic examples..." | tee -a "$RESULTS_FILE"
mpicc -O2 -o examples/basic/hello_world_mpi examples/basic/hello_world_mpi.c 2>&1 | tee -a "$RESULTS_FILE"
mpicc -O2 -o examples/basic/parallel_sum_mpi examples/basic/parallel_sum_mpi.c 2>&1 | tee -a "$RESULTS_FILE"

# Compile intermediate examples
echo "Compiling intermediate examples..." | tee -a "$RESULTS_FILE"
mpicc -O2 -lm -o examples/intermediate/matrix_multiply_mpi examples/intermediate/matrix_multiply_mpi.c 2>&1 | tee -a "$RESULTS_FILE"
mpicc -O2 -lm -o examples/intermediate/monte_carlo_pi_mpi examples/intermediate/monte_carlo_pi_mpi.c 2>&1 | tee -a "$RESULTS_FILE"

echo "Compilation complete." | tee -a "$RESULTS_FILE"

# Function to test scalability
test_scalability() {
    local program=$1
    local description=$2
    local extra_args=$3
    
    echo "" | tee -a "$RESULTS_FILE"
    echo "=== SCALABILITY TEST: $description ===" | tee -a "$RESULTS_FILE"
    
    for np in 1 2 4 8; do
        if [ $np -le $MAX_PROCESSES ]; then
            run_benchmark "$program" "$np" "$description" "$extra_args"
        fi
    done
    
    echo "=== END SCALABILITY TEST: $description ===" | tee -a "$RESULTS_FILE"
}

# Run benchmarks
echo "" | tee -a "$RESULTS_FILE"
echo "=== STARTING BENCHMARKS ===" | tee -a "$RESULTS_FILE"

# Quick hello world test
run_benchmark "examples/basic/hello_world_mpi" 4 "Hello World MPI"

# Parallel sum test
test_scalability "examples/basic/parallel_sum_mpi" "Parallel Sum"

# Matrix multiplication test
test_scalability "examples/intermediate/matrix_multiply_mpi" "Matrix Multiplication"

# Monte Carlo tests with different sample sizes
echo "" | tee -a "$RESULTS_FILE"
echo "=== MONTE CARLO PI ESTIMATION TESTS ===" | tee -a "$RESULTS_FILE"
test_scalability "examples/intermediate/monte_carlo_pi_mpi" "Monte Carlo Pi (10M samples)" "10000000"
test_scalability "examples/intermediate/monte_carlo_pi_mpi" "Monte Carlo Pi (100M samples)" "100000000"

# Generate summary
echo "" | tee -a "$RESULTS_FILE"
echo "=== BENCHMARK SUMMARY ===" | tee -a "$RESULTS_FILE"
echo "Results saved to: $RESULTS_FILE" | tee -a "$RESULTS_FILE"
echo "Benchmark completed at: $(date)" | tee -a "$RESULTS_FILE"

# Extract performance metrics if possible
echo "" | tee -a "$RESULTS_FILE"
echo "=== PERFORMANCE METRICS SUMMARY ===" | tee -a "$RESULTS_FILE"
echo "Matrix Multiplication GFLOPS:" | tee -a "$RESULTS_FILE"
grep "GFLOPS:" "$RESULTS_FILE" | tail -4 | tee -a "$RESULTS_FILE"

echo "" | tee -a "$RESULTS_FILE"
echo "Monte Carlo Samples/Second:" | tee -a "$RESULTS_FILE"
grep "Samples per second:" "$RESULTS_FILE" | tail -8 | tee -a "$RESULTS_FILE"

echo ""
echo "Benchmarking complete! Results saved to: $RESULTS_FILE"
echo "View results with: cat $RESULTS_FILE"