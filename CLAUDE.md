# Sliding Screen Catch

CAD project for a catch for a sliding screen, modeled in OpenSCAD. The repo root is
`screen catch/` and holds two self-contained variants:

- `2-piece/` — a mounting plate screwed to the frame above, and a catch that slides into it toolless.
- `1-piece/` — a single part screwed to the frame, with a tapered flexible leg; push the foot
  forward ~5 mm to release. Designed for PLA.

This work started in a Claude desktop Project. `README.md` is the overview; current status and
print/assembly notes are in each variant's `README.md`. Each variant has its own parameter file;
the variants share no code, so change both when a shared dimension changes.

## Files — `2-piece/`

- `catch_common.scad` — **all dimensions live here**, plus the `dovetail()` helper.
  Included by every other `.scad` file and read by `make_section_png.py`.
- `catch_lower.scad` — the catch: plate, dovetail tongue with detent bump, leg, foot.
- `catch_mount.scad` — mounting plate: dovetail channel, countersunk screw hole, detent dimple.
- `catch_assembly.scad` — both parts in installed position (`explode` param to separate).
- `catch_print_plate.scad` — both parts in print orientation side by side → `stl/catch_print_plate.stl`.
  Catch prints lying on its side (+X end on the bed, supports under leg and foot); mount prints
  frame face down. `catch_lower.scad` renders in this print orientation (`catch_lower_print()`);
  the assembly and section views use `catch_lower()` in installed coordinates.
  Do not print the catch tongue-down: the plate would overhang and the detent bump would be on the bed.
- `catch_print_plate_multi.scad` — as many catch + mount sets as fit on the bed
  (`bed_x`/`bed_y`, default 220 × 220 is a guess), mounts nested beside each leg, rows
  interlocked, grid turned 90° if that fits more → `stl/catch_print_plate_multi.stl`.
- `make_section_png.py` — renders `catch_section.png` (1:1 cross-sections at 300 dpi for
  test fitting). Needs Pillow only. Re-run after changing any dimension.
- `catch_section.png` — generated; do not edit by hand.
- `catch_section_view.scad`, `make_cutaways.sh`, `scale_cutaways.py` — true-scale OpenSCAD
  cutaway renders (see Tooling).
- `catch_cutaway_A.png`, `catch_cutaway_B.png`, `stl/` — generated; `render/` and
  `stl/cut_*.stl` are intermediates, git-ignored.

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
- Leg flush with the plate front edge (-Y). Foot 5 wide × 5 thick, projecting forward (away from
  the plate) 12 mm in front of the leg; foot length = 12 + the leg thickness under it.
- One countersunk wood screw for now (#8 / ~4 mm flat head). A second screw was offered and declined.

2-piece:

- Mount thickness is **derived** (`mount_t = dt_h + dt_clear + csk_depth + screw_meat`);
  the leg length absorbs the rest so the total stays 57 mm. Never hard-code `mount_t` or `leg_h`.
- Leg 5×5 mm; foot 17 mm long (12 mm projection + 5 under the leg).
- Attachment: sliding dovetail + snap detent. Which end of the channel is closed does not matter.

1-piece:

- Screws directly to the frame above; plate thickness derived (`plate_t = csk_depth + screw_meat`).
- Leg flexes forward (-Y) ~5 mm to release. **Print material is PLA**: keep root strain ≤ 1 %.
  Leg tapers 3.5 → 2.0 mm thick (Y), 5 mm wide, with a 3 mm fillet at the root (back face);
  currently 0.8 % strain, 5.7 N push force.
- Foot outside edges have a slight bevel (`foot_bevel` = 0.8 mm); edges running into the leg stay square.

## Conventions

- Units are millimetres. Origin at the plate centre, Z up, frame above (+Z), front is -Y,
  (2-piece) catch slides in from +X.
- Keep dimensions as named parameters in each variant's common file; mark anything not taken
  from the sketch or confirmed by the user with `// guess`.
- One module per feature, joined in a top-level module per part.

## Repository

- Public repo: https://github.com/apsteinmetz/sliding-screen-catch (branch `main`).
- Commits must use the GitHub noreply email (set in this repo's local git config);
  the user does not want their personal email in the public history.

## Tooling

- OpenSCAD 2021.01 is installed as a **Flatpak**: run it as `flatpak run org.openscad.OpenSCAD`
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
