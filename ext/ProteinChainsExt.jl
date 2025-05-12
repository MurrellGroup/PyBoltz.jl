module ProteinChainsExt

using Boltz1
using ProteinChains: ProteinStructure
using ProteinChains.BioStructures: MolecularStructure

function Boltz1.predict(input::AbstractVector{MolecularSchema}, ::Type{ProteinStructure}; options...)
    return Boltz1.predict(input, MolecularStructure; options...) .|> ProteinStructure
end

function Boltz1.predict(input::MolecularSchema, ::Type{ProteinStructure}; options...)
    return Boltz1.predict([input], ProteinStructure; options...) |> only
end

end
