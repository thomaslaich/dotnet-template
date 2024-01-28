default:
    @just --list

# Autoformat the project tree
format:
    nix fmt

restore:
    dotnet tool restore && dotnet restore

build APP:
    nix build .#{{APP}}

check:
    nix flake check --impure

run APP:
    (cd ./northwind.{{APP}} && nix run .#{{APP}})
