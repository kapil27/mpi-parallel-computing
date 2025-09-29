# MPI Examples and Tutorial

This directory contains several MPI (Message Passing Interface) examples to help you understand parallel programming and the `mpirun` command.

## What is MPI?

MPI is a standardized library for parallel programming that allows multiple processes to communicate and coordinate work. `mpirun` is the command used to launch MPI programs across multiple processes.

## Prerequisites

### macOS Installation
```bash
# Install MPI using Homebrew
brew install open-mpi

# For Python examples, install mpi4py
pip3 install mpi4py
```

### Verify Installation
```bash
# Check if mpirun is available
which mpirun

# Check MPI version
mpirun --version
```

## Files Included

1. **hello_world_mpi.c** - Basic C MPI program showing process identification
2. **hello_world_mpi.py** - Python MPI program with simple communication
3. **parallel_sum_mpi.c** - Advanced example demonstrating parallel computation
4. **Makefile** - Build automation for C programs

## How to Run the Examples

### Method 1: Using the Makefile (Recommended)

```bash
# See available options
make help

# Compile all C programs
make all

# Run the hello world example
make run-hello

# Run the parallel sum example
make run-sum

# Run the Python example
make run-python
```

### Method 2: Manual Compilation and Execution

#### C Programs:
```bash
# Compile the C programs
mpicc -o hello_world_mpi hello_world_mpi.c
mpicc -o parallel_sum_mpi parallel_sum_mpi.c

# Run with different numbers of processes
mpirun -np 2 ./hello_world_mpi
mpirun -np 4 ./hello_world_mpi
mpirun -np 8 ./parallel_sum_mpi
```

#### Python Program:
```bash
# Run directly (no compilation needed)
mpirun -np 2 python3 hello_world_mpi.py
mpirun -np 4 python3 hello_world_mpi.py
```

## Understanding mpirun Command

### Basic Syntax
```bash
mpirun [options] <executable> [program_arguments]
```

### Common Options
- `-np N` or `--np N`: Number of processes to launch
- `-H host1,host2`: Specify hosts to run on
- `--hostfile filename`: Use a hostfile for host specification
- `--bind-to core`: Bind processes to CPU cores
- `--map-by core`: Map processes by cores

### Examples of Different Process Counts
```bash
# Run with 1 process (sequential)
mpirun -np 1 ./hello_world_mpi

# Run with 2 processes
mpirun -np 2 ./hello_world_mpi

# Run with 4 processes
mpirun -np 4 ./hello_world_mpi

# Run with as many processes as CPU cores
mpirun -np $(nproc) ./parallel_sum_mpi
```

## What Each Example Demonstrates

### 1. hello_world_mpi.c
- Basic MPI initialization and finalization
- Getting process rank and total number of processes
- Getting processor name
- **Key Concepts**: `MPI_Init`, `MPI_Comm_rank`, `MPI_Comm_size`, `MPI_Finalize`

### 2. hello_world_mpi.py
- Python MPI programming with mpi4py
- Simple point-to-point communication
- Sending and receiving data between processes
- **Key Concepts**: Process communication, data serialization

### 3. parallel_sum_mpi.c
- Parallel computation (calculating sum of numbers)
- Work distribution among processes
- Collective communication (reduction)
- **Key Concepts**: `MPI_Reduce`, parallel algorithms, load balancing

## Expected Output Examples

### Hello World (4 processes):
```
Hello world from processor YourMac.local, rank 0 out of 4 processors
Hello world from processor YourMac.local, rank 1 out of 4 processors  
Hello world from processor YourMac.local, rank 2 out of 4 processors
Hello world from processor YourMac.local, rank 3 out of 4 processors
```

### Parallel Sum (4 processes):
```
Process 0: calculated local sum = 125000250000 (elements 1 to 250000)
Process 1: calculated local sum = 375000250000 (elements 250001 to 500000)
Process 2: calculated local sum = 625000250000 (elements 500001 to 750000)
Process 3: calculated local sum = 875000250000 (elements 750001 to 1000000)

=== RESULTS ===
Parallel sum of numbers 1 to 1000000 = 500000500000
Expected sum (formula n*(n+1)/2) = 500000500000
Number of processes used: 4
```

## Tips for Learning MPI

1. **Start Small**: Begin with 2-4 processes to understand the concepts
2. **Process 0 is Special**: Often used as the "master" process for coordination
3. **Ranks are 0-indexed**: Process ranks go from 0 to (size-1)
4. **Communication Patterns**: Learn about point-to-point vs collective communication
5. **Debugging**: Use `printf` with rank information to trace execution

## Common Issues and Solutions

### Issue: "No executable was specified"
**Solution**: Always provide an executable after `mpirun`:
```bash
# Wrong
mpirun -np 4

# Right
mpirun -np 4 ./my_program
```

### Issue: "Command not found: mpirun"
**Solution**: Install MPI implementation:
```bash
brew install open-mpi
```

### Issue: Python import error for mpi4py
**Solution**: Install mpi4py:
```bash
pip3 install mpi4py
```

## Next Steps

After running these examples, try:
1. Modifying the number of processes
2. Adding more complex communication patterns
3. Implementing your own parallel algorithms
4. Exploring performance differences with different process counts

Happy parallel programming!