# Boltz.jl

[![Build Status](https://github.com/MurrellGroup/Boltz.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MurrellGroup/Boltz.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia bindings for the [boltz](https://github.com/jwohlwend/boltz) Python package.

## Installation

```julia
using Pkg
Pkg.Registry.add(url="https://github.com/MurrellGroup/MurrellGroupRegistry")
Pkg.add("Boltz")
```

## Usage

The `predict` function takes an input path, and options as keyword arguments, which get mapped to the `boltz predict` command.

### Getting output in a directory

```julia
using Boltz

write("1CRN.fasta", ">1CRN|protein|empty\nTTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN")
Boltz.predict("1CRN.fasta")
```

### Getting the folded structure directly

```julia
using BioStructures # activates extension

structure = Boltz.predict(MolecularStructure, "1CRN.fasta")
```

See `?Boltz.predict` for keyword arguments.