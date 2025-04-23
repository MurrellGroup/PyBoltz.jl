# Boltz1.jl

[![Build Status](https://github.com/MurrellGroup/Boltz1.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/MurrellGroup/Boltz1.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia bindings for the [boltz](https://github.com/jwohlwend/boltz) Python package.

## Installation

```julia
using Pkg
pkg"registry add https://github.com/MurrellGroup/MurrellGroupRegistry"
pkg"add Boltz1"
```

## Usage

The `predict` function takes an input path, and options as keyword arguments, which get mapped to the `boltz predict` command.

### Getting output in a directory

```julia
using Boltz1

write("1CRN.fasta", ">1CRN|protein|empty\nTTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN")
predict("1CRN.fasta")
```

### Getting the folded structure directly

```julia
using BioStructures # activates extension

structures = predict(MolecularStructure, "path/to/input_files") # batched, returning a vector of structures

structure = only(predict(MolecularStructure, "1CRN.fasta")) # only one element if path isn't a directory
```

See `?predict` for keyword arguments.
