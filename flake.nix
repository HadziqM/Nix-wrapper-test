{
  description = "simple Nix Wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  };

  outputs =
    {
      self,
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
        foot = pkgs.callPackage ./modules/gui/foot { };
        vesktop = pkgs.callPackage ./modules/gui/vesktop { };
        music = pkgs.callPackage ./modules/tui/music { };
      };

      devShells.${system}.default = pkgs.mkShell {
        name = "wrapper";

        buildInputs = [
          self.packages.${system}.music
        ];
      };
    };
}
