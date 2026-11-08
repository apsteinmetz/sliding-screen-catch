# Sliding Screen Catch

3D-printable catch for a Sunscape brand sliding screen, modelled in OpenSCAD. It prevents the screens from sliding down. 

It screws to the frame above the screen, and its leg and foot stop the screen. The 2-piece catch allows the catch to be removed by sliding it out of the mounting plate.  I can be reversed so it stays in the mounting without catching the screen
Two variants, each self-contained in its own folder:

| Variant | Parts | Release | Status |
|---|---|---|---|
| [`2-piece/`](2-piece/README.md) | Mounting plate + catch that slides in on a dovetail (from either side) and clicks in with a snap detent; spring leg like the 1-piece | Push the foot forward ~3 mm (leg bends), or slide the catch out of the mount | Modelled, not yet test-printed |
| [`1-piece/`](1-piece/README.md) | Single part: plate + flexible leg | Push the foot forward ~3 mm (leg bends) | Modelled, not yet test-printed |

Both are designed for PLA and 50 mm tall from the bottom of the foot block to frame face (about 60 mm including the
foot extension below it), use one countersunk #8 (~4 mm) wood screw,
and have a 7 mm wide foot that sticks out 15 mm in front of the leg. Both print lying on their
side with supports under the leg and foot. Print files are in each folder's `stl/`;
`stl/catch_print_plate_combined.stl` at the top level holds one of each variant
(`catch_print_plate_combined.scad`).

Requires OpenSCAD (tested with 2021.01). See each folder's README for dimensions, printing
notes and export commands.
