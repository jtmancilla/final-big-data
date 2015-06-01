#! /bin/bash
# $1: Directorio donde bajan los datos
# $2: Directorio spool donde esta escuchando Flume
# $3: Segundos entre que se acaba de procesar un archivo y se checa si hay nuevos

if [ -z "$3" ]
then
    wait=5
else
    wait=$3
fi

echo "wait = " $wait "sec"

while true
    do
	./process_one.sh $1 $2
	sleep $wait
    done
