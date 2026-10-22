# python/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          runtimeLibs = with pkgs; [ stdenv.cc.cc.lib zlib glib libffi openssl postgresql ];
        in {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.python310 pkgs.python311 (pkgs.python312.withPackages (ps: with ps; [ pip ]))
              pkgs.uv pkgs.poetry pkgs.pyright pkgs.ruff
            ];
            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"
              if [ -t 0 ]; then exec fish; fi
            '';
          };
        });
    };
}
