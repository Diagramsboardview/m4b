#!/bin/bash

# License

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# SPDX-License-Identifier: GPL-2.0-or-later

# Network Access

# This script accesses the following networks.
# These are not illegal network sites.
# 1. https://diagramsboardview.com (to transmit collected information)
# 2. https://api.country.is (to check the network and obtain information)


# Collecting

# This script collects basic device information when a network connection is established.
# The collected information is used to gather performance data on genuine and third-party batteries.
# This data is then used to generate statistics on MacBook usage by model, battery type, and country.
#
# The information collected includes:
# Current network address, network country code
# MacBook serial number, MacBook architecture, MacBook system version
# Battery design capacity, battery serial number, battery maximum charge capacity, battery cycle count, battery voltage
#
# This collection is enabled by default, but you can opt out of it by using the -n off or --network off option when running the script.

function help()
{
    echo "	-h | --help : Display script options."
	echo -e "\n"
	echo "	-n | --network : Activate network mode. If this option is not used, it will default to the network option during execution."
	echo "	example) bash m4b.sh -n on"
	echo "	example) bash m4b.sh --network on"
	echo -e "\n"
	echo "	-k | --key : Record battery consumption on the Diagramsboardview.com account along with the CSV file. If this option is not used, it will not be activated by default, and the data will be recorded in a local CSV file."
	echo "	example) bash m4b.sh -k <my API key>"
	echo "	example) bash m4b.sh --key <my API key>"
	echo -e "\n"
	echo "	-r | --online-record : Activate online logging of battery consumption. This option must be used with the -k or --key option."
	echo "	example) bash m4b.sh -r on -k <my API key>"
	echo "	example) bash m4b.sh --online-record on --key <my API key>"
	echo -e "\n"
	echo "	-t | --threads-mode : To accelerate battery consumption, the script artificially creates 100 unnecessary processes."
	echo "	example) bash m4b.sh -t yes"
	echo "	example) bash m4b.sh --threads-mode yes"
	echo -e "\n"
	echo "	-c | --clear : Terminate unnecessary processes, except those required for OS operation, to measure battery consumption."
	echo "	example) bash m4b.sh -c"
	echo "	example) bash m4b.sh --clear"
    exit 0
}

#arguments
while [[ $# -gt 0 ]]
do
arg_key="$1"

case ${arg_key} in
    -h | --help)    help      ; shift   ;;
	--auto)		automatic_mode="1"	;	shift	;;
    -n | --network)   network_mode=${2}    ; shift 2   ;;
    -k | --key)    user_request_code=${2}     ; shift 2   ;;
    -r | --online-record)   online_record=${2}   ; shift 2 ;;
	-t | --threads-mode)	threads_mode=${2}	;	shift 2	;;
	-c | --clear)	clear_mode="yes"	;	shift	;;
    *)
    shift
    ;;
esac
done
#functions

function kill_process()
{
	pkill -u $(whoami)
}
function call_threads()
{
	if [ "${threads_mode}" == "yes" ]; then
		number=0
		echo "To increase CPU usage and deplete battery faster, we create threaded processes."
		while [ $number -le 100 ]
		do
		  yes > /dev/null &
		  ((number++))
		done
	else
		true
	fi
}
function clear_mode()
{
	if [ "${clear_mode}" == "yes" ]; then
		pkill -u $(whoami)
	else
		true
	fi
}
function online_record_auth_API()
{
	local fnc_datetime="${1}"
	local fnc_battery_percentage="${2}"
	local fnc_battery_current_caps="${3}" 
	local fnc_battery_count="${4}"
	local fnc_api_key="${user_request_code}"
	
	if [ "${auth_API_vaildate}" == "yes" ]; then
		record_battery "${fnc_datetime}" "${fnc_battery_percentage}" "${fnc_battery_current_caps}" "${fnc_battery_count}" "${fnc_api_key}"
	else
		false
	fi
}
#online record
function record_battery()
{
	local datetime="${1}"
	local battery_percentage="${2}"
	local battery_current_caps="${3}" 
	local battery_count="${4}"
	local api_key="${5}"
	
	curl -s \
	-d "datetime=${datetime}" \
	-d "btr_percent=${battery_percentage}" \
	-d "btr_cap=${battery_current_caps}" \
	-d "btr_cnt=${battery_count}" \
	-d "userkey=${api_key}"\
	-H "Content-Type: application/x-www-form-urlencoded" \
	-X POST https://diagramsboardview.com/collector/battery_health/battery_record.php -A "${user_agent_curl}" > /dev/null
}

#request code
if [ -z "${user_request_code}" ]; then
    user_request_code=""
else
	true
fi

if [ -z "${network_mode}" ]; then
	network_mode="on"
else
	true
fi

#default variables
Battery_count="1"
battery_measure=""
DATE4csv="$(date +"%Y-%m-%d_%H.%M.%S")"

user_agent_curl="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"

#create csv file
echo "Count,Datetime,Battery Percent,Current Capacity" > ./${DATE4csv}.csv

#check network connection
if [ "${network_mode}" == "on" ]; then
	net_chk=$(ping -c 3 diagramsboardview.com)
	if [ "$?" == "0" ]; then
		#user infomation collecting
		#Collecting device information

		#about device
		 #hardware information
		Current_mac_serial_number="$(system_profiler SPHardwareDataType | grep -a "Serial Number" | cut -d":" -f2 | sed 's/^ //g')"
		Currnet_mac_arch="$(system_profiler SPHardwareDataType | egrep -ai "Chip|intel" | cut -d":" -f2 | sed 's/^ //g')"
		 #software information
		Current_mac_sysver="$(system_profiler SPSoftwareDataType | grep -ai "System Version" | cut -d":" -f2 | sed 's/^ //g')"
			
		 #about battery
		Current_btr_designcaps="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"DesignCapacity\" =" | cut -d"=" -f2 | sed 's/ //g')"
		Current_btr_serial="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"Serial\" =" | cut -d"=" -f2 | sed -e 's/ //g' -e 's/\"//g')"

		Current_btr_maxcaps="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"AppleRawMaxCapacity\"" | cut -d"=" -f2 | sed 's/ //g')"
		Current_btr_cycle="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"CycleCount\" =" | cut -d"=" -f2 | sed 's/ //g')"
		Current_btr_voltage="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"Voltage\" =" | cut -d"=" -f2 | sed 's/ //g')"
		
		#get network information via country.is
		Current_ipaddress="$(curl -s https://api.country.is | sed -e 's/\"//g' -e 's/{//g' -e 's/}//g'| awk -F"," '{print $1}' | cut -d":" -f2)"
		Current_locale="$(curl -s https://api.country.is | sed -e 's/\"//g' -e 's/{//g' -e 's/}//g'| awk -F"," '{print $2}' | cut -d":" -f2)"

		#send request information to diagramsboardview.com
		curl -d "ipaddr=${Current_ipaddress}" \
		-d "countrycode=${Current_locale}" \
		-d "device_serial=${Current_mac_serial_number}" \
		-d "arch=${Currnet_mac_arch}" \
		-d "systemv=${Current_mac_sysver}" \
		-d "designcapacity=${Current_btr_designcaps}" \
		-d "battery_serial=${Current_btr_serial}" \
		-d "maxcap=${Current_btr_maxcaps}" \
		-d "cycle=${Current_btr_cycle}" \
		-d "voltage=${Current_btr_voltage}" \
		-d "userkey=${user_request_code}" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-X POST https://diagramsboardview.com/collector/battery_health/battery_info.php -A "${user_agent_curl}"
		
		if [ -z "${online_record}" ]; then
			true
		else
			if [ "${online_record}" == "on" ]; then
				if [ -z "${user_request_code}" ]; then
					echo "need User code, reference details using --help option."
					echo "Online record ERROR 2 : User API key missing"
					exit 1
				else
					#check request code from diagramsboardview.com
					get_api="$(curl -s -d "apikey=${user_request_code}" https://diagramsboardview.com/collector/user_api.php -A "${user_agent_curl}")"
					if [ "${get_api}" == "1" ]; then
						echo "There is no API key."
						echo "Online record ERROR 3 : API key unavailable"
						exit 1
					else
						#API info
						api_username="$(echo "${get_api}" | cut -d":" -f1)"
						api_type="$(echo "${get_api}" | cut -d":" -f2)"
						auth_API_vaildate="yes"
						
						echo "Activate online recording username : ${api_username} user apikey : ${user_request_code}"
					fi
				fi
			else
				echo "Online record ERROR 1 : wrong parameter"
			fi
		fi

	else
		echo "Network unavailable."
		echo "Network ERROR 1 : Network unavailable."
		exit 1
	fi
else
	echo "Network Disable Mode Keep processing."
	network_mode="off"
fi


#current battery percentage check
current_BATTERY_PERCENT="$(pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f1 -d';' | sed 's/\%//g')"
if [ "${current_BATTERY_PERCENT}" -lt "100" ]; then
	read -p "The battery percentage is ${current_BATTERY_PERCENT}%,keep doing it ? [Y/N] : " user_ans
	if [ "${user_ans}" == "[Yy]" ]; then
		true
	else
		read -p "Shall we wait until the battery is fully charged? [Y/N] : " user_ans
		if [ "${user_ans}" == "Y" ]; then
			echo "The script will enter standby mode until the battery reaches 100%. To exit, press Ctrl + C"
			while [ : ];
			do
				current_BATTERY_PERCENT="$(pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f1 -d';' | sed 's/\%//g')"
				if [ "${current_BATTERY_PERCENT}" == "100" ]; then
					break
				else
					false
				fi
				sleep 5
			done
		else
			echo "Script ERROR 1 : Battery isn't 100% charged"
			exit 1
		fi
	fi
else
	true
fi
	
#on working
while [ : ];
do
	[[ $(pmset -g ps | head -1) =~ "AC Power" ]] && AC=1 || AC=0
	if [ "${AC}" == "1" ]; then
		echo "Waiting charger disconnect"
		sleep 1
	else
		clear
		if [ "${clear_mode}" == yes ]; then
			echo "Execute the clear mode to terminate unnecessary processes."
			clear_mode
		else
			true
		fi
		if [ "${threads_mode}" == "yes" ]; then
			call_threads
		else
			true
		fi
		echo "Starting to measure battery consumption time"
		first_datetime="$(date +"%Y-%m-%d %H:%M:%S")"
		current_BATTERY_PERCENT="$(pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f1 -d';')"
		current_Battery_capacity="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"AppleRawCurrentCapacity\"" | cut -d"=" -f2 | sed 's/ //g')"
		echo "${Battery_count},${first_datetime},${current_BATTERY_PERCENT},${current_Battery_capacity}mAh" >> ./${DATE4csv}.csv
		echo "${first_datetime} Battery Health check Start, Current : ${current_BATTERY_PERCENT} ${current_Battery_capacity}mAh Count : ${Battery_count}"
		
		#network collecting cross-check
		if [ "${network_mode}" == "off" ]; then
			true
		else
			online_record_auth_API "${first_datetime}" "${current_BATTERY_PERCENT}" "${current_Battery_capacity}" "${Battery_count}"
		fi
		battery_measure="${current_BATTERY_PERCENT}"
		Battery_count="$(expr 1 + ${Battery_count})"
		while [ : ];
		do
			[[ $(pmset -g ps | head -1) =~ "AC Power" ]] && AC=1 || AC=0
			if [ "${AC}" == "1" ]; then
				echo "Macbook Charger is Connected"
				exit 1
			else
				true
			fi
			
			current_BATTERY_PERCENT="$(pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f1 -d';')"
			current_Battery_capacity="$(ioreg -w 0 -f -r -c AppleSmartBattery | grep -a "\"AppleRawCurrentCapacity\"" | cut -d"=" -f2 | sed 's/ //g')"
				if [ "${current_BATTERY_PERCENT}" == "${battery_measure}" ]; then
					true
				else
					Datetime="$(date +"%Y-%m-%d %H:%M:%S")"
					#record
					echo "${Datetime} Battery lowing ${battery_measure} -> ${current_BATTERY_PERCENT} ${current_Battery_capacity}mAh Count : ${Battery_count}"
					echo "${Battery_count},${Datetime},${current_BATTERY_PERCENT},${current_Battery_capacity}mAh" >> ./${DATE4csv}.csv
					
					#network collecting cross-check
					if [ "${network_mode}" == "off" ]; then
						true
					else
						online_record_auth_API "${Datetime}" "${current_BATTERY_PERCENT}" "${current_Battery_capacity}" "${Battery_count}"
					fi
					Battery_count="$(expr 1 + ${Battery_count})"
					battery_measure="${current_BATTERY_PERCENT}"
				fi
			sleep 5
		done
	fi
done
