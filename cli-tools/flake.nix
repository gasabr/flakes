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
            buildInputs = [ pkgs.git pkgs.jq pkgs.lazygit pkgs.ripgrep pkgs.k9s pkgs.kubectl pkgs.doctl pkgs.cursor-cli pkgs.github-cli pkgs.clickhouse pkgs.pgcli pkgs.mdformat ];
            shellHook = ''
              if [[ $- == *i* ]]; then
                exec fish --init-command '
                  abbr -a gp "git pull"
                  abbr -a gst "git status"
                  abbr -a gf "git fetch"
                  abbr -a lg "lazygit"
                  abbr -a dc "docker-compose"
                '
              fi
            '';
          };
        });
    };
}
