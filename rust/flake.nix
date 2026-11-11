{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.rustc pkgs.cargo pkgs.rustfmt pkgs.clippy pkgs.rust-analyzer
              pkgs.pkg-config pkgs.cargo-watch pkgs.cargo-edit
            ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];
            # rust-analyzer needs std sources for completion/goto-definition into std.
            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };
        });
    };
}
