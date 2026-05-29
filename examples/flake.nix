{
  description = "jobs/develop — Python 3.12 + Spark + Neovim dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nvim.url    = "path:/Users/glebabroskin/Projects/flakes/nvim";
    spark.url   = "path:/Users/glebabroskin/Projects/flakes/spark";
  };

  outputs = { self, nixpkgs, nvim, spark }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            inputsFrom = [ spark.devShells.${system}.default ];
            buildInputs = [ nvim.packages.${system}.default ];
          };
        });

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pythonEnv = pkgs.python312.withPackages (ps: with ps; [ pip gunicorn pyspark numpy pandas ]);
          appScript = pkgs.writeShellScriptBin "run-job" ''
            exec ${pythonEnv}/bin/gunicorn app.main:app --bind 0.0.0.0:8080
          '';
        in {
          default = appScript;
          dockerImage = pkgs.dockerTools.buildLayeredImage {
            name = "registry.digitalocean.com/ten-sammas/py-jobs-";
            tag = "latest";
            contents = [ appScript pkgs.cacert pkgs.bash pkgs.openjdk17_headless ];
            config = {
              Cmd = [ "${appScript}/bin/run-job" ];
              Env = [
                "PYTHONUNBUFFERED=1"
                "JAVA_HOME=${pkgs.openjdk17_headless.home}"
              ];
            };
          };
        });
    };
}
