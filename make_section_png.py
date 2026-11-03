#!/usr/bin/env python3
"""Render 1:1 cross-sections of the assembled catch to a PNG for test fitting.

Reads all dimensions from catch_common.scad so it stays in sync with the model.
Output: catch_section.png at 300 dpi. Print at 100% (no "fit to page") and
check the 10 mm and 50 mm bars with a ruler before trusting the scale.

Sections:
  A-A  plane X=0  (through screw, leg, foot, dovetail profile)   1:1
  B-B  plane Y=0  (along the slide: end wall, screw, detent)      1:1
  C    one dovetail flank from A-A                                4:1
"""
import math, re, pathlib
from PIL import Image, ImageDraw, ImageFont

HERE = pathlib.Path(__file__).resolve().parent
DPI = 300
PX_MM = DPI / 25.4

# ---- read parameters from catch_common.scad ----
env = {"tan": lambda d: math.tan(math.radians(d)),
       "sin": lambda d: math.sin(math.radians(d)),
       "cos": lambda d: math.cos(math.radians(d))}
for line in (HERE / "catch_common.scad").read_text().splitlines():
    m = re.match(r"\s*([A-Za-z_]\w*)\s*=\s*([^;]+);", line)
    if m:
        env[m.group(1)] = eval(m.group(2), {"__builtins__": {}}, env)
P = type("P", (), env)

ceil_z = P.tongue_top_z + P.dt_clear
ch_wb = P.dt_w_bot + 2 * P.dt_clear
ch_wt = P.dt_w_top + 2 * P.dt_clear + 2 * P.dt_clear * (P.dt_w_top - P.dt_w_bot) / (2 * P.dt_h)
ch_top = P.plate_top_z + P.dt_h + P.dt_clear
mount_top = P.plate_top_z + P.mount_t

MOUNT = (120, 150, 190)
CATCH = (235, 150, 60)
BG = (255, 255, 255)
INK = (20, 20, 20)
DIM = (90, 90, 90)


def rect(a0, a1, z0, z1):
    return [(a0, z0), (a1, z0), (a1, z1), (a0, z1)]


def trap(wb, wt, z0, z1):
    return [(-wb / 2, z0), (wb / 2, z0), (wt / 2, z1), (-wt / 2, z1)]


def sections():
    """Return {name: [(colour, polygon_or_circle), ...]} in (horizontal, Z) mm."""
    csk = [(-P.screw_head_d / 2, ceil_z), (P.screw_head_d / 2, ceil_z),
           (P.screw_d / 2, ceil_z + P.csk_depth), (-P.screw_d / 2, ceil_z + P.csk_depth)]
    shank = rect(-P.screw_d / 2, P.screw_d / 2, ceil_z, mount_top + 0.5)

    # A-A: horizontal = Y (front, -Y, on the left)
    a = [
        (MOUNT, rect(-P.plate_d / 2, P.plate_d / 2, P.plate_top_z, mount_top)),
        (BG, trap(ch_wb, ch_wt, P.plate_top_z - 0.05, ch_top)),
        (BG, csk), (BG, shank),
        (CATCH, rect(-P.plate_d / 2, P.plate_d / 2, P.plate_top_z - P.plate_t, P.plate_top_z)),
        (CATCH, trap(P.dt_w_bot, P.dt_w_top, P.plate_top_z, P.tongue_top_z)),
        (CATCH, rect(P.leg_y0, P.leg_y0 + P.leg_d, P.foot_t, P.plate_top_z - P.plate_t)),
        (CATCH, rect(P.foot_y0, P.foot_y0 + P.foot_l, 0, P.foot_t)),
    ]
    # B-B: horizontal = X (open end of channel, +X, on the right)
    dim_cz = P.tongue_top_z + P.dt_clear - (P.det_r - P.det_h) + 0.1
    bump_cz = P.tongue_top_z - (P.det_r - P.det_h)
    b = [
        (MOUNT, rect(-P.plate_w / 2, P.plate_w / 2, P.plate_top_z, mount_top)),
        (BG, rect(-P.plate_w / 2 + P.end_wall, P.plate_w / 2 + 0.5, P.plate_top_z - 0.05, ch_top)),
        (BG, ("circle", P.det_x, dim_cz, P.det_r + 0.1)),
        (BG, csk), (BG, shank),
        (CATCH, rect(-P.plate_w / 2, P.plate_w / 2, P.plate_top_z - P.plate_t, P.plate_top_z)),
        (CATCH, rect(P.tongue_x0, P.plate_w / 2, P.plate_top_z, P.tongue_top_z)),
        (CATCH, ("circle", P.det_x, bump_cz, P.det_r, P.tongue_top_z)),
    ]
    return a, b


def draw_shapes(d, shapes, ox, oy, s):
    """ox, oy: pixel position of (0, 0) in section coords; s: px per mm."""
    tf = lambda h, z: (ox + h * s, oy - z * s)
    for col, shp in shapes:
        outline = None if col == BG else INK
        if isinstance(shp, tuple) and shp[0] == "circle":
            _, h, z, r, *clip = shp
            box = [tf(h - r, z + r), tf(h + r, z - r)]
            d.ellipse(box, fill=col, outline=outline, width=1)
            if clip:  # hide the part of the bump that is inside the tongue
                zc = clip[0]
                d.rectangle([tf(h - r - 0.1, zc), tf(h + r + 0.1, z - r - 0.1)], fill=col)
        else:
            d.polygon([tf(h, z) for h, z in shp], fill=col, outline=outline, width=2 if s > 20 else 1)


def vdim(d, x, y0, y1, text, font):
    d.line([(x, y0), (x, y1)], fill=DIM, width=2)
    for y in (y0, y1):
        d.line([(x - 10, y), (x + 10, y)], fill=DIM, width=2)
    d.text((x + 8, (y0 + y1) / 2), text, fill=DIM, font=font, anchor="lm")


def main():
    W, H = int(160 * PX_MM), int(100 * PX_MM)
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)
    f = ImageFont.load_default(size=30)
    fs = ImageFont.load_default(size=24)
    s = PX_MM
    base = H - 18 * s          # pixel row of Z=0
    a, b = sections()

    # A-A at 1:1
    oxa = 32 * s
    draw_shapes(d, a, oxa, base, s)
    d.text((oxa, base - (mount_top + 4) * s), "A-A  (X = 0)  1:1", fill=INK, font=f, anchor="mm")
    d.text((oxa - 14 * s, base + 4 * s), "front (-Y)", fill=DIM, font=fs, anchor="mm")
    vdim(d, oxa + 19 * s, base, base - mount_top * s, f"{P.total_h:g}", fs)
    vdim(d, oxa - 23 * s, base - P.plate_top_z * s, base - mount_top * s, f"{P.mount_t:.2f}", fs)
    d.text((oxa - 23 * s - 8, base - (P.plate_top_z + P.mount_t / 2) * s), "mount", fill=DIM, font=fs, anchor="rm")
    d.text((oxa - 18.5 * s, base - 20 * s), f"leg {P.leg_h:.2f}", fill=DIM, font=fs, anchor="rm")

    # B-B at 1:1
    oxb = 88 * s
    draw_shapes(d, b, oxb, base, s)
    d.text((oxb, base - (mount_top + 4) * s), "B-B  (Y = 0)  1:1", fill=INK, font=f, anchor="mm")
    d.text((oxb + 15 * s, base - (P.plate_top_z - 6) * s), "slides in from + X ->", fill=DIM, font=fs, anchor="rm")

    # C: joint detail, 4:1, one flank of the dovetail (front side, -Y)
    k = 4 * s
    hc = -(P.dt_w_bot + P.dt_w_top) / 4      # centre on the flank
    zc = P.plate_top_z + P.dt_h / 2
    half_w, half_h = 5 * k, 4.5 * k
    cx, cy = 135 * s, 50 * s                  # pixel centre of the detail box
    clip = Image.new("RGB", (W, H), BG)
    draw_shapes(ImageDraw.Draw(clip), a, cx - hc * k, cy + zc * k, k)
    region = (int(cx - half_w), int(cy - half_h), int(cx + half_w), int(cy + half_h))
    img.paste(clip.crop(region), region[:2])
    d.rectangle(region, outline=INK, width=2)
    d.text((cx, region[1] - 24), "C  dovetail flank (A-A)  4:1", fill=INK, font=f, anchor="mm")
    d.text((cx, region[3] + 26), f"clearance {P.dt_clear:g} mm per side", fill=DIM, font=fs, anchor="mm")
    d.text((cx, region[3] + 56), f"tongue {P.dt_w_bot:g} -> {P.dt_w_top:g} wide, {P.dt_h:g} tall",
           fill=DIM, font=fs, anchor="mm")
    # 1 mm reference tick at 4:1
    d.line([(region[0] + 20, region[3] - 20), (region[0] + 20 + k, region[3] - 20)], fill=INK, width=4)
    d.text((region[0] + 20 + k / 2, region[3] - 40), "1 mm", fill=INK, font=fs, anchor="mm")

    # scale check bars
    y = H - 7 * s
    x0 = 8 * s
    d.line([(x0, y), (x0 + 10 * s, y)], fill=INK, width=4)
    d.text((x0 + 5 * s, y - 22), "10 mm", fill=INK, font=fs, anchor="mm")
    x1 = 30 * s
    d.line([(x1, y), (x1 + 50 * s, y)], fill=INK, width=4)
    for xx in range(0, 51, 10):
        d.line([(x1 + xx * s, y - 8), (x1 + xx * s, y + 8)], fill=INK, width=2)
    d.text((x1 + 25 * s, y - 22), "50 mm", fill=INK, font=fs, anchor="mm")
    d.text((x1 + 56 * s, y), "Print at 100% scale (300 dpi). Check these bars with a ruler.",
           fill=INK, font=fs, anchor="lm")
    d.rectangle([(W - 60 * s, 4 * s), (W - 56 * s, 7 * s)], fill=MOUNT, outline=INK)
    d.text((W - 54 * s, 5.5 * s), "mount", fill=INK, font=fs, anchor="lm")
    d.rectangle([(W - 38 * s, 4 * s), (W - 34 * s, 7 * s)], fill=CATCH, outline=INK)
    d.text((W - 32 * s, 5.5 * s), "catch", fill=INK, font=fs, anchor="lm")

    out = HERE / "catch_section.png"
    img.save(out, dpi=(DPI, DPI))
    print(out, img.size)


if __name__ == "__main__":
    main()
