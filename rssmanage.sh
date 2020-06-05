#!/bin/bash

FEEDTITLE="iserv aufgaben"
RSSLINKTO="https://schulserver-xyz.tld/iserv/exercise"
FEEDIMAGEURL="https://coolimagehosting.tld/logo.png"
FEEDDESCRIPTION="rss feed for iserv exercises"
RSSFILE="/SOME/DIRECTORY/YOUR/WEBSERVER/HOSTS/aufgabenfeed.rss"
RSSDATE="$(date +%a,-%d-%b-%Y-%T-%z | sed -e 's/-/ /g')"

insertnewitem() {
  ITEMTITLE=""$(date +%H:%M)" "$1""
  ITEMCONTENT="Neue I-Serv Aufgabe: "$1""
  ITEMLINK="$2"
  ENCLURL="https://coolimagehosting.tld/enclosure-image.png"
  ENCLLEN="1234"
  ENCLMIME="image/jpeg"
  sed -i '/<\/lastBuildDate>/a\\t<item>\n\t\t<title>'"$ITEMTITLE"'<\/title>\n\t\t<guid isPermaLink=\"false\">'"$(date +%s)"'<\/guid>\n\t\t<link>'"$ITEMLINK"'<\/link>\n\t\t<description><![CDATA[<p>'"$ITEMCONTENT"'<\/p>]]><\/description>\n\t\t<enclosure url="'"$ENCLURL"'" length="'"$ENCLLEN"'" type="'"$ENCLMIME"'"/>\n\t\t<pubDate>'"$RSSDATE"'</pubDate>\n\t<\/item>' "$RSSFILE"
  sed -i "s/<lastBuildDate>.*<\/lastBuildDate>/<lastBuildDate>$RSSDATE<\/lastBuildDate>/gi" "$RSSFILE"
}

rsscleanup() {
  # VERY hacky way to cleanup up rss items older than 3 days
  mapfile -t guids <<< "$(grep -oP '(?<=guid isPermaLink="false">).*(?=</guid>)' "$RSSFILE")"
  for guid in "${guids[@]}"; do
    if [ "$guid" -lt $(( $(date +%s) - 259200 )) ]; then # if older than 3 days
      linenum=$(grep -n "$guid" "$RSSFILE" | sed 's/:.*//gi')
      upperlim=$(( $linenum - 2 ))
      lowerlim=$(( $linenum + 5 ))
      sed -i ''"$upperlim"','"$lowerlim"'d' "$RSSFILE"
    fi
  done
}

updatefeed() {
  insertnewitem "$1" "$2"
  rsscleanup
}

createfeed() {
  echo "$RSSBOILERPLATE" > "$RSSFILE" || exit 1
  echo "created rss feed at "$RSSFILE""
}

RSSBOILERPLATE='<rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
<channel>
    <title>'"$FEEDTITLE"'</title>
    <link>'"$RSSLINKTO"'</link>
    <description>'"$FEEDDESCRIPTION"'</description>
    <image><url>'"$FEEDIMAGEURL"'</url>
    <link>'"$RSSLINKTO"'</link>
    <title>'"$FEEDTITLE"'</title>
    </image>
    <atom:link href='"$RSSLINKTO"' rel="self"/>
    <lastBuildDate>'"$RSSDATE"'</lastBuildDate>
	<item>
		<title>first entry</title>
		<link>https://127.0.0.1</link>
		<description>example content</description>
		<pubDate>'"$RSSDATE"'</pubDate>
	</item>
</channel>
</rss>'

case "$1" in
  create) createfeed ;;
  update) updatefeed "$2" "$3" ;;
  *) echo "args: create||update"
     exit 1 ;;
esac

