
{
  description = "Starter Configuration for NixOS and MacOS";

  inputs = {
    nixpkgs.url = "github:dustinlyons/nixpkgs/master"; 
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    # optional: Declarative tap mgmt
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
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-cask-fonts, home-manager, nixpkgs,  ... } @inputs:
    let
      user = "reynardtw";
      system = "aarch64-darwin";
      in {
        darwinConfigurations = {
            macos = darwin.lib.darwinSystem {
                inherit system;
                specialArgs = inputs;
                modules = [
                    nix-homebrew.darwinModules.nix-homebrew
                    home-manager.darwinModules.home-manager
                    ./darwin
                ];
            };
        };
     };
  }
