import random as rnd
import time
import os
import luigi


class MainTask(luigi.Task):
    def complete(self):
	return False 
    
    def output(self):
        return luigi.LocalTarget('tmp/main_task_.txt')

    def requires(self):
	child_tasks = {"hive_query_1":1,"hive_query_2":2,"hive_query_3":3}
	tasks = []
        for item in child_tasks:
                print "Starting with task at:",item
                tasks.append(Export(child_tasks[item]))
        return tasks

    def run(self):
	
        # esto de aqui abajo es por el comentario (***)
        with self.output().open('w') as f:
            f.write("main task done mother fucker...")



class Export(luigi.Task):
    rseed = luigi.IntParameter(default=1)

    def complete(self):
        return False

    def output(self):
        """ (***)
	luigi.Task.output es una funcion que escribe en un archivo local como 
	acknowledgement que la tarea termino. Si este archivo existe, la tarea
	ya no se ejecuta.
	"""
	return luigi.LocalTarget('/tmp/log_hive_task_%s.txt' % self.rseed)


    def requires(self): # esta tarea no tiene dependencias en otras
	return None
	
    def run(self):
	if self.rseed == 1:
		query = "hive -e 'set hive.cli.print.header=true; SELECT MonthYear, ActionGeo_Long, ActionGeo_Lat, ActionGeo_FullName FROM gdelt limit 1000' | sed 's/[\t]/,/g' > data/map_hive_%d.csv"%self.rseed
	elif self.rseed == 2: # second query
		query = """hive -e "SELECT MonthYear, ActionGeo_Long, ActionGeo_Lat, ActionGeo_FullName,count(*) c_mx FROM gdelt WHERE EventRootCode = '19' AND ActionGeo_CountryCode = 'MX' GROUP BY MonthYear, ActionGeo_Long, ActionGeo_Lat, ActionGeo_FullName ORDER BY MonthYear" | sed 's/[\t]/,/g'  > /data/conflictos.csv"""
	elif self.rseed == 3:
		query = """hive -e "SELECT Year, Actor1Name, Actor2Name, Count FROM (SELECT Actor1Name, Actor2Name, Year, COUNT(*) Count, RANK() OVER(PARTITION BY YEAR ORDER BY Count DESC) rank FROM SELECT Actor1Name, Actor2Name,  Year FROM gdelt WHERE Actor1Name < Actor2Name and Actor1CountryCode != '' and Actor2CountryCode != '' and Actor1CountryCode!=Actor2CountryCode and ActionGeo_CountryCode='MX'), ( SELECT Actor2Name Actor1Name, Actor1Name Actor2Name, Year FROM gdelt WHERE Actor1Name > Actor2Name  and Actor1CountryCode != '' and Actor2CountryCode != '' and Actor1CountryCode!= Actor2CountryCode and ActionGeo_CountryCode='MX'), WHERE Actor1Name IS NOT null AND Actor2Name IS NOT null GROUP EACH BY 1, 2, 3 HAVING Count > 100 ) WHERE rank=1 ORDER BY Year" | sed 's/[\t]/,/g'  > /data/actores.csv"""
	output = os.popen(query)
	
	# esto de aqui abajo es por el comentario (***)
        with self.output().open('w') as f:
            f.write(output.read())


if __name__ == '__main__':
    luigi.run(main_task_cls=MainTask)



