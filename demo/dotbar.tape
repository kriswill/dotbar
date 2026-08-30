# Regenerate .github/dotbar.gif and .github/dotbar.mp4:
#   cp demo/dotbar-braille.ttf ~/Library/Fonts/
#   nix run nixpkgs#vhs -- demo/dotbar.tape
# The tape only drives the terminal; the content lives in demo/tour.sh, so the
# demo and the README stay in step with one edit, not two.
# The GIF is what the README shows: GitHub strips <video> and renders a bare
# .mp4 URL as a plain link, so an animated image is the only thing that plays
# on the page from a file kept in the repo. The mp4 stays for the smaller,
# seekable copy.
Output .github/dotbar.gif
Output .github/dotbar.mp4

# 12fps rather than the default 50. The bar steps ~20 times a second at its
# fastest, and a 57s GIF at 50fps is four times the bytes for no more detail.
Set Framerate 12

Require bash

Set Shell bash
# Braille first, text second. demo/dotbar-braille.ttf must be installed (copy
# it to ~/Library/Fonts) — see demo/mkfont.py for why an ordinary font will not
# do. Any mono font works as the second entry.
Set FontFamily "dotbar braille, JetBrainsMono Nerd Font Mono"
Set FontSize 20
Set Width 1100
Set Height 760
Set Padding 20
Set TypingSpeed 0ms

Hide
Type "cargo build -q && clear"
Enter
Sleep 20s
Show

Type "./demo/tour.sh"
Enter
Sleep 60s
