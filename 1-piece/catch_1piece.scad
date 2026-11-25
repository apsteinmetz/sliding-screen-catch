// ============================================================
// Sliding screen catch - one-piece variant
// Plate screws to the frame above with one countersunk wood screw
// (head sits flush in the plate underside). The leg is a cantilever
// spring; push the foot forward (-Y) ~3 mm to release. Starting leg_front_drop
// below the plate it is thickened leg_front_add toward the front, and the whole leg
// and foot leg_back_add toward the back; foot top edges square, 1 mm fillets on the
// leg back and foot bottom side edges (same as the 2-piece, 2026-11-25).
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

// Foot block (z 0 .. foot_t). Plain box: the top edges are square (the top chamfer
// was removed 2026-11-25); the side edges of the bottom, bevel, toe and back faces
// are filleted by legfoot_round().
module foot_block() {
    translate([-foot_w/2, foot_y0, 0]) cube([foot_w, foot_l, foot_t]);
}

// Foot extension below the foot (z < 0). Back edge (+Y, under the leg)
// drops straight down. The toe keeps a foot_bevel-high vertical face; below it the
// front is one 45-degree bevel running down and back until the bottom is
// foot_ext_bot long (the rest of the block's vertical front face is cut away). Full foot width in X.

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

// Everything in front of the 45-degree bevel line (below the toe's vertical face).
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

// Half-space on the left of the Y-Z line through a along u (left = u turned +90 deg),
// limited to |x| <= w/2, with its two edges along the line rounded to radius r.
module round_slab(a, u, w, r, L = 200, D = 200) {
    t = u / norm(u);
    n = [-t[1], t[0]];   // inward normal
    multmatrix([[1, 0,    0,    0],
                [0, t[0], n[0], a[0]],
                [0, t[1], n[1], a[1]],
                [0, 0,    0,    1]])
        rotate([90, 0, 0]) linear_extrude(L, center = true)
            translate([0, D/2]) offset(r, $fn = 24) square([w - 2*r, D - 2*r], center = true);
}

// Envelope that fillets (edge_fillet_r) the side edges of the leg's back face and of
// the foot's toe, bevel, bottom and back faces; the leg front, the foot top and the
// profile corners stay square. back_add moves the back faces back (leg_back_add).
// Above the foot top only the leg's back face is rounded; below it the foot's faces
// (the foot piece reaches 1 mm higher so the two overlap; split there because the tapered leg back and the vertical foot back meet at a
// slightly concave corner).
module legfoot_round(back_add = leg_back_add) {
    r  = edge_fillet_r;
    yb = leg_y0 + leg_t + back_add;              // leg back face at the root
    yt = leg_y0 + leg_t_tip + back_add;          // leg back face at the foot = foot back
    yf = leg_y0 + leg_t_tip - foot_ext_bot;      // front of the bottom flat
    zt = foot_t - foot_bevel;                    // top of the 45-degree bevel
    big = 200;
    union() {
        intersection() {
            // 0.01 mm behind the leg's back face: a slab face almost (not exactly) in the
            // plane of the back face leaves a non-manifold mesh
            round_slab([yt + 0.01, foot_t], [yb - yt, plate_bot_z - foot_t], leg_w, r);
            // stops short of the toe, so the toe's rounded edges run on up to the top of
            // the foot piece instead of ending in a ledge in the plane of the foot top
            translate([-big/2, foot_y0 + 2*r, foot_t]) cube(big);
        }
        intersection() {
            round_slab([foot_y0, foot_t], [0, -1], foot_w, r);                        // toe
            round_slab([foot_y0, zt], [yf - foot_y0, foot_ext_z - zt], foot_w, r);    // bevel
            round_slab([yf, foot_ext_z], [1, 0], foot_w, r);                          // bottom
            round_slab([yt, foot_ext_z], [0, 1], foot_w, r);                          // back
            translate([-big/2, -big/2, foot_t + 1 - big]) cube(big);   // overlaps the leg piece (inside it there)
        }
    }
}

// Front thickening: a block on the front (-Y) of the leg, from leg_front_drop below the
// plate underside down to the foot top. Its front face is parallel to the leg front,
// leg_front_add further forward, so the step is a horizontal shelf. The toe is untouched.
module leg_front_extra() {
    z_step = plate_bot_z - leg_front_drop;
    e = 0.5;                                       // overlap into the leg so the union is solid
    translate([-leg_w/2, leg_front_y, foot_t - 0.01])
        cube([leg_w, leg_front_add + e, z_step - foot_t + 0.01]);
}

// Back (+Y) thickening: full length of the leg and foot, from the plate underside down
// to the bottom of the foot extension. Follows the tapered back face (offset
// leg_back_add behind it), then straight down behind the foot.
module leg_back_extra() {
    e  = 0.5;                                      // overlap into the leg/foot
    yb = leg_y0 + leg_t;                           // back face at the root
    yt = leg_y0 + leg_t_tip;                       // back face at the foot (= foot back edge)
    foot_yz([[yb - e, plate_bot_z + 0.01], [yb + leg_back_add, plate_bot_z + 0.01],
             [yt + leg_back_add, foot_t], [yt + leg_back_add, foot_ext_z],
             [yt - e, foot_ext_z], [yt - e, foot_t]], leg_w);
}

// Plate and root fillet, plus the leg, its thickening and the foot, filleted by
// legfoot_round(); minus the screw hole.
module catch_1piece() {
    difference() {
        union() {
            plate();
            leg_fillet();
            intersection() {
                union() { leg(); leg_front_extra(); leg_back_extra(); catch_foot(); }
                legfoot_round();
            }
        }
        screw_hole();
    }
}

// Print orientation: +X face on the bed (z = 0), installed Z runs along +X.
module catch_1piece_print() {
    translate([0, 0, plate_w/2]) rotate([0, 90, 0]) catch_1piece();
}

catch_1piece_print();
