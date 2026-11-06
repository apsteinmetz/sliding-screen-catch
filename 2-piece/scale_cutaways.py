#!/usr/bin/env python3
"""Turn the raw OpenSCAD cutaway renders into true-scale 300 dpi PNGs.

Called by make_cutaways.sh. Reads render/raw_A.png and render/raw_B.png (straight-on,
orthographic, cut face toward the camera), finds the part outline, and works out
pixels-per-mm from the known model extents in catch_common.scad. Checks that the
horizontal and vertical scales agree (i.e. no tilt/distortion), then resamples to
300 dpi and adds a title, scale bars and DPI metadata.

Print at 100% (no "fit to page") and check the 10 mm / 50 mm bars with a ruler.
"""
import math, re, pathlib, sys
from PIL import Image, ImageDraw, ImageFont

HERE = pathlib.Path(__file__).resolve().parent
DPI = 300
PX_MM = DPI / 25.4

env = {"tan": lambda d: math.tan(math.radians(d))}
for line in (HERE / "catch_common.scad").read_text().splitlines():
    m = re.match(r"\s*([A-Za-z_]\w*)\s*=\s*([^;]+);", line)
    if m:
        try:
            env[m.group(1)] = eval(m.group(2), {"__builtins__": {}}, env)
        except (NameError, SyntaxError, TypeError):
            pass  # OpenSCAD-only expressions (flex analysis functions)
P = type("P", (), env)

mount_top = P.plate_top_z + P.mount_t
VIEWS = {
    # name: (title, extent across mm, extent down mm, note)
    "A": ("Cutaway A-A: cut at X = 0 (through screw, leg and foot)",
          P.plate_d / 2 - P.foot_y0, mount_top - P.foot_ext_z,
          "front (-Y) on the left"),
    "B": ("Cutaway B-B: cut at Y = 0 (along the slide direction)",
          P.plate_w, mount_top - P.foot_ext_z,
          "catch slides in from either side"),
}


def bbox_of_part(img, tol=12):
    bg = img.getpixel((0, 0))

    w, h = img.size
    px = img.load()
    diff = Image.new("L", (w, h))
    dp = diff.load()
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            if max(abs(p[i] - bg[i]) for i in range(3)) > tol:
                dp[x, y] = 255
    return diff.getbbox(), diff


def main():
    f = ImageFont.load_default(size=34)
    fs = ImageFont.load_default(size=26)
    for name, (title, w_mm, h_mm, note) in VIEWS.items():
        raw = Image.open(HERE / "render" / f"raw_{name}.png").convert("RGB")
        (x0, y0, x1, y1), mask = bbox_of_part(raw)
        raw = Image.composite(raw, Image.new("RGB", raw.size, "white"), mask)  # white background
        sx, sy = (x1 - x0) / w_mm, (y1 - y0) / h_mm
        if abs(sx - sy) / sx > 0.01:
            sys.exit(f"{name}: scale mismatch {sx:.2f} vs {sy:.2f} px/mm - view is tilted or clipped")
        part = raw.crop((x0, y0, x1, y1))
        part = part.resize((round(w_mm * PX_MM), round(h_mm * PX_MM)), Image.LANCZOS)

        mx, top, bottom = 20 * PX_MM, 22 * PX_MM, 30 * PX_MM
        W = int(max(part.width + 2 * mx, 110 * PX_MM))
        H = int(part.height + top + bottom)
        page = Image.new("RGB", (W, H), "white")
        px0 = int((W - part.width) / 2)
        page.paste(part, (px0, int(top)))
        d = ImageDraw.Draw(page)
        d.text((W / 2, 8 * PX_MM), title, fill="black", font=f, anchor="mm")
        d.text((W / 2, 14 * PX_MM), f"ACTUAL SIZE - {note}", fill=(90, 90, 90), font=fs, anchor="mm")

        # 50 mm height dimension beside the part
        xd = px0 + part.width + 6 * PX_MM
        yt, yb = top, top + part.height
        d.line([(xd, yt), (xd, yb)], fill="black", width=2)
        for y in (yt, yb):
            d.line([(xd - 12, y), (xd + 12, y)], fill="black", width=2)
        d.text((xd + 10, (yt + yb) / 2), f"{h_mm:g}", fill="black", font=fs, anchor="lm")

        # scale bars
        y = H - 12 * PX_MM
        x = 10 * PX_MM
        d.line([(x, y), (x + 10 * PX_MM, y)], fill="black", width=4)
        d.text((x + 5 * PX_MM, y - 24), "10 mm", fill="black", font=fs, anchor="mm")
        x = 30 * PX_MM
        d.line([(x, y), (x + 50 * PX_MM, y)], fill="black", width=4)
        for t in range(0, 51, 10):
            d.line([(x + t * PX_MM, y - 10), (x + t * PX_MM, y + 10)], fill="black", width=2)
        d.text((x + 25 * PX_MM, y - 24), "50 mm", fill="black", font=fs, anchor="mm")
        d.text((W / 2, H - 4 * PX_MM), "Print at 100% / 300 dpi (no fit-to-page). Check bars with a ruler.",
               fill=(90, 90, 90), font=fs, anchor="mm")

        out = HERE / f"catch_cutaway_{name}.png"
        page.save(out, dpi=(DPI, DPI))
        print(f"{out.name}: {page.width / PX_MM:.1f} x {page.height / PX_MM:.1f} mm page, "
              f"raw scale {sx:.2f}/{sy:.2f} px/mm")


if __name__ == "__main__":
    main()
