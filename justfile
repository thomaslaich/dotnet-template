default:
    @just --list

# Autoformat the project tree
fmt:
    treefmt
    
restore:
    dotnet tool restore && dotnet restore
    
build:
    dotnet build
