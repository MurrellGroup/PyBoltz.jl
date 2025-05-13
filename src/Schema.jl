module Schema

export MolecularInput
export protein, dna, rna, ligand
export bond, pocket

const BOLTZ_SCHEMA_VERSION = 1

"""
    MolecularInput

A dictionary object that can be written to a YAML file.

Implemented according to the schema definition in the
[boltz documentation](https://github.com/jwohlwend/boltz/blob/a9b3abc2c1f90f26b373dd1bcb7afb5a3cb40293/docs/prediction.md),
allowing for easy in-memory construction of the schema.

Sequences passed to `protein`, `dna`, and `rna` get automatically converted to strings,
so any type (e.g. `BioSequences.BioSequence`) that has sensible `Base.string`-conversion
defined will work.

One addition is that `msa` can be provided as a vector of strings.

# Examples

## Ligand

```julia
using Boltz1.Schema

input1 = MolecularInput(
    sequences = [
        protein(
            id = ["A", "B"],
            sequence = seq,
            msa = [seq, other...] # or path to a3m file
        ),
        ligand(
            id = ["C", "D"],
            ccd = "SAH"
        ),
        ligand(
            id = ["E", "F"],
            smiles = "N[C@@H](Cc1ccc(O)cc1)C(=O)O"
        )
    ]
)

input2 = MolecularInput(
    sequences = [
        protein(
            id = ["A1"],
            sequence = seq
        ),
        ligand(
            id = ["B1"],
            ccd = "EKY"
        )
    ],
    constraints = [
        pocket(
            binder = "B1",
            contacts = [ ["B1", 1], ["A1", 138] ]
        )
    ]
)
```
"""
struct MolecularInput <: AbstractDict{String,Any}
    dict::Dict{String,Any}
end

function MolecularInput(;
    sequences,
    constraints = nothing
)
    dict = Dict{String,Any}("version" => BOLTZ_SCHEMA_VERSION, "sequences" => sequences)
    !isnothing(constraints) && (dict["constraints"] = constraints)
    return MolecularInput(dict)
end

Base.length(input::MolecularInput) = length(input.dict)
Base.iterate(input::MolecularInput, args...) = iterate(input.dict, args...)
Base.getindex(input::MolecularInput, key::AbstractString) = input.dict[key]


## sequences

"""
    protein(; id, sequence, msa=nothing, modifications=nothing, cyclic=nothing)

```julia
using Boltz1.Schema: protein
protein(id="A", sequence="RHKDE")
protein(id=["A", "B"], sequence="RHKDE")
protein(id="A", sequence="RHKDE", msa="path/to/msa.a3m")
protein(id="A", sequence="RHKDE", msa=["RHKDE", "RHKDE"])
protein(id="A", sequence="RHKDE", modifications=[(1, "MSE"), (5, "MSE")])
protein(id="A", sequence="RHKDE", cyclic=true)
```
"""
function protein(;
    id::Union{AbstractString,Vector{<:AbstractString}},
    sequence,
    msa::Union{AbstractString,Vector,Nothing} = nothing,
    modifications::Union{Vector{Tuple{Int,String}},Nothing} = nothing,
    cyclic::Union{Bool,Nothing} = nothing
)
    dict = Dict{String,Any}("id" => id, "sequence" => string(sequence))
    if !isnothing(msa)
        if msa isa AbstractString
            dict["msa"] = msa
        elseif msa isa Vector
            dict["msa"] = string.(msa)
        end
    end
    !isnothing(modifications) && (dict["modifications"] = modifications)
    !isnothing(cyclic) && (dict["cyclic"] = cyclic)
    return Dict("protein" => dict)
end

function _dna_or_rna(type;
    id::Union{AbstractString,Vector{<:AbstractString}},
    sequence,
    modifications::Union{Vector{Tuple{Int,String}},Nothing} = nothing,
    cyclic::Union{Bool,Nothing} = nothing
)
    dict = Dict(type => Dict{String,Any}("id" => id, "sequence" => string(sequence)))
    !isnothing(modifications) && (dict[type]["modifications"] = modifications)
    !isnothing(cyclic) && (dict[type]["cyclic"] = cyclic)
    return dict
end

"""
    dna(; id, sequence)

```julia
using Boltz1.Schema: dna
dna(id="A", sequence="GATTACA")
dna(id=["A", "B"], sequence="GATTACA")
dna(id="A", sequence="GATTACA", modifications=[(2, "6MA"), (6, "5MC")]) # untested
dna(id="A", sequence="GATTACA", cyclic=true)
```
"""
const dna = (; kwargs...) -> _dna_or_rna("dna"; kwargs...)

"""
    rna(; id, sequence)

```julia
using Boltz1.Schema: rna
rna(id="A", sequence="GAUUACA")
rna(id=["A", "B"], sequence="GAUUACA")
rna(id="A", sequence="GAUUACA", modifications=[(2, "I"), (3, "PSU")]) # untested
rna(id="A", sequence="GAUUACA", cyclic=true)
```
"""
const rna = (; kwargs...) -> _dna_or_rna("rna"; kwargs...)


"""
    ligand(; id, smiles=nothing, ccd=nothing)

```julia
using Boltz1.Schema: ligand
ligand(id="C", smiles="C1=CC=CC=C1")
ligand(id=["D", "E"], ccd="SAH")
```
"""
function ligand(;
    id::Union{AbstractString,Vector{<:AbstractString}},
    smiles::Union{AbstractString,Nothing} = nothing,
    ccd::Union{AbstractString,Nothing} = nothing,
)
    dict = Dict{String,Any}("id" => id)
    !isnothing(smiles) && (dict["smiles"] = smiles)
    !isnothing(ccd) && (dict["ccd"] = ccd)
    !isnothing(smiles) && !isnothing(ccd) && throw(ArgumentError("smiles and ccd cannot both be provided"))
    return Dict("ligand" => dict)
end


## constraints

"""
    bond(; atom1, atom2)

```julia
using Boltz1.Schema: bond
# atom1 and atom2 are tuples of (chain_id, residue_index, atom_name)
bond(atom1=("A", 1, "CA"), atom2=("B", 2, "CA"))
```
"""
function bond(;
    atom1::Tuple{String,Int,String},
    atom2::Tuple{String,Int,String}
)
    return Dict("bond" => Dict{String,Any}("atom1" => [atom1...], "atom2" => [atom2...]))
end

"""
    pocket(; binder, contacts)

```julia
using Boltz1.Schema: pocket
# binder is a chain_id
# contacts is a vector of vectors of (chain_id, residue_index)
pocket(binder="A", contacts=[["B", 1], ["C", 2]])
```
"""
function pocket(;
    binder::AbstractString,
    contacts::Vector{Tuple{String,Int}}
)
    return Dict("pocket" => Dict{String,Any}("binder" => binder, "contacts" => [[c...] for c in contacts]))
end

end
