# Sliding Screen Catch — one-piece variant

_Last updated 2026-11-25. Derived from the 2-piece design in `../2-piece/`._

One printed part: the plate screws to the frame above, and the leg is a cantilever spring.
To release the screen, push the foot **forward (away from the plate, −Y) about 3 mm**.
Designed for **PLA**.

| Feature | Size |
|---|---|
| Overall height (foot bottom to frame face) | 51 mm (same as 2-piece) to the bottom of the foot block; 65.0 mm including the foot extension |
| Plate | 30 × 30 × 5.55 mm, one countersunk #8 wood screw at the centre (9.6 mm countersink, 2.55 mm deep), head flush in the underside |
| Leg | 7 wide (X) × 40.45 mm long, flush with the front edge; **tapers from 3.9 mm thick at the root to 2.2 mm at the foot** (Y, flex direction), plus 1 mm on the back for its full length (`leg_back_add`) and 3 mm on the front from 10 mm below the plate down to the foot (`leg_front_add`, `leg_front_drop`; horizontal step), same as the 2-piece (2026-11-25) |
| Leg back | 1 mm fillet (`edge_fillet_r`) on its two long side edges, down through the foot |
| Leg root | 3 mm fillet on the back face (the side that is stretched when you push the foot) |
| Foot | 7 wide × 20.2 long (+1 mm back thickening) × 5 thick, sticks out 18 mm in front of the leg (same as 2-piece); square top edges; 1 mm fillet (`edge_fillet_r`) on the side edges of the toe, bevel, bottom and back faces |
| Foot extension | Below the foot, 14.0 mm deep: back edge straight down, front a 45° bevel starting 0.8 mm (`foot_bevel`) below the foot top, down to a 2 mm long bottom (`foot_ext_bot`, same as 2-piece) |

### Flex in PLA

PLA is stiff and brittle: it yields at about 2–3 % strain, and anything that flexes often should
stay under about **1 %**. The leg is sized for that:

| Leg | Root strain | Push force |
|---|---|---|
| 5 × 5 straight (original 2-piece leg), 5 mm travel | ~1.7 % | — |
| 3.5 straight (first 1-piece draft), 5 mm travel | 1.2 % | 8.5 N |
| 2.8 → 1.4 taper, 5 wide, 38.45 mm long, 5 mm travel (previous) | 0.9 % | 4.9 N |
| 3.5 → 1.8 taper, 7 wide, 39.45 mm long, 3 mm travel (previous) | 0.63 % | 7.5 N |
| 3.9 → 2.2 taper, 7 wide, 39.45 mm long, 3 mm travel (previous) | 0.75 % | 11.1 N |
| **3.9 → 2.2 taper, 40.45 mm long, plus the front/back thickening (current)** | **not computed** | **not computed** |

Tapering the leg spreads the bending along its length instead of concentrating it at the root,
so the same travel needs less strain. The 3 mm root fillet removes the sharp inside
corner where a crack would start.

`catch1_common.scad` computes the root strain and push force by integrating over the tapered
leg (`mat_E` = 3300 MPa, a guess for PLA) and echoes them in the OpenSCAD console. Rendering
**fails with an assert** if the strain goes over `max_strain` (1 %). To make the leg stiffer
or softer, change `leg_t` / `leg_t_tip`. The analysis covers only the plain tapered leg (it echoes
0.7 % / 10.3 N): the front and back thickening make the real leg much stiffer, so the real strain and
push force were not checked. `catch_1piece_flexed.scad` draws only the plain leg bending.

PLA creeps under constant load. The leg is unloaded at rest, so that's fine, but don't leave
it pushed out, and keep it away from hot sun on a south-facing window (PLA softens around 55 °C).

Install: drive the screw up through the plate into the frame. The screw is at the plate centre
and the foot sticks out in front of the leg, so there is room for a screwdriver from below.

## Files

- `catch1_common.scad` — all dimensions (`// guess` marks values not taken from the 2-piece design).
- `catch_1piece.scad` — the part; renders in print orientation (`catch_1piece_print()`),
  `catch_1piece()` is in installed coordinates.
- `catch_1piece_flexed.scad` — preview only: rest position vs. leg pushed 3 mm (`release_flex`).
- `stl/catch_1piece.stl` — print file (already in print orientation).
- `render/` — preview images (generated, not in git; re-render from `catch_1piece_flexed.scad`).

## Printing

Print lying on its side (+X face on the bed), the same way as the 2-piece catch. The leg's
length and bending direction are then in the layer plane, so the spring never bends across
layer lines. That matters more here than in the 2-piece because the leg is meant to flex.
**Enable supports** under the leg and foot; they sit 11.5 mm above the bed.

Slicer settings for the spring: **100 % infill or enough walls to make the leg solid**
(e.g. 5+ perimeters at 0.4 mm), and normal-to-warm nozzle temperature for good layer bonding.

## To do

- [ ] Test print; check push force and that 3 mm travel actually clears the screen
- [ ] Tune `leg_t` / `leg_t_tip` (3.9 → 2.2 mm guess) for stiffness
- [ ] Consider a stop that keeps the leg from being pushed too far (not modelled)

## Export

```
flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_1piece.stl" "$PWD/catch_1piece.scad"
```
