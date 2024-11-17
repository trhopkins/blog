{
  description = "Nix Flake for deploying Terraform";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  flake-utils.lib.eachSystem [ "x86_64-linux" ]
  {
  }
}

