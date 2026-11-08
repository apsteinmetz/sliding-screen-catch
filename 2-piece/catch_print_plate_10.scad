// ============================================================
// Catch - 10-set print plate: n_sets catch + mount sets (default 10).
// Same parts, orientation and nesting as catch_print_plate_multi.scad:
//   Catch: lying on its side, +X end on the bed. Supports under leg and foot.
//   Mount: frame face on the bed, groove up, directly under its catch's leg,
//          so the leg's supports stand on the mount's front rail.
//   Rows interlock: a row's feet sit beside the mounts of the row below.
//
// Layout: of every cols x rows grid that holds n_sets and fits the bed
// (either way round), the one with the smallest bounding area is used;
// the last row may be part-filled.
//
// Export:
//   flatpak run org.openscad.OpenSCAD -o "$PWD/stl/catch_print_plate_10.stl" "$PWD/catch_print_plate_10.scad"
// Support-enforcer volumes for the slicer: add -D enforcers=true
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

n_sets = 10;    // number of catch + mount sets
bed_x  = 250;   // usable bed size, X - Original Prusa MK3S
bed_y  = 210;   // usable bed size, Y - Original Prusa MK3S
margin = 5;     // keep-out at the bed edge // guess
gap    = 2.5;   // minimum spacing between parts // guess
enforcers = false;   // true: export the support-enforcer volumes instead (see catch_lower.scad)

// ---- One set - same as catch_print_plate_multi.scad ----
catch_x  = tongue_top_z + det_h;          // catch length on the bed
mount_cx = foot_t + gap + plate_w/2;      // mount centre, beside the foot
mount_cy = leg_y0 + plate_d/2;           // mount front edge flush with the leg's front face
set_y0   = foot_y0;                       // lowest Y of a set (foot tip)
set_y1   = mount_cy + plate_d/2;          // highest Y of a set (mount edge)

assert(mount_cx + plate_w/2 + gap <= plate_bot_z - leg_fillet_r,
       "mount does not fit in the pocket beside the leg");
assert(plate_w/2 - leg_w/2 >= mount_t + 0.2,
       "mount touches the leg - widen plate_w");

pitch_x  = catch_x - foot_ext_z + gap;
pitch_y  = set_y1 + gap - front_y;
set_h    = set_y1 - set_y0;

function grid_w(c) = c * pitch_x - gap;
function grid_h(r) = set_h + (r - 1) * pitch_y;

// Candidates [area, cols, rows, turn] that hold n_sets and fit the bed.
cands = [for (c = [1 : n_sets], t = [false, true])
            let (r  = ceil(n_sets / c),
                 bw = t ? bed_y : bed_x,      // bed size along the grid's X
                 bh = t ? bed_x : bed_y)
            if (grid_w(c) <= bw - 2*margin && grid_h(r) <= bh - 2*margin)
                [grid_w(c) * grid_h(r), c, r, t]];
assert(len(cands) > 0, str(n_sets, " sets do not fit on a ", bed_x, " x ", bed_y, " bed"));

best_area = min([for (k = cands) k[0]]);
best      = [for (k = cands) if (k[0] == best_area) k][0];
cols = best[1];
rows = best[2];
turn = best[3];

echo(str("catch_print_plate_10: ", n_sets, " sets (", cols, " x ", rows,
         turn ? ", turned 90 deg" : "", "), grid ",
         turn ? grid_h(rows) : grid_w(cols), " x ", turn ? grid_w(cols) : grid_h(rows),
         " mm on a ", bed_x, " x ", bed_y, " bed"));

module set() {
    if (enforcers) catch_lower_support_enforcer();
    else {
        catch_lower_print();
        translate([mount_cx, mount_cy, plate_top_z + mount_t])
            rotate([180, 0, 0]) catch_mount();
    }
}

module grid() {
    for (i = [0 : n_sets - 1])
        let (c = i % cols, r = floor(i / cols))
            translate([c * pitch_x - foot_ext_z, r * pitch_y - set_y0, 0]) set();
}

// Grid centred on the origin (slicers centre the model on the bed anyway).
rotate([0, 0, turn ? 90 : 0])
    translate([-grid_w(cols)/2, -grid_h(rows)/2, 0]) grid();
