module Boltz1

import PythonCall # for boltz predict command

export predict

using Scratch: @get_scratch!, delete_scratch!
const CACHE_KEY = "boltz_cache"

"""
    predict(input; options...)

Run `boltz predict` with the given input and options.

## Options

### Numeric Options
- `devices::Integer`: Number of devices to use. Default: 1.
- `recycling_steps::Integer`: Number of recycling steps. Default: 3.
- `sampling_steps::Integer`: Number of sampling steps. Default: 200.
- `diffusion_samples::Integer`: Number of diffusion samples. Default: 1.
- `step_scale::Float64`: Step size related to temperature. Default: 1.638.
- `num_workers::Integer`: Number of dataloader workers. Default: 2.
- `seed::Integer`: RNG seed; default: none.

### String Options
- `out_dir::String`: The path where to save the predictions.
- `cache::String`: The directory where to download the data and model.
Defaults to a Scratch.jl-backed directory created at module init; call `clear_cache()` to reset it.
- `checkpoint::String`: Optional checkpoint path; defaults to Boltz-1 model.
- `accelerator::String`: 'gpu', 'cpu', or 'tpu'. Default: 'gpu'.
- `output_format::String`: 'pdb' or 'mmcif'. Default: 'mmcif'.
- `msa_server_url::String`: MSA server URL; requires `use_msa_server=true`.
- `msa_pairing_strategy::String`: 'greedy' or 'complete'; requires `use_msa_server=true`.

### Boolean Flags
- `write_full_pae::Bool`: Dump PAE to a npz file. Default: true.
- `write_full_pde::Bool`: Dump PDE to a npz file. Default: false.
- `override::Bool`: Override existing predictions. Default: false.
- `use_msa_server::Bool`: Use MMSeqs2 server for MSA generation. Default: false.
"""
predict(input::AbstractString; options...) = run(predict_cmd(input; options...))

function predict_cmd(input::AbstractString; options...)
    options = merge((; cache=@get_scratch!(CACHE_KEY)), options)
    cmd_vec = String["boltz", "predict", input]
    for (key, val) in pairs(options)
        if val === true
            push!(cmd_vec, "--$key")
        elseif val === false
            nothing
        else
            push!(cmd_vec, "--$key", string(val))
        end
    end
    return Cmd(cmd_vec)
end

end
