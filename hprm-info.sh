#!/bin/sh
#==========================================================================================
# HighPoint RAID Manager info exporter
# Exports the xml with the info/status of all arrays and disks from HighPoint RAID Manager.
#==========================================================================================
case "$1" in
	"")
		echo "Error: IP missing" >&2
		echo "Usage: $(basename $0) {ip} {port} {path-to-credentials-file} {path-to-export-directory}" >&2
		exit 3
	;;
	*)
		hprmip=$1
	;;
esac

case "$2" in
	"")
		echo "Error: Port missing" >&2
		echo "Usage: $(basename $0) {ip} {port} {path-to-credentials-file} {path-to-export-directory}" >&2
		exit 3
	;;
	*)
		hprmport=$2
	;;
esac

case "$3" in
	"")
		echo "Error: Path to credentials-file missing" >&2
		echo "Usage: $(basename $0) {ip} {port} {path-to-credentials-file} {path-to-export-directory}" >&2
		exit 3
	;;
	*)
		. "$3"
		case "$username" in
			"")
				echo "Error: username=username missing in credentials-file" >&2
				echo "Usage: $(basename $0) {ip} {port} {path-to-credentials-file} {path-to-export-directory}" >&2
				exit 3
			;;
			*)
				hprmuser=$username
			;;
		esac
		case "$password" in
			"")
				echo "Error: password=password missing in credentials-file" >&2
				echo "Usage: $(basename $0) {ip} {port} {path-to-credentials-file} {path-to-export-directory}" >&2
				exit 3
			;;
			*)
				hprmpwd=$password
			;;
		esac
	;;
esac

case "$4" in
	"")
		exportdir=.
	;;
	*)
		exportdir=$4
	;;
esac

hprmsessionid=$(hprmsessionid=$(curl --silent "http://${hprmip}:${hprmport}/login.cgi" --data "func=Auth&user=${hprmuser}&pwd=${hprmpwd}&submit=Login"|grep -oPm1 "(?<=session_id>)[^<]+") && echo $hprmsessionid|tr '\r' ' ')
curl --silent "http://${hprmip}:${hprmport}/arrman.cgi?userid=${hprmsessionid}" -o $exportdir/hprm-info.xml
curl --silent -S "http://${hprmip}:${hprmport}/login.cgi" --data "func=Logout&userid=${hprmsessionid}" > /dev/null
