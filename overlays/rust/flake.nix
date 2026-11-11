{
  description = "rust — Rust + CLI tools + Neovim dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nvim.url    = "path:/Users/gasabr/Projects/flakes/nvim";
    rust.url    = "path:/Users/gasabr/Projects/flakes/rust";
    tools.url   = "path:/Users/gasabr/Projects/flakes/cli-tools";
  };

  outputs = { self, nixpkgs, nvim, rust, tools }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            # mkShell runs inputsFrom hooks in reverse order, so tools (which execs fish) runs last.
            inputsFrom = [ tools.devShells.${system}.default rust.devShells.${system}.default ];
            buildInputs = [ nvim.packages.${system}.default ];
            inherit (rust.devShells.${system}.default) RUST_SRC_PATH;
          };
        });
    };
}
