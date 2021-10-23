# installr::install.Rtools()

if (!require(devtools)) {
  install.packages('devtools', repos = "http://cran.us.r-project.org")
}
devtools::install_github('ropensci/gtfsr')

library(gtfsr)
library(rgdal)


setwd("C://Users//jessm//OneDrive//Documents//Columbia University//Fall 2019//STAT 5291 - Advanced Data Analysis//Project//Stops In Census Tract//Data//LA")

chicagoGTFS <- import_gtfs("gtfsBus.zip", local = TRUE)
chicagoStopLocations <- chicagoGTFS$stops_df
chicagoStops <- chicagoStopLocations[, c('stop_lon', 'stop_lat')]


spdf <- SpatialPointsDataFrame(coords = chicagoStops, data = chicagoStopLocations,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

chicagoCensusTract <- readOGR("LABoundariesCensusTracts2010.geojson", layer = "LABoundariesCensusTracts2010")

proj4string(spdf)
proj4string(chicagoCensusTract)

plot(chicagoCensusTract)
plot(spdf, col="red" , add=TRUE)

res <- over(spdf, chicagoCensusTract)
head(res)
chicagoCountOfStopsInCensusTract <- table(res$name) # count points

write.csv(chicagoCountOfStopsInCensusTract,"LA_CountOfBusStopsInCensusTract.csv", row.names = FALSE)

# typeof(chicagoCensusTract)
# 
# summary(chicagoCensusTract)
# class(chicagoCensusTract)
# names(chicagoCensusTract)
# head(chicagoCensusTract)
# plot(chicagoCensusTract)