module Boltz1

import PythonCall # for boltz predict command

using Scratch: @get_scratch!, delete_scratch!
const CACHE_KEY = "boltz_cache"
clear_cache() = delete_scratch!(CACHE_KEY)

include("Schema.jl")
using Compat; @compat public Schema

include("utils.jl")

include("predict.jl")
export predict

end
