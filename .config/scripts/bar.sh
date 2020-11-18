#!/bin/bash

# ~/bin/dwm-statusbar
# Adapted from w0ng status bar: https://github.com/w0ng/bin
# Adapted from jasonwryan status bar: https://bitbucket.org/jasonwryan/shiv/src/1ad5950c3108a4e5a9dcb78888a1ccfeb9252b45/Scripts/dwm-status?at=default

# Colour codes from dwm/config.h
#color0="\x01" # normal  
#color6="\x02" # green 
#color7="\x03" # blue 
#color1="\x01" # white-ish fg

color0="" # normal  
color6="" # green 
color7="" # blue 
color1="" # white-ish fg




#---separator                              
sp="$(echo -ne "${color0} ")" 
sp1="$(echo -ne "${color0} | ")" 
sp2="$(echo -ne "${color0}| ")"
sp3="$(echo -ne "${color0}|")"

print_song_info() {
  track="$(mpc current)"
  artist="${track%%- *}"
  title="${track##*- }"
  [[ -n "$artist" ]] && echo -e "${color6}ê${color0}${artist}${color7}${title} ${color0}|"
}

print_power() {
  status="$(cat /sys/class/power_supply/AC/online)"
  battery="$(cat /sys/class/power_supply/BAT0/capacity)"
  # timer="$(acpi -b | grep "Battery" | awk '{print $5}' | cut -c 1-5)"
  timer="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep hours | awk '{print $4}')"
  if [ "${status}" == 1 ]; then
    printf "AC ${battery}%%"
  else
    printf "BAT ${battery}%%(${timer})"
  fi
}

print_wifiqual() {
  wifiessid="$(/sbin/iwconfig 2>/dev/null | grep ESSID | cut -d: -f2)"
  wifiawk="$(echo $wifiessid | awk -F',' '{gsub(/"/, "", $1); print $1}')"
  wificut="$(echo $wifiawk | cut -d' ' -f1)"
  printf "SSID ${wificut}"
}

print_hddfree() {
  hddfree="$(df -Ph /dev/nvme0n1p4 | awk '$3 ~ /[0-9]+/ {print $4}')"
  echo -ne "${color6}  HDD  ${color0}${hddfree}"
}

 print_volume(){
    muted="$(pamixer --get-mute)"
    vol="$(pamixer --get-volume)"
    if [[ $muted == true ]]; then
      #red 2                                                
      printf "SND OFF"
    elif [[ $muted == false ]]; then
      #green 9
      printf "SND ${vol}"
    else
      #yellow6
      printf "SND ${muted}"
    fi
 }

print_light() {
  light="$(light -G)"
  printf "LIGHT ${light}"
}

print_datetime() {
  datetime="$(date "+%a %d %b %I:%M")"
  printf "${datetime}"
}

print_cputemp() {
  cputemp="$(sensors | grep Tctl | awk '{print $2}')"
    echo -ne "${color6}TEMP ${color0}${cputemp}  "

}

print_mem() {
  mem="$(free -h | grep Mem | awk '{print $4}')"
  printf "MEM ${mem}"
}

# cpu (from: https://bbs.archlinux.org/viewtopic.php?pid=661641#p661641)

while true; do
  # get new cpu idle and total usage
  eval $(awk '/^cpu /{print "cpu_idle_now=" $5 "; cpu_total_now=" $2+$3+$4+$5 }' /proc/stat)
  cpu_interval=$((cpu_total_now-${cpu_total_old:-0}))
  # calculate cpu usage (%)
  let cpu_used="100 * ($cpu_interval - ($cpu_idle_now-${cpu_idle_old:-0})) / $cpu_interval"

  # output vars
print_cpu_used() {
  printf "CPU ${cpu_used}%%"
}
 
  # Pipe to status bar, not indented due to printing extra spaces/tabs
  #xsetroot -name "$(print_power)${sp1}$(print_wifiqual)$(print_hddfree)${sp1}$(print_email_count)$(print_pacup)$(print_aurups)$(print_aurphans)${sp2}$(print_volume)${sp2}$(print_datetime)"
  echo "$(print_cpu_used)   $(print_mem)   $(print_light)   $(print_volume)   $(print_power)   $(print_wifiqual)   $(print_datetime)   " | dwm-status
  #xsetroot -name "$(print_song_info)$(print_power)${sp1}$(print_wifiqual)$(print_hddfree)${sp2}$(print_volume)${sp2}$(print_datetime)"

  # reset old rates
  cpu_idle_old=$cpu_idle_now
  cpu_total_old=$cpu_total_now
  # loop stats every 1 second
  sleep 5
 done
