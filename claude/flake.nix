# claude/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
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
              pkgs.claude-code
              # LSPs matching nvim setup
              pkgs.pyright
              pkgs.ruff
              pkgs.typescript-language-server
              pkgs.elixir-ls
              pkgs.gopls
            ];
            shellHook = ''if [ -t 0 ]; then exec fish; fi'';
          };
        });
    };
}
