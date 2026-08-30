#!/usr/bin/env python3
"""Generate demo/dotbar-braille.ttf: U+2800-28FF only, drawn to fill the cell.

Ghostty draws braille with its own sprite renderer, so the dots sit on a
uniform pitch and neighbouring cells merge into one continuous bar. Every
ordinary font instead centres a small dot cluster inside a wide advance, which
leaves a gap at each cell boundary. VHS records through xterm.js, which has no
sprite path and uses the font -- so the recording only matches the terminal if
the font itself draws braille the way Ghostty does.

This is a braille-only font: the tape lists it first and a normal mono font
second, so text keeps the base font's outlines and only U+28xx comes from here.
No third-party outlines are copied, so nothing is redistributed.

Usage:  python3 demo/mkfont.py [out.ttf]
Needs:  pip install fonttools
"""
import sys

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

# Metrics copied from JetBrains Mono, the base font in the tape's fallback
# list. They must match, or the braille cells drift out of step with the text.
UPM, ADVANCE, ASCENT, DESCENT = 1000, 600, 1020, -300

# Fraction of each dot's pitch that is inked. Ghostty's dots nearly touch:
# below ~0.6 the bar reads as scattered dots, at 1.0 it is a solid block.
FILL = 0.62

COLS, ROWS = 2, 4
# Braille bit -> (column, row from top). Bits 0-2 and 6 are the left column
# top-to-bottom, bits 3-5 and 7 the right.
CELLS = {0: (0, 0), 1: (0, 1), 2: (0, 2), 6: (0, 3),
         3: (1, 0), 4: (1, 1), 5: (1, 2), 7: (1, 3)}


def dot(pen, col, row):
    """Ink one dot, centred on its slot in a uniform COLS x ROWS grid."""
    pitch_x, pitch_y = ADVANCE / COLS, (ASCENT - DESCENT) / ROWS
    cx = (col + 0.5) * pitch_x
    cy = ASCENT - (row + 0.5) * pitch_y
    hw, hh = pitch_x * FILL / 2, pitch_y * FILL / 2
    pen.moveTo((cx - hw, cy - hh))
    pen.lineTo((cx + hw, cy - hh))
    pen.lineTo((cx + hw, cy + hh))
    pen.lineTo((cx - hw, cy + hh))
    pen.closePath()


def main(out):
    names = [".notdef"] + [f"uni{0x2800 + i:04X}" for i in range(256)]
    glyphs, metrics = {}, {}
    for i, name in enumerate(names):
        pen = TTGlyphPen(None)
        if name != ".notdef":
            for bit, (col, row) in CELLS.items():
                if (i - 1) >> bit & 1:
                    dot(pen, col, row)
        glyphs[name] = pen.glyph()
        metrics[name] = (ADVANCE, 0)

    fb = FontBuilder(UPM, isTTF=True)
    fb.setupGlyphOrder(names)
    fb.setupCharacterMap({0x2800 + i: names[i + 1] for i in range(256)})
    fb.setupGlyf(glyphs)
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=ASCENT, descent=DESCENT)
    fb.setupNameTable({
        "familyName": "dotbar braille",
        "styleName": "Regular",
        "psName": "dotbarbraille-Regular",
        "version": "1.0",
        # Own work, no imported outlines.
        "licenseDescription": "Public domain / CC0.",
    })
    fb.setupOS2(sTypoAscender=ASCENT, sTypoDescender=DESCENT, achVendID="DOTB",
                usWinAscent=ASCENT, usWinDescent=-DESCENT)
    fb.setupPost(isFixedPitch=1)
    fb.save(out)
    print(f"wrote {out}: 256 braille glyphs, {ADVANCE}/{UPM} advance, fill {FILL}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "demo/dotbar-braille.ttf")
