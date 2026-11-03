// ============================================================
// Preview only: the one-piece catch at rest (orange) and with the leg
// pushed forward by release_flex (translucent), approximating the bent
// leg as a cantilever curve. Not for printing.
// ============================================================

include <catch1_common.scad>
use <catch_1piece.scad>

color("Orange") catch_1piece();

// Deflected leg: tapered cantilever under tip load (leg_defl from
// catch1_common.scad), s measured down from the root. Drawn as stacked slices.
n = 24;
function defl(s) = leg_defl(s);
function slope(s) = (leg_defl(s) - leg_defl(s - 0.5)) / 0.5;
color("SteelBlue", 0.5) {
    for (i = [0 : n - 1]) {
        s0 = leg_h * i / n; s1 = leg_h * (i + 1) / n;
        hull() {
            translate([-leg_w/2, leg_y0 - defl(s0), plate_bot_z - s0 - 0.01]) cube([leg_w, leg_t_at(s0), 0.01]);
            translate([-leg_w/2, leg_y0 - defl(s1), plate_bot_z - s1]) cube([leg_w, leg_t_at(s1), 0.01]);
        }
    }
    // foot carried along, rotated by the tip slope
    translate([0, leg_y0 - defl(leg_h), foot_t])
        rotate([-atan(slope(leg_h)), 0, 0])
            translate([0, -leg_y0, -foot_t]) catch_foot();
}
