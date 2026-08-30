#!/usr/bin/env bash
# Guided tour of every dotbar capability, in one pane.
cd "$(dirname "$0")/.."
D=${DOTBAR:-./target/debug/dotbar}
say() { printf '\n\033[1;36m%s\033[0m\n' "$1"; sleep 1.2; }
run() { printf '\033[2m$ %s\033[0m\n' "$*"; eval "$@"; sleep 1.6; }

clear
printf '\033[1mdotbar — everything it does\033[0m\n'
sleep 1.5

say '1. Percent argument: 13 cells, 1% per dot, green→red ramp'
for p in 0 12 37 63 88 100; do printf '  '; $D $p; done
sleep 2

say '2. --dense: 3 cells, 5% per dot, for a tight statusline'
for p in 0 25 50 75 100; do printf '  '; $D --dense $p; done
sleep 2

say '3. NO_COLOR=1: every escape dropped, for literal-text consumers'
run 'NO_COLOR=1 '$D' 76'
run 'NO_COLOR=1 '$D' --dense 76'

say '4. Statusline mode: Claude Code JSON on stdin'
run "echo '{\"context_window\":{\"remaining_percentage\":24.3}}' | $D"
say '   ...and no such field means no output, exit 0 (segment vanishes)'
run "echo '{}' | $D; echo \"  exit=\$?\""

say '5. Git-style dispatch: unknown sub → dotbar-<sub>'
run "$D nope; echo \"  exit=\$?\""

say '6. demo — 0→100% over 5s'
$D demo
say '   demo-slow is the same at 1%/s. Skipping the 100s wait.'

say 'Fin. cargo test: 5 passing. clippy -D warnings: clean.'
