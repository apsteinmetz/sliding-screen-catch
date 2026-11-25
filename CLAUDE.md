# Sliding Screen Catch

CAD project for a catch for a Sunscape brand sliding screen, modeled in OpenSCAD. The repo root is
`screen catch/` and holds two self-contained variants:

- `2-piece/` — a mounting plate screwed to the frame above, and a catch that slides into it toolless
  from either end. Its leg is the same tapered cantilever spring as the 1-piece.
- `1-piece/` — a single part screwed to the frame, with a tapered flexible leg; push the foot
  forward ~3 mm to release. Designed for PLA.

This work started in a Claude desktop Project. `README.md` is the overview; current status and
print/assembly notes are in each variant's `README.md`. Each variant has its own parameter file;
the variants share no code, so change both when a shared dimension changes.

## Files — `2-piece/`

- `catch_common.scad` — **all dimensions live here**, plus the `dovetail()` helper and the leg
  flex analysis (copied from `1-piece/catch1_common.scad`, same `assert` on `max_strain`).
  Included by every other `.scad` file and read by `make_section_png.py` / `scale_cutaways.py`
  (unused now; their parsers skip the OpenSCAD-only flex-analysis lines).
- `catch_lower.scad` — the catch: plate, full-width dovetail tongue with two detent bumps, tapered
  leg, root fillet, foot (leg/fillet/foot modules copied from `1-piece/catch_1piece.scad`, since changed:
  2026-11-25 the foot's top chamfer was removed and `legfoot_round()` fillets, by `edge_fillet_r` = 1 mm, the
  side edges of the leg's back face and of the foot's toe, bevel, bottom and back faces; leg front and foot
  top stay square). `catch_lower_parts(back_add) { extra parts }` builds the part; version B passes its
  thickening as children so it is filleted too. Same changes ported to the 1-piece (2-piece `catch_lower()` now
  builds the thickening directly; see the B note below).
- Version B (2026-11-23, `catch_lower_B.scad` / `catch_print_plate_B.scad`) became the only 2-piece catch on
  2026-11-25 (user's request): its thickening is merged into `catch_lower.scad` (`leg_front_extra()`,
  `leg_back_extra()`) with its values in `catch_common.scad`, and the B files were deleted. The user's last B
  edits (foot 18 mm, front thickening 3 mm) were carried over; the merged part matched their exported B STL.
- `catch_mount.scad` — mounting plate: dovetail channel open at both ends, countersunk screw hole,
  two detent dimples.
- `catch_assembly.scad` — both parts in installed position (`explode` param to separate).
- `catch_print_plate.scad` — both parts in print orientation → `stl/catch_print_plate.stl`. The mount
  is nested under the catch's leg (as on the multi plate), front edge flush with the thickened leg front
  (`leg_front_y`), so the leg's supports stand on it.
  Catch prints lying on its side (+X end on the bed, supports under leg and foot); mount prints
  frame face down. `catch_lower.scad` renders in this print orientation (`catch_lower_print()`);
  the assembly and section views use `catch_lower()` in installed coordinates.
  Do not print the catch tongue-down: the plate would overhang and the detent bump would be on the bed.
- `catch_print_plate_multi.scad` — as many catch + mount sets as fit on the bed
  (`bed_x`/`bed_y`, default 250 × 210 = the user's Original Prusa MK3S), grid turned 90° if that fits more
  → `stl/catch_print_plate_multi.stl`. Each mount sits directly under its catch's leg (front
  edge flush with the thickened leg's front face, `leg_front_y`; row pitch also uses it) so the leg's supports stand on the mount's front rail
  (user's request, 2026-11-06); rows interlock, each foot beside the mount of the row below.
- `catch_print_plate_10.scad` — exactly `n_sets` (10) sets, same set layout as the multi plate;
  picks the smallest-area grid that fits the bed (2 × 5), last row may be part-filled
  → `stl/catch_print_plate_10.stl` / `stl/catch_print_plate_10.3mf` (multi plate's PrusaSlicer
  settings + enforcer volume; user's request, 2026-11-08). Keep its set geometry in sync with the multi plate.
- **No PNG output (user's request, 2026-11-23):** the section and cutaway PNGs were deleted. Do not
  generate PNGs (no `make_section_png.py`, `make_cutaways.sh`, `scale_cutaways.py`, or OpenSCAD image
  exports) unless the user asks again. Those scripts and `catch_section_view.scad` remain in `2-piece/`
  but are unused.
- `stl/` — generated; `render/` and
  `stl/cut_*.stl` are intermediates, git-ignored. `stl/*.3mf` are PrusaSlicer projects (MK3S,
  Generic PLA, settings from the user's own project). Rebuilt 2026-11-06 by packing each plate STL
  plus its support-enforcer volume (`-D enforcers=true` on `catch_print_plate.scad` /
  `catch_print_plate_multi.scad`, module `catch_lower_support_enforcer()`) into one object;
  supports are enforcers only, snug, `raft_first_layer_expansion` = 0, so support never spreads
  past the leg and foot (user requirement). The user may also re-save them from PrusaSlicer. `catch_print_plate.3mf` (renamed from `catch_print_plate_B.3mf` 2026-11-25) is a user re-save
  with hand-painted supports (no enforcer volume): not regenerated by Claude, so it predates the 2026-11-25 fillets
  and the user's last B edits;
  `_multi` / `_10` were rebuilt then by swapping in the new plate and enforcer meshes (settings kept). `catch_print_plate.3mf` was rebuilt 2026-11-08 from the
  09f34db project's settings (snug, no raft, first-layer expansion 0) after a user re-save had switched to
  grid/organic support with a raft and 3 mm expansion, which spread support past the leg and foot.

## Files — top level

- `catch_print_plate_combined.scad` — the 2-piece set plus the 1-piece catch on one plate
  → `stl/catch_print_plate_combined.stl`. Both catches are turned 90° about Z (length along Y),
  side by side left of the mount, which sits `gap` to the right of the catch plates.
  Standing the catches upright (plate down) was tried and rejected (2026-11-05): it needs more
  support material than lying them on their side.

## Files — `1-piece/`

- `catch1_common.scad` — all dimensions, plus the flex analysis: tapered-cantilever push force,
  deflected shape (`leg_defl()`) and root strain, with an `assert` that fails the render if the
  strain exceeds `max_strain` (1 %, PLA).
- `catch_1piece.scad` — the part: plate with countersink from below, tapered leg with front/back thickening,
  root fillet, foot, 1 mm edge fillets (`legfoot_round()` etc. copied from `2-piece/catch_lower.scad`, 2026-11-25). Renders in print orientation (`catch_1piece_print()`, +X face on the bed);
  `catch_1piece()` is in installed coordinates. → `stl/catch_1piece.stl`.
- `catch_1piece_flexed.scad` — preview only: rest vs. leg pushed `release_flex` (3 mm); draws the plain leg
  bending, without the thickening.
- `render/` — preview images, git-ignored.

## Design decisions (settled with the user)

Shared by both variants:

- Overall height is **50 mm** (was 57; leg shortened 9 mm and foot lengthened 3 mm 2026-11-07, then several 1 mm leg tweaks through 2026-11-08), foot bottom to frame face (`total_h`). **51 mm** in both variants since 2026-11-25 (2-piece version B made primary,
  1-piece changed to match at the user's request).
- Tapered cantilever spring leg with root fillet; push the foot forward (-Y) ~3 mm to release
  (`release_flex`, 5 → 3 mm on 2026-11-07).
  **PLA**: keep root strain ≤ 1 %. The two variants' leg/foot code is duplicated, so change both.
- Leg flush with the plate front edge (-Y). Leg and foot 7 wide (`leg_w`, `foot_w`, 5 → 7 on 2026-11-07); foot 5 thick, projecting forward (away from
  the plate) 18 mm (`foot_proj`, 15 until 2026-11-25) in front of the leg; foot length = that + the leg tip thickness under it.
- Leg thickening, both variants (2026-11-25; from 2-piece version B): `leg_back_add` 1 mm on the back, full length of leg
  and foot; `leg_front_add` 3 mm on the front from `leg_front_drop` 10 mm below the plate to the foot (horizontal step).
  The flex analysis ignores it, so the real strain and force are unchecked.
- Foot top edges square (top chamfer removed 2026-11-25); `edge_fillet_r` 1 mm fillets on the side edges of the leg's
  back face and the foot's toe, bevel, bottom and back faces (`legfoot_round()`, duplicated in both variants).
- Foot extension below the foot block (z < 0), both variants (2026-11-06): back edge straight down;
  front keeps a `foot_bevel` (0.8 mm) vertical face (was the front-top chamfer until 2026-11-25), then one 45° bevel down and back until the bottom is
  `foot_ext_bot` = 2 mm long (`foot_ext_z` ≈ -13.8 2-piece, -14.0 1-piece). `total_h` (51) is still
  measured from z = 0, the bottom of the foot block; the leg and flex analysis are unchanged.
- One countersunk wood screw for now (#8 / ~4 mm flat head). A second screw was offered and declined.
  Countersink deepened 0.5 mm (2026-11-07): `screw_head_d` 8.6 → 9.6, `csk_depth` ≈ 2.55.

2-piece:

- Mount thickness is **derived** (`mount_t = dt_h + dt_clear + csk_depth + screw_meat`);
  the leg length absorbs the rest so the total stays at `total_h` (51 mm). Never hard-code `mount_t` or `leg_h`.
- Leg is a cantilever spring, same design as the 1-piece (decided 2026-11-05): 7 mm wide, 34.75 mm long (33.75 before 2026-11-25),
  tapers 3.4 → 2.0 mm (thickened 2026-11-07 when the release travel dropped to 3 mm, from 2.2 → 1.1;
  thickened again 2026-11-23: 2.8 → 1.4, then 3.2 → 1.8, then 3.4 → 2.0, each at the user's request to stiffen it), 3 mm root fillet, 1 mm fillets on the leg back and foot bottom side edges (2026-11-25; not in the flex analysis). Plus the former version-B thickening: `leg_back_add` 1 mm on the back, full length;
  `leg_front_add` 3 mm on the front from `leg_front_drop` 10 mm below the plate to the foot. The flex analysis ignores the
  thickening (echoes 0.9 % / 11.1 N for the plain taper); the real leg is stiffer and was not checked. Print material is PLA.
- Mount 1 mm thinner than originally (`screw_meat` 3 → 2, 2026-11-05); total height unchanged (then 50 mm).
  `screw_meat` 2 → 1.5 with the deeper countersink (2026-11-07) so `mount_t` stayed 8.25 (8.45 since `dt_clear` 0.3 and `dt_h` 4.1): the mount
  must clear the leg (plate_w/2 - leg_w/2 above the bed, now 9.0 mm; asserted in both print-plate files) on the nested print plates.
- Mount/catch plate `plate_w` shrunk 30 → 22 mm (X), then 24 mm for the 7 mm leg (print-plate `gap` 3 → 2.5), then 25 mm for `dt_clear` 0.3 (2026-11-08), and `det_x` 11 → 7 on 2026-11-07 so the mount still
  nests in the pocket under the shorter leg on the print plates (user's choice).
- Detent bumps `det_h` = 0.6 mm, 0.4 mm interference with `dt_clear` 0.2 (0.5 did not quite click into the dimples on the test print; was 0.7 until 2026-11-23).
- Dovetail joint (`dt_*`, `det_*`): change only when the user asks. `dt_clear` 0.2 → 0.3 (2026-11-08) because
  0.2 printed too tight; `dt_h` 4 → 4.1 to match (2026-11-08). Tightened to `dt_clear` 0.25, `dt_h` 4.05 on
  2026-11-23, then restored to `dt_clear` 0.2, `dt_h` 4.0 the same day at the user's request (`mount_t` 8.25,
  `leg_h` 33.75, `plate_w` left at 25); `det_h` 0.7 → 0.6 to cut the detent interference to 0.4 mm.
- Attachment: sliding dovetail + snap detent. The channel is open at both ends (no end wall) so the
  catch slides in from either side; detent bump/dimple pairs at ±`det_x` both click home together
  (decided 2026-11-05). The detents alone locate the catch along X.

1-piece:

- Screws directly to the frame above; plate thickness derived (`plate_t = csk_depth + screw_meat`).
- Leg flexes forward (-Y) ~3 mm to release. **Print material is PLA**: keep root strain ≤ 1 %.
  Leg tapers 3.9 → 2.2 mm thick (Y), 7 mm wide, with a 3 mm fillet at the root (back face);
  plain-taper analysis now 0.7 % strain, 10.3 N at 3 mm (leg 40.45 mm since 2026-11-25; was 0.75 % / 11.1 N at 39.45 mm;
  thickened 0.4 mm at root and tip 2026-11-23 from 3.5 → 1.8, was 0.63 % / 7.5 N; plate 5.55 mm), plus the thickening above.

## Conventions

- Units are millimetres. Origin at the plate centre, Z up, frame above (+Z), front is -Y,
  (2-piece) catch slides in along X from either end.
- Keep dimensions as named parameters in each variant's common file; mark anything not taken
  from the sketch or confirmed by the user with `// guess`.
- One module per feature, joined in a top-level module per part.

## Repository

- Public repo: https://github.com/apsteinmetz/sliding-screen-catch (branch `main`).
- Commits must use the GitHub noreply email (set in this repo's local git config);
  the user does not want their personal email in the public history.

## Tooling

- On the Windows machine, OpenSCAD 2021.01 is at `C:\Program Files\OpenSCAD\openscad.com`; pass
  Windows-style absolute paths (`pwd -W` in Git Bash). `make_cutaways.sh` hard-codes the Flatpak
  command, so run its steps by hand there.
- Elsewhere, OpenSCAD 2021.01 is installed as a **Flatpak**: run it as `flatpak run org.openscad.OpenSCAD`
  (there is no `openscad` on PATH). Pass absolute paths for input and output files, and run
  from inside the variant folder. Example:
  `cd 2-piece && flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_lower.stl" "$PWD/catch_lower.scad"`.
  All parts render as clean single solids (checked 2026-11-03).
- `2-piece/make_cutaways.sh` (unused, see the no-PNG note above) rendered `catch_cutaway_A.png` / `catch_cutaway_B.png`
  (true scale, 300 dpi):
  1. cuts each part to an STL in `stl/` via `catch_section_view.scad`;
  2. renders straight-on orthographic views (no tilt) to `render/raw_*.png`, cut face laid facing
     up because OpenSCAD lights faces pointing toward -X/-Y too dark;
  3. `scale_cutaways.py` measures the part's pixel bounding box against its known mm extents,
     fails if the X and Y scales differ by >1 %, then resamples to 300 dpi with scale bars.
- Pillow is available; matplotlib is not.

## Project instructions (from the Claude desktop Project)

<!-- Paste the Project's custom instructions and key decisions here. -->
