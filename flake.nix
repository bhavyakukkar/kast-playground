{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import rust-overlay) ];
        config = { allowUnfree = true; };
      };
      rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
        targets = [ "wasm32-unknown-unknown" ];
      };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            rust-toolchain
            rust-analyzer
            just
            # trunk downloads binaries that dont work on nixos
            (writeShellScriptBin "trunk" ''
              ${lib.getExe pkgs.steam-run} ${lib.getExe pkgs.trunk} "$@"
            '')
          ];
        };
      };
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
