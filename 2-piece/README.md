# Sliding Screen Catch — 2-piece variant

_Last updated 2026-11-05_

Separate mounting plate (screwed to the frame) and catch that slides into it on a dovetail
and clicks in with a snap detent. The channel is open at both ends, so the catch slides in
from either side. The leg is a cantilever spring with the same design as the 1-piece variant,
so you can also release the screen by pushing the foot **forward (−Y) about 3 mm** without
removing the catch. Designed for **PLA**. All paths below are relative to this folder.

## Current design

| Part | Size |
|---|---|
| Overall height (foot bottom to frame face) | 50 mm (`total_h`) to the bottom of the foot block; 60.2 mm including the foot extension |
| Mounting plate | 25 × 30 × 8.45 mm (25 mm along X), one countersunk #8 wood screw at the centre (9.6 mm countersink, 2.55 mm deep; 1.5 mm of material between countersink and frame face) |
| Catch plate | 25 × 30 × 3 mm (thickness is a guess) |
| Dovetail tongue | 14 → 18 mm wide, 4.1 mm tall (`dt_h`, 4 → 4.1 with the clearance change), full 25 mm plate width, 0.3 mm clearance per side (`dt_clear`, 0.2 → 0.3 on 2026-11-08: 0.2 was too tight) |
| Snap detent | Two bumps on the tongue / two dimples in the mount, 7 mm either side of the screw; bumps 0.7 mm tall (0.4 mm interference after the 0.3 mm clearance) |
| Leg | 7 wide (X) × 33.55 mm long, flush with the front edge; **tapers from 2.8 mm thick at the root to 1.4 mm at the foot** (Y, flex direction) |
| Leg root | 3 mm fillet on the back face (the side that is stretched when you push the foot) |
| Foot | 7 wide × 16.4 long × 5 thick, sticks out 15 mm in front of the leg; 0.8 mm chamfer on the outside edges |
| Foot extension | Below the foot, 10.2 mm deep: back edge straight down, front a 45° bevel starting under the front-top chamfer, down to a 2 mm long bottom (`foot_ext_bot`) |

**Attachment:** the mount is screwed to the frame first (the screw head sits flush in the
groove ceiling), then the catch slides in sideways from either end. The leading bump clicks
once as it passes the near dimple (14 mm before home); push on until it clicks again with the
catch plate flush with the mount. There is no end wall, so only the detents hold the catch in
place along the slide.

### Flex in PLA

The leg follows the 1-piece design (taper + root fillet + chamfered foot) but is about 6 mm
shorter, because the dovetail joint takes up height. The 1-piece taper (3.5 → 2.0 mm) would
strain the shorter leg to 1.06 %, over the 1 % limit for repeated flexing in PLA, so it is
thinner here:

| Leg | Root strain | Push force |
|---|---|---|
| 5 × 5 straight (previous 2-piece leg), 5 mm travel | ~2 % | — |
| 3.5 → 2.0 taper (1-piece leg, 40.75 mm long), 5 mm travel | 1.06 % | 8.8 N |
| 2.2 → 1.1 taper, 5 wide, 32.75 mm long, 5 mm travel (previous) | 0.94 % | 3.8 N |
| **2.8 → 1.4 taper, 7 wide, 3 mm travel (current)** | **0.7 %** | **6.2 N** (about 0.6 kg) |

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
- [x] Multi-set print plate for batch printing (`stl/catch_print_plate_multi.stl`), plus a 10-set plate
- [x] OpenSCAD cutaway images (`catch_cutaway_A.png`, `catch_cutaway_B.png`)
- [ ] Test print; tune `dt_clear` (fit) and `det_h` (click strength; without an end wall the
      detents are all that keep the catch from sliding out)
- [ ] Check push force and that 3 mm of foot travel clears the screen; tune `leg_t` / `leg_t_tip`
- [x] PrusaSlicer projects `stl/*.3mf` rebuilt from the current STLs with leg/foot support
      enforcers (2026-11-06)
- [ ] Confirm catch plate thickness (3 mm guess)

## Printing

Print both parts together from `stl/catch_print_plate.stl` (about 62 × 45 mm footprint, 25 mm tall),
already laid out in print orientation. The mount sits under the catch's leg, between the foot
and the catch plate, so the leg's supports stand on the mount (same nesting as the batch plate
below):

- **Catch:** lying on its side, with the +X end of the plate and tongue on the bed. The L-shaped
  leg/foot profile and the dovetail flanks are in the layer plane, so the spring never bends
  across layer lines. **Enable supports.** The leg and foot are only 7 mm wide and sit in the middle of the
  25 mm plate, so they hang ~9 mm above the bed. `stl/catch_lower.stl` is in the same orientation.
- **Mount:** frame face on the bed, groove facing up. No supports needed.

Slicer settings for the spring leg: **100 % infill or enough walls to make the leg solid**
(e.g. 5+ perimeters at 0.4 mm), and normal-to-warm nozzle temperature for good layer bonding.

**Batch printing:** `stl/catch_print_plate_multi.stl` packs as many catch + mount sets as fit
(21 sets on the default 250 × 210 mm Original Prusa MK3S bed). Each mount sits directly under
its catch's leg, front edge flush with the leg's front face, so the leg's supports stand on the
mount's front rail (8.45 mm up) instead of reaching down to the bed. The rows interlock: each
foot sits beside the mount of the row below. Set `bed_x` / `bed_y` in `catch_print_plate_multi.scad` for your printer
and re-export. The set count is echoed in the OpenSCAD console.

**10-set plate:** `stl/catch_print_plate_10.stl` / `stl/catch_print_plate_10.3mf` hold exactly 10 sets
(2 × 5, 115.6 × 175 mm), laid out the same way. `catch_print_plate_10.scad` picks the smallest grid that
fits `n_sets` on the bed, so change `n_sets` for another count. The PrusaSlicer project uses the
multi plate's settings and enforcers (about 7 h 15 min and 78 g of PLA).

If your slicer puts supports everywhere, split the STL into separate objects
("Split to objects") and enable supports for the catch only. On the multi-set plate, supports
must be allowed to start on the model (not "support on build plate only"), or the legs above
the mounts get no support.

**PrusaSlicer projects:** `stl/catch_print_plate.3mf` and `stl/catch_print_plate_multi.3mf`
(Original Prusa MK3S, Generic PLA, 0.20 mm SPEED) are ready to slice. Each holds the plate as one
object, so the leg supports can stand on the mounts, plus a **support enforcer** volume: the plan
outline of each leg, root fillet and foot. Supports are set to *enforcers only*, *snug* style, not
build-plate-only, with the first-layer support expansion (`raft_first_layer_expansion`) at 0,
so support stays inside the leg and foot outline (checked in the sliced G-code: every support
line within 0.5 mm of it). The enforcer volume is exported from the same `.scad` files with
`-D enforcers=true`.

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
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate_multi.stl" "$PWD/catch_print_plate_multi.scad"
```
