{
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake-utils.url  = "github:numtide/flake-utils";
      rust-overlay.url = "github:oxalica/rust-overlay";
    };
  
    outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        {
          devShell = with pkgs; mkShell {
            buildInputs = [ 
              cargo
              rustc
              wasm-pack
              llvmPackages.bintools
              pkg-config 
              openssl 
              trunk
              (rust-bin.selectLatestNightlyWith( toolchain: toolchain.default.override {
              extensions= [ "rust-src" "rust-analyzer" ];
              targets = [ "wasm32-unknown-unknown" ];
            })) ] ++ pkgs.lib.optionals pkg.stdenv.isDarwin [
            darwin.apple_sdk.frameworks.SystemConfiguration
          ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
            CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "lld";
          };
        }
      );
  }
  