# dotbar

A braille-dot progress bar for statuslines and terminals.

https://github.com/tlehman/dotbar/raw/main/.github/dotbar.mp4

<!-- GitHub renders a bare video URL on its own line as a player. On a renderer
     that does not, open .github/dotbar.mp4 directly. Regenerate with
     `nix run nixpkgs#vhs -- demo/dotbar.tape`; the content is demo/tour.sh,
     which is also runnable on its own. -->

```
dotbar 76            ⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣀⣀⣀ 76%   (13 cells, 1% per dot)
dotbar --dense 76    ⣿⡿⣀ 76%                (3 cells, 5% per dot)
dotbar demo          animate 0 -> 100% over 5s
dotbar demo-slow     animate 0 -> 100% at 1%/s
```

With no percent argument it reads Claude Code statusline JSON on stdin and
renders `100 - .context_window.remaining_percentage`. No such field means no
output and exit 0, so a statusline segment with no data vanishes rather than
printing an error.

Cells ramp green to red left to right. `NO_COLOR=1` drops every escape
sequence, for consumers that render the output as literal text.

Any other first argument is dispatched git-style to `dotbar-<subcommand>`,
preferring a sibling of the `dotbar` binary over `$PATH`.

## Develop

`devenv shell` (trust once with `devenv allow`), then `devenv test` for the
full contract: toolchain present, `cargo clippy -D warnings`, `cargo test`.

Panic-capable constructs are denied in production code (`Cargo.toml`
`[lints.clippy]`) and allowed in tests (`clippy.toml`).

## License

MIT OR Apache-2.0.
