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

        local results
        if all(name -> startswith(name, PyBoltz.PYBOLTZ_INPUT_INDEX_PREFIX), prediction_names)
            # output vector needs to match input vector (with possible missing values)
            @assert input isa AbstractVector{PyBoltz.Schema.MolecularInput}
            results = Union{MolecularStructure,Missing}[fill(missing, length(input))...]
            for prediction_name in prediction_names
                index, name = split(split(prediction_name, PyBoltz.PYBOLTZ_INPUT_INDEX_PREFIX, limit=2)[2], "_", limit=2)
                idx = parse(Int, index)
                prediction_path = joinpath(joinpath(out_dir, only(readdir(out_dir)), "predictions"), prediction_name)
                cif_path = joinpath(prediction_path, basename(prediction_path)*"_model_0.cif")
                try
                    results[idx] = read_boltz_cif(cif_path, name)
                catch e
                    @warn e
                    results[idx] = missing
                end
            end
        else
            results = Union{MolecularStructure,Missing}[]
            for prediction_path in prediction_paths
                cif_path = joinpath(prediction_path, basename(prediction_path)*"_model_0.cif")
                try
                    push!(results, read_boltz_cif(cif_path, basename(prediction_path)))
                catch e
                    @warn e
                    push!(results, missing)
                end
            end
        end
        return results
    end
end

function PyBoltz.predict(input::PyBoltz.Schema.MolecularInput, ::Type{MolecularStructure}; options...)
    return PyBoltz.predict([input], MolecularStructure; options...) |> only
end

end
