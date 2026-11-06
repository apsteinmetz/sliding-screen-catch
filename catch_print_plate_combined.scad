// ============================================================
// Combined print plate: 2-piece set (catch + mount) and the 1-piece catch.
// Each part is in its own print orientation (catches lying on their side,
// mount frame face down). Both catches are turned 90 deg about Z so their
// length runs along Y, side by side to the left of the mount; the mount
// sits where 2-piece/catch_print_plate.scad puts it.
// Export: openscad -o stl/catch_print_plate_combined.stl catch_print_plate_combined.scad
// ============================================================

include <2-piece/catch_common.scad>
use <2-piece/catch_lower.scad>
use <2-piece/catch_mount.scad>
use <1-piece/catch_1piece.scad>

gap      = 10;                          // spacing between the parts on the bed
catch_w  = plate_d/2 - foot_y0;         // catch width once turned: foot tip to plate back, 42 (same for both variants)
mount_x0 = tongue_top_z + det_h + gap;  // mount's left edge, as in 2-piece/catch_print_plate.scad

// Turn a catch 90 deg about Z: its foot tip lands at X = x0, its bed face
// (the installed +X end) along Y = -plate_d/2, level with the mount's front edge.
module turned(x0) {
    translate([x0 + plate_d/2, -plate_d/2, 0]) rotate([0, 0, 90]) children();
}

turned(mount_x0 - gap - catch_w)           catch_1piece_print();
turned(mount_x0 - 2*gap - 2*catch_w)       catch_lower_print();

translate([mount_x0 + plate_w/2, 0, plate_top_z + mount_t])
    rotate([180, 0, 0]) catch_mount();
