using YAML


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


function write_alignment(path::AbstractString, alignment::Vector{<:AbstractString})
    open(path, "w") do io
        for (i, sequence) in enumerate(alignment)
            write(io, ">$i\n$sequence\n")
        end
    end
end

function MSAs_to_files!(input::Schema.BoltzInput, dir::AbstractString; prefix="")
    for (i, type_dict) in enumerate(input["sequences"])
        type, seq_dict = only(type_dict)
        type == "protein" || continue # only proteins have msas
        !haskey(seq_dict, "msa") && continue # nothing specified
        msa = seq_dict["msa"]
        msa isa AbstractString && continue # already a path
        msa isa AbstractVector{<:AbstractString} || throw(ArgumentError("msa must be a path or vector of strings"))
        msa_path = joinpath(dir, "input$prefix-sequence$i.a3m")
        write_alignment(msa_path, msa)
        seq_dict["msa"] = msa_path
    end
    return input
end
