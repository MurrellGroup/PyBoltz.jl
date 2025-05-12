module BioStructuresExt

using Boltz1
using BioStructures

function read_boltz_cif(path::AbstractString)
    mmcifdict = MMCIFDict(path)
    mmcifdict["_atom_site.auth_atom_id"] = mmcifdict["_atom_site.label_atom_id"]
    mmcifdict["_atom_site.pdbx_formal_charge"] = repeat(["?"], length(mmcifdict["_atom_site.auth_atom_id"]))
    return MolecularStructure(mmcifdict)
end

function Boltz1.predict(input, ::Type{MolecularStructure}; options...)
    structures = MolecularStructure[]
    mktempdir() do out_dir
        predict(input; out_dir, output_format="mmcif", options...)
        prediction_paths = readdir(joinpath(out_dir, only(readdir(out_dir)), "predictions"); join=true)
        for prediction_path in prediction_paths
            cif_path = joinpath(prediction_path, basename(prediction_path)*"_model_0.cif")
            push!(structures, read_boltz_cif(cif_path))
        end
    end
    return structures
end

function Boltz1.predict(input::MolecularSchema, ::Type{MolecularStructure}; options...)
    return Boltz1.predict([input], MolecularStructure; options...) |> only
end

end
