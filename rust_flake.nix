{  
  description = "Rust development environment based on the Go flake"  
  inputs.azure = { url = "github:gausjoe/nix-flakes:main" }  
  outputs = {  
    devShell = {  
      x86_64-linux = {  
        packages = [  
          pkgs.rustup,  
          pkgs.rustc,  
          pkgs.cargo  
        ],  
        shellHook = ''  
          export RUSTUP_HOME=$HOME/.rustup  
          export CARGO_HOME=$HOME/.cargo  
          export PATH=$CARGO_HOME/bin:$PATH  
        ''  
      }  
    }  
  }  
}