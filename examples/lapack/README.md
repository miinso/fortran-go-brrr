# LAPACK Example

Solves a 5×5 linear system **Ax = b** using LAPACK's `DGESV` routine.

**Test problem:** Symmetric positive definite matrix with known solution **x = [1, 2, 3, 4, 5]'**

## Run

```bash
bazel run //examples/lapack:main
```

## Output

```sh
 Solution:
  x(1) =    1.0000000000  (expected:    1.0000000000)
  x(2) =    2.0000000000  (expected:    2.0000000000)
  x(3) =    3.0000000000  (expected:    3.0000000000)
  x(4) =    4.0000000000  (expected:    4.0000000000)
  x(5) =    5.0000000000  (expected:    5.0000000000)
Max error:   8.8818E-16
```
