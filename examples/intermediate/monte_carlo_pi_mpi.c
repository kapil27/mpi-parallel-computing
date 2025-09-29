#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define MASTER_RANK 0
#define DEFAULT_SAMPLES 100000000  // 100 million samples

double monte_carlo_pi(long long num_samples, int rank) {
    long long points_in_circle = 0;
    double x, y, distance;
    
    // Seed random number generator with rank to ensure different sequences
    srand(time(NULL) + rank);
    
    for (long long i = 0; i < num_samples; i++) {
        // Generate random point in unit square [-1,1] x [-1,1]
        x = ((double)rand() / RAND_MAX) * 2.0 - 1.0;
        y = ((double)rand() / RAND_MAX) * 2.0 - 1.0;
        
        // Check if point is inside unit circle
        distance = x * x + y * y;
        if (distance <= 1.0) {
            points_in_circle++;
        }
    }
    
    // Estimate pi for this process
    return 4.0 * (double)points_in_circle / (double)num_samples;
}

int main(int argc, char *argv[]) {
    int rank, size;
    long long total_samples, local_samples;
    double local_pi, global_pi, start_time, end_time;
    double local_pi_squared, global_pi_squared;
    double mean, variance, std_dev;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    // Parse command line arguments or use default
    if (argc > 1) {
        total_samples = atoll(argv[1]);
    } else {
        total_samples = DEFAULT_SAMPLES;
    }
    
    local_samples = total_samples / size;
    
    if (rank == MASTER_RANK) {
        printf("=== MPI Monte Carlo Pi Estimation ===\\n");
        printf("Total samples: %lld\\n", total_samples);
        printf("Samples per process: %lld\\n", local_samples);
        printf("Number of processes: %d\\n", size);
        printf("Actual value of π: %.10f\\n\\n", M_PI);
    }
    
    // Synchronize and start timing
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();
    
    // Each process performs Monte Carlo simulation
    local_pi = monte_carlo_pi(local_samples, rank);
    
    printf("Process %d: Local π estimate = %.8f\\n", rank, local_pi);
    
    // Calculate statistics
    local_pi_squared = local_pi * local_pi;
    
    // Reduce to get global average
    MPI_Reduce(&local_pi, &global_pi, 1, MPI_DOUBLE, MPI_SUM, MASTER_RANK, MPI_COMM_WORLD);
    MPI_Reduce(&local_pi_squared, &global_pi_squared, 1, MPI_DOUBLE, MPI_SUM, MASTER_RANK, MPI_COMM_WORLD);
    
    // End timing
    MPI_Barrier(MPI_COMM_WORLD);
    end_time = MPI_Wtime();
    
    if (rank == MASTER_RANK) {
        // Calculate final statistics
        mean = global_pi / size;
        variance = (global_pi_squared / size) - (mean * mean);
        std_dev = sqrt(variance);
        
        printf("\\n=== RESULTS ===\\n");
        printf("Parallel π estimate: %.10f\\n", mean);
        printf("Actual π value:      %.10f\\n", M_PI);
        printf("Absolute error:      %.10f\\n", fabs(mean - M_PI));
        printf("Relative error:      %.6f%%\\n", fabs(mean - M_PI) / M_PI * 100);
        
        printf("\\n=== STATISTICS ===\\n");
        printf("Mean across processes:     %.8f\\n", mean);
        printf("Standard deviation:        %.8f\\n", std_dev);
        printf("Coefficient of variation:  %.4f%%\\n", (std_dev / mean) * 100);
        
        printf("\\n=== PERFORMANCE ===\\n");
        printf("Total execution time:      %.4f seconds\\n", end_time - start_time);
        printf("Samples per second:        %.0f\\n", (double)total_samples / (end_time - start_time));
        printf("Time per million samples:  %.4f seconds\\n", (end_time - start_time) / (total_samples / 1000000.0));
        
        // Theoretical accuracy analysis
        double theoretical_error = 1.0 / sqrt(total_samples);
        printf("\\n=== THEORETICAL ANALYSIS ===\\n");
        printf("Theoretical standard error: %.8f\\n", theoretical_error);
        printf("Observed vs theoretical:    %.2fx\\n", std_dev / theoretical_error);
    }
    
    MPI_Finalize();
    return 0;
}