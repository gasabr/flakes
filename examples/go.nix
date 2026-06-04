{
  description = "go development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nvim.url    = "path:/Users/gasabr/Projects/flakes/nvim";
    go.url   = "path:/Users/gasabr/Projects/flakes/go";
    tools.url   = "path:/Users/gasabr/Projects/flakes/cli-tools";
  };

  outputs = { self, nixpkgs, nvim, go, tools }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            inputsFrom = [ go.devShells.${system}.default tools.devShells.${system}.default ];
            buildInputs = [ nvim.packages.${system}.default ];
          };
        });
    };
}
