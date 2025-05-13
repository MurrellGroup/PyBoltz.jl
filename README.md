# PyBoltz.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://MurrellGroup.github.io/PyBoltz.jl/dev/)
[![Build Status](https://github.com/MurrellGroup/PyBoltz.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MurrellGroup/PyBoltz.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/MurrellGroup/PyBoltz.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/MurrellGroup/PyBoltz.jl)

> [!WARNING]
> Boltz currently fails when using CPU as accelerator (and thus also GitHub's default CI). See https://github.com/MurrellGroup/PyBoltz.jl/issues/2 for tracker.

Bindings for Python's [boltz](https://github.com/jwohlwend/boltz) in Julia for biomolecular structure prediction.

## Installation

```julia
using Pkg
pkg"add PyBoltz"
```

## Quickstart

### In-memory input/output

```julia
using PyBoltz, PyBoltz.Schema

input = MolecularInput(
    sequences = [
        protein(id="A", sequence="TTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN", msa="empty"),
    ]
)

using BioStructures: MolecularStructure

predicted_structure = predict(input, MolecularStructure)
```

### `boltz predict` command binding

```julia
using PyBoltz

PyBoltz.predict(input_path; options...)
```
