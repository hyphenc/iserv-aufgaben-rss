# iserv aufgaben rss

generiert einen rss feed für das iserv aufgabenmodul.

## benutzeranleitung

* `ISERV_INSTANCE_URL, USERNAME, PASSWORD, THIS_DIRECTORY_PATH` in `scrape.sh` anpassen-
* `RSSLINKTO, FEEDIMAGEURL, RSSFILE` in `rssmanage.sh` anpassen. sowie `ENCLURL, ENCLLEN, ENCLMIME` in der `insertnewitem()` funktion, damit rss feedreader das enclosure bild richtig anzeigen können.

> `ENCLLEN` ist die content length, kann man vom `Content-Length` Header abschreiben, den mime-type sonst mit 'view image info' in firefox herausfinden.

dann:
1. `rssmanage.sh createfeed` erstellt einen boilerplate rss feed in `$RSSFILE`
2. `scrape.sh login` ausführen, um die login cookies zu speichern
3. `scrape.sh fetch`
4. wahrscheinlich in den `crontab` packen

### automatisieren
> im crontab

```
# run every 10 minutes
# refresh login cookie at 12
*/10 * * * * <PATHTO scrape.sh> fetch
0 12 * * * <PATHTO scrape.sh> login
```

## etc

* aktuell wird die `CACHEFILE` nicht automatisch bereinigt.

* beim ersten mal sind - logischerweise - alle aufgaben erstmal 'neu'.

* license: gpl3

