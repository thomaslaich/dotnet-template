default:
    @just --list

# Autoformat the project tree
fmt:
    treefmt
    
restore:
    dotnet tool restore && dotnet restore
    
build APP:
    nix build .#{{APP}}
    
run APP:
    (cd ./northwind.{{APP}} && nix run .#{{APP}})
