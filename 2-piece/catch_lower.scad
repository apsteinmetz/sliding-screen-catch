// ============================================================
// Catch - lower part
// Plate with a full-width dovetail tongue on top; slides into
// catch_mount.scad from either end. A detent bump near each end of the
// tongue clicks into the matching mount dimple.
// The leg drops from the front edge (-Y); the foot projects forward.
// The leg is a cantilever spring, same design as the 1-piece variant:
// push the foot forward (-Y) ~5 mm to release the screen.
//
// Print: lying on its side - the +X end (plate edge and end of the
// tongue) on the bed, so the L-shaped profile, the dovetail flanks and
// the leg's bending direction lie in the layer plane (layers never run
// across the spring). Needs support under the leg and foot only.
// This file renders in print orientation (catch_lower_print); the assembly
// and print plate use the modules.
// ============================================================

include <catch_common.scad>

echo(str("mount_t = ", mount_t, " mm, leg_h = ", leg_h,
         " mm; at ", release_flex, " mm flex: root strain = ",
         round(flex_strain * 1000) / 10, " %, push force = ",
         round(push_force * 10) / 10, " N"));

module top_plate() {
    translate([-plate_w/2, -plate_d/2, plate_bot_z])
        cube([plate_w, plate_d, plate_t]);
}

module tongue() {
    // starts slightly below the plate top so the union is solid
    translate([tongue_x0, 0, plate_top_z - 0.01])
        dovetail(dt_w_bot, dt_w_top, dt_h + 0.01, tongue_len);
    // snap detent bumps on the tongue top face, one near each end
    for (x = [-det_x, det_x])
        intersection() {
            translate([x, 0, tongue_top_z - (det_r - det_h)]) sphere(det_r);
            translate([x - det_r, -det_r, tongue_top_z - 0.01])
                cube([2*det_r, 2*det_r, det_h + 0.01]);
        }
}

// Tapered leg: front face flush with the plate edge, back face slopes
// from leg_t at the root to leg_t_tip at the foot.
module leg() {
    hull() {
        translate([-leg_w/2, leg_y0, plate_bot_z - 0.01]) cube([leg_w, leg_t, 0.02]);
        translate([-leg_w/2, leg_y0, foot_t - 0.01])      cube([leg_w, leg_t_tip, 0.02]);
    }
}

// Concave fillet in the corner between the leg's back face (+Y) and the
// plate underside - the side in tension when the foot is pushed forward.
module leg_fillet() {
    r = leg_fillet_r;
    y0 = leg_y0 + leg_t;
    translate([-leg_w/2, 0, 0])
        difference() {
            translate([0, y0 - 0.01, plate_bot_z - r]) cube([leg_w, r + 0.01, r + 0.01]);
            translate([-1, y0 + r, plate_bot_z - r]) rotate([0, 90, 0])
                cylinder(r = r, h = leg_w + 2);
        }
}

// Foot block (z 0 .. foot_t) with every exposed edge chamfered by foot_bevel. Edges that run
// into the leg (top edges of the part under the leg) stay square so the
// leg's faces carry straight down into the foot.
module foot_block() {
    c  = foot_bevel;
    y0 = foot_y0;  y1 = foot_y0 + foot_l;  w = foot_w / 2;  t = foot_t;
    intersection() {
        // side profile (Y-Z): front-top, front-bottom, back-bottom corners
        rotate([90, 0, 90]) translate([0, 0, -w - 1]) linear_extrude(foot_w + 2)
            polygon([[y0 + c, 0], [y1 - c, 0], [y1, c], [y1, t],
                     [y0 + c, t], [y0, t - c], [y0, c]]);
        // plan (X-Y): front vertical corners
        translate([0, 0, -1]) linear_extrude(t + 2)
            polygon([[-w, y0 + c], [-w + c, y0], [w - c, y0], [w, y0 + c],
                     [w, y1 + 1], [-w, y1 + 1]]);
        // cross-section (X-Z): bottom edges full length; top edges only in
        // front of the leg
        union() {
            translate([0, y0 - 1, 0]) rotate([-90, 0, 0]) mirror([0, 1, 0])
                linear_extrude(leg_y0 - y0 + 1)
                    polygon([[-w + c, 0], [w - c, 0], [w, c], [w, t - c],
                             [w - c, t], [-w + c, t], [-w, t - c], [-w, c]]);
            translate([0, leg_y0, 0]) rotate([-90, 0, 0]) mirror([0, 1, 0])
                linear_extrude(y1 - leg_y0 + 1)
                    polygon([[-w + c, 0], [w - c, 0], [w, c], [w, t + 1], [-w, t + 1], [-w, c]]);
        }
    }
}

// Foot extension below the foot (z < 0). Back edge (+Y, under the leg)
// drops straight down. The foot keeps its front-top chamfer; below it the
// front is one 45-degree bevel running down and back until the bottom is
// foot_ext_bot long (the vertical front face and lower front chamfers are
// cut away). Full foot width in X.

// Y-Z profile, extruded across X (width w, centred).
module foot_yz(pts, w) {
    rotate([90, 0, 90]) translate([0, 0, -w/2]) linear_extrude(w) polygon(pts);
}

module foot_extension() {
    zt = foot_t - foot_bevel;   // bevel starts at (foot_y0, zt)
    y1 = foot_y0 + foot_l;
    foot_yz([[foot_y0 + zt - foot_bevel, foot_bevel], [y1, foot_bevel],
             [y1, foot_ext_z], [y1 - foot_ext_bot, foot_ext_z]], foot_w);
}

// Everything in front of the 45-degree bevel line (below the chamfer).
module foot_front_cut() {
    zt = foot_t - foot_bevel;  zl = foot_ext_z - 1;  e = 0.01;
    foot_yz([[foot_y0 - e, foot_t + 1], [foot_y0 - e, zt],
             [foot_y0 - e + zt - zl, zl],
             [foot_y0 - 1, zl], [foot_y0 - 1, foot_t + 1]], foot_w + 2);
}

module catch_foot() {
    difference() {
        union() { foot_block(); foot_extension(); }
        foot_front_cut();
    }
}

module catch_lower() {
    union() {
        top_plate();
        tongue();
        leg();
        leg_fillet();
        catch_foot();
    }
}

// Print orientation: rotated so the +X face is on the bed (z = 0),
// assembled Z (height) runs along +X, Y unchanged.
module catch_lower_print() {
    translate([0, 0, plate_w/2]) rotate([0, 90, 0]) catch_lower();
}

// Support enforcer for the slicer (print orientation): the plan outline of
// everything that hangs above the bed - leg, root fillet and foot (all of the
// catch below the plate underside) - from the bed up through the top of the
// foot. With "supports from enforcers only", support is generated only inside
// this outline, so it never spreads past the leg and foot.
module catch_lower_support_enforcer() {
    linear_extrude(plate_w/2 + foot_w/2 + 0.5)
        projection() intersection() {
            catch_lower_print();
            translate([-100, -100, -1]) cube([100 + plate_bot_z, 200, 200]);
        }
}

catch_lower_print();
