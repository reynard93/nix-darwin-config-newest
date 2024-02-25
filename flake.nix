
{
  description = "Starter Configuration for NixOS and MacOS";

  inputs = {
    nixpkgs.url = "github:dustinlyons/nixpkgs/master"; 
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-cask-fonts = {
      url = "github:homebrew/homebrew-cask-fonts";
      flake = false;
    };
  };
  outputs = { self, darwin, rust-overlay, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-cask-fonts, home-manager, nixpkgs, disko, ... } @inputs:
    let
      user = "reylee";
      pkgs = import nixpkgs {
         overlays = [rust-overlay.overlays.default];
      };
      toolchain = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllLinuxSystems = f: nixpkgs.lib.genAttrs linuxSystems (system: f system);
      forAllDarwinSystems = f: nixpkgs.lib.genAttrs darwinSystems (system: f system);
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) (system: f system);
      devShell = system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = with pkgs; mkShell {
          packages = [
            toolchain
            # we want the unwrapped ver, "rust-analyzer" (wrapped) comes with nixpkgs' toolchain
            pkgs.rust-analyzer-unwrapped
          ];
          nativeBuildInputs = with pkgs; [ bashInteractive git age age-plugin-yubikey rustup ];
          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
          shellHook = with pkgs; ''
            export EDITOR=vim
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
          '';
        };
      };
    in
    {
      devShells = forAllSystems devShell;
      darwinConfigurations = let user = "reylee"; in {
        macos = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs;
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              nix-homebrew = {
                enable = true;
                user = "${user}";
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "homebrew/homebrew-cask-fonts" = homebrew-cask-fonts;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./darwin
          ];
        };
      };
  };
}
