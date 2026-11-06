// ============================================================
// Catch - multi print plate: as many catch + mount sets as fit on the bed.
// Same print orientation as catch_print_plate.scad:
//   Catch: lying on its side, +X end on the bed. Supports under leg and foot.
//   Mount: frame face on the bed, groove up. No supports.
//
// Nesting: each mount sits in the open pocket between its catch's foot and
// plate, beside the leg. Rows interlock: a row's legs pass above the mounts
// of the row below. The grid is turned 90 deg if that fits more sets.
//
// Set bed_x / bed_y for your printer, then export:
//   flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate_multi.stl" "$PWD/catch_print_plate_multi.scad"
// Override from the command line with e.g. -D bed_x=256 -D bed_y=256
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

bed_x  = 220;   // usable bed size, X // guess - set for your printer
bed_y  = 220;   // usable bed size, Y // guess - set for your printer
margin = 5;     // keep-out at the bed edge // guess
gap    = 3;     // minimum spacing between parts // guess

// ---- One set (catch + mount), footprint in catch_lower_print() coordinates ----
// Catch footprint is an L: foot at X foot_ext_z..foot_t (extension below 0),
// leg along Y -15..-12 (root),
// plate + tongue at X catch_h-plate_t .. catch_x.
catch_x  = tongue_top_z + det_h;          // catch length on the bed, ~52.95
leg_in_y = leg_y0 + leg_t;                // inner (+Y) face of the leg at its root (thickest), -12
mount_cx = foot_t + gap + plate_w/2;      // mount centre, beside the foot
mount_cy = leg_in_y + gap + plate_d/2;    // mount centre, beside the leg
set_y0   = foot_y0;                       // lowest Y of a set (foot tip), -27
set_y1   = mount_cy + plate_d/2;          // highest Y of a set (mount edge)

// The mount must fit between the foot and the leg-root fillet.
assert(mount_cx + plate_w/2 + gap <= plate_bot_z - leg_fillet_r,
       "mount does not fit in the pocket beside the leg");

pitch_x  = catch_x - foot_ext_z + gap;
// next row's leg (outer face at front_y) clears this row's mount
pitch_y  = set_y1 + gap - front_y;
set_h    = set_y1 - set_y0;

function n_cols(w) = max(0, floor((w - 2*margin + gap) / pitch_x));
function n_rows(h) = (h - 2*margin < set_h) ? 0
                   : floor((h - 2*margin - set_h) / pitch_y) + 1;

count_a = n_cols(bed_x) * n_rows(bed_y);   // grid as laid out
count_b = n_cols(bed_y) * n_rows(bed_x);   // grid turned 90 deg
turn    = count_b > count_a;
cols    = turn ? n_cols(bed_y) : n_cols(bed_x);
rows    = turn ? n_rows(bed_x) : n_rows(bed_y);
grid_w  = cols * pitch_x - gap;
grid_h  = set_h + (rows - 1) * pitch_y;

echo(str("catch_print_plate_multi: ", cols * rows, " sets (", cols, " x ", rows,
         turn ? ", turned 90 deg" : "", "), grid ",
         turn ? grid_h : grid_w, " x ", turn ? grid_w : grid_h, " mm on a ",
         bed_x, " x ", bed_y, " bed"));

module set() {
    catch_lower_print();
    translate([mount_cx, mount_cy, plate_top_z + mount_t])
        rotate([180, 0, 0]) catch_mount();
}

module grid() {
    for (c = [0 : cols - 1], r = [0 : rows - 1])
        translate([c * pitch_x - foot_ext_z, r * pitch_y - set_y0, 0]) set();
}

// Grid centred on the origin (slicers centre the model on the bed anyway).
rotate([0, 0, turn ? 90 : 0])
    translate([-grid_w/2, -grid_h/2, 0]) grid();
