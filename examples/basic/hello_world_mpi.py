#!/usr/bin/env python3

from mpi4py import MPI
import socket

# Initialize MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
processor_name = socket.gethostname()

print(f"Hello world from processor {processor_name}, rank {rank} out of {size} processors")

# Example of simple communication
if rank == 0:
    data = {'message': 'Hello from rank 0!', 'numbers': [1, 2, 3, 4, 5]}
    # Send data to all other processes
    for i in range(1, size):
        comm.send(data, dest=i, tag=11)
    print(f"Rank {rank}: Sent data to all other processes")
else:
    # Receive data from rank 0
    data = comm.recv(source=0, tag=11)
    print(f"Rank {rank}: Received data: {data['message']}")