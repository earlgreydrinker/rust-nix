{
  description = "Summary service configuration";

  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    extra-substituters = "https://devenv.cachix.org https://nix-community.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devenv.shells.default = {
          name = "rust-nix";

          # https://devenv.sh/reference/options/
          packages = with pkgs;[ locale sqlx-cli nixpkgs-fmt ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk; [
            frameworks.Security
          ]);

          env = {
            LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            LANG = "en_US.UTF-8";
          };

          enterShell = ''
          '';

          languages.nix.enable = true;

          languages.rust = {
            enable = true;
            # https://devenv.sh/reference/options/#languagesrustchannel
            channel = "nightly";
            components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
          };

          dotenv.enable = true;
          # dotenv.filename = ".env.production";
        };

      };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
