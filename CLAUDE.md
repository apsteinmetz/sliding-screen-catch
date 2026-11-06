# Sliding Screen Catch

CAD project for a catch for a sliding screen, modeled in OpenSCAD. The repo root is
`screen catch/` and holds two self-contained variants:

- `2-piece/` — a mounting plate screwed to the frame above, and a catch that slides into it toolless
  from either end. Its leg is the same tapered cantilever spring as the 1-piece.
- `1-piece/` — a single part screwed to the frame, with a tapered flexible leg; push the foot
  forward ~5 mm to release. Designed for PLA.

This work started in a Claude desktop Project. `README.md` is the overview; current status and
print/assembly notes are in each variant's `README.md`. Each variant has its own parameter file;
the variants share no code, so change both when a shared dimension changes.

## Files — `2-piece/`

- `catch_common.scad` — **all dimensions live here**, plus the `dovetail()` helper and the leg
  flex analysis (copied from `1-piece/catch1_common.scad`, same `assert` on `max_strain`).
  Included by every other `.scad` file and read by `make_section_png.py` / `scale_cutaways.py`
  (their parsers skip the OpenSCAD-only flex-analysis lines).
- `catch_lower.scad` — the catch: plate, full-width dovetail tongue with two detent bumps, tapered
  leg, root fillet, chamfered foot (leg/fillet/foot modules copied from `1-piece/catch_1piece.scad`).
- `catch_mount.scad` — mounting plate: dovetail channel open at both ends, countersunk screw hole,
  two detent dimples.
- `catch_assembly.scad` — both parts in installed position (`explode` param to separate).
- `catch_print_plate.scad` — both parts in print orientation → `stl/catch_print_plate.stl`. The mount
  is nested under the catch's leg (as on the multi plate) so the leg's supports stand on it.
  Catch prints lying on its side (+X end on the bed, supports under leg and foot); mount prints
  frame face down. `catch_lower.scad` renders in this print orientation (`catch_lower_print()`);
  the assembly and section views use `catch_lower()` in installed coordinates.
  Do not print the catch tongue-down: the plate would overhang and the detent bump would be on the bed.
- `catch_print_plate_multi.scad` — as many catch + mount sets as fit on the bed
  (`bed_x`/`bed_y`, default 250 × 210 = the user's Original Prusa MK3S), grid turned 90° if that fits more
  → `stl/catch_print_plate_multi.stl`. Each mount sits directly under its catch's leg (front
  edge flush with the leg's front face) so the leg's supports stand on the mount's front rail
  (user's request, 2026-11-06); rows interlock, each foot beside the mount of the row below.
- `make_section_png.py` — renders `catch_section.png` (1:1 cross-sections at 300 dpi for
  test fitting). Needs Pillow only. Re-run after changing any dimension.
- `catch_section.png` — generated; do not edit by hand.
- `catch_section_view.scad`, `make_cutaways.sh`, `scale_cutaways.py` — true-scale OpenSCAD
  cutaway renders (see Tooling).
- `catch_cutaway_A.png`, `catch_cutaway_B.png`, `stl/` — generated; `render/` and
  `stl/cut_*.stl` are intermediates, git-ignored. `stl/*.3mf` are PrusaSlicer projects (MK3S,
  Generic PLA, settings from the user's own project). Rebuilt 2026-11-06 by packing each plate STL
  plus its support-enforcer volume (`-D enforcers=true` on `catch_print_plate.scad` /
  `catch_print_plate_multi.scad`, module `catch_lower_support_enforcer()`) into one object;
  supports are enforcers only, snug, `raft_first_layer_expansion` = 0, so support never spreads
  past the leg and foot (user requirement). The user may also re-save them from PrusaSlicer.

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
- `catch_1piece.scad` — the part: plate with countersink from below, tapered leg, root fillet,
  chamfered foot. Renders in print orientation (`catch_1piece_print()`, +X face on the bed);
  `catch_1piece()` is in installed coordinates. → `stl/catch_1piece.stl`.
- `catch_1piece_flexed.scad` — preview only: rest vs. leg pushed `release_flex` (5 mm).
- `render/` — preview images, git-ignored.

## Design decisions (settled with the user)

Shared by both variants:

- Overall height is **57 mm**, foot bottom to frame face (`total_h`).
- Tapered cantilever spring leg with root fillet; push the foot forward (-Y) ~5 mm to release.
  **PLA**: keep root strain ≤ 1 %. The two variants' leg/foot code is duplicated, so change both.
- Leg flush with the plate front edge (-Y). Foot 5 wide × 5 thick, projecting forward (away from
  the plate) 12 mm in front of the leg; foot length = 12 + the leg thickness under it.
- Foot extension below the foot block (z < 0), both variants (2026-11-06): back edge straight down;
  front keeps the front-top chamfer, then one 45° bevel down and back until the bottom is
  `foot_ext_bot` = 2 mm long (`foot_ext_z` ≈ -7.4 2-piece, -7.8 1-piece). `total_h` (57) is still
  measured from z = 0, the bottom of the foot block; the leg and flex analysis are unchanged.
- One countersunk wood screw for now (#8 / ~4 mm flat head). A second screw was offered and declined.

2-piece:

- Mount thickness is **derived** (`mount_t = dt_h + dt_clear + csk_depth + screw_meat`);
  the leg length absorbs the rest so the total stays 57 mm. Never hard-code `mount_t` or `leg_h`.
- Leg is a cantilever spring, same design as the 1-piece (decided 2026-11-05): 5 mm wide, tapers
  3.0 → 1.6 mm (thinner than the 1-piece's 3.5 → 2.0 because the leg is shorter; that taper
  would be 1.06 % strain), 3 mm root fillet, foot chamfered 0.8 mm; currently 0.9 % strain,
  5.3 N push force. Print material is PLA.
- Mount 1 mm thinner than originally (`screw_meat` 3 → 2, 2026-11-05); total height stays 57 mm.
- Detent bumps `det_h` = 0.7 mm (0.5 did not quite click into the dimples on the test print).
- Attachment: sliding dovetail + snap detent. The channel is open at both ends (no end wall) so the
  catch slides in from either side; detent bump/dimple pairs at ±`det_x` both click home together
  (decided 2026-11-05). The detents alone locate the catch along X.

1-piece:

- Screws directly to the frame above; plate thickness derived (`plate_t = csk_depth + screw_meat`).
- Leg flexes forward (-Y) ~5 mm to release. **Print material is PLA**: keep root strain ≤ 1 %.
  Leg tapers 3.5 → 2.0 mm thick (Y), 5 mm wide, with a 3 mm fillet at the root (back face);
  currently 0.8 % strain, 5.7 N push force.
- Foot outside edges have a slight bevel (`foot_bevel` = 0.8 mm); edges running into the leg stay square.

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
- `2-piece/make_cutaways.sh` (run from `2-piece/`) renders `catch_cutaway_A.png` / `catch_cutaway_B.png`
  (true scale, 300 dpi):
  1. cuts each part to an STL in `stl/` via `catch_section_view.scad`;
  2. renders straight-on orthographic views (no tilt) to `render/raw_*.png`, cut face laid facing
     up because OpenSCAD lights faces pointing toward -X/-Y too dark;
  3. `scale_cutaways.py` measures the part's pixel bounding box against its known mm extents,
     fails if the X and Y scales differ by >1 %, then resamples to 300 dpi with scale bars.
- Pillow is available; matplotlib is not.

## Project instructions (from the Claude desktop Project)

<!-- Paste the Project's custom instructions and key decisions here. -->
