#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define MATRIX_SIZE 800
#define MASTER_RANK 0

void print_matrix(double *matrix, int rows, int cols, const char* name) {
    printf("\n%s:\n", name);
    for (int i = 0; i < rows && i < 5; i++) { // Only print first 5 rows
        for (int j = 0; j < cols && j < 5; j++) { // Only print first 5 columns
            printf("%6.2f ", matrix[i * cols + j]);
        }
        if (cols > 5) printf("...");
        printf("\n");
    }
    if (rows > 5) printf("...\n");
}

void initialize_matrix(double *matrix, int size, int seed_offset) {
    srand(time(NULL) + seed_offset);
    for (int i = 0; i < size * size; i++) {
        matrix[i] = ((double)rand() / RAND_MAX) * 10.0;
    }
}

int main(int argc, char *argv[]) {
    int rank, size;
    double *A = NULL, *B = NULL, *C = NULL;
    double *local_A, *local_C;
    int rows_per_process;
    double start_time, end_time;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    rows_per_process = MATRIX_SIZE / size;
    
    // Allocate memory for local matrices
    local_A = (double*)malloc(rows_per_process * MATRIX_SIZE * sizeof(double));
    local_C = (double*)malloc(rows_per_process * MATRIX_SIZE * sizeof(double));
    B = (double*)malloc(MATRIX_SIZE * MATRIX_SIZE * sizeof(double));
    
    // Master process initializes matrices
    if (rank == MASTER_RANK) {
        A = (double*)malloc(MATRIX_SIZE * MATRIX_SIZE * sizeof(double));
        C = (double*)malloc(MATRIX_SIZE * MATRIX_SIZE * sizeof(double));
        
        printf("=== MPI Matrix Multiplication ===\n");
        printf("Matrix size: %dx%d\n", MATRIX_SIZE, MATRIX_SIZE);
        printf("Number of processes: %d\n", size);
        printf("Rows per process: %d\n", rows_per_process);
        
        // Initialize matrices A and B
        initialize_matrix(A, MATRIX_SIZE, 1);
        initialize_matrix(B, MATRIX_SIZE, 2);
        
        printf("\\nInitialized matrices A and B\n");
        print_matrix(A, MATRIX_SIZE, MATRIX_SIZE, "Matrix A (sample)");
        print_matrix(B, MATRIX_SIZE, MATRIX_SIZE, "Matrix B (sample)");
    }
    
    // Start timing
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();
    
    // Scatter rows of matrix A to all processes
    MPI_Scatter(A, rows_per_process * MATRIX_SIZE, MPI_DOUBLE,
                local_A, rows_per_process * MATRIX_SIZE, MPI_DOUBLE,
                MASTER_RANK, MPI_COMM_WORLD);
    
    // Broadcast matrix B to all processes
    MPI_Bcast(B, MATRIX_SIZE * MATRIX_SIZE, MPI_DOUBLE, MASTER_RANK, MPI_COMM_WORLD);
    
    // Perform local matrix multiplication
    for (int i = 0; i < rows_per_process; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            local_C[i * MATRIX_SIZE + j] = 0.0;
            for (int k = 0; k < MATRIX_SIZE; k++) {
                local_C[i * MATRIX_SIZE + j] += 
                    local_A[i * MATRIX_SIZE + k] * B[k * MATRIX_SIZE + j];
            }
        }
    }
    
    // Gather results from all processes
    MPI_Gather(local_C, rows_per_process * MATRIX_SIZE, MPI_DOUBLE,
               C, rows_per_process * MATRIX_SIZE, MPI_DOUBLE,
               MASTER_RANK, MPI_COMM_WORLD);
    
    // End timing
    MPI_Barrier(MPI_COMM_WORLD);
    end_time = MPI_Wtime();
    
    // Master process displays results
    if (rank == MASTER_RANK) {
        printf("\\n=== RESULTS ===\n");
        print_matrix(C, MATRIX_SIZE, MATRIX_SIZE, "Result Matrix C = A × B (sample)");
        
        printf("\\n=== PERFORMANCE ===\n");
        printf("Execution time: %.4f seconds\n", end_time - start_time);
        printf("Operations: %.0f (matrix multiplications)\n", 
               (double)MATRIX_SIZE * MATRIX_SIZE * MATRIX_SIZE);
        printf("GFLOPS: %.2f\n", 
               (2.0 * MATRIX_SIZE * MATRIX_SIZE * MATRIX_SIZE) / 
               ((end_time - start_time) * 1e9));
        
        // Simple verification (check one element)
        double verification = 0.0;
        for (int k = 0; k < MATRIX_SIZE; k++) {
            verification += A[0 * MATRIX_SIZE + k] * B[k * MATRIX_SIZE + 0];
        }
        printf("Verification: C[0][0] = %.6f (computed: %.6f)\n", 
               C[0], verification);
    }
    
    // Cleanup
    free(local_A);
    free(local_C);
    free(B);
    if (rank == MASTER_RANK) {
        free(A);
        free(C);
    }
    
    MPI_Finalize();
    return 0;
}