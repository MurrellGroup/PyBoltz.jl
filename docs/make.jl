using PyBoltz
using Documenter

DocMeta.setdocmeta!(PyBoltz, :DocTestSetup, :(using PyBoltz); recursive=true)

makedocs(;
    modules=[PyBoltz],
    authors="Anton Oresten and Aron Stålmarck",
    sitename="PyBoltz.jl",
    format=Documenter.HTML(;
        canonical="https://MurrellGroup.github.io/PyBoltz.jl",
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
    repo="github.com/MurrellGroup/PyBoltz.jl",
    devbranch="main",
)
