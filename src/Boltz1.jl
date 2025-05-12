module Boltz1

import PythonCall # for boltz predict command

using Scratch: @get_scratch!, delete_scratch!
const CACHE_KEY = "boltz_cache"
clear_cache() = delete_scratch!(CACHE_KEY)

using YAML

include("schema.jl")
export MolecularSchema, protein, dna, rna, ligand
export bond, pocket

include("utils.jl")

include("predict.jl")
export predict

end
