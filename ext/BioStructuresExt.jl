module BioStructuresExt

using Boltz1
using BioStructures

basename_no_ext(input::AbstractString) = splitext(basename(input))[1]

function getnames(input::AbstractString)
    prediction_names = isdir(input) ? basename_no_ext.(readdir(input)) : [basename_no_ext(input)]
    return basename_no_ext(input), prediction_names
end

function read_boltz_cif(path::AbstractString)
    mmcifdict = MMCIFDict(path)
    mmcifdict["_atom_site.auth_atom_id"] = mmcifdict["_atom_site.label_atom_id"]
    mmcifdict["_atom_site.pdbx_formal_charge"] = repeat(["?"], length(mmcifdict["_atom_site.auth_atom_id"]))
    return MolecularStructure(mmcifdict)
end

function Boltz1.predict(::Type{MolecularStructure}, input::AbstractString; options...)
    structures = MolecularStructure[]
    mktempdir() do out_dir
        Boltz1.predict(input; out_dir, options...)
        run_name, prediction_names = getnames(input)
        for prediction_name in prediction_names
            path = joinpath(out_dir, "boltz_results_$run_name/predictions/$prediction_name/$(prediction_name)_model_0.cif")
            push!(structures, read_boltz_cif(path))
        end
    end
    return structures
end

end
