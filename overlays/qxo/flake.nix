{
  description = "qxo — Python + TypeScript + CLI tools + Neovim dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nvim.url    = "path:/Users/Gleb.Abroskin/Projects/flakes/nvim";
    python.url  = "path:/Users/Gleb.Abroskin/Projects/flakes/python";
    ts.url      = "path:/Users/Gleb.Abroskin/Projects/flakes/ts";
    tools.url   = "path:/Users/Gleb.Abroskin/Projects/flakes/cli-tools";
  };

  outputs = { self, nixpkgs, nvim, python, ts, tools }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      # Each sub-shell ends its shellHook with `exec fish`; strip that so only the
      # cli-tools hook (which runs last) starts fish, with its abbreviations.
      noExec = shell: shell.overrideAttrs (old: {
        shellHook = builtins.replaceStrings
          [ "if [ -t 0 ]; then exec fish; fi" "if [[ $- == *i* ]]; then exec fish; fi" ]
          [ "" "" ]
          (old.shellHook or "");
      });
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            # mkShell runs inputsFrom hooks in reverse order: ts, python, then tools.
            inputsFrom = [
              tools.devShells.${system}.default
              (noExec python.devShells.${system}.default)
              (noExec ts.devShells.${system}.default)
            ];
            buildInputs = [ nvim.packages.${system}.default pkgs.jdk21 pkgs.glab ];
            JAVA_HOME = pkgs.jdk21.home;
          };
        });
    };
}
