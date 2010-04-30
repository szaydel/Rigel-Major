#!/bin/bash

local GT_RESET="\[$(tput sgr0)\]"  # Reset all attributes
local GT_BRIGHT="\[$(tput bold)\]"  # Set “bright” attribute
local GT_DIM="\[$(tput dim)\]"   # Set “dim” attribute
# The next line is problematic on some of my systems, so I have it commented out.
#local GT_UBAR="\[$(    tput set smul unset rmul)\]" # smul unset rmul :?: Set “underscore” (underlined text)\]" attribute
local GT_BLINK="\[$(tput blink)\]" # Set “blink” attribute
local GT_REVERSE="\[$(tput rev)\]"   # Set “reverse” attribute
local GT_HIDDEN="\[$(tput invis)\]" # Set “hidden” attribute

local BLACK="\[$(tput setaf 0)\]" #foreground to color #0 - black
local RED="\[$(tput setaf 1)\]" #foreground to color #1 - red
local GREEN="\[$(tput setaf 2)\]" #foreground to color #2 - green
local YELLOW="\[$(tput setaf 3)\]" #foreground to color #3 - yellow
local BLUE="\[$(tput setaf 4)\]" #foreground to color #4 - blue
local MAGENTA="\[$(tput setaf 5)\]" #foreground to color #5 - magenta
local CYAN="\[$(tput setaf 6)\]" #foreground to color #6 - cyan
local WHITE="\[$(tput setaf 7)\]" #foreground to color #7 - white
local DEFAULT="\[$(tput setaf 9)\]" #default foreground color

local BG_BLACK="\[$(tput setaf 0)\]" #background to color #0 - black
local BG_RED="\[$(tput setaf 1)\]" #background to color #1 - red
local BG_GREEN="\[$(tput setaf 2)\]" #background to color #2 - green
local BG_YELLOW="\[$(tput setaf 3)\]" #background to color #3 - yellow
local BG_BLUE="\[$(tput setaf 4)\]" #background to color #4 - blue
local BG_MAGENTA="\[$(tput setaf 5)\]" #background to color #5 - magenta
local BG_CYAN="\[$(tput setaf 6)\]" #background to color #6 - cyan
local BG_WHITE="\[$(tput setaf 7)\]" #background to color #7 - white
local BG_DEFAULT="\[$(tput setaf 9)\]" #default background color

local EM_BLACK="\[$(tput bold; tput setaf 0)\]" #foreground to color #0 - black
local EM_RED="\[$(tput bold; tput setaf 1)\]" #foreground to color #1 - red
local EM_GREEN="\[$(tput bold; tput setaf 2)\]" #foreground to color #2 - green
local EM_YELLOW="\[$(tput bold; tput setaf 3)\]" #foreground to color #3 - yellow
local EM_BLUE="\[$(tput bold; tput setaf 4)\]" #foreground to color #4 - blue
local EM_MAGENTA="\[$(tput bold; tput setaf 5)\]" #foreground to color #5 - magenta
local EM_CYAN="\[$(tput bold; tput setaf 6)\]" #foreground to color #6 - cyan
local EM_WHITE="\[$(tput bold; tput setaf 7)\]" #foreground to color #7 - white
local EM_DEFAULT="\[$(tput bold; tput setaf 9)\]" #default foreground color