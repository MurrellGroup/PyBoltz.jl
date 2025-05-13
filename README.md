# Boltz1.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://MurrellGroup.github.io/Boltz1.jl/dev/)
[![Build Status](https://github.com/MurrellGroup/Boltz1.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MurrellGroup/Boltz1.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/MurrellGroup/Boltz1.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/MurrellGroup/Boltz1.jl)

Julia bindings for the [boltz](https://github.com/jwohlwend/boltz) Python package.

## Installation

```julia
using Pkg
pkg"registry add https://github.com/MurrellGroup/MurrellGroupRegistry"
pkg"add Boltz1"
```

## Quickstart

### In-memory input/output

```julia
using Boltz1, Boltz1.Schema

input = MolecularInput(
    sequences = [
        protein(id="A", sequence="TTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN"),
    ]
)

using BioStructures: MolecularStructure

predicted_structure = predict(input, MolecularStructure)
```

### `boltz predict` command binding

```julia
using Boltz1

Boltz1.predict(input_path; options...)
```
