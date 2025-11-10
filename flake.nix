{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        config = {
          allowUnfree = true;
        };
      };

    in
    {
      packages.${system} = {
        shell = pkgs.symlinkJoin {
          name = "shell";
          paths = with pkgs; [
            callPackage
            ./modules/tui/starship
            { }
            callPackage
            ./modules/tui/zsh.nix
            { }
            atuin
            zoxide
            direnv
            bat
            eza
            ripgrep
            fd
          ];
        };
      };
    };
}
