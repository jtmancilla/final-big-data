library(bigrquery)
library(dplyr)
library(ggplot2)
library(knitr)
#get_access_cred()

# Eventos que se registraron  en Mexico por MonthYear. (Todos los eventos).
project <- "massive-period-93602"  # ID proyecto

############### Eventos de mexico entre eventos totales. #####################

sql <- "select MonthYear, c_mx/c prop from (SELECT MonthYear, count(*) c, count(IF(ActionGeo_CountryCode = 'MX',1,NULL)) c_mx 
FROM [gdelt-bq:full.events] WHERE MonthYear > 0 
GROUP BY MonthYear
ORDER BY MonthYear)"

req.mx.full <- query_exec(sql, project = project)

# visualizamos
#head(req.mx.full)

ggplot(req.mx.full, aes(x=MonthYear,y=prop))  +
    geom_line() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme_minimal() +
    ggtitle("Registros de Mexico") +
    xlab("Fechas") +
    ylab("Reportos")


####################### CONFLICTOS EN MEXICO ################################

# conflictos o fightings 19
sql <- "SELECT MonthYear, ActionGeo_Long, ActionGeo_Lat, ActionGeo_FullName,
        count(*) c_mx
FROM [gdelt-bq:full.events]
WHERE EventRootCode = '19' AND ActionGeo_CountryCode = 'MX'
GROUP BY MonthYear, ActionGeo_Long, ActionGeo_Lat, ActionGeo_FullName
ORDER BY MonthYear;"


conflictos <- query_exec(sql, project = project)

head(conflictos)

#traemos la informacion de la base a un dataframe
conflictos.mx <- as.data.frame(conflictos)

################# MAPA ###############################
library(ggplot2)
library(ggmap)

mexico.map <- qmap(location = "Mexico", maptype = "terrain", color = "bw", zoom = 5)
mexico.map + geom_point(data = conflictos.mx, aes(x = ActionGeo_Long, y = ActionGeo_Lat, 
                                            size = c_mx), color = "red", alpha = 0.6)

############### ACTORES  MEXICO VS ##############################

sql <- "SELECT Year, Actor1Name, Actor2Name, Count FROM (
    SELECT Actor1Name, Actor2Name, Year, COUNT(*) Count, 
    RANK() OVER(PARTITION BY YEAR ORDER BY Count DESC) rank
    FROM 
    (
        SELECT Actor1Name, Actor2Name,  Year 
        FROM [gdelt-bq:full.events] 
        WHERE Actor1Name < Actor2Name and Actor1CountryCode != '' and 
        Actor2CountryCode != '' and Actor1CountryCode!=Actor2CountryCode 
        and ActionGeo_CountryCode='MX'),
    (
        SELECT Actor2Name Actor1Name, Actor1Name Actor2Name, Year 
        FROM [gdelt-bq:full.events] 
        WHERE Actor1Name > Actor2Name  and Actor1CountryCode != ''
        and Actor2CountryCode != '' and Actor1CountryCode!= Actor2CountryCode
        and ActionGeo_CountryCode='MX'),
        WHERE Actor1Name IS NOT null
        AND Actor2Name IS NOT null
        GROUP EACH BY 1, 2, 3
        HAVING Count > 100
    )
    WHERE rank=1
    ORDER BY Year"
    
actores <- query_exec(sql, project = project)
    
kable(head(actores,10))

