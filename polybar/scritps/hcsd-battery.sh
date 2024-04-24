while sleep 1; do

	####You can config this parameters
	#####################################################################################################
	host=$(hostname)
	batStatePath="/sys/class/power_supply/BAT0/status"
	batCapacityPath="/sys/class/power_supply/BAT0/capacity"
	warnPercent=15
	criticalPercent=10
	suspendSecs=30
	zntWarnTitle='Clitical battery state'
	zntWarnTxt='Connect charger'
	zntWarnIcon='/usr/share/icons/Adwaita/symbolic/status/battery-level-0-symbolic.svg'
	playWarnSound='/usr/lib/libreoffice/share/gallery/sounds/drama.wav'
	zntCriticalTitle='Clitical battery state'
	zntCriticalTxt="<b>$host</b> will go into suspend mode in $suspendSecs seconds"
	zntCriticalIcon='/usr/share/icons/Adwaita/symbolic/status/battery-level-0-symbolic.svg'
	playCriticalSound='/usr/lib/libreoffice/share/gallery/sounds/drama.wav'
	#####################################################################################################

	# Pleas, don't touch this 👇

	normalPercent=$(expr $warnPercent + 1)
	batState=$(/usr/bin/cat $batStatePath)
	batCapacity=$(/usr/bin/cat $batCapacityPath)

	if [[ $batState = "Charging" ]]; then
		warnState=0
	fi

	if [[ $batCapacity -le $warnPercent ]] && [[ $warnState -eq 0 ]] && [[ "$batState" != "Charging" ]]; then

		play -q "$playWarnSound" &

		notify-send -u critical -i "$zntWarnIcon" "$zntWarnTitle" "$zntWarnTxt"

		warnState=1

	fi

	if [[ $batCapacity -le $criticalPercent ]] && [[ "$batState" != "Charging" ]]; then

		play -q "$playCriticalSound" &

		notify-send -u critical -i "$zntCriticalIcon" "$zntCriticalTitle" "$zntCriticalTxt"

		for sec in $(seq $suspendSecs -1 1); do
			fst=$(/usr/bin/cat $batStatePath)

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

	echo "󰂄 %{F#F0C674}$batState: %{F#C5C8C6}$batCapacity%"
done
