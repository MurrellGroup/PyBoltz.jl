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
- `verbose::Bool`: Whether to print boltz logs to stdout. Default: true.
- `write_full_pae::Bool`: Dump PAE to a npz file. Default: true.
- `write_full_pde::Bool`: Dump PDE to a npz file. Default: false.
- `override::Bool`: Override existing predictions. Default: false.
- `use_msa_server::Bool`: Use MMSeqs2 server for MSA generation. Default: false.
"""
function predict(input::AbstractString; verbose=true, options...)
    cmd = predict_cmd(input; options...)
    if verbose
        run(cmd)
    else
        read(cmd, String)
    end
    return nothing
end


function predict(schemas::AbstractVector{MolecularSchema}; options...)
    mktempdir() do dir
        schema_dir = joinpath(dir, "schemas")
        mkdir(schema_dir)
        msa_dir = joinpath(dir, "msas")
        mkdir(msa_dir)
        for (i, schema) in enumerate(schemas)
            path = joinpath(schema_dir, "schema$i.yaml")
            YAML.write_file(path, MSAs_to_files!(deepcopy(schema), msa_dir; prefix=i))
        end
        predict(schema_dir; options...)
    end
    return nothing
end

predict(schema::MolecularSchema; options...) = predict([schema]; options...)
