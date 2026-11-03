// ============================================================
// Catch - cutaway views of the assembly, for PNG export.
//   part = "mount" | "catch"  : one half-part, for STL export (CGAL)
//   part = "view"             : imports the half-part STLs in colour
//   cut  = "A" : cut at X = 0, keep -X half (screw, leg, foot, dovetail profile)
//   cut  = "B" : cut at Y = 0, keep -Y half (slide direction, end wall, detent)
// Regenerate with ./make_cutaways.sh
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

cut  = "A";
part = "view";
big  = 200;

module keep() {
    if (cut == "A") translate([-big, -big/2, -big/2]) cube(big);
    else            translate([-big/2, -big, -big/2]) cube(big);
}

if (part == "mount") intersection() { catch_mount(); keep(); }
if (part == "catch") intersection() { catch_lower(); keep(); }
// For the view, lay the cut face facing up (+Z, best lit) with the part's
// "up" pointing to the top of the image; the camera looks down on it.
module lay_flat() {
    if (cut == "A") rotate([0, 0, -90]) rotate([0, -90, 0]) children();  // front (-Y) on the left
    else            rotate([0, 0, 180]) rotate([90, 0, 0])  children();  // slide entry (+X) on the left
}

if (part == "view") lay_flat() {
    color("SteelBlue")  import(str("stl/cut_", cut, "_mount.stl"));
    color("DarkOrange") import(str("stl/cut_", cut, "_catch.stl"));
}
