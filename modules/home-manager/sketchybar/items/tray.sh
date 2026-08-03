#!/bin/bash

# Mirror the Stats menu-bar widgets (plus the system battery) into the bar.
#
# These used to be hardcoded as "Centrum sterowania,CPU_mini" and friends,
# which silently produced an empty tray on a rebuilt machine: the owner of a
# system item is named in the current UI language ("Control Center" vs
# "Centrum sterowania"), Stats' own items are owned by "Stats" rather than by
# Control Center, and each Stats item is suffixed with the widget style
# currently selected for that module (CPU_mini, CPU_line_chart, RAM, ...).
# Any of those changing breaks a hardcoded name with no error, so resolve
# whatever is actually on the menu bar at runtime instead.
#
# Requires Screen Recording permission; without it `default_menu_items`
# returns an error and no aliases are added.

menu_items=$(sketchybar --query default_menu_items 2>/dev/null \
  | grep '^[[:space:]]*"' \
  | sed -e 's/^[[:space:]]*"//' \
        -e 's/"[[:space:]]*,\{0,1\}[[:space:]]*$//' \
        -e 's/([0-9]\{1,\})$//')

first_match() {
  printf '%s\n' "$menu_items" | grep -m1 -E "$1"
}

tray_aliases=()
for pattern in \
  '^(Control Center|Centrum sterowania),Battery' \
  '^Stats,CPU' \
  '^Stats,GPU' \
  '^Stats,RAM' \
  '^Stats,Disk' \
  '^Stats,Network'
do
  name=$(first_match "$pattern")
  [ -n "$name" ] || continue
  sketchybar --add alias "$name" right --set "$name"
  tray_aliases+=("$name")
done

if [ "${#tray_aliases[@]}" -gt 0 ]; then
  stats_bracket=(
    background.color=$BACKGROUND_1
    background.border_color=$BACKGROUND_2
  )
  sketchybar --add bracket stats "${tray_aliases[@]}" \
             --set stats "${stats_bracket[@]}"
fi
