{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          beamPkgs = pkgs.beam.packagesWith pkgs.erlang_27;
        in {
          default = pkgs.mkShell {
            buildInputs = [ beamPkgs.elixir beamPkgs.elixir-ls pkgs.chromedriver pkgs.google-chrome ];
            shellHook = ''
              export WALLABY_CHROMEDRIVER_PATH="${pkgs.chromedriver}/bin/chromedriver"
              export WALLABY_CHROME_BINARY="${pkgs.google-chrome}/bin/google-chrome-stable"
            '';
          };
        });
    };
}
