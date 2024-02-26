
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
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-cask-fonts, home-manager, nixpkgs, disko, ... } @inputs:
    let
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
      }
  };
