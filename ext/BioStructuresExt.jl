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
    mktempdir() do out_dir
        predict(input;
            _prefix_index=(input isa AbstractVector{PyBoltz.Schema.MolecularInput}),
            out_dir,
            output_format="mmcif",
            options...)
        prediction_paths = readdir(joinpath(out_dir, only(readdir(out_dir)), "predictions"); join=true)
        prediction_names = basename.(prediction_paths)
        structures = MolecularStructure[]
        perm, structure_names = if all(name -> startswith(name, PyBoltz.PYBOLTZ_INPUT_INDEX_PREFIX), prediction_names)
            indices = Int[]
            structure_names = String[]
            for prediction_name in prediction_names
                index, name = split(split(prediction_name, PyBoltz.PYBOLTZ_INPUT_INDEX_PREFIX, limit=2)[2], "_", limit=2)
                push!(indices, parse(Int, index))
                push!(structure_names, name)
            end
            sortperm(indices), structure_names
        else
            collect(1:length(prediction_names)), prediction_names
        end
        for (structure_name, prediction_path) in zip(structure_names, prediction_paths)
            cif_path = joinpath(prediction_path, basename(prediction_path)*"_model_0.cif")
            push!(structures, read_boltz_cif(cif_path, structure_name))
        end
        return structures[perm]
    end
end

function PyBoltz.predict(input::PyBoltz.Schema.MolecularInput, ::Type{MolecularStructure}; options...)
    return PyBoltz.predict([input], MolecularStructure; options...) |> only
end

end
