---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''

---

## Bug Description
A clear and concise description of what the bug is.

## System Information
- **OS**: [e.g., Ubuntu 20.04, macOS 12.0, CentOS 8]
- **MPI Implementation**: [e.g., Open MPI 4.1.0, Intel MPI, MPICH]  
- **Compiler**: [e.g., gcc 9.3.0, clang 12.0]
- **Python Version**: [e.g., Python 3.8.5] (if applicable)

## Steps to Reproduce
Steps to reproduce the behavior:
1. Run `make all`
2. Execute `mpirun -np 4 examples/basic/hello_world_mpi`
3. Observe error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
A clear and concise description of what actually happened.

## Error Output
If applicable, paste the complete error message:
```
[paste error messages here]
```

## Additional Context
Add any other context about the problem here.

## Minimal Example
If possible, provide a minimal code example that reproduces the issue:
```c
// Minimal code that shows the problem
```

## Checklist
- [ ] I have searched existing issues for similar problems
- [ ] I have verified my MPI installation works with other programs
- [ ] I have included complete error messages
- [ ] I have provided system information