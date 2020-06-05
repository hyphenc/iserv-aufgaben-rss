#!/bin/bash
set -eu -o pipefail

ISERV_INSTANCE_URL="https://schulserver-xyz.tld"
USERNAME='user.name'
PASSWORD='plaintext password'
THIS_DIRECTORY_PATH="/home/USER/ABCXYZ/aufgabenscrape"
COOKIEFILE="./.iserv-cookies"
CACHEFILE="./.iserv-curled-html"

cd "$THIS_DIRECTORY_PATH"

if [ ! -f "$CACHEFILE" ]; then touch "$CACHEFILE"; fi

# acquire cookies
getcreds() {
	curl -s --cookie-jar "$COOKIEFILE" "$ISERV_INSTANCE_URL""/iserv/login_check" -d "_username="$USERNAME"" -d "_password="$PASSWORD"" -d '_remember_me=true'
}

update() {
	BASEINFOSTRING="$(curl -s --cookie "$COOKIEFILE" "$ISERV_INSTANCE_URL""/iserv/exercise?filter[status]=current" | grep -oP '<a href="'"$(sed 's;/;\\/;g' <<< "$ISERV_INSTANCE_URL")"'\/iserv\/exercise\/show\/[0-9]*">.*?<\/a>')"
	_TITLES="$(grep -oP '(?<=">).*?(?=</a>)' <<< "$BASEINFOSTRING")"
	_LINKS="$(grep -oP '(?<=<a href=").*?(?=">)' <<< "$BASEINFOSTRING")"
	
	mapfile -t titles <<< "$_TITLES"
	mapfile -t links <<< "$_LINKS"
	for ((i=0; i<${#links[@]}; i++)); do
		if ! grep -q "${links[i]}" "$CACHEFILE"; then
			echo "$(date) -- ${titles[i]} -- ${links[i]}" >> "$CACHEFILE"
			./rssmanage.sh update "${titles[i]}" "${links[i]}"
		fi
	done
}

case "$1" in
	login) getcreds ;;
	fetch) update ;;
esac
