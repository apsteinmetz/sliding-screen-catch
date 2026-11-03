// ============================================================
// Catch - lower part
// Plate with a dovetail tongue on top; slides into catch_mount.scad.
// The leg drops from the front edge (-Y); the foot projects forward.
//
// Print: lying on its side - the +X end (plate edge and open end of the
// tongue) on the bed, so the L-shaped profile and the dovetail flanks lie
// in the layer plane. Needs support under the leg and foot only.
// This file renders in print orientation (catch_lower_print); the assembly
// and print plate use the modules.
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

// Print orientation: rotated so the +X face is on the bed (z = 0),
// assembled Z (height) runs along +X, Y unchanged.
module catch_lower_print() {
    translate([0, 0, plate_w/2]) rotate([0, 90, 0]) catch_lower();
}

catch_lower_print();
