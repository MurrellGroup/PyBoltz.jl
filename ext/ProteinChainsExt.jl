module ProteinChainsExt

using Boltz1
using ProteinChains: ProteinStructure
using ProteinChains.BioStructures: MolecularStructure

function Boltz1.predict(input, ::Type{ProteinStructure}; options...)
    return Boltz1.predict(input, MolecularStructure; options...) .|> ProteinStructure
end

function Boltz1.predict(input::MolecularInput, ::Type{ProteinStructure}; options...)
    return Boltz1.predict(input, MolecularStructure; options...) |> ProteinStructure
end

end
