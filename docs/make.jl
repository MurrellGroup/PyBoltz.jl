using Boltz1
using Documenter

DocMeta.setdocmeta!(Boltz1, :DocTestSetup, :(using Boltz1); recursive=true)

makedocs(;
    modules=[Boltz1],
    authors="Anton Oresten and Aron Stålmarck",
    sitename="Boltz1.jl",
    format=Documenter.HTML(;
        canonical="https://MurrellGroup.github.io/Boltz1.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
    doctest=false,
)

deploydocs(;
    repo="github.com/MurrellGroup/Boltz1.jl",
    devbranch="main",
)
