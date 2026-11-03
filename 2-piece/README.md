# Sliding Screen Catch — 2-piece variant

_Last updated 2026-11-03_

Separate mounting plate (screwed to the frame) and catch that slides into it on a dovetail
and clicks in with a snap detent. All paths below are relative to this folder.

## Current design

| Part | Size |
|---|---|
| Overall height (foot bottom to frame face) | 57 mm |
| Mounting plate | 30 × 30 × 9.25 mm, one countersunk #8 wood screw at the centre |
| Catch plate | 30 × 30 × 3 mm (thickness is a guess) |
| Dovetail tongue | 14 → 18 mm wide, 4 mm tall, 0.2 mm clearance per side |
| Leg | 5 × 5 × 39.75 mm, flush with the front edge |
| Foot | 5 wide × 17 long × 5 thick, sticks out 12 mm in front of the leg |

**Attachment:** the mount is screwed to the frame first (the screw head sits flush in the
groove ceiling), then the catch slides in sideways until the detent clicks.

## Status

- [x] Catch geometry (leg, foot, plate)
- [x] Mounting plate with countersunk screw hole
- [x] Toolless dovetail + snap detent joint
- [x] 1:1 cross-section PNG for test fitting (`catch_section.png`)
- [x] Render in OpenSCAD: both parts are clean single solids; STLs in `stl/`
- [x] Combined print-plate STL (`stl/catch_print_plate.stl`)
- [x] Multi-set print plate for batch printing (`stl/catch_print_plate_multi.stl`)
- [x] OpenSCAD cutaway images (`catch_cutaway_A.png`, `catch_cutaway_B.png`)
- [ ] Test print; tune `dt_clear` (fit) and `det_h` (click strength)
- [ ] Confirm catch plate thickness (3 mm guess)

## Printing

Print both parts together from `stl/catch_print_plate.stl` (92 × 42 mm footprint, 30 mm tall),
already laid out in print orientation:

- **Catch:** lying on its side, with the open end of the tongue (+X) on the bed. The L-shaped
  leg/foot profile and the dovetail flanks are in the layer plane, so the layers don't run across
  the leg. **Enable supports.** The leg and foot are only 5 mm thick and sit in the middle of the
  30 mm plate, so they hang 12.5 mm above the bed. `stl/catch_lower.stl` is in the same orientation.
- **Mount:** frame face on the bed, groove facing up. No supports needed.

**Batch printing:** `stl/catch_print_plate_multi.stl` packs as many catch + mount sets as fit
(12 sets on a 220 × 220 mm bed, 20 on 235 or 256 mm). Each mount sits beside its catch's leg,
and the rows interlock. Set `bed_x` / `bed_y` in `catch_print_plate_multi.scad` for your printer
and re-export. The set count is echoed in the OpenSCAD console.

If your slicer puts supports everywhere, split the STL into separate objects
("Split to objects") and enable supports for the catch only.

## Test-fit drawing

`catch_section.png` — print at 100 % (no "fit to page"), then check the 10 mm and 50 mm bars
with a ruler. Regenerate with `python3 make_section_png.py` after changing any dimension.

## OpenSCAD cutaways

- `catch_cutaway_A.png` — cut through the screw, front to back: leg, foot, dovetail, countersink.
- `catch_cutaway_B.png` — cut along the slide direction: end wall, screw, detent bump in its dimple.

Both are **actual size** at 300 dpi (110 × 102 mm page): print at 100 % with no fit-to-page and
check the 10 mm / 50 mm bars with a ruler. Regenerate with `./make_cutaways.sh`.

## STL export

```
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_lower.stl" "$PWD/catch_lower.scad"
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_mount.stl" "$PWD/catch_mount.scad"
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate.stl" "$PWD/catch_print_plate.scad"
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate_multi.stl" -D bed_x=220 -D bed_y=220 "$PWD/catch_print_plate_multi.scad"
```
