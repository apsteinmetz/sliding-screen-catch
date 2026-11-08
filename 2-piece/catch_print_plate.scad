// ============================================================
// Catch - print plate: one catch + mount set in print orientation.
//   Catch: lying on its side, +X end of the tongue on the bed.
//          Needs support under the leg and foot only.
//   Mount: frame face on the bed, dovetail groove facing up. No supports.
//          It sits in the pocket between the catch's foot and plate,
//          directly under the leg (front edge flush with the leg's front
//          face), so the leg's supports stand on the mount's front rail
//          instead of the bed - same nesting as catch_print_plate_multi.scad.
// Export: flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate.stl" "$PWD/catch_print_plate.scad"
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

gap = 2.5;  // spacing between the mount and the foot / leg-root fillet // guess
enforcers = false;   // true: export the support-enforcer volume instead (see catch_lower.scad)

mount_cx = foot_t + gap + plate_w/2;   // mount centre, beside the foot
mount_cy = leg_y0 + plate_d/2;         // front edge flush with the leg's front face, mount under the leg

assert(mount_cx + plate_w/2 + gap <= plate_bot_z - leg_fillet_r,
       "mount does not fit in the pocket under the leg");
// The leg lies plate_w/2 - leg_w/2 above the bed; the mount (mount_t tall) must clear it.
assert(plate_w/2 - leg_w/2 >= mount_t + 0.2,
       "mount touches the leg - widen plate_w");

module catch_print_plate() {
    catch_lower_print();   // occupies X foot_ext_z .. tongue_top_z + det_h

    translate([mount_cx, mount_cy, plate_top_z + mount_t])
        rotate([180, 0, 0]) catch_mount();
}

if (enforcers) catch_lower_support_enforcer();
else            catch_print_plate();
