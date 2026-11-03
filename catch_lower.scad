// ============================================================
// Catch - lower part
// Plate with a dovetail tongue on top; slides into catch_mount.scad.
// The leg drops from the front edge (-Y); the foot projects forward.
//
// Print: upside down (tongue on the bed), leg pointing up.
// ============================================================

include <catch_common.scad>

module top_plate() {
    translate([-plate_w/2, -plate_d/2, plate_top_z - plate_t])
        cube([plate_w, plate_d, plate_t]);
}

module tongue() {
    // starts slightly below the plate top so the union is solid
    translate([tongue_x0, 0, plate_top_z - 0.01])
        dovetail(dt_w_bot, dt_w_top, dt_h + 0.01, tongue_len);
    // snap detent bump on the tongue top face
    intersection() {
        translate([det_x, 0, tongue_top_z - (det_r - det_h)]) sphere(det_r);
        translate([det_x - det_r, -det_r, tongue_top_z - 0.01])
            cube([2*det_r, 2*det_r, det_h + 0.01]);
    }
}

module leg() {
    translate([-leg_w/2, leg_y0, foot_t])
        cube([leg_w, leg_d, leg_h]);
}

module catch_foot() {
    translate([-foot_w/2, foot_y0, 0])
        cube([foot_w, foot_l, foot_t]);
}

module catch_lower() {
    union() {
        top_plate();
        tongue();
        leg();
        catch_foot();
    }
}

catch_lower();
