#!/usr/bin/env bash
# shellcheck disable=SC2004,SC2317,SC2053,SC1090

## Author: Tommy Miland (@tmiland) - Copyright (c) 2024


######################################################################
####                dynamic wallpaper installer.sh                ####
####          Dynamic wallpaper install script for gnome          ####
####         Script to install dynamic wallpaper in gnome         ####
####                   Maintained by @tmiland                     ####
######################################################################

VERSION='1.0.0' # Must stay on line 14 for updater to fetch the numbers

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2024 Tommy Miland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#------------------------------------------------------------------------------#
if [[ $2 == "debug" ]]
then
  set -o errexit
  set -o pipefail
  set -o nounset
  set -o xtrace
fi

config_folder=$HOME/.dynamic_wallpaper_installer
cfg_sh_file=$config_folder/dynamic_wallpaper_installer_config.sh
cfg_file=$config_folder/dynamic_wallpaper_installer_config

config() {
  . "$cfg_sh_file"
}

install() {
  # Read hidden configuration file with entries separated by " " into array
  if [[ -f $cfg_file ]]
  then
    IFS=' ' read -ra cfg_array < "$cfg_file"
    # Light bg wallpaper
    light_wp="${cfg_array[0]}"
    # Dark bg wallpaper
    dark_wp="${cfg_array[1]}"
    # Wallpaper name
    wp_name="${cfg_array[2]}"
    # Wallpaper rendering
    wp_rendering="${cfg_array[3]}"
  else
    # Light bg wallpaper
    light_wp=
    # Dark bg wallpaper
    dark_wp=
    # Wallpaper name
    wp_name=
    # Wallpaper rendering
    wp_rendering=
  fi
  if ! [ -d "$config_folder" ]
  then
    mkdir -p "$config_folder"
  fi
  gbp_folder="$HOME"/.local/share/gnome-background-properties
  if [[ ! -d "$gbp_folder" ]]
  then
    mkdir -p "$gbp_folder"
  fi
  bg_folder="$HOME"/.local/share/backgrounds
  if [[ ! -d $bg_folder ]]
  then
    mkdir -p "$bg_folder"
  fi
  echo ""
  read -n1 -r -p "Dynamic background installer is ready to be installed, press any key to continue..."
  echo ""
  if [[ $(command -v 'git') ]]; then
    git clone https://github.com/tmiland/dynamic-wallpaper-installer.git "$HOME"/.dynamic_wallpaper_installer >/dev/null 2>&1
  else
    echo -e "${RED}${ERROR} This script requires git.\nProcess aborted${NC}"
    exit 0
  fi
  if [[ ! -d "$HOME"/.local/bin ]]
  then
    mkdir -p "$HOME"/.local/bin
  fi
  ln -sfn "$HOME"/.dynamic_wallpaper_installer/dynamic_wallpaper_installer.sh "$HOME"/.local/bin/dynamic_wallpaper_installer
  chown -R "$USER":"$USER" "$HOME"/.local/bin/dynamic_wallpaper_installer
  chmod +x "$HOME"/.dynamic_wallpaper_installer/dynamic_wallpaper_installer.sh
  chmod +x "$HOME"/.dynamic_wallpaper_installer/dynamic_wallpaper_installer_config.sh
  "$HOME"/.local/bin/dynamic_wallpaper_installer -c
  tee <<EOF > "$gbp_folder"/"$wp_name".xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
<wallpaper deleted="false">
  <name>$wp_name</name>
  <filename>$bg_folder/$light_wp</filename>
  <filename-dark>$bg_folder/$dark_wp</filename-dark>
  <options>$wp_rendering</options>
</wallpaper>
</wallpapers>
EOF
  cp -rp "$HOME"/.dynamic_wallpaper_installer/assets/debian/* "$bg_folder"/
  exit 0
}

uninstall() {
  if [ -d "$config_folder" ]
  then
    rm -rf "$gbp_folder"/"$wp_name".xml
    rm -rf "$config_folder"
    rm "$HOME"/.local/bin/dynamic_wallpaper_installer
    exit 0
  fi
}

usage() {
  # shellcheck disable=SC2046
  printf "Usage: %s %s [options]\\n" "" $(basename "$0")
  echo
  printf "  --config            | -c           run config dialog\\n"
  printf "  --install           | -i           install\\n"
  printf "  --uninstall         | -u           uninstall\\n"
  printf "\\n"
  echo
}

ARGS=()
while [[ $# -gt 0 ]]
do
  case $1 in
    --help | -h)
      usage
      exit 0
      ;;
    --install | -i)
      install
      ;;
    --uninstall | -u)
      uninstall
      exit 0
      ;;
    --config | -c)
      config
      exit 0
      ;;
    -*|--*)
      printf "Unrecognized option: $1\\n\\n"
      usage
      exit 1
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${ARGS[@]}"