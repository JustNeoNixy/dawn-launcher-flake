# dawn-launcher-flake

Nix flake for the Dawn Minecraft launcher.

Unofficial. Not affiliated with InPvP or Dawn.

## Install

Build and run it directly:

```bash
nix build .#default
./result/bin/dawn-launcher
```

Or add it to your system flake. Add this block under `inputs`:

```nix
dawn-launcher = {
  url = "github:JustNeoNixy/dawn-launcher-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then reference `inputs.dawn-launcher.packages.${system}.default` wherever you build your package set, for example:

```nix
packages = builtins.mapAttrs (system: pkgs: {
  dawn-launcher = inputs.dawn-launcher.packages.${system}.default;
  # ...your other packages
}) inputs.nixpkgs.legacyPackages;
```

Or, inside a NixOS module (your `nixosSystem` call needs `specialArgs = { inherit inputs; };` for `inputs` to be available in `configuration.nix`):

```nix
environment.systemPackages = [
  inputs.dawn-launcher.packages.${pkgs.system}.default
];
```

If you'd rather use the overlay so it shows up as `pkgs.dawn-launcher`, add this instead:

```nix
nixpkgs.overlays = [ dawn-launcher.overlays.default ];
```

and reference it as `pkgs.dawn-launcher`.
