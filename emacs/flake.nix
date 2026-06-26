{
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = with nixpkgs; [ emacs ];
    # Add any additional configurations here
  };
}