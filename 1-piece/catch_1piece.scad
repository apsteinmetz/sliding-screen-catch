// ============================================================
// Sliding screen catch - one-piece variant
// Plate screws to the frame above with one countersunk wood screw
// (head sits flush in the plate underside). The leg is a cantilever
// spring; push the foot forward (-Y) ~5 mm to release.
//
// Print: lying on its side, +X face on the bed, so the leg's length and
// its bending direction lie in the layer plane (layers never run across
// the spring). Needs support under the leg and foot only.
// This file renders in print orientation (catch_1piece_print);
// catch_1piece() is in installed coordinates.
// ============================================================

include <catch1_common.scad>

echo(str("plate_t = ", plate_t, " mm, leg_h = ", leg_h,
         " mm; at ", release_flex, " mm flex: root strain = ",
         round(flex_strain * 1000) / 10, " %, push force = ",
         round(push_force * 10) / 10, " N"));

module plate() {
    translate([-plate_w/2, -plate_d/2, plate_bot_z])
        cube([plate_w, plate_d, plate_t]);
}

module screw_hole() {
    // shank
    translate([0, 0, plate_bot_z - 1]) cylinder(d = screw_d, h = plate_t + 2);
    // countersink cone, opening downward (screw driven up into the frame)
    translate([0, 0, plate_bot_z - 0.01])
        cylinder(d1 = screw_head_d, d2 = screw_d, h = csk_depth + 0.01);
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

module catch_1piece() {
    difference() {
        union() {
            plate();
            leg();
            leg_fillet();
            catch_foot();
        }
        screw_hole();
    }
}

// Print orientation: +X face on the bed (z = 0), installed Z runs along +X.
module catch_1piece_print() {
    translate([0, 0, plate_w/2]) rotate([0, 90, 0]) catch_1piece();
}

catch_1piece_print();
