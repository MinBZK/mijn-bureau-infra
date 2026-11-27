#!/usr/bin/env python3
"""v4 header logos: original LaSuite app marks (colors and gradients intact)
with the Dutch bureaublad names typeset in Marianne Bold as vector outlines.

Differences with v3 (gen-logos3.py): nothing is flattened to Rijksblauw, the
multi-layer gradient logos (meet, drive, dictaphone) keep their original
artwork, and the name is real outlines instead of a <text> element that fell
back to Arial when the SVG is shown via <img>/CSS.

Alpha/BETA badges are removed: dictaphone loses the BETA strip via its crop,
drive loses the beta pill (rects + letter paths) explicitly.

Output is written straight into helmfile/apps/branding/files/<app>/ (same
v3-*.svg filenames, so no helmfile reference changes) plus
output/v4-contact-sheet.svg for review.

Run with the project venv: output/.venv/bin/python scripts/gen-logos4.py
Requires fonttools + brotli and output/Marianne-Bold.woff2 (from the
@gouvfr-lasuite/ui-kit npm package).
"""
import os
import re

from fontTools.misc.transform import Transform
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "output")
BRANDING = os.path.join(ROOT, "helmfile", "apps", "branding", "files")
FONT_PATH = os.path.join(OUT, "Marianne-Bold.woff2")

ICON_H = 40  # all icons normalized to 40px high
GAP = 9  # icon -> text gap, matches the original wordmarks (~7 on 31px height)
FONT_SIZE = 26  # cap height ~18px on a 40px tall logo, like the originals

DARK = "#15171f"  # default wordmark colour (cunningham grey text)

# folder: (svg basename, icon source, icon crop "x y w h", label, colour,
#          badge rules). Rules: ("paths-below", y) drops <path>s starting at
#          y or lower, ("paths-in-box", x, y) drops <path>s starting at or
#          right of x AND at/below y, ("rects-at", x, y) drops the <rect>s at
#          that position. Used to remove the BETA badges: drive has a pill
#          (rects at 8,27) with letter paths at x>=12 (the folder body below
#          them starts at x=9.68 and must be kept), dictaphone has a pill
#          (rects at 4,23) with letter paths at y>=25.9 (the record ring
#          starts at y=23.55 and must be kept).
APPS = {
    "docs": ("v3-documents", "orig-docs.svg", "0 0 32 33", "Notities", DARK, None),
    "drive": ("v3-bestanden", "wm-drive.svg", "0 0 40 40", "Bestanden", "#2845C1",
              [("rects-at", "8", "27"), ("paths-in-box", 11, 28.5)]),
    "messages": ("v3-email", "orig-messages.svg", "0 0 32 32", "E-mail", DARK, None),
    "conversations": ("v3-ai-assistent", "orig-conversations.svg", "0 0 32 32",
                      "AI Assistent", DARK, None),
    "calendars": ("v3-kalender", "orig-calendars.svg", "0 0 40 40", "Kalender", DARK, None),
    "dictaphone": ("v3-opnemen", "orig-dictaphone.svg", "0 0 32 32", "Opnemen", DARK,
                   [("rects-at", "4", "23"), ("paths-below", 24.5)]),
    "meet": ("v3-videobellen", "wm-meet.svg", "0 0 41 31", "Videobellen", "#000091", "meet-colour"),
    "projects": ("v3-projecten", "orig-projects.svg", "0 0 32 32", "Projecten", DARK, None),
    "element": ("v3-chat", "orig-element.svg", "0 0 200 200", "Chat", DARK, None),
}


# Meet ("visio") coloured icon: the official "La Suite Meet" wordmark ships
# the cube in flat dark grey; the product icon (src/frontend/public/icon.png,
# docker/dinum-frontend/logo.svg upstream) uses la-suite blue #000091 with a
# red #C9191E left face. Same geometry as the wordmark icon, recoloured.
MEET_ICON = """<path d="M4.12361 11.0152C4 11.6494 4 12.4305 4 13.7388V16.886C4 18.5092 4 19.3208 4.23607 20.0474C4.44495 20.6902 4.78662 21.282 5.23892 21.7844C5.7501 22.3521 6.45297 22.7579 7.85872 23.5695L10.5842 25.1431C11.8283 25.8614 12.5219 26.2618 13.1829 26.4545V16.7441C13.1829 16.2587 12.9178 15.812 12.4917 15.5796L4.12361 11.0152Z" fill="#C9191E"/>
<path d="M26.9113 12.4414V17.5045C26.9113 18.2046 27.2155 18.8701 27.7448 19.3282L31.3889 22.4817C31.6022 22.6622 31.8236 22.8098 32.0532 22.9246C32.291 23.0312 32.5207 23.0845 32.7421 23.0845C33.2177 23.0845 33.5991 22.9287 33.8861 22.6171C34.1813 22.2972 34.3289 21.8831 34.3289 21.3746V8.58126C34.3289 8.07281 34.1813 7.66276 33.8861 7.35113C33.5991 7.0313 33.2177 6.87138 32.7421 6.87138C32.5207 6.87138 32.291 6.92469 32.0532 7.0313C31.8236 7.13791 31.6022 7.28552 31.3889 7.47414L27.7477 10.6152C27.2166 11.0734 26.9113 11.74 26.9113 12.4414Z" fill="#000091"/>
<path d="M5.34145 9.20693C5.24012 9.15166 5.13386 9.11423 5.02627 9.09356C5.09416 9.0069 5.16509 8.92246 5.23897 8.8404C5.75015 8.27267 6.45303 7.86686 7.85877 7.05525L10.5843 5.48166C11.99 4.67005 12.6929 4.26424 13.4402 4.1054C14.1014 3.96487 14.7847 3.96487 15.4459 4.1054C16.1931 4.26424 16.896 4.67005 18.3017 5.48166L20.9951 7.03669C21.0059 7.04286 21.0166 7.04905 21.0273 7.05526C22.4331 7.86687 23.136 8.27268 23.6471 8.84041C24.0994 9.34274 24.4411 9.93452 24.65 10.5774C24.8861 11.304 24.8861 12.1156 24.8861 13.7388V16.886C24.8861 18.5092 24.8861 19.3208 24.65 20.0474C24.4411 20.6903 24.0994 21.282 23.6471 21.7844C23.136 22.3521 22.4331 22.7579 21.0274 23.5695C21.0154 23.5764 21.0032 23.5834 20.9912 23.5903L18.3017 25.1431C16.896 25.9547 16.1931 26.3605 15.4459 26.5194C15.4151 26.5259 15.3844 26.5321 15.3536 26.538L15.3536 16.7441C15.3536 15.4644 14.6546 14.2869 13.5311 13.6741L5.34145 9.20693Z" fill="#000091"/>"""


def read_source(name):
    s = open(os.path.join(OUT, name)).read()
    return re.search(r"<svg[^>]*>(.*)</svg>", s, re.S).group(1).strip()


def apply_badge_rules(inner, rules):
    for rule in rules or []:
        if rule[0] == "paths-below":
            x_min, y_min, is_box = 0.0, rule[1], False
        elif rule[0] == "paths-in-box":
            x_min, y_min, is_box = rule[1], rule[2], True
        elif rule[0] == "rects-at":
            _, x, y = rule
            inner = re.sub(
                r'<rect x="%s" y="%s"[^>]*/>' % (re.escape(x), re.escape(y)), "", inner
            )
            continue
        else:
            continue

        def keep(m, x_min=x_min, y_min=y_min):
            p = re.search(r'd="M\s*(-?[0-9.]+)[ ,]\s*(-?[0-9.]+)', m.group(0))
            if p and float(p.group(1)) >= x_min and float(p.group(2)) >= y_min:
                return ""
            return m.group(0)

        inner = re.sub(r"<path\b[^>]*/?>", keep, inner)
    return inner


FONT = TTFont(FONT_PATH)
CMAP = FONT.getBestCmap()
GLYPHS = FONT.getGlyphSet()
HMTX = FONT["hmtx"]
UPM = FONT["head"].unitsPerEm
CAP_H = FONT["OS/2"].sCapHeight * FONT_SIZE / UPM
BASELINE_Y = (ICON_H + CAP_H) / 2  # vertically center the capitals


def text_outlines(text):
    """Return (list of path d strings, advance width in px) for the label."""
    scale = FONT_SIZE / UPM
    parts = []
    pen_x = 0.0
    for ch in text:
        gname = CMAP.get(ord(ch))
        if gname is None:
            continue
        spen = SVGPathPen(GLYPHS)
        # font coords are y-up, svg is y-down: flip and place on the baseline
        tpen = TransformPen(spen, Transform(scale, 0, 0, -scale, pen_x, BASELINE_Y))
        GLYPHS[gname].draw(tpen)
        d = spen.getCommands()
        if d:
            parts.append(d)
        pen_x += HMTX[gname][0] * scale
    return parts, pen_x


def build(folder):
    basename, src, crop, label, color, badge = APPS[folder]
    if badge == "meet-colour":
        inner = MEET_ICON
    else:
        inner = apply_badge_rules(read_source(src), badge)
    cx, cy, cw, ch = [float(v) for v in crop.split()]
    scale = ICON_H / ch
    icon_w = cw * scale

    text_paths, text_w = text_outlines(label)
    text_x = icon_w + GAP
    width = icon_w + GAP + text_w
    text_group = "".join('<path d="%s"/>' % d for d in text_paths)

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width:.0f}" height="{ICON_H}" viewBox="0 0 {width:.1f} {ICON_H}">
  <svg viewBox="{cx:g} {cy:g} {cw:g} {ch:g}" width="{icon_w:.1f}" height="{ICON_H}">
{inner}
  </svg>
  <g fill="{color}" transform="translate({text_x:.1f} 0)">
{text_group}
  </g>
</svg>
"""
    out = os.path.join(BRANDING, folder, basename + ".svg")
    open(out, "w").write(svg)
    print(f"geschreven: {out} ({width:.0f}x{ICON_H})")
    return svg


def contact_sheet(svgs):
    pad, rh = 16, 64
    parts = []
    maxw = 0.0
    for i, svg in enumerate(svgs):
        inner = re.search(r"<svg[^>]*>(.*)</svg>", svg, re.S).group(1).strip()
        vb = [float(v) for v in re.search(r'viewBox="([^"]+)"', svg).group(1).split()]
        sc = rh / vb[3]
        maxw = max(maxw, vb[2] * sc)
        parts.append(
            f'<g transform="translate({pad} {pad + i * (rh + pad):.0f}) scale({sc:.3f})">{inner}</g>'
        )
    sheet = (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{int(maxw) + pad * 2}" '
        f'height="{len(svgs) * (rh + pad) + pad}" viewBox="0 0 {int(maxw) + pad * 2} '
        f'{len(svgs) * (rh + pad) + pad}" style="background:#f5f6f7">' + "".join(parts) + "</svg>"
    )
    path = os.path.join(OUT, "v4-contact-sheet.svg")
    open(path, "w").write(sheet)
    print("geschreven:", path)


def main():
    svgs = [build(folder) for folder in APPS]
    contact_sheet(svgs)


if __name__ == "__main__":
    main()
