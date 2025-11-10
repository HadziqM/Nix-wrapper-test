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
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      helix = pkgs.callPackage ./modules/tui/helix { withNixd = false; };
    in
    {
      packages.${system} = {
        shell = pkgs.symlinkJoin {
          name = "shell";
          paths = with pkgs; [
            (callPackage ./modules/tui/starship { })
            (callPackage ./modules/tui/zsh.nix { })
            atuin
            zoxide
            direnv
            bat
            eza
            ripgrep
            fd
          ];
        };
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
