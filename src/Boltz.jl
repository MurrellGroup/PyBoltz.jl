module Boltz

import PythonCall # for boltz predict command

export predict, clear_cache

using Scratch: @get_scratch!, delete_scratch!
const CACHE_KEY = "boltz_cache"
clear_cache() = delete_scratch!(CACHE_KEY)

"""
    predict(input; kwargs...)

Run `boltz predict` with the given input and keyword options.

## Keyword Arguments

- `out_dir::String`: The path where to save the predictions.
- `cache::String`: The directory where to download the data and model.
Defaults to a Scratch.jl-backed directory created at module init; call `clear_cache()` to reset it.
- `checkpoint::String`: Optional checkpoint path; defaults to Boltz-1 model.
- `devices::Integer`: Number of devices to use. Default: 1.
- `accelerator::String`: 'gpu', 'cpu', or 'tpu'. Default: 'gpu'.
- `recycling_steps::Integer`: Number of recycling steps. Default: 3.
- `sampling_steps::Integer`: Number of sampling steps. Default: 200.
- `diffusion_samples::Integer`: Number of diffusion samples. Default: 1.
- `step_scale::Float64`: Step size related to temperature. Default: 1.638.
- `write_full_pae::Bool`: Dump PAE to a npz file. Default: true.
- `write_full_pde::Bool`: Dump PDE to a npz file. Default: false.
- `output_format::String`: 'pdb' or 'mmcif'. Default: 'mmcif'.
- `num_workers::Integer`: Number of dataloader workers. Default: 2.
- `override::Bool`: Override existing predictions. Default: false.
- `seed::Integer`: RNG seed; default: none.
- `use_msa_server::Bool`: Use MMSeqs2 server for MSA generation. Default: false.
- `msa_server_url::String`: MSA server URL; requires `use_msa_server=true`.
- `msa_pairing_strategy::String`: 'greedy' or 'complete'; requires `use_msa_server=true`.
"""
predict(input::AbstractString; kwargs...) = run(predict_cmd(input; kwargs...))

function predict_cmd(input::AbstractString; kwargs...)
    if !haskey(kwargs, :cache)
        kwargs = merge(kwargs, (cache=@get_scratch!(CACHE_KEY)))
    end
    cmd_vec = String["boltz", "predict", input]
    for (key, val) in kwargs
        if val === true
            push!(cmd_vec, "--$flag")
        elseif val === false
            # skip disabled flags
        else
            push!(cmd_vec, "--$flag", string(val))
        end
    end
    return Cmd(cmd_vec)
end

end
