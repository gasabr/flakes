{
  description = "python for hits development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nvim.url    = "path:/Users/glebabroskin/Projects/flakes/nvim";
    python.url   = "path:/Users/glebabroskin/Projects/flakes/spark";
    tools.url   = "path:/Users/glebabroskin/Projects/flakes/cli-tools";
  };

  outputs = { self, nixpkgs, nvim, python, tools }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            inputsFrom = [ python.devShells.${system}.default tools.devShells.${system}.default ];
            buildInputs = [ nvim.packages.${system}.default ];
          };
        });
    };
}
