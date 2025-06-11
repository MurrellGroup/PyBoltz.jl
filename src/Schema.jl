module Schema

export BoltzInput
export protein, dna, rna, ligand
export bond, pocket

const BOLTZ_SCHEMA_VERSION = 1

"""
    BoltzInput

A dictionary object that can be written to a YAML file.

Implemented according to the schema definition in the
[boltz documentation](https://github.com/jwohlwend/boltz/blob/744b4aecb6b5e847a25692ced07c328e7995ee33/docs/prediction.md),
allowing for easy in-memory construction of the schema.

# Additions

- `name` is an optional argument that changes the name of the output file/structure.
- Sequences passed to `protein`, `dna`, and `rna` get automatically converted to strings,
  so any type (e.g. `BioSequences.BioSequence`) that has sensible `Base.string`-conversion
  defined will work.
- `msa` can be provided as a vector of sequences.

# Examples

```julia
using PyBoltz.Schema

input1 = BoltzInput(
    name = "example1", # optional name YAML file (and thus output pdb/cif file)
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

input2 = BoltzInput(
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
            contacts = [ ("B1", 1), ("A1", 138) ]
        )
    ]
)
```
"""
struct BoltzInput <: AbstractDict{String,Any}
    dict::Dict{String,Any}
end

function BoltzInput(;
    sequences,
    constraints = nothing,
    templates = nothing,
    properties = nothing,
    name = nothing
)
    dict = Dict{String,Any}("version" => BOLTZ_SCHEMA_VERSION, "sequences" => sequences)
    !isnothing(constraints) && (dict["constraints"] = constraints)
    !isnothing(templates) && (dict["templates"] = templates)
    !isnothing(properties) && (dict["properties"] = properties)
    !isnothing(name) && (dict["name"] = name)
    return BoltzInput(dict)
end

Base.length(input::BoltzInput) = length(input.dict)
Base.iterate(input::BoltzInput, args...) = iterate(input.dict, args...)
Base.getindex(input::BoltzInput, key::AbstractString) = input.dict[key]
Base.get(input::BoltzInput, key::AbstractString, default) = get(input.dict, key, default)

# deprecated
const MolecularInput = BoltzInput
export MolecularInput

## sequences

"""
    protein(; id, sequence, msa=nothing, modifications=nothing, cyclic=nothing)

```julia
using PyBoltz.Schema: protein
protein(id="A", sequence="RHKDE")
protein(id=["A", "B"], sequence="RHKDE")
protein(id="A", sequence="RHKDE", msa="path/to/msa.a3m")
protein(id="A", sequence="RHKDE", msa=["RHKDE", "RHKDE"])
protein(id="A", sequence="RHKDE", modifications=[(position=1, ccd="MSE"), (position=5, ccd="MSE")])
protein(id="A", sequence="RHKDE", cyclic=true)
```
"""
function protein(;
    id::Union{AbstractString,AbstractVector{<:AbstractString}},
    sequence,
    msa::Union{Any,AbstractVector{<:Any},Nothing} = nothing,
    modifications::Union{AbstractVector{<:NamedTuple{(:position,:ccd),<:Tuple{Integer,AbstractString}}},Nothing} = nothing,
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
    !isnothing(modifications) && (dict["modifications"] = [Dict("position" => position, "ccd" => ccd) for (position, ccd) in modifications])
    !isnothing(cyclic) && (dict["cyclic"] = cyclic)
    return Dict("protein" => dict)
end

function _dna_or_rna(type;
    id::Union{AbstractString,AbstractVector{<:AbstractString}},
    sequence,
    modifications::Union{AbstractVector{<:NamedTuple{(:position,:ccd),<:Tuple{Integer,AbstractString}}},Nothing} = nothing,
    cyclic::Union{Bool,Nothing} = nothing
)
    dict = Dict(type => Dict{String,Any}("id" => id, "sequence" => string(sequence)))
    !isnothing(modifications) && (dict[type]["modifications"] = [Dict("position" => position, "ccd" => ccd) for (position, ccd) in modifications])
    !isnothing(cyclic) && (dict[type]["cyclic"] = cyclic)
    return dict
end

"""
    dna(; id, sequence)

```julia
using PyBoltz.Schema: dna
dna(id="A", sequence="GATTACA")
dna(id=["A", "B"], sequence="GATTACA")
dna(id="A", sequence="GATTACA", modifications=[(position=2, ccd="6MA"), (position=6, ccd="5MC")]) # untested
dna(id="A", sequence="GATTACA", cyclic=true)
```
"""
const dna = (; kwargs...) -> _dna_or_rna("dna"; kwargs...)

"""
    rna(; id, sequence)

```julia
using PyBoltz.Schema: rna
rna(id="A", sequence="GAUUACA")
rna(id=["A", "B"], sequence="GAUUACA")
rna(id="A", sequence="GAUUACA", modifications=[(position=2, ccd="I"), (position=3, ccd="PSU")]) # untested
rna(id="A", sequence="GAUUACA", cyclic=true)
```
"""
const rna = (; kwargs...) -> _dna_or_rna("rna"; kwargs...)


"""
    ligand(; id, smiles=nothing, ccd=nothing)

```julia
using PyBoltz.Schema: ligand
ligand(id="C", smiles="C1=CC=CC=C1")
ligand(id=["D", "E"], ccd="SAH")
```
"""
function ligand(;
    id::Union{AbstractString,AbstractVector{<:AbstractString}},
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
using PyBoltz.Schema: bond
# atom1 and atom2 are tuples of (chain_id, residue_index, atom_name)
bond(atom1=("A", 1, "CA"), atom2=("B", 2, "CA"))
```
"""
function bond(;
    atom1::Tuple{AbstractString,Integer,AbstractString},
    atom2::Tuple{AbstractString,Integer,AbstractString}
)
    return Dict("bond" => Dict{String,Any}("atom1" => [atom1...], "atom2" => [atom2...]))
end

"""
    pocket(; binder, contacts, max_distance=nothing)

```julia
using PyBoltz.Schema: pocket
# binder is a chain_id
# contacts is a vector of vectors of (chain_id, residue_index)
pocket(binder="A", contacts=[("B", 1), ("C", 2)])
```
"""
function pocket(;
    binder::AbstractString,
    contacts::AbstractVector{<:Tuple{AbstractString,Any}},
    max_distance::Union{Real,Nothing} = nothing,
)
    dict = Dict("pocket" => Dict{String,Any}(
        "binder" => binder,
        "contacts" => [[c...] for c in contacts]))
    !isnothing(max_distance) && (dict["max_distance"] = max_distance)
    return dict
end

"""
    contact(; token1, token2, max_distance=nothing)
"""
function contact(;
    token1::Tuple{AbstractString,Any},
    token2::Tuple{AbstractString,Any},
    max_distance::Union{Real,Nothing} = nothing,
)
    dict = Dict("contact" => Dict(
        "token1" => token1,
        "token2" => token2))
    !isnothing(max_distance) && (dict["max_distance"] = max_distance)
    return dict
end

## templates

"""
    template(; cif, chain_id=nothing, template_id=nothing)
"""
function template(;
    cif::AbstractString,
    chain_id::Union{AbstractString,AbstractVector{<:AbstractString},Nothing} = nothing,
    template_id::Union{AbstractString,AbstractVector{<:AbstractString},Nothing} = nothing,
)
    dict = Dict{String,Any}("cif" => cif)
    !isnothing(chain_id) && (dict["chain_id"] = chain_id)
    !isnothing(template_id) && (dict["template_id"] = template_id)
end

## properties

"""
    affinity(; binder)
"""
function affinity(;
    binder::AbstractString
)
    return Dict("affinity" => Dict("binder" => binder))
end

end
