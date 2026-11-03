// ============================================================
// Catch - print plate: both parts in print orientation, side by side.
//   Catch: lying on its side, +X end (open end of the tongue) on the bed.
//          Needs support under the leg and foot only.
//   Mount: frame face on the bed, dovetail groove facing up. No supports.
// Export: flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate.stl" "$PWD/catch_print_plate.scad"
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

gap = 10;   // spacing between the parts on the bed

catch_lower_print();   // occupies X 0 .. tongue_top_z + det_h

translate([tongue_top_z + det_h + gap + plate_w/2, 0, plate_top_z + mount_t])
    rotate([180, 0, 0]) catch_mount();
