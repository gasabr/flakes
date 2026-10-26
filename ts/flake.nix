# ts/flake.nix
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
            buildInputs = [ pkgs.nodejs_24 pkgs.pnpm_10 pkgs.nodePackages.typescript-language-server pkgs.vscode-langservers-extracted ];
            shellHook = ''if [[ $- == *i* ]]; then exec fish; fi'';
          };
        });
    };
}
