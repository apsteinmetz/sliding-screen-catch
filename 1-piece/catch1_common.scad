// ============================================================
// Sliding screen catch - ONE-PIECE variant: parameters
// Included by catch_1piece.scad and catch_1piece_print_plate.scad.
//
// Same envelope as the 2-piece design, but the plate screws straight to
// the frame above and the leg is a cantilever spring: push the foot
// forward (-Y) about 5 mm to release the screen.
//
// Coordinate system (installed position):
//   Origin at plate centre (X, Y), Z up, foot bottom at z = 0.
//   The frame is above: plate top face at z = total_h.
//   Front edge of the plate is -Y; the leg hangs from it.
// ============================================================

$fn = 64;

// ---- Plate (screws to the frame) ----
plate_w      = 30;   // plate size, X
plate_d      = 30;   // plate size, Y
screw_meat   = 3;    // solid material between countersink bottom and frame face

// ---- Leg (flex spring) ----
leg_w        = 7;    // leg width, X (stiff direction) - same as 2-piece
leg_t        = 3.5;  // leg thickness at the root, Y (flex direction) // guess
leg_t_tip    = 1.8;  // leg thickness at the foot - linear taper spreads the strain along the leg // guess
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

total_h      = 50;   // bottom of foot to frame face - overall installed height

// ---- Wood screw (#8 / ~4 mm flat head) ----
screw_d      = 4.5;  // shank clearance hole
screw_head_d = 9.6;  // countersink diameter at the surface
screw_csk_angle = 90; // included angle (82 for US imperial screws, 90 metric)

// ---- Derived ----
csk_depth    = (screw_head_d - screw_d) / 2 / tan(screw_csk_angle / 2);   // ~2.55
plate_t      = csk_depth + screw_meat;      // ~5.55, countersunk from below
plate_bot_z  = total_h - plate_t;
leg_h        = plate_bot_z - foot_t;        // flexing length, ~46.95
foot_l       = foot_proj + leg_t_tip;       // total foot length incl. the part under the leg
front_y      = -plate_d / 2;
leg_y0       = front_y;                     // leg flush with front edge
foot_y0      = leg_y0 + leg_t_tip - foot_l; // foot projects forward (-Y)
foot_ext_z   = foot_t - foot_bevel - (foot_l - foot_ext_bot);  // bottom of the foot extension, below z = 0

// ---- Flex analysis (tapered cantilever, point load at the foot) ----
// s = distance down from the leg root (0 .. leg_h).
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
