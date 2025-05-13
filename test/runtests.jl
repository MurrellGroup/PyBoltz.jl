using Boltz1, Boltz1.Schema
using Test

using BioAlignments
using BioSequences
using BioStructures

include("TMscore.jl") # remove this once TMscore.jl is registered: https://github.com/JuliaRegistries/General/pull/130867
using .TMscore

ENV["BOLTZ1_TEST_ACCELERATOR"] = "gpu"

const accelerator = get(ENV, "BOLTZ1_TEST_ACCELERATOR", "cpu")

@testset "Boltz1.jl" begin

    @testset "Single structure run" begin
        mktempdir() do dir
            structure = retrievepdb("1TIT"; dir)
            sequence = LongAA(structure["A"], standardselector)
            input = MolecularInput(
                sequences = [
                    protein(; id="A", sequence, msa="empty")
                ]
            )
            predicted_structure = predict(input, MolecularStructure; seed=0, accelerator)
            @test predicted_structure isa MolecularStructure
            @test tmscore(structure, predicted_structure) > 0.5
        end
    end

    @testset "Directory run" begin
        mktempdir() do dir
            inputs = [
                MolecularInput(
                    sequences = [
                        protein(; id="A", sequence=randaaseq(10), msa="empty"),
                    ]
                ),
                MolecularInput(
                    sequences = [
                        protein(; id="A", sequence=randaaseq(20), msa="empty"),
                    ]
                ),
            ]
            predicted_structures = predict(inputs, MolecularStructure; seed=0, accelerator)
            @test predicted_structures isa Vector{MolecularStructure}
            @test length(predicted_structures) == 2
            @test predicted_structures[1] |> countresidues == 10
            @test predicted_structures[2] |> countresidues == 20
        end
    end

    @testset "MSA run" begin
        mktempdir() do dir
            input = MolecularInput(
                sequences = [
                    protein(; id="A", sequence=randaaseq(15), msa=[randaaseq(15) for _ in 1:10]),
                ]
            )
            predicted_structure = predict(input, MolecularStructure; seed=0, accelerator)
            @test predicted_structure isa MolecularStructure
            @test predicted_structure |> countresidues == 15
        end
    end

end
