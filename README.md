# .NET example projects

## Develop

Install nix:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then run:

```bash
$ nix develop --impure
```

This will install a .NET SDK in version 8 and all other required dependencies in a completely isolated way (they will not interfere
with any system installations of .NET SDK or any other software).

For even better ergonomics, install [direnv](https://direnv.net/) using your favourite package manager. After that, just `cd` into the directory.
(Note that you might have to run `direnv allow` inside the directory once.)

When using `vscode` or `emacs`, use the corresponding direnv extension:
- [direnv for VSCode](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv).
- [direnv for Emacs](https://melpa.org/#/direnv)

## Build

To build the entire solution:

```bash
$ just build
```





