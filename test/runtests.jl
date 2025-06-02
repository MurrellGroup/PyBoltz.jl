using PyBoltz, PyBoltz.Schema
using Test

using BioAlignments
using BioSequences
using BioStructures

using TMscore

# ENV["PyBoltz_TEST_ACCELERATOR"] = "gpu"

const accelerator = get(ENV, "PyBoltz_TEST_ACCELERATOR", "cpu")

@testset "PyBoltz.jl" begin

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
                    name = "Z",
                    sequences = [
                        protein(; id="A", sequence=randaaseq(10), msa="empty"),
                    ]
                ),
                MolecularInput(
                    name = "X",
                    sequences = [
                        protein(; id="A", sequence=randaaseq(30), msa="empty"),
                    ]
                ),
                MolecularInput(
                    name = "Y",
                    sequences = [
                        protein(; id="A", sequence=randaaseq(20), msa="empty"),
                    ]
                ),
                MolecularInput(
                    name = "W",
                    sequences = [
                        protein(; id="A", sequence=randaaseq(40), msa="empty"),
                    ]
                ),
            ]
            predicted_structures = predict(inputs, MolecularStructure; seed=0, accelerator)
            @test predicted_structures isa Vector{MolecularStructure}
            @test length(predicted_structures) == 4
            @testset "Order preservation" begin
                @test countresidues.(predicted_structures) == [10, 30, 20, 40]
                @test [predicted_structure.name for predicted_structure in predicted_structures] == ["Z", "X", "Y", "W"]
            end
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
