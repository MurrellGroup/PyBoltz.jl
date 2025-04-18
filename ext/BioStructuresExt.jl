module BioStructuresExt

using Boltz1
using BioStructures

function read_boltz_cif(path::AbstractString)
    mmcifdict = MMCIFDict(path)
    mmcifdict["_atom_site.auth_atom_id"] = mmcifdict["_atom_site.label_atom_id"]
    mmcifdict["_atom_site.pdbx_formal_charge"] = repeat(["?"], length(mmcifdict["_atom_site.auth_atom_id"]))
    return MolecularStructure(mmcifdict)
end

function Boltz1.predict(::Type{MolecularStructure}, input::AbstractString; options...)
    mktempdir() do out_dir
        Boltz1.predict(input; out_dir, options...)
        name = splitext(basename(input))[1]
        path = joinpath(out_dir, "boltz_results_$name/predictions/$name/$(name)_model_0.cif")
        return read_boltz_cif(path)
    end
end

end
