{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      helix = pkgs.callPackage ./modules/tui/helix { withNixd = false; };
    in
    {
      packages.${system} = {
        shell = pkgs.callPackage ./modules/tui/zsh.nix { };
        inherit helix;
        helix-complete = pkgs.callPackage ./modules/tui/helix { };
        test = pkgs.callPackage ./test.nix { };
      };

      devShells.${system}.default = pkgs.mkShell {
        name = "my-dev-shell";

        buildInputs = [
          helix
        ];
      };
    };
}
