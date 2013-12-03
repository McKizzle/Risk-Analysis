# R Script that takes all of the CSV data calls the proper scripts and dumps it to an sqlite database.
rm(list=ls())

# Set the working directory
cddir <- tryCatch({
  setwd('./src/')
}, error=function(w) {
  cat("No need to set the working directory to the source folder.\n")
})
rm(cddir)

source("./utils/helpers.R")
source("./utils/dump2arr.R")

llibrary('ISOcodes')

llibrary('rgdal') #gSimplify 
llibrary('maptools')
llibrary('ggplot2') 
llibrary('plyr')

# get the countries in the UN_M ISO and extract teh set of countries that match
# the map_data countries. 
data("UN_M.49_Countries")
data("UN_M.49_Regions")

# Build a simple df of all of the countries and regions. 
countries.and.regions <- UN_M.49_Countries[,]
countries.and.regions$isRegion = F
rgns <- UN_M.49_Regions[,c('Code', 'Name')]
rgns$ISO_Alpha_3 <- NA
rgns$isRegion <- T
countries.and.regions <- rbind(countries.and.regions, rgns)

# Lets aquire the countries from the shapefiles I downloaded from the internet.
countries <- readOGR(dsn='../data/mapdata/TM_WORLD_BORDERS-0.3/', layer='TM_WORLD_BORDERS-0.3')
nc <- length(rownames(countries@data))

# Associate the country ID's to the data. 
countries@data$id <- rownames(countries@data) 

# Create a simplified map for ggplot to improve the plotting speed. 
countries.dp <- gSimplify(countries, 0.273, topologyPreserve=T)
countries.dp.points <- fortify(countries, region='id')
countries.dp.df <- join(countries.dp.points, countries@data, by='id')

# Create a complex map for ggplot to generate a pretty plot. 
countries.points <- fortify(countries, region='id')
countries.df <- join(countries.points, countries@data, by='id')

ggplot(countries.dp.df) + 
  aes(long,lat,group=group,fill=NAME) +
  geom_polygon() + 
  geom_path(color="white") +
  coord_equal()


# UN == Code 



