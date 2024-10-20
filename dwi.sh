#!/usr/bin/env bash
# shellcheck disable=SC2004,SC2317,SC2053

## Author: Tommy Miland (@tmiland) - Copyright (c) 2024


######################################################################
####                           dwi.sh                             ####
####          Dynamic wallpaper install script for gnome          ####
####         Script to install dynamic wallpaper in gnome         ####
####                   Maintained by @tmiland                     ####
######################################################################

# VERSION='1.0.0' # Must stay on line 14 for updater to fetch the numbers

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

install() {
  config_folder=$HOME/.dwi
  cfg_sh_file=$config_folder/dwi_config.sh
  cfg_file=$config_folder/.dwi_config
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

  url=https://github.com/tmiland/Dynamic-Wallpaper-Installer/raw/refs/heads/main
  dwi_config_url=$url/dwi_config
  dwi_config_sh_url=$url/dwi_config.sh
  dwi_url=$url/dwi.sh
  download_files() {
    if [[ $(command -v 'curl') ]]; then
      curl -fsSLk "$dwi_config_url" > "${config_folder}"/dwi_config
      curl -fsSLk "$dwi_config_sh_url" > "${config_folder}"/dwi_config.sh
      curl -fsSLk "$dwi_url" > "${config_folder}"/dwi.sh
    elif [[ $(command -v 'wget') ]]; then
      wget -q "$dwi_config_url" -O "${config_folder}"/dwi_config
      wget -q "$dwi_config_sh_url" -O "${config_folder}"/dwi_config.sh
      wget -q "$dwi_url" -O "${config_folder}"/dwi.sh
    else
      echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
      exit 0
    fi
  }
  echo ""
  read -n1 -r -p "Dynamic background installer is ready to be installed, press any key to continue..."
  echo ""
  download_files
  ln -sfn "$HOME"/.dwi/dwi.sh "$HOME"/.local/bin/dwi
  chmod +x "$HOME"/.dwi/dwi.sh
  chmod +x "$HOME"/.dwi/dwi_config.sh
  "$HOME"/.local/bin/dwi -c
  tee <<EOF >> "$gbp_folder"/"$wp_name".xml
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
exit 0
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
    --config | -c)
      . "$cfg_sh_file"
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