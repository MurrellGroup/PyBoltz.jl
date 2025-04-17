using Boltz
using Test

using BioAlignments
using BioSequences
using BioStructures
using TMscore

@testset "Boltz.jl" begin

    mktempdir() do dir
        structure = retrievepdb("1TIT"; dir)
        sequence = LongAA(structure["A"], standardselector)
        fasta_file = joinpath(dir, "1TIT.fasta")
        write(fasta_file, ">seq|protein|empty\n$sequence\n")
        refolded_structure = predict(MolecularStructure, fasta_file; seed=0)
        @test refolded_structure isa MolecularStructure
        @test tmscore(structure, refolded_structure).tmscore > 0.5
    end

end
