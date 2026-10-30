{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          unstable = nixpkgs-unstable.legacyPackages.${system};
          # Official HashiCorp release (same zip CI installs). nixpkgs' terraform is unfree, so it is
          # never in the binary cache and has to be built from source.
          terraformVersion = "1.15.2";
          terraformRelease = {
            aarch64-darwin = { platform = "darwin_arm64"; sha256 = "4204bc3450418a7ce423e58451b053e5daed625ad6c6a15de98bc09345269f99"; };
            x86_64-linux   = { platform = "linux_amd64";  sha256 = "c56ff2bc7e6ce9b3879a50392b03c2ea074b47688bf503ff966c87fb01b2aab8"; };
            aarch64-linux  = { platform = "linux_arm64";  sha256 = "cf27657e96bbdc6116f4c16a0c801d36ae6410d7210183a520ac6b2198fb723e"; };
          }.${system};
          terraform = pkgs.stdenvNoCC.mkDerivation {
            pname = "terraform";
            version = terraformVersion;
            src = pkgs.fetchurl {
              url = "https://releases.hashicorp.com/terraform/${terraformVersion}/terraform_${terraformVersion}_${terraformRelease.platform}.zip";
              inherit (terraformRelease) sha256;
            };
            nativeBuildInputs = [ pkgs.unzip ];
            sourceRoot = ".";
            installPhase = "install -Dm755 terraform $out/bin/terraform";
          };
        in {
          default = pkgs.mkShell {
            buildInputs = [ pkgs.git unstable.terragrunt terraform pkgs.opentofu pkgs.git-lfs (pkgs.google-cloud-sdk.withExtraComponents [ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin ]) pkgs.jq pkgs.lazygit pkgs.ripgrep pkgs.k9s pkgs.kubectl pkgs.doctl pkgs.cursor-cli pkgs.github-cli pkgs.clickhouse pkgs.pgcli pkgs.mdformat ];
            shellHook = ''
              if [[ $- == *i* ]]; then
                exec fish --init-command '
                  abbr -a gp "git pull"
                  abbr -a gpp "git push"
                  abbr -a gst "git status"
                  abbr -a gf "git fetch"
                  abbr -a lg "lazygit"
                  abbr -a dc "docker-compose"
                  abbr -a gco "git checkout"
                '
              fi
            '';
          };
        });
    };
}
