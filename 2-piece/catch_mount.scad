// ============================================================
// Catch - mounting plate
// Screws to the frame above with one countersunk wood screw.
// Dovetail channel on the underside receives the catch tongue,
// sliding in from +X; closed end at -X; snap detent near the entry.
//
// Install: screw the mount on first (the screw head sits flush in the
// channel ceiling), then slide the catch in until it clicks.
//
// Print: frame face (top) down on the bed, channel facing up.
// ============================================================

include <catch_common.scad>

module mount_body() {
    translate([-plate_w/2, -plate_d/2, plate_top_z])
        cube([plate_w, plate_d, mount_t]);
}

module channel() {
    x0 = -plate_w/2 + end_wall;
    translate([x0, 0, plate_top_z - 0.01])
        dovetail(dt_w_bot + 2*dt_clear,
                 dt_w_top + 2*dt_clear + 2*dt_clear * (dt_w_top - dt_w_bot) / (2*dt_h),
                 dt_h + dt_clear + 0.01,
                 plate_w - end_wall + 1);
}

module screw_hole() {
    ceil_z = tongue_top_z + dt_clear;   // channel ceiling, where the head sits
    // shank
    translate([0, 0, ceil_z - 1]) cylinder(d = screw_d, h = mount_t + 2);
    // countersink cone, opening downward into the channel
    translate([0, 0, ceil_z - 0.01])
        cylinder(d1 = screw_head_d, d2 = screw_d, h = csk_depth + 0.01);
}

module detent_dimple() {
    translate([det_x, 0, tongue_top_z + dt_clear - (det_r - det_h) + 0.1])
        sphere(det_r + 0.1);
}

module catch_mount() {
    difference() {
        mount_body();
        channel();
        screw_hole();
        detent_dimple();
    }
}

catch_mount();
