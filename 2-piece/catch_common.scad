// ============================================================
// Sliding screen catch - shared parameters and helpers
// Included by catch_lower.scad, catch_mount.scad, catch_assembly.scad
//
// The leg is a cantilever spring like the 1-piece variant's: push the
// foot forward (-Y) about 5 mm to release the screen without removing
// the catch from the mount.
//
// Coordinate system (assembled position):
//   Origin at plate centre, Z up. The frame is above (+Z).
//   Front edge of the plates is -Y; the leg hangs from it.
//   The catch slides into the mount along X, from either end
//   (the channel is open at both ends).
// ============================================================

$fn = 64;

// ---- Catch (lower part) ----
plate_w      = 25;   // plate size, X
plate_d      = 30;   // plate size, Y
plate_t      = 3;    // catch plate thickness // guess - not on sketch

// ---- Leg (flex spring, same design as 1-piece) ----
leg_w        = 7;    // leg width, X (stiff direction)
leg_t        = 2.8;  // leg thickness at the root, Y (flex direction) // guess
leg_t_tip    = 1.4;  // leg thickness at the foot - linear taper spreads the strain along the leg // guess
leg_fillet_r = 3;    // fillet at the leg root, back (tension) side // guess
release_flex = 3;    // foot travel needed to release the catch

// ---- Material: PLA ----
mat_E        = 3300; // MPa, PLA printed with layers along the leg // guess (typical 3000-3500)
max_strain   = 0.01; // allowed peak strain for repeated flexing in PLA (yield ~2-3 %, brittle)

// ---- Foot ----
foot_w       = 7;    // foot width, X
foot_proj    = 15;   // how far the foot sticks out in front of the leg
foot_t       = 5;    // foot thickness, Z
foot_bevel   = 0.8;  // 45-degree chamfer on the foot's outside edges // guess
foot_ext_bot = 2;    // foot extends below z = 0 until its bottom is this long (Y): back edge
                     // straight down, front a 45-degree bevel below the front-top chamfer

total_h      = 50;   // bottom of foot to top of mount (frame face) - overall assembled height

// ---- Dovetail joint ----
dt_h         = 4.1;   // tongue height
dt_w_bot     = 14;   // tongue width where it meets the catch plate (narrow)
dt_w_top     = 18;   // tongue width at its top face (wide)
dt_clear     = 0.3;  // clearance per side - tune for your printer

// ---- Snap detent (one bump/dimple pair at each of +-det_x) ----
det_x        = 7;    // detent distance from the centre along X, near each channel end
det_r        = 1.5;  // bump sphere radius
det_h        = 0.7;  // bump height above tongue top - raise for a firmer click (0.5 did not quite catch)

// ---- Mounting plate ----
screw_meat   = 1.5;  // solid material between countersink bottom and frame face (was 3, then 2; 1.5 keeps mount_t 8.25 with the deeper countersink)

// ---- Wood screw (#8 / ~4 mm flat head) ----
screw_d      = 4.5;  // shank clearance hole
screw_head_d = 9.6;  // countersink diameter at the surface
screw_csk_angle = 90; // included angle (82 for US imperial screws, 90 metric)

// ---- Derived ----
csk_depth    = (screw_head_d - screw_d) / 2 / tan(screw_csk_angle / 2);   // ~2.55
mount_t      = dt_h + dt_clear + csk_depth + screw_meat;                   // ~8.25
catch_h      = total_h - mount_t;            // foot bottom to catch plate top, ~48.75
leg_h        = catch_h - plate_t - foot_t;   // flexing length, ~40.75
foot_l       = foot_proj + leg_t_tip;        // total foot length incl. the part under the leg
front_y      = -plate_d / 2;
leg_y0       = front_y;                      // leg flush with front edge
foot_y0      = leg_y0 + leg_t_tip - foot_l;  // foot projects forward (-Y)
foot_ext_z   = foot_t - foot_bevel - (foot_l - foot_ext_bot);  // bottom of the foot extension, below z = 0
plate_top_z  = catch_h;
plate_bot_z  = plate_top_z - plate_t;        // catch plate underside, leg root
tongue_top_z = plate_top_z + dt_h;
tongue_x0    = -plate_w/2;                   // tongue runs the full plate width
tongue_len   = plate_w;

// ---- Flex analysis (tapered cantilever, point load at the foot) ----
// Same as 1-piece/catch1_common.scad. s = distance down from the leg root (0 .. leg_h).
function leg_t_at(s) = leg_t + (leg_t_tip - leg_t) * s / leg_h;
function leg_I(s)    = leg_w * pow(leg_t_at(s), 3) / 12;
flex_n = 200;        // integration steps
// compliance: sum over the leg of (L - x)(s - x) / I(x) for x < s
function _c(s, i = 0) = i >= flex_n ? 0 :
    let(x = (i + 0.5) * s / flex_n)
    (leg_h - x) * (s - x) / leg_I(x) * s / flex_n + _c(s, i + 1);
push_force   = release_flex * mat_E / _c(leg_h);              // N, to push the foot 5 mm
function leg_defl(s) = push_force / mat_E * _c(s);            // mm, deflected shape
flex_strain  = push_force * leg_h * (leg_t / 2) / (mat_E * leg_I(0));  // peak, at the root
assert(flex_strain <= max_strain,
       str("leg root strain ", flex_strain, " exceeds max_strain - thin or taper the leg"));

// Trapezoid (narrow at z=0, wide at z=h) in the Y-Z plane, extruded along +X.
module dovetail(w_bot, w_top, h, len) {
    rotate([90, 0, 90])
        linear_extrude(len)
            polygon([[-w_bot/2, 0], [w_bot/2, 0], [w_top/2, h], [-w_top/2, h]]);
}
