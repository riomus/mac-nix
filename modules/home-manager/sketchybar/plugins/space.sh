#!/bin/bash

update() {
  source "$CONFIG_DIR/colors.sh"
  COLOR=$BACKGROUND_2
  if [ "$SELECTED" = "true" ]; then
    COLOR=$ACCENT_COLOR
  fi
  sketchybar --set $NAME icon.highlight=$SELECTED \
                         label.highlight=$SELECTED \
                         background.border_color=$COLOR
}

set_space_label() {
  sketchybar --set $NAME icon="$@"
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    yabai -m space --destroy $SID
  else
    if [ "$MODIFIER" = "shift" ]; then
      SPACE_LABEL="$(osascript -e "return (text returned of (display dialog \"Give a name to space $NAME:\" default answer \"\" with icon note buttons {\"Cancel\", \"Continue\"} default button \"Continue\"))")"
      if [ $? -eq 0 ]; then
        if [ "$SPACE_LABEL" = "" ]; then
          set_space_label "${NAME:6}"
        else
          set_space_label "${NAME:6} ($SPACE_LABEL)"
        fi
      fi
    else    
    typeset desktophash
    typeset hashmodifier
    desktophash[1]=18
    desktophash[2]=19
    desktophash[3]=20
    desktophash[4]=21
    desktophash[5]=23
    desktophash[6]=22
    desktophash[7]=26
    desktophash[8]=28
    desktophash[9]=25
    desktophash[10]=29
    desktophash[11]=18
    desktophash[12]=19
    desktophash[13]=20
    desktophash[14]=21
    MODIFIER=', option down'
    hashmodifier[11]=${MODIFIER}
    hashmodifier[12]=${MODIFIER}
    hashmodifier[13]=${MODIFIER}
    hashmodifier[14]=${MODIFIER}
    desktopkey=${desktophash[$SID]}
    picked_modifier=${hashmodifier[$SID]:-''}
    command="tell application \"System Events\" to key code $desktopkey using {control down $picked_modifier}"
    echo $command
    osascript -e "$command"
    fi
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
