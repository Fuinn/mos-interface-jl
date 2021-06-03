push!(LOAD_PATH,"../src/")

using Documenter, MOSInterface

makedocs(
    sitename="MOS Interface", 
    modules = [MOSInterface],   
    pages=[
        "Getting Started" => "index.md",
        "API Reference" => [
            "interface.md",
            "model.md"
        ],
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    )
)

deploydocs(
    repo = "github.com/Fuinn/mos-interface-jl.git",
)


