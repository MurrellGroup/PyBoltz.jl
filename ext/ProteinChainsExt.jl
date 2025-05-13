module ProteinChainsExt

using PyBoltz
using ProteinChains: ProteinStructure
using ProteinChains.BioStructures: MolecularStructure

function PyBoltz.predict(input, ::Type{ProteinStructure}; options...)
    return PyBoltz.predict(input, MolecularStructure; options...) .|> ProteinStructure
end

function PyBoltz.predict(input::MolecularInput, ::Type{ProteinStructure}; options...)
    return PyBoltz.predict(input, MolecularStructure; options...) |> ProteinStructure
end

end
