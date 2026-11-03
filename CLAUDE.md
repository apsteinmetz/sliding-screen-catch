# Sliding Screen Catch

CAD project for a catch for a sliding screen, modeled in OpenSCAD. Two printed parts:
a mounting plate screwed to the frame above, and a catch that slides into it toolless.
This folder continues work that started in a Claude desktop Project.
Current status and print/assembly notes are in `README.md`.

## Files

- `catch_common.scad` — **all dimensions live here**, plus the `dovetail()` helper.
  Included by every other `.scad` file and read by `make_section_png.py`.
- `catch_lower.scad` — the catch: plate, dovetail tongue with detent bump, leg, foot.
- `catch_mount.scad` — mounting plate: dovetail channel, countersunk screw hole, detent dimple.
- `catch_assembly.scad` — both parts in installed position (`explode` param to separate).
- `catch_print_plate.scad` — both parts in print orientation side by side → `stl/catch_print_plate.stl`.
  Catch prints as installed (foot down, supports under the plate); mount prints frame face down.
  Do not print the catch tongue-down: the plate would overhang and the detent bump would be on the bed.
- `make_section_png.py` — renders `catch_section.png` (1:1 cross-sections at 300 dpi for
  test fitting). Needs Pillow only. Re-run after changing any dimension.
- `catch_section.png` — generated; do not edit by hand.
- `catch_section_view.scad`, `make_cutaways.sh`, `scale_cutaways.py` — true-scale OpenSCAD
  cutaway renders (see Tooling).
- `catch_cutaway_A.png`, `catch_cutaway_B.png`, `stl/`, `render/` — generated.

## Design decisions (settled with the user)

- Overall height is **50 mm**, foot bottom to frame face (`total_h`).
- Mount thickness is **derived** (`mount_t = dt_h + dt_clear + csk_depth + screw_meat`);
  the leg length absorbs the rest so the total stays 50 mm. Never hard-code `mount_t` or `leg_h`.
- Leg 5×5 mm, flush with the plate front edge (-Y). Foot 5 wide × 10 long × 5 thick,
  projecting forward (away from the plate); the 10 mm includes the 5 mm under the leg.
- Attachment: sliding dovetail + snap detent. Which end of the channel is closed does not matter.
- One countersunk wood screw for now (#8 / ~4 mm flat head). A second screw was offered and declined.

## Conventions

- Units are millimetres. Origin at the plate centre, Z up, frame above (+Z), front is -Y,
  catch slides in from +X.
- Keep dimensions as named parameters in `catch_common.scad`; mark anything not taken from the
  sketch or confirmed by the user with `// guess`.
- One module per feature, joined in a top-level module per part.

## Repository

- Public repo: https://github.com/apsteinmetz/sliding-screen-catch (branch `main`).
- Commits must use the GitHub noreply email (set in this repo's local git config);
  the user does not want their personal email in the public history.

## Tooling

- OpenSCAD 2021.01 is installed as a **Flatpak**: run it as `flatpak run org.openscad.OpenSCAD`
  (there is no `openscad` on PATH). Pass absolute paths for input and output files.
  Export STLs: `flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_lower.stl" "$PWD/catch_lower.scad"`.
  Both parts render as clean single solids (checked 2026-11-03).
- `./make_cutaways.sh` renders `catch_cutaway_A.png` / `catch_cutaway_B.png` (true scale, 300 dpi):
  1. cuts each part to an STL in `stl/` via `catch_section_view.scad`;
  2. renders straight-on orthographic views (no tilt) to `render/raw_*.png`, cut face laid facing
     up because OpenSCAD lights faces pointing toward -X/-Y too dark;
  3. `scale_cutaways.py` measures the part's pixel bounding box against its known mm extents,
     fails if the X and Y scales differ by >1 %, then resamples to 300 dpi with scale bars.
- Pillow is available; matplotlib is not.

## Project instructions (from the Claude desktop Project)

<!-- Paste the Project's custom instructions and key decisions here. -->
