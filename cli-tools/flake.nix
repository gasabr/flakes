# go/flake.nix
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
            buildInputs = [ pkgs.git pkgs.jq pkgs.lazygit pkgs.ripgrep pkgs.k9s pkgs.kubectl pkgs.doctl ];
            shellHook = ''if [[ $- == *i* ]]; then exec fish; fi'';
          };
        });
    };
}
