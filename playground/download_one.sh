#! /bin/bash
# $1: Directorio de salida relativo al directorio actual

ls data > temp001

url=http://data.gdeltproject.org/events

curl -s $url/filesizes > all_links.txt

< all_links.txt grep -v -f temp001 \
    | head -1 | cut -d" " -f2 \
    | while read f;
	do
	    curl -s $url/$f > $1/$f
	done
