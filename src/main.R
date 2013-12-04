FLUSH_ENV <- F
RM_IGNORE <- c('countries.dp', 'countries.dp.points', 'countries.dp.df',
               'countries.points', 'countries.df')
FLUSH_IGNORE <- c('FLUSH_ENV', 'RM_IGNORE')

# R Script that takes all of the CSV data calls the proper scripts and dumps it to an sqlite database.
if(FLUSH_ENV) {
  lst <- ls()
  lst <- lst[which(!(lst %in% FLUSH_IGNORE))]
  rm(list=lst)
} else {
  lst <- ls()
  lst <- lst[which(!(lst %in% c(RM_IGNORE, FLUSH_IGNORE)))]
  rm(list=lst)
}

# Set the working directory
cddir <- tryCatch({
  setwd('./src/')
}, error=function(w) {
  cat("No need to set the working directory to the source folder.\n")
})
rm(cddir)

source("./utils/helpers.R")
source("./utils/dump2arr.R")
source("./tools.R")

llibrary('ISOcodes')
llibrary('shiny')
llibrary('rgdal') 
llibrary('rgeos')#gSimplify 
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

# Simplify the polygon data so the map quality increases. 
countries@data$id <- rownames(countries@data) 
if(length(RM_IGNORE[RM_IGNORE %in% ls()]) != length(RM_IGNORE)) { 
  system.time(countries.dp <- gSimplify(countries, 0.273, topologyPreserve=T))
  system.time(countries.dp.points <- fortify(countries, region='id'))
  system.time(countries.dp.df <- join(countries.dp.points, countries@data, by='id'))
  
  # Create a complex map for ggplot to generate a pretty plot. 
  system.time(countries.points <- fortify(countries, region='id'))
  system.time(countries.df <- join(countries.points, countries@data, by='id'))
}


runApp('./') #Start the shiny application.

# ggplot(countries.dp.df) + 
#   aes(long,lat,group=group,fill=NAME) +
#   geom_polygon() + 
#   geom_path(color="white") +
#   coord_equal()

# UN == Code 



