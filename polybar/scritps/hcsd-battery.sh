while sleep 1; do

	####You can config this parameters
	#####################################################################################################
	host=$(hostname)
	batStatusPath="/sys/class/power_supply/BAT0/status"
	batCapacityPath="/sys/class/power_supply/BAT0/capacity"
	warnPercent=15
	criticalPercent=10
	suspendSecs=30
	sndWarnTitle='Clitical battery status'
	sndWarnTxt='Connect charger'
	sndWarnIcon='/usr/share/icons/Adwaita/symbolic/status/battery-level-0-symbolic.svg'
	playWarnSound='/usr/lib/libreoffice/share/gallery/sounds/drama.wav'
	sndCriticalTitle='Clitical battery status'
	sndCriticalTxt="<b>$host</b> will go into suspend mode in $suspendSecs seconds"
	sndCriticalIcon='/usr/share/icons/Adwaita/symbolic/status/battery-level-0-symbolic.svg'
	playCriticalSound='/usr/lib/libreoffice/share/gallery/sounds/drama.wav'
	#####################################################################################################

	# Pleas, don't touch this 👇

	normalPercent=$(expr $warnPercent + 1)
	batStatus=$(/usr/bin/cat $batStatusPath)
	batCapacity=$(/usr/bin/cat $batCapacityPath)

	if [[ $batStatus = "Charging" ]]; then
		warnStatus=0
	fi

	if [[ $batCapacity -le $warnPercent ]] && [[ $warnStatus -eq 0 ]] && [[ "$batStatus" != "Charging" ]]; then

		play -q "$playWarnSound" &

		notify-send -u critical -i "$sndWarnIcon" "$sndWarnTitle" "$sndWarnTxt"

		warnStatus=1

	fi

	if [[ $batCapacity -le $criticalPercent ]] && [[ "$batStatus" != "Charging" ]]; then

		play -q "$playCriticalSound" &

		notify-send -u critical -i "$sndCriticalIcon" "$sndCriticalTitle" "$sndCriticalTxt"

		for sec in $(seq $suspendSecs -1 1); do
			fst=$(/usr/bin/cat $batStatusPath)

			echo "󰂄 %{F#F0C674}$fst: %{F#C5C8C6}$batCapacity% %{F#f80000}$sec"

			if [[ "$fst" != "Charging" ]] && [[ "$sec" -eq "1" ]]; then
				systemctl suspend
			fi

			if [[ "$fst" = "Charging" ]]; then
				echo "󰂄 %{F#F0C674}$fst: %{F#C5C8C6}$batCapacity%"
				break
			fi

			sleep 1
		done
	fi

	echo "󰂄 %{F#F0C674}$batStatus: %{F#C5C8C6}$batCapacity%"
done
