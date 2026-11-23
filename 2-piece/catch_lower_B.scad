// ============================================================
// Catch - lower part, VERSION B (user's request, 2026-11-23)
// Same as catch_lower.scad, but starting leg_b_drop below the catch plate
// underside the leg is thickened by leg_b_add toward the front (-Y), down to
// the top of the foot. The step is a horizontal shelf at a right angle to the
// leg's front face. The back face and the foot toe are unchanged. Flex force is
// ignored (the leg is much stiffer than the strain-checked original).
// The leg is also leg_extra (1 mm) longer than the standard catch: the foot
// is 1 mm lower, so the installed height with the mount is 51 mm.
// This file renders in print orientation (catch_lower_B_print).
// ============================================================

catch_lower_B = true;   // tells catch_lower.scad not to render its own part
leg_extra = 1;          // leg 1 mm longer: the foot sits 1 mm lower, total height 51 mm
foot_extra = 1;         // foot 1 mm longer (projects 16 mm in front of the leg)

leg_b_drop = 10;    // thickening starts this far below the catch plate underside
leg_b_add  = 2;     // extra leg thickness, toward the front (-Y)
leg_b_back = 1;     // extra leg thickness, toward the back (+Y), parallel to the tapered back face, full length of leg and foot

include <catch_lower.scad>   // catch_lower() plus all parameters (read leg_b_add, so define it first)


// The added material: a block on the front (-Y) side of the leg, from the
// step down to the foot top. Its front face is flush-parallel to the leg's
// front face, 2 mm further forward, so the step is a horizontal shelf at a
// right angle to the leg front face. It sits over the foot, so the toe is untouched.
module leg_b_extra() {
    z_step = plate_bot_z - leg_b_drop;
    e = 0.5;                                       // overlap into the leg so the union is solid
    translate([-leg_w/2, leg_y0 - leg_b_add, foot_t - 0.01])
        cube([leg_w, leg_b_add + e, z_step - foot_t + 0.01]);
}

// Back (+Y) thickening: runs the full length of the leg and foot, from the plate
// underside down to the bottom of the foot extension. Follows the tapered back
// face (offset leg_b_back behind it), then straight down behind the foot.
module leg_b_back_extra() {
    e  = 0.5;                                      // overlap into the leg/foot
    yb = leg_y0 + leg_t;                           // back face at the root
    yt = leg_y0 + leg_t_tip;                       // back face at the foot (= foot back edge)
    foot_yz([[yb - e, plate_bot_z + 0.01], [yb + leg_b_back, plate_bot_z + 0.01],
             [yt + leg_b_back, foot_t], [yt + leg_b_back, foot_ext_z],
             [yt - e, foot_ext_z], [yt - e, foot_t]], leg_w);
}

module catch_lower_B() {
    union() {
        catch_lower();
        leg_b_extra();
        leg_b_back_extra();
    }
}

// Print orientation: +X face on the bed, same as catch_lower_print().
module catch_lower_B_print() {
    translate([0, 0, plate_w/2]) rotate([0, 90, 0]) catch_lower_B();
}

// Support enforcer for the slicer (print orientation), same idea as
// catch_lower_support_enforcer() but for version B's leg.
module catch_lower_B_support_enforcer() {
    linear_extrude(plate_w/2 + foot_w/2 + 0.5)
        projection() intersection() {
            catch_lower_B_print();
            translate([-100, -100, -1]) cube([100 + plate_bot_z, 200, 200]);
        }
}

if (is_undef(print_plate_B)) catch_lower_B_print();   // catch_print_plate_B.scad includes this file
