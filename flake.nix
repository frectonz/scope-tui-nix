{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        latestRust = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = latestRust;
          rustc = latestRust;
        };

        scope-tui = rustPlatform.buildRustPackage rec {
          pname = "scope-tui";
          version = "0.3.0";

          src = pkgs.fetchFromGitHub {
            owner = "alemidev";
            repo = "scope-tui";
            rev = "dev";
            hash = "sha256-ELcNSjie/AGrPFT06VXR5mNxiBPwYGVzeC8I9ybN8Bc=";
          };

          cargoPatches = [
            ./add-Cargo.lock.patch
          ];

          cargoHash = "sha256-wjkJqbWQZz/AN0nHAXqfhJIOsgmm6UJU87Rm+9F4/60=";

          nativeBuildInputs = with pkgs; [
            pulseaudio
            pkg-config
          ];
          buildInputs = with pkgs; [
            pulseaudio
          ];

          meta = with pkgs.lib; {
            description = "A simple oscilloscope/vectorscope/spectroscope for your terminal";
            homepage = "https://github.com/alemidev/scope-tui";
            license = with licenses; [ mit ];
            maintainers = with maintainers; [ ];
          };
        };
      in
      with pkgs;
      {
        packages.default = scope-tui;
        formatter = nixpkgs-fmt;
      }
    );
}
