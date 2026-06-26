{\n  description = "A new flake for emacs configuration.\n  inputs.nixpkgs.url = "github:NixOS/nixpkgs";\n  outputs = { self, nixpkgs }: {\n    packages.default = nixpkgs.emacs;\n  };\n}
