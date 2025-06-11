module ProteinChainsExt

using PyBoltz
using ProteinChains: ProteinStructure
using ProteinChains.BioStructures: MolecularStructure

to_structure(x) = ProteinStructure(x)
to_structure(::Missing) = missing

function PyBoltz.predict(input, ::Type{ProteinStructure}; options...)
    return PyBoltz.predict(input, MolecularStructure; options...) .|> to_structure
end

function PyBoltz.predict(input::PyBoltz.Schema.BoltzInput, ::Type{ProteinStructure}; options...)
    return PyBoltz.predict(input, MolecularStructure; options...) |> to_structure
end

end
