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

The `predict` function takes a `MolecularSchema`, and options as keyword arguments.

### Getting output in a directory

```julia
using Boltz1

input = MolecularSchema(
    sequences = [
        protein(id="A", sequence="TTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN"),
        protein(id="B", sequence="TTCCPSIVARSNFNVCRLPGTPEALCATYTGCIIIPGATCPGDYAN")
    ]
)

using BioStructures: MolecularStructure

predicted_structure = predict(input, MolecularStructure)
```

### Getting the folded structure directly

```julia
using BioStructures # activates extension

structure = only(predict(MolecularStructure, "1CRN.fasta")) # only one element if path isn't a directory

mkdir("batch")
write("batch/1CRN.fasta", ">1CRN|protein|empty\nTTCCPSIVARSNFNVCRLPGTPEAICATYTGCIIIPGATCPGDYAN")
write("batch/1EJG.fasta", ">1EJG|protein|empty\nTTCCPSIVARSNFNVCRLPGTPEALCATYTGCIIIPGATCPGDYAN")
structures = predict(MolecularStructure, "batch") # batched, returning a vector of structures
```

See `?predict` for keyword arguments.
