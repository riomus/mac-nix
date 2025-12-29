#!/bin/bash

sketchybar --add alias "Centrum sterowania,Battery_battery" right --set "Centrum sterowania,Battery_battery";
sketchybar --add alias "Centrum sterowania,CPU_mini" right  --set "Centrum sterowania,CPU_mini";
sketchybar --add alias "Centrum sterowania,Network_speed" right --set "Centrum sterowania,Network_speed";
sketchybar --add alias "Centrum sterowania,RAM_mini"  right --set "Centrum sterowania,RAM_mini" display=1,2;
sketchybar --add alias "Centrum sterowania,GPU_mini" right --set "Centrum sterowania,GPU_mini" display=1,2;
sketchybar --add alias "Centrum sterowania,Disk_mini" right   --set "Centrum sterowania,Disk_mini" display=1,2;
stats_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
)
sketchybar --add bracket stats "Centrum sterowania,Battery_battery" "Centrum sterowania,RAM_mini" "Centrum sterowania,GPU_mini" "Centrum sterowania,CPU_mini" "Centrum sterowania,Disk_mini" "Centrum sterowania,Network_speed"   \
           --set stats "${stats_bracket[@]}"
           