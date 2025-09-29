#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    
    int world_rank, world_size;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    
    // Define the size of the array and calculate local portion
    int total_size = 1000000;
    int local_size = total_size / world_size;
    int remainder = total_size % world_size;
    
    // Adjust for remainder
    if (world_rank < remainder) {
        local_size += 1;
    }
    
    // Calculate starting index for this process
    int start_idx = world_rank * (total_size / world_size) + 
                    (world_rank < remainder ? world_rank : remainder);
    
    // Calculate local sum
    long long local_sum = 0;
    for (int i = 0; i < local_size; i++) {
        local_sum += (start_idx + i + 1); // Sum of numbers 1 to N
    }
    
    printf("Process %d: calculated local sum = %lld (elements %d to %d)\n", 
           world_rank, local_sum, start_idx + 1, start_idx + local_size);
    
    // Reduce all local sums to get global sum
    long long global_sum = 0;
    MPI_Reduce(&local_sum, &global_sum, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
    
    // Only rank 0 prints the final result
    if (world_rank == 0) {
        printf("\n=== RESULTS ===\n");
        printf("Parallel sum of numbers 1 to %d = %lld\n", total_size, global_sum);
        printf("Expected sum (formula n*(n+1)/2) = %lld\n", 
               (long long)total_size * (total_size + 1) / 2);
        printf("Number of processes used: %d\n", world_size);
    }
    
    MPI_Finalize();
    return 0;
}