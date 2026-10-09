{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          beamPkgs = pkgs.beam.packagesWith pkgs.erlang_28;
        in {
          default = pkgs.mkShell {
            WALLABY_CHROMEDRIVER_PATH = "${pkgs.chromedriver}/bin/chromedriver";
            WALLABY_CHROME_BINARY = "${pkgs.google-chrome}/bin/google-chrome-stable";
            buildInputs = [ beamPkgs.elixir_1_20 beamPkgs.expert pkgs.chromedriver pkgs.google-chrome ];
          };
        });
    };
}
