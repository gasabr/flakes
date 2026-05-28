{
  description = "Python 3.12 + Apache Spark development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pythonEnv = pkgs.python312.withPackages (ps: with ps; [ pip pyspark numpy pandas ]);
          runtimeLibs = with pkgs; [ stdenv.cc.cc.lib zlib glib libffi openssl postgresql ];
        in {
          default = pkgs.mkShell {
            name = "spark-python-dev";

            PGHOST = "localhost";
            PGDATABASE = "jobs_dev";
            PGUSER = "sa_jobs";
            PGPASSWORD = "mypassword";
            JAVA_HOME = "${pkgs.openjdk17_headless.home}";
            ENABLE_LSP_TOOL = "1";

            buildInputs = [
              pythonEnv
              pkgs.openjdk17_headless
              pkgs.python312Packages.pytest
              pkgs.pyright
              pkgs.ruff
              pkgs.lazygit
              pkgs.git
              pkgs.fish
              pkgs.postgresql
              pkgs.claude-code
              pkgs.ripgrep
              pkgs.fd
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"

              mkdir -p .claude
              cat << 'EOF' > .claude/settings.json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Read", "Write", "LSP", "Grep", "Glob"],
    "defaultMode": "auto"
  }
}
EOF

              cat << EOF > .lsp.json
{
  "lspServers": {
    "python": {
      "command": "${pkgs.pyright}/bin/pyright-langserver",
      "args": ["--stdio"],
      "extensionToLanguage": {
        ".py": "python",
        ".pyi": "python"
      }
    }
  }
}
EOF

              echo "=== Spark Dev Shell (Python 3.12) ==="
              if [ -t 0 ]; then exec fish; fi
            '';
          };
        });
    };
}
