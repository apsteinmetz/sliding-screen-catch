#!/usr/bin/env bash
# Render cutaway PNGs of the assembled catch with OpenSCAD (Flatpak install).
set -e
cd "$(dirname "$0")"
OS="flatpak run org.openscad.OpenSCAD"
mkdir -p stl
for c in A B; do
  for p in mount catch; do
    $OS -o "$PWD/stl/cut_${c}_${p}.stl" -D "cut=\"$c\"" -D "part=\"$p\"" "$PWD/catch_section_view.scad"
  done
done
# Straight-on orthographic renders (no tilt, so they can be scaled exactly)
mkdir -p render
for c in A B; do
  $OS -o "$PWD/render/raw_${c}.png" -D "cut=\"$c\"" --imgsize=3000,4000 --projection=o \
      --colorscheme=Tomorrow --camera=0,0,0,0,0,0,100 --viewall --autocenter "$PWD/catch_section_view.scad"
done
# Crop, scale to 300 dpi actual size, add scale bars
python3 scale_cutaways.py
