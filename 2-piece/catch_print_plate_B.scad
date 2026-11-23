// ============================================================
// Catch - print plate, VERSION B: one version-B catch + mount set in print
// orientation (user's request, 2026-11-23). Same layout as catch_print_plate.scad:
//   Catch B: lying on its side, +X end of the tongue on the bed. Supports under leg and foot only.
//   Mount:   frame face on the bed, groove up, in the pocket between the foot and
//            the catch plate, under the leg, so the leg's supports stand on its
//            front rail. Its front edge is flush with version B's thickened leg
//            front face (leg_b_add in front of the plain leg face).
// Export: flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate_B.stl" "$PWD/catch_print_plate_B.scad"
// Support enforcer: add -D enforcers=true
// ============================================================

print_plate_B = true;   // tells catch_lower_B.scad not to render its own part
include <catch_lower_B.scad>   // catch_lower_B_print(), all parameters (leg_extra = 1)
use <catch_mount.scad>

gap = 2.5;  // spacing between the mount and the foot / leg-root fillet // guess
enforcers = false;   // true: export the support-enforcer volume instead

mount_cx = foot_t + gap + plate_w/2;                 // mount centre, beside the foot
mount_cy = leg_y0 - leg_b_add + plate_d/2;           // front edge flush with B's thickened leg front face
// catch_mount.scad is built without leg_extra, so its own frame has the frame face at z = total_h - leg_extra.
mount_flip_z = total_h - leg_extra;

assert(mount_cx + plate_w/2 + gap <= plate_bot_z - leg_fillet_r,
       "mount does not fit in the pocket under the leg");
// The leg lies plate_w/2 - leg_w/2 above the bed; the mount (mount_t tall) must clear it.
assert(plate_w/2 - leg_w/2 >= mount_t + 0.2,
       "mount touches the leg - widen plate_w");

module catch_print_plate_B() {
    catch_lower_B_print();

    translate([mount_cx, mount_cy, mount_flip_z])
        rotate([180, 0, 0]) catch_mount();
}

if (enforcers) catch_lower_B_support_enforcer();
else            catch_print_plate_B();
