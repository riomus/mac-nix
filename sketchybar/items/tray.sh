#!/bin/bash

sketchybar --add alias "Stats,Battery" right --set "Stats,Battery" alias.scale=0.8;
sketchybar --add alias "Stats,RAM"  right;
sketchybar --add alias "Stats,GPU" right;
sketchybar --add alias "Stats,CPU" right;
sketchybar --add alias "Stats,Disk" right;
sketchybar --add alias "Stats,Network" right;
stats_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
)
sketchybar --add bracket stats "Stats,Battery" "Stats,RAM" "Stats,GPU" "Stats,CPU" "Stats,Disk" "Stats,Network"   \
           --set stats "${stats_bracket[@]}"