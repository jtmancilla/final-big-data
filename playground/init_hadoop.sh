#! /bin/bash

# Crear la instancia
docker run -ti --name hadoop-pseudo-proyecto2 \
	   -v /Users/Felipe/data-science/final-big-data:/home/itam/localhost \
	   -p 2122:2122 -p 2181:2181 -p 39534:39534 -p 9000:9000 \
	   -p 50070:50070 -p 50010:50010 -p 50020:50020 -p 50075:50075 \
	   -p 50090:50090 -p 8030:8030 -p 8031:8031 -p 8032:8032 \
	   -p 8033:8033 -p 8088:8088 -p 8040:8040 -p 8042:8042 \
	   -p 13562:13562 -p 47784:47784 -p 10020:10020 -p 19888:19888 \
	   -p 8000:8000 -p 9999:9999 \
	   --net=host \
	   nanounanue/docker-hadoop
# ISSUE [SOLVED]: En algunas redes se necesita el --net=host

# Para tener el comando man
sudo apt-get install man-db

# Necesario para usar Flume
sudo ln -s /usr/lib/kite/kite-morphlines-* /usr/lib/flume-ng/lib
sudo ln -s /usr/lib/kite/lib/metrics* /usr/lib/flume-ng/lib
sudo ln -s /usr/lib/kite/lib/config-1.0.2.jar /usr/lib/flume-ng/lib
sudo ln -s /usr/lib/kite/lib/Saxon-HE-9.5.1-5.jar /usr/lib/flume-ng/lib
sudo ln -s /usr/lib/kite/lib/tika-* /usr/lib/flume-ng/lib

# Correr el contenedor si ya se había creado
docker start -ia hadoop-pseudo-proyecto

#---------------------------------------------------------------------------------------------------------------
# Crear las carpetas de prueba. Cuando esto quede, habrá que hacerlo en /etl etc, en lugar de /user/itam...
sudo -u hdfs hadoop fs -mkdir /user/itam
sudo -u hdfs hadoop fs -chown itam:itam /user/itam

#---------------------------------------------------------------------------------------------------------------
# Generar el esquema de los datos (desde playground)
curl http://gdeltproject.org/data/lookups/CSV.header.dailyupdates.txt > data/gdelt_headers.tsv
unzip -p data/raw/20130412.export.CSV.zip | cat data/gdelt_headers.tsv - > data/schema/20130412.export.CSV
kite-dataset csv-schema data/schema/20130412.export.CSV --class GDELT --delimiter "\t" -o data/schema/gdelt_raw20130412.avsc
# IMPORTANTE: Hay que cambiar el tipo de Actor1Geo_FeatureID y Actor2Geo_FeatureID a string manualmente y renombrarlo a gdelt.avsc.
# ISSUE: POR QUE AL LEER EL CSV DE 20130409 LEE PUROS NULLS??
# [SOLVED] Tiene que tener los headers para que lo lea! Para leer con Flume no hacen falta, así que no los ponemos después.

# Crear el dataset en el hive metastore (desde playground)
kite-dataset create dataset:hive:gdelt --schema data/schema/gdelt.avsc 

# El dataset queda en: /user/hive/warehouse/gdelt
hadoop fs -ls -R /user/hive

#---------------------------------------------------------------------------------------------------------------
# Probamos importar unos datos
#unzip -p data/raw/20130412.export.CSV.zip | cat data/gdelt_headers.tsv - > data/spool/20130412.export.CSV
#kite-dataset csv-import data/spool/20130412.export.CSV dataset:hive:gdelt --delimiter "\t"
#hadoop fs -ls -R /user/hive

# Podemos ver los datos en HIVE
#beeline -u jdbc:hive2://localhost:10000
#show tables;
#select * from gdelt limit 10;

# Borramos el dataset de pruebas (hay que crearlo de nuevo)
#kite-dataset delete dataset:hive:gdelt


#---------------------------------------------------------------------------------------------------------------
# Correr el agente de flume (desde playground)
# NOTA: Preferí usar un sink en Avro directo al HDFS en lugar de la cosa experimental con Kite
flume-ng agent -n GDELTAgent -Xmx300m --conf flume -f flume/gdelt-agent.conf

# Abrir otra conexión al contenedor (desde otra terminal)
docker exec -it hadoop-pseudo-proyecto /bin/zsh

# Correr el código que baja los datos y los mete al spoolDir (desde playground)
./process_background.sh data/raw data/spool 5

#---------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------









