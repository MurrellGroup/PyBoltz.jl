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

function MSAs_to_files!(schema::MolecularSchema, dir::AbstractString; prefix="")
    for (i, type_dict) in enumerate(schema["sequences"])
        type, seq_dict = only(type_dict)
        type == "protein" || continue # only proteins have msas
        !haskey(seq_dict, "msa") && continue # nothing specified
        msa = seq_dict["msa"]
        msa isa AbstractString && continue # already a path
        msa isa AbstractVector{<:AbstractString} || throw(ArgumentError("msa must be a path or vector of strings"))
        msa_path = joinpath(dir, "schema$prefix-sequence$i.a3m")
        write_alignment(msa_path, msa)
        seq_dict["msa"] = msa_path
    end
    return schema
end


#=function to_schema(structure::MolecularStructure; alignments)
    if isnothing(alignments)
        alignments = Dict{String,Any}()
    end
    dict = Dict{String,Any}()
    dict["version"] = BOLTZ_SCHEMA_VERSION
    proteinchains = filter(chain -> countresidues(chain, proteinselector) > 0, collectchains(structure))
    dict["sequences"] = map(proteinchains) do chain
        sequence_dict = Dict{String,Any}(
            "id" => chain.id,
            "sequence" => String(chain.sequence),
        )
        if haskey(alignments, chain.id)
            sequence_dict["msa"] = alignments[chain.id]
        end
        return sequence_dict
    end
    return dict
end
function predict(structure, args...; alignments=nothing, options...)
    return predict(to_schema(structure; alignments), args...; options...)
end
=#