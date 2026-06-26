{  
  description = "Flake for Emacs",  
  inputs = {  
    flake-utils.url = "github:numtide/flake-utils"  
  },  
  outputs = {  
    x: {  
      defaultPackage = self.packages.x86_64-linux.emacs;  
    },  
    packages: {  
      x86_64-linux = {  
        emacs = {  
          type = "application";  
          src = ./.;  
        };  
      };  
    },  
  }  
}