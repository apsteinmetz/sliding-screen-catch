# Sliding Screen Catch — status

_Last updated 2026-11-03_

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
- [x] OpenSCAD cutaway images (`catch_cutaway_A.png`, `catch_cutaway_B.png`)
- [ ] Test print; tune `dt_clear` (fit) and `det_h` (click strength)
- [ ] Confirm catch plate thickness (3 mm guess)

## Printing

Print both parts together from `stl/catch_print_plate.stl` (70 × 42 mm footprint, 52.25 mm tall),
already laid out in print orientation:

- **Catch:** as installed, foot on the bed. The tongue and plate top (the fit surfaces) print on top.
  **Enable supports** — needed only under the 30 × 30 plate.
- **Mount:** frame face on the bed, groove facing up. No supports needed.

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
```
