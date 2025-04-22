{
  description = "This is my overlay for the alacritty themes!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        mod,
        ...
      }:
      {
        imports = [ ];
        flakoe = {
          overlays = rec {
            alacritty-theme = final: prev: {
              alacritty-theme = self.packages.${prev.system};
            };
            default = alacritty-theme;
          };

        };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        perSystem =
          { lib, pkgs, ... }:
          let
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
            packages = themes;

          };
      }
    );

}
