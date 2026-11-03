// ============================================================
// Catch - assembly preview (both parts in installed position)
// Set explode > 0 to pull the catch out along +X to see the joint.
// ============================================================

include <catch_common.scad>
use <catch_lower.scad>
use <catch_mount.scad>

explode = 0;   // mm

color("SteelBlue", 0.6) catch_mount();
color("Orange") translate([explode, 0, 0]) catch_lower();
