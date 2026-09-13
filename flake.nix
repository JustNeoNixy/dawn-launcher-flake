{
  description = "Dawn (Minecraft launcher/client) packaged from the upstream Linux tarball";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage ./pkgs/dawn-launcher.nix { };

        apps.update = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "dawn-launcher-update";
            runtimeInputs = [ pkgs.curl pkgs.jq pkgs.gnugrep pkgs.gnused pkgs.nix ];
            text = builtins.readFile ./scripts/update.sh;
          }}/bin/dawn-launcher-update";
        };
      }) // {
        overlays.default = final: prev: {
          dawn-launcher = final.callPackage ./pkgs/dawn-launcher.nix { };
        };
      };
}
