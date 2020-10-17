#!/bin/ksh

red="%{F#cd0000}"
yellow="%{F#cdcd00}"
black="%{F#000000}"

wifi_ssid=$(cat <<EOF
\$1 ~ "ieee80211" {
	split(\$0, chars, "");
	match(\$0, /join .* chan/);
	ssid = substr(\$0, RSTART + 5, RLENGTH - 10)
	gsub(/\"/, "", ssid)
	print ssid
}
EOF
)
wifi_sig=$(cat <<EOF
\$1 ~ "ieee80211" {
	split(\$0, chars, "");
	match(\$0, /[0-9]+%/);
	val=substr(\$0, RSTART, RLENGTH)
	if (val == "") {
		printf \$(NF - 9)
	} else {
		printf "%3d%%", val
	}
}
EOF
)

mem_fix=$(cat <<EOF
{
	split(\$3, real, "/")
	print "Mem: U: " real[2] " F: " \$6 " C: " \$8
}
EOF
)

temp_avg=$(cat <<EOF
BEGIN {
	count=0
	sum=0
}
{
	count++
	sum += \$1
}
END {
	b = sum / count
	printf("%d",b+=b<0?0:0.9)
}
EOF
)

# TODO check lengte and make sure we aren't wayy off base
wifi() {
	local w sig ssid
	w=$(ifconfig wlan | grep "ieee80211")
	ssid="$(echo "$w" | awk "${wifi_ssid}")"
	sig="$(echo "$w" | awk "${wifi_sig}")"
  printf "%s(%s)" "${ssid}" "${sig}"
}

beat() {
	local b
	b=$(echo "(($(date +'%s')+3600)%86400)/86.4" | bc)
	printf "%03d" "${b}"
}

hz() {
	local hz
	hz=$(apm -Pv | \
		awk \
		'{gsub(/\(/, "", $5); gsub(/\)/, "", $6); print $5 " " $6 " " $4}')
	printf "%s" "$hz"
}

mem() {
	local mem_info
	mem_info=$(top -n | grep Mem | awk "${mem_fix}")
	printf "%s" "${mem_info}"
}

temp() {
	local TMP
	# Average all the sensors
	TMP=$(sysctl hw.sensors | grep cpu | \
		awk -F= '{print $2}' | \
		awk "${temp_avg}")
	if [ $TMP -ge 85 ]; then
		printf "\\${red}%2d\\${black}°C" "${TMP}"
	else
		printf "%2d°C" "${TMP}"
	fi
}
battery() {
	local BATT BAR BATT_LINE
	if sysctl -n hw.product | grep -iq pine64; then
		pct=$(sysctl -n hw.sensors.cwfg0.percent0)
		pct=${pct%%.*}
		set -A batt_info $pct 0 0
	else
		set -A batt_info $(apm -alm)
	fi

	BATT=$((${batt_info[0]}/10))
	BAR="#"
	if [ "${batt_info[2]}" == "1" ] ; then
		BAR="+"
	fi

	BATT_LINE=""
	for i in $(jot 10); do
		if [ "$i" -le "$BATT" ]; then
			BATT_LINE="${BATT_LINE}${BAR}"
		else
			BATT_LINE="${BATT_LINE}-"
		fi
	done

	if [ $BATT -lt 3 ] && [ "${batt_info[2]}" == "0" ]; then
		BATT_LINE="${red}${BATT_LINE}${black}"
	fi

	if [ $BATT -lt 5 ] && [ "${batt_info[2]}" == "0" ]; then
		BATT_LINE="${yellow}${BATT_LINE}${black}"
	fi
	echo "${batt_info[0]}%"
}

vmm() {
	if pgrep -q vmd; then
		set -A running_vms $(vmctl status | grep running | awk '{print $NF"("$5")"}')
		echo -n "VMs: "
		for vm in "${running_vms[@]}"; do
			echo -n "${vm} "
		done
	else
		echo -n ""
	fi
}


function Battery {
	ADAPTER=$(/usr/sbin/apm -a)
	BPERCENT=$(/usr/sbin/apm -l)
	BMINUTES=$(/usr/sbin/apm -m)
	CHARGING=$(sysctl -n hw.sensors.acpibat0.raw0 | awk '{print $1}')

	if [ ${ADAPTER} = 0 ] ; then
		print -n "Batt: "
	elif [ ${ADAPTER} = 1 ] ; then
		print -n "AC: "
	else
		print -n "AC: "
	fi
	if [ ${BPERCENT} -gt 75 ] ; then
		print -n "${GREEN}${BPERCENT}%${COLOROFF}"
	elif [ ${BPERCENT} -gt 50 ] ; then
		print -n "${YELLOW}${BPERCENT}%${COLOROFF}"
	elif [ ${BPERCENT} -gt 25 ] ; then
		print -n "${ORANGE}${BPERCENT}%${COLOROFF}"
	else
		if [ $CHARGING = 2 ]; then
			print -n "${BPERCENT}%"
		else
			print -n "${RED}${REVERSE}${BPERCENT}${BATTERY}%${COLOROFF}"
		fi
	fi
	[[ "${BMINUTES}" != "unknown" ]] && print -n \
		" ($((${BMINUTES} / 60))h$((${BMINUTES} % 60))m)${COLOROFF}"
	[[ ${CHARGING} = 2 ]] && print -n " ${COLOROFF}charging"
}

function Clock {
	# local DATETIME=$(date "+%a %F %H:%M %Z")
  local DATETIME=$(date +'%a %d %b %H:%M')
	print -n "${COLOROFF}${DATETIME}"
}


function Display {
	local LIGHT=$(xbacklight | awk -F. '{print $1'})
	print -n "Display: ${LIGHT}%"
}


function Volume {
	local MUTE=$(sndioctl output.mute | awk -F '=' '{ print $2 }')
	local SPK="$(sndioctl output.level | awk -F '=' '{ print $2 * 100 }')%"
  print -n "Vol: "
	if [ "${MUTE}" = "1" ] ; then
		SPK="mute"
	else
		#print -pn "${GREEN}"
		print -n ""
	fi
	print -n "${SPK}${COLOROFF}"
}

while true ; do
  printf "  %s  |  %s  |  %s  |  CPU: %s  |  %s %s  |  WIFI: %s  |  %s\n" \
  "$(Battery)" "$(Display)" "$(Volume)" "$(temp)" "$(mem)" \
  "$(vmm)" "$(wifi)" "$(Clock)" | dwm-status
  sleep 5
done
