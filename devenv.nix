# The dev environment: stable rust toolchain plus coverage. Entered via
# devenv's cd hook (trust once with `devenv allow`).
{ pkgs, ... }:
{
  # nixpkgs' stable rust toolchain — rustc, cargo, clippy, rustfmt,
  # rust-analyzer.
  languages.rust.enable = true;

  # Coverage: `cargo llvm-cov`. nixpkgs' rustc ships no llvm-tools-preview
  # component, so point cargo-llvm-cov at nixpkgs' LLVM.
  packages = [
    pkgs.cargo-llvm-cov
    # `dotbar` on PATH inside the shell, resolved against the live checkout at
    # run time (via $DEVENV_ROOT, not git, so it works before `git init`)
    # rather than a store copy, so an edit is visible on the next invocation
    # with no rebuild of the environment.
    # ponytail: cargo decides each call whether a rebuild is needed, which
    # costs ~50ms on a warm target dir. Fine for a dev shell; install the
    # release binary if you want it in a statusline.
    (pkgs.writeShellScriptBin "dotbar" ''
      exec cargo run --quiet --manifest-path "$DEVENV_ROOT/Cargo.toml" -- "$@"
    '')
  ];

  env = {
    LLVM_COV = "${pkgs.llvm}/bin/llvm-cov";
    LLVM_PROFDATA = "${pkgs.llvm}/bin/llvm-profdata";
  };

  # The contract `devenv test` asserts — the environment must provide the
  # tools, not merely evaluate without crashing.
  enterTest = ''
    set -euo pipefail
    for tool in cargo rustc clippy-driver rustfmt rust-analyzer cargo-llvm-cov dotbar; do
      command -v "$tool" > /dev/null || {
        echo "devenv contract: $tool missing from PATH" >&2
        exit 1
      }
    done
    for var in LLVM_COV LLVM_PROFDATA; do
      [ -x "''${!var}" ] || {
        echo "devenv contract: \$$var does not point at an executable" >&2
        exit 1
      }
    done
    cargo clippy --all-targets -- -D warnings
    cargo test
    # The wrapper must actually render, not merely exist on PATH.
    [ "$(NO_COLOR=1 dotbar --dense 100)" = "⣿⣿⡇ 100%" ] || {
      echo "devenv contract: dotbar wrapper did not render" >&2
      exit 1
    }
  '';
}
