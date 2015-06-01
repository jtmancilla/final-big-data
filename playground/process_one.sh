#! /bin/bash
# $1: Directorio de los datos
# $2: Directorio spool donde esta escuchando Flume

ls $1 > temp001

url=http://data.gdeltproject.org/events

curl -s $url/filesizes > all_links.txt

< all_links.txt grep -v -f temp001 \
    | head -1 | cut -d" " -f2 \
    | while read f;
	do
	    echo "Bajando  " $f "..."
	    curl -s $url/$f > $1/$f
	    echo "Mandando " $f " a carpeta spool..."
	    unzip -p $1/$f > $2/$f
	done

rm temp001
