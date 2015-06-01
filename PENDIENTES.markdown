
ETL + Análisis
-----------------

1. Bajar datos periódicamente.
    + Ya jala sin mucho refinamiento.
    - Falta checar qué pasa cuando no hay datos.
2. Usar un spoolDir de Flume para subirlo a Hive.
    + Jala moderadamente bien.
    + Sube como Avro directo al HDFS, no usando el plugin de Kite porque es experimental.
    - Tiene bugs. Hay que checar la configuración para que sea estable.
3. Transformar en Pig o Spark.
    - Falta
4. Un ejemplo de analítica en Hive o Impala.
    + Creo que es mejor en Hive porque detecta automáticamente las bases, pero checar.


Falta
-----------------

0. Cambiar la estructura de carpetas de playground a algo definitivo. También hay que modificar la del HDFS. Pushear la imagen de docker.
    + Felipe
1. Robustecer y refinar el código de bajada de datos.
    + Felipe
2. Checar los errores que arroja Flume después de un rato (se queda sin memoria, no borra los archivos del spoolDir, etc)
    + Felipe
3. Orquestar con luigi.
4. Decidir qué análisis se va a hacer (algo simple).
    + Carlos
5. Transformar la base cruda en Pig o Spark a una base para análisis.
    + Carlos
6. Análisis en Hive.
    + Carlos
7. Caso de negocio + reporte + presentación ejecutiva.

