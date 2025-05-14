module BioStructuresExt

using PyBoltz
using BioStructures

function read_boltz_cif(path::AbstractString, structure_name::AbstractString)
    mmcifdict = MMCIFDict(path)
    mmcifdict["_atom_site.auth_atom_id"] = mmcifdict["_atom_site.label_atom_id"]
    mmcifdict["_atom_site.pdbx_formal_charge"] = repeat(["?"], length(mmcifdict["_atom_site.auth_atom_id"]))
    return MolecularStructure(mmcifdict; structure_name)
end

function PyBoltz.predict(input, ::Type{MolecularStructure}; options...)
    structures = MolecularStructure[]
    mktempdir() do out_dir
        predict(input; out_dir, output_format="mmcif", options...)
        prediction_paths = readdir(joinpath(out_dir, only(readdir(out_dir)), "predictions"); join=true)
        for prediction_path in prediction_paths
            cif_path = joinpath(prediction_path, basename(prediction_path)*"_model_0.cif")
            push!(structures, read_boltz_cif(cif_path, basename(prediction_path)))
        end
    end
    return structures
end

function PyBoltz.predict(input::PyBoltz.Schema.MolecularInput, ::Type{MolecularStructure}; options...)
    return PyBoltz.predict([input], MolecularStructure; options...) |> only
end

end
