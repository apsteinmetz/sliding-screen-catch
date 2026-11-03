// ============================================================
// Sliding screen catch - shared parameters and helpers
// Included by catch_lower.scad, catch_mount.scad, catch_assembly.scad
//
// Coordinate system (assembled position):
//   Origin at plate centre, Z up. The frame is above (+Z).
//   Front edge of the plates is -Y; the leg hangs from it.
//   The catch slides into the mount from +X toward -X.
// ============================================================

$fn = 64;

// ---- Catch (lower part) ----
plate_w      = 30;   // plate size, X
plate_d      = 30;   // plate size, Y
plate_t      = 3;    // catch plate thickness // guess - not on sketch

leg_w        = 5;    // leg cross-section, X
leg_d        = 5;    // leg cross-section, Y

foot_w       = 5;    // foot width, X
foot_l       = 10;   // foot length, Y (total, incl. the part under the leg)
foot_t       = 5;    // foot thickness, Z

total_h      = 50;   // bottom of foot to top of mount (frame face) - overall assembled height

// ---- Dovetail joint ----
dt_h         = 4;    // tongue height
dt_w_bot     = 14;   // tongue width where it meets the catch plate (narrow)
dt_w_top     = 18;   // tongue width at its top face (wide)
dt_clear     = 0.2;  // clearance per side - tune for your printer
end_wall     = 3;    // closed end of the channel in the mount (-X side)

// ---- Snap detent ----
det_x        = 11;   // detent position along X (near the open/entry end)
det_r        = 1.5;  // bump sphere radius
det_h        = 0.5;  // bump height above tongue top - raise for a firmer click

// ---- Mounting plate ----
screw_meat   = 3;    // solid material between countersink bottom and frame face

// ---- Wood screw (#8 / ~4 mm flat head) ----
screw_d      = 4.5;  // shank clearance hole
screw_head_d = 8.6;  // countersink diameter at the surface
screw_csk_angle = 90; // included angle (82 for US imperial screws, 90 metric)

// ---- Derived ----
csk_depth    = (screw_head_d - screw_d) / 2 / tan(screw_csk_angle / 2);   // ~2.05
mount_t      = dt_h + dt_clear + csk_depth + screw_meat;                   // ~9.25
catch_h      = total_h - mount_t;            // foot bottom to catch plate top, ~40.75
leg_h        = catch_h - plate_t - foot_t;   // ~32.75
front_y      = -plate_d / 2;
leg_y0       = front_y;                      // leg flush with front edge
foot_y0      = leg_y0 + leg_d - foot_l;      // foot projects forward (-Y)
plate_top_z  = catch_h;
tongue_top_z = plate_top_z + dt_h;
tongue_x0    = -plate_w/2 + end_wall + dt_clear;
tongue_len   = plate_w/2 - tongue_x0;

// Trapezoid (narrow at z=0, wide at z=h) in the Y-Z plane, extruded along +X.
module dovetail(w_bot, w_top, h, len) {
    rotate([90, 0, 90])
        linear_extrude(len)
            polygon([[-w_bot/2, 0], [w_bot/2, 0], [w_top/2, h], [-w_top/2, h]]);
}
