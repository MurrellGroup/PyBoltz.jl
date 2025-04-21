using Boltz1
using Test

using BioAlignments
using BioSequences
using BioStructures
using TMscore

@testset "Boltz1.jl" begin

    mktempdir() do tempdir

        @testset "Single run" begin
            structure = retrievepdb("1TIT"; dir=tempdir)
            sequence = LongAA(structure["A"], standardselector)
            fasta_file = joinpath(tempdir, "1TIT.fasta")
            write(fasta_file, ">seq|protein|empty\n$sequence\n")
            refolded_structure = predict(MolecularStructure, fasta_file; seed=0, accelerator="cpu")[1]
            @test refolded_structure isa MolecularStructure
            @test tmscore(structure, refolded_structure) > 0.5
        end

        @testset "Directory run" begin
            dir = mkdir(joinpath(tempdir, "batchedrun"))
            write(joinpath(dir, "1RND.fasta"), ">seq|protein|empty\n$(randaaseq(10))\n")
            write(joinpath(dir, "2RND.fasta"), ">seq|protein|empty\n$(randaaseq(20))\n")
            refolded_structures = predict(MolecularStructure, dir; seed=0, accelerator="cpu")
            @test refolded_structures isa Vector{MolecularStructure}
            @test length(refolded_structures) == 2
            @test refolded_structures[1] |> countresidues == 10
            @test refolded_structures[2] |> countresidues == 20
        end

        @testset "Directory run with MSA" begin
            dir = mkdir(joinpath(tempdir, "batchedrunmsa"))
            msafile = joinpath(dir, "1RND.a3m")
            open(msafile, "w") do io
                for i in 1:10
                    write(io, ">$i\n$(randaaseq(15))\n")
                end
            end
            fasta_file = joinpath(dir, "1MSA.fasta")
            write(fasta_file, ">seq|protein|$(msafile)\n$(randaaseq(15))\n")
            refolded_structures = predict(MolecularStructure, fasta_file; seed=0, accelerator="cpu")
            @test refolded_structures isa Vector{MolecularStructure}
            @test length(refolded_structures) == 1
            @test refolded_structures[1] |> countresidues == 15
        end

    end

end
