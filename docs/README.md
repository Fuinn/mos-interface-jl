# Documentation Guide

## Building the docs

```
./build.sh
```

from the `docs` directory. The generated documentation can be then found in the created ``build`` directory.

If MOSInterface has been updated, then the following must be executed for the docstrings inside to be picked up:

```
using Pkg
Pkg.activate(".")
Pkg.update("MOSInterface")
```