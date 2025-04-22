{
  description = "This is my overlay for the alacritty themes!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake {
      inherit self;
      inherit nixpkgs;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      overlays = [
        (
          final: prev:
          let
            lib = nixpkgs.lib;
            themeDir = ./themes;
            tomls = builtins.attrNames (builtins.readDir themeDir);
            mkThemes =
              name:
              let
                raw = builtins.readFile "${themeDir}/${name}";
                data = builtins.fromTOML raw;
                base = lib.removeSuffix ".toml" name;
              in
              {
                inherit base;
                value = data.colors;
              };
            themes = lib.listToAttrs (map mkThemes tomls);
          in
          {
            myAlacrittyThemes = themes;
          }
        )
      ];
    };
}
