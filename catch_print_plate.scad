// ============================================================
// Catch - print plate: both parts in print orientation, side by side.
//   Catch: as installed, foot on the bed (fit surfaces print on top).
//          Needs support under the plate only.
//   Mount: frame face on the bed, dovetail groove facing up. No supports.
// Export: flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate.stl" "$PWD/catch_print_plate.scad"
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

gap = 10;   // spacing between the parts on the bed

catch_lower();

translate([plate_w + gap, 0, plate_top_z + mount_t])
    rotate([180, 0, 0]) catch_mount();
