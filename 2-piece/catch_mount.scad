// ============================================================
// Catch - mounting plate
// Screws to the frame above with one countersunk wood screw.
// Dovetail channel on the underside receives the catch tongue. The
// channel is open at both ends, so the catch slides in from either side;
// a detent dimple near each end takes the catch's bumps.
//
// Install: screw the mount on first (the screw head sits flush in the
// channel ceiling), then slide the catch in until it clicks. The leading
// bump clicks once in passing (2 * det_x before home); push on until it
// clicks again with the catch plate flush with the mount.
// No end wall: the detents alone locate the catch along X.
//
// Print: frame face (top) down on the bed, channel facing up.
// ============================================================

include <catch_common.scad>

module mount_body() {
    translate([-plate_w/2, -plate_d/2, plate_top_z])
        cube([plate_w, plate_d, mount_t]);
}

// Through the full plate width, open at both ends.
module channel() {
    translate([-plate_w/2 - 1, 0, plate_top_z - 0.01])
        dovetail(dt_w_bot + 2*dt_clear,
                 dt_w_top + 2*dt_clear + 2*dt_clear * (dt_w_top - dt_w_bot) / (2*dt_h),
                 dt_h + dt_clear + 0.01,
                 plate_w + 2);
}

module screw_hole() {
    ceil_z = tongue_top_z + dt_clear;   // channel ceiling, where the head sits
    // shank
    translate([0, 0, ceil_z - 1]) cylinder(d = screw_d, h = mount_t + 2);
    // countersink cone, opening downward into the channel
    translate([0, 0, ceil_z - 0.01])
        cylinder(d1 = screw_head_d, d2 = screw_d, h = csk_depth + 0.01);
}

module detent_dimples() {
    for (x = [-det_x, det_x])
        translate([x, 0, tongue_top_z + dt_clear - (det_r - det_h) + 0.1])
            sphere(det_r + 0.1);
}

module catch_mount() {
    difference() {
        mount_body();
        channel();
        screw_hole();
        detent_dimples();
    }
}

catch_mount();
