#!/bin/bash

hyprctl keyword monitor "eDP-1,disable"
hyprctl keyword monitor "HDMI-A-1,disable"

sleep 0.5

connected=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

if echo "$connected" | grep -q "HDMI-A-1"; then
  hyprctl keyword monitor "HDMI-A-1,2560x1440@143.94,0x0,1"
else
  hyprctl keyword monitor "eDP-1,preferred,0x0,1"
fi
