{
  description = "Development Environment for Blast";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nvim.url    = "path:/Users/gasabr/Projects/flakes/nvim";
    elixir.url  = "path:/Users/gasabr/Projects/flakes/elixir";
    ts.url      = "path:/Users/gasabr/Projects/flakes/ts";
    tools.url   = "path:/Users/gasabr/Projects/flakes/cli-tools";
  };

  outputs = { self, nixpkgs, nvim, elixir, tools, ts }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            inputsFrom = [ elixir.devShells.${system}.default tools.devShells.${system}.default ts.devShells.${system}.default ];
            buildInputs = [ nvim.packages.${system}.default ];
            inherit (elixir.devShells.${system}.default) WALLABY_CHROMEDRIVER_PATH WALLABY_CHROME_BINARY;
          };
        });

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pythonEnv = pkgs.python312.withPackages (ps: with ps; [ pip ]);
          appScript = pkgs.writeShellScriptBin "run-job" ''
            /priv/bin/server
          '';
        in {
          default = appScript;
          dockerImage = pkgs.dockerTools.buildLayeredImage {
            name = "registry.digitalocean.com/ten-sammas/py-jobs-";
            tag = "latest";
            contents = [ appScript ];
            config = {
              Cmd = [ "${appScript}/bin/run-job" ];
              Env = [
                "PYTHONUNBUFFERED=1"
                "JAVA_HOME=${pkgs.openjdk17_headless.home}"
              ];
            };
          };
        });

      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          elixirShell = elixir.devShells.${system}.default;
          beamPkgs = pkgs.beam.packagesWith pkgs.erlang_27;
        in {
          test = {
            type = "app";
            program = toString (pkgs.writeShellScript "blast-test" ''
              export WALLABY_CHROMEDRIVER_PATH="${elixirShell.WALLABY_CHROMEDRIVER_PATH}"
              export WALLABY_CHROME_BINARY="${elixirShell.WALLABY_CHROME_BINARY}"
              export PATH="${beamPkgs.elixir}/bin:${pkgs.chromedriver}/bin:${pkgs.google-chrome}/bin:$PATH"
              exec mix test "$@"
            '');
          };
        });
    };
}
