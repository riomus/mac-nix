#!/bin/bash

sketchybar --add alias "Stats,Battery" right --set "Stats,Battery";
sketchybar --add alias "Stats,RAM"  right --set "Stats,RAM" display=1,2;
sketchybar --add alias "Stats,GPU" right --set "Stats,GPU" display=1,2;
sketchybar --add alias "Stats,CPU" right  --set "Stats,CPU" display=1,2;
sketchybar --add alias "Stats,Disk" right   --set "Stats,Disk" display=1,2;
sketchybar --add alias "Stats,Network" right --set "Stats,Network" display=1,2;
stats_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  display=1,2
)
sketchybar --add bracket stats "Stats,Battery" "Stats,RAM" "Stats,GPU" "Stats,CPU" "Stats,Disk" "Stats,Network"   \
           --set stats "${stats_bracket[@]}"
           