# dawn-launcher-flake

Nix flake for the Dawn Minecraft launcher (Linux tarball build).

Unofficial. Not affiliated with InPvP or Dawn.

## Install

Build and run it directly:

```bash
nix build .#default
./result/bin/dawn-launcher
```

Or add it to your NixOS flake.

In your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dawn-launcher = {
      url = "github:JustNeoNixy/dawn-launcher-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dawn-launcher, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
```

Then in `configuration.nix`:

```nix
{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.dawn-launcher.packages.${pkgs.system}.default
  ];
}
```

If you'd rather use the overlay so it shows up as `pkgs.dawn-launcher`, add this to your system flake instead:

```nix
nixpkgs.overlays = [ dawn-launcher.overlays.default ];
```

and in `configuration.nix`:

```nix
environment.systemPackages = [ pkgs.dawn-launcher ];
```
