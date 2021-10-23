# installr::install.Rtools()

if (!require(devtools)) {
  install.packages('devtools', repos = "http://cran.us.r-project.org")
}
devtools::install_github('ropensci/gtfsr')

library(gtfsr)
library(rgdal)


setwd("C://Users//jessm//OneDrive//Documents//Columbia University//Fall 2019//STAT 5291 - Advanced Data Analysis//Project//Stops In Census Tract//Data//Chicago")

chicagoGTFS <- import_gtfs("http://gtfs.s3.amazonaws.com/chicago-transit-authority_20160416_0123.zip")
chicagoStopLocations <- chicagoGTFS$stops_df
chicagoStops <- chicagoStopLocations[, c('stop_lon', 'stop_lat')]


spdf <- SpatialPointsDataFrame(coords = chicagoStops, data = chicagoStopLocations,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

chicagoCensusTract <- readOGR("ChicagoBoundariesCensusTracts2010.geojson", layer = "ChicagoBoundariesCensusTracts2010")

proj4string(spdf)
proj4string(chicagoCensusTract)

plot(chicagoCensusTract)
plot(spdf, col="red" , add=TRUE)

res <- over(spdf, chicagoCensusTract)
head(res)
chicagoCountOfStopsInCensusTract <- table(res$geoid10) # count points

write.csv(chicagoCountOfStopsInCensusTract,"Chicago_CountOfStopsInCensusTract.csv", row.names = FALSE)

# typeof(chicagoCensusTract)
# 
# summary(chicagoCensusTract)
# class(chicagoCensusTract)
# names(chicagoCensusTract)
# head(chicagoCensusTract)
# plot(chicagoCensusTract)