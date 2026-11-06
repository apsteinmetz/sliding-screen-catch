# Sliding Screen Catch — 2-piece variant

_Last updated 2026-11-05_

Separate mounting plate (screwed to the frame) and catch that slides into it on a dovetail
and clicks in with a snap detent. The channel is open at both ends, so the catch slides in
from either side. The leg is a cantilever spring with the same design as the 1-piece variant,
so you can also release the screen by pushing the foot **forward (−Y) about 5 mm** without
removing the catch. Designed for **PLA**. All paths below are relative to this folder.

## Current design

| Part | Size |
|---|---|
| Overall height (foot bottom to frame face) | 57 mm (`total_h`) to the bottom of the foot block; 64.4 mm including the foot extension |
| Mounting plate | 30 × 30 × 8.25 mm, one countersunk #8 wood screw at the centre (2 mm of material between countersink and frame face) |
| Catch plate | 30 × 30 × 3 mm (thickness is a guess) |
| Dovetail tongue | 14 → 18 mm wide, 4 mm tall, full 30 mm plate width, 0.2 mm clearance per side |
| Snap detent | Two bumps on the tongue / two dimples in the mount, 11 mm either side of the screw; bumps 0.7 mm tall (0.5 mm interference after the 0.2 mm clearance) |
| Leg | 5 wide (X) × 40.75 mm long, flush with the front edge; **tapers from 3.0 mm thick at the root to 1.6 mm at the foot** (Y, flex direction) |
| Leg root | 3 mm fillet on the back face (the side that is stretched when you push the foot) |
| Foot | 5 wide × 13.6 long × 5 thick, sticks out 12 mm in front of the leg; 0.8 mm chamfer on the outside edges |
| Foot extension | Below the foot, 7.4 mm deep: back edge straight down, front a 45° bevel starting under the front-top chamfer, down to a 2 mm long bottom (`foot_ext_bot`) |

**Attachment:** the mount is screwed to the frame first (the screw head sits flush in the
groove ceiling), then the catch slides in sideways from either end. The leading bump clicks
once as it passes the near dimple (22 mm before home); push on until it clicks again with the
catch plate flush with the mount. There is no end wall, so only the detents hold the catch in
place along the slide.

### Flex in PLA

The leg follows the 1-piece design (taper + root fillet + chamfered foot) but is about 6 mm
shorter, because the dovetail joint takes up height. The 1-piece taper (3.5 → 2.0 mm) would
strain the shorter leg to 1.06 %, over the 1 % limit for repeated flexing in PLA, so it is
thinner here:

| Leg | Root strain at 5 mm | Push force |
|---|---|---|
| 5 × 5 straight (previous 2-piece leg) | ~2 % | — |
| 3.5 → 2.0 taper (1-piece leg, at this length) | 1.06 % | 8.8 N |
| **3.0 → 1.6 taper (current)** | **0.9 %** | **5.3 N** (about 0.5 kg) |

`catch_common.scad` computes the strain and force the same way as the 1-piece
(`mat_E` = 3300 MPa, a guess) and `catch_lower.scad` echoes them. Rendering **fails with an
assert** if the strain goes over `max_strain` (1 %). Change `leg_t` / `leg_t_tip` to tune it.

## Status

- [x] Catch geometry (leg, foot, plate)
- [x] Mounting plate with countersunk screw hole
- [x] Toolless dovetail + snap detent joint
- [x] Channel open at both ends: catch slides in from either side (2026-11-05)
- [x] Cantilever spring leg + chamfered foot from the 1-piece design; detent bumps 0.5 → 0.7 mm;
      mount 1 mm thinner, leg 1 mm longer (2026-11-05)
- [x] 1:1 cross-section PNG for test fitting (`catch_section.png`)
- [x] Render in OpenSCAD: both parts are clean single solids; STLs in `stl/`
- [x] Combined print-plate STL (`stl/catch_print_plate.stl`)
- [x] Multi-set print plate for batch printing (`stl/catch_print_plate_multi.stl`)
- [x] OpenSCAD cutaway images (`catch_cutaway_A.png`, `catch_cutaway_B.png`)
- [ ] Test print; tune `dt_clear` (fit) and `det_h` (click strength; without an end wall the
      detents are all that keep the catch from sliding out)
- [ ] Check push force and that 5 mm of foot travel clears the screen; tune `leg_t` / `leg_t_tip`
- [ ] Re-save `stl/*.3mf` (PrusaSlicer projects) from the new STLs; they still hold the old
      design
- [ ] Confirm catch plate thickness (3 mm guess)

## Printing

Print both parts together from `stl/catch_print_plate.stl` (100 × 42 mm footprint, 30 mm tall),
already laid out in print orientation:

- **Catch:** lying on its side, with the +X end of the plate and tongue on the bed. The L-shaped
  leg/foot profile and the dovetail flanks are in the layer plane, so the spring never bends
  across layer lines. **Enable supports.** The leg and foot are only 5 mm wide and sit in the middle of the
  30 mm plate, so they hang 12.5 mm above the bed. `stl/catch_lower.stl` is in the same orientation.
- **Mount:** frame face on the bed, groove facing up. No supports needed.

Slicer settings for the spring leg: **100 % infill or enough walls to make the leg solid**
(e.g. 5+ perimeters at 0.4 mm), and normal-to-warm nozzle temperature for good layer bonding.

**Batch printing:** `stl/catch_print_plate_multi.stl` packs as many catch + mount sets as fit
(15 sets on a 220 × 220 mm bed, 15 on 235 mm, 18 on 256 mm). Each mount sits beside its catch's leg,
and the rows interlock. Set `bed_x` / `bed_y` in `catch_print_plate_multi.scad` for your printer
and re-export. The set count is echoed in the OpenSCAD console.

If your slicer puts supports everywhere, split the STL into separate objects
("Split to objects") and enable supports for the catch only.

## Test-fit drawing

`catch_section.png` — print at 100 % (no "fit to page"), then check the 10 mm and 50 mm bars
with a ruler. Regenerate with `python3 make_section_png.py` after changing any dimension.

## OpenSCAD cutaways

- `catch_cutaway_A.png` — cut through the screw, front to back: leg, foot, dovetail, countersink.
- `catch_cutaway_B.png` — cut along the slide direction: open channel, screw, both detent bumps in their dimples.

Both are **actual size** at 300 dpi (110 × 116 mm page): print at 100 % with no fit-to-page and
check the 10 mm / 50 mm bars with a ruler. Regenerate with `./make_cutaways.sh`.

## STL export

```
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_lower.stl" "$PWD/catch_lower.scad"
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_mount.stl" "$PWD/catch_mount.scad"
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate.stl" "$PWD/catch_print_plate.scad"
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate_multi.stl" -D bed_x=220 -D bed_y=220 "$PWD/catch_print_plate_multi.scad"
```
