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

llibrary('rgdal')
llibrary('maptools')
llibrary('ggplot2') 
llibrary('plyr')

# llibrary('maps')
# llibrary('rgeos')
# llibrary('mapdata')
# llibrary('spatstat')

# get the countries in the UN_M ISO and extract teh set of countries that match
# the map_data countries. 
data("UN_M.49_Countries")
data("UN_M.49_Regions")
map.data <- map_data('world2') 

map.regions <- unique(map.data$region)
map.regions <- map.regions[which(map.regions %in% UN_M.49_Countries$Name)]

not.in.map.regions <- UN_M.49_Countries$Name[
  !(UN_M.49_Countries$Name %in% unique(map.data$region))
  ]
not.in.un.countries <- unique(map.data$region[
  !(unique(map.data$region) %in% UN_M.49_Countries$Name)  
  ])

# Lets aquire the countries from the shapefiles I downloaded from the internet.
countries <- readOGR(dsn='../data/mapdata/TM_WORLD_BORDERS-0.3/', layer='TM_WORLD_BORDERS-0.3')

# llibrary('shapefiles')
countries.dp <- gSimplify(spgeom=countries@data, tol=0.01)
# countries <- dp(points=countries@data, tolerance=2)

# countries@data$id <- rownames(countries@data)
# countries.points <- fortify(countries, region='id')
# countries.df <- join(countries.points, countries@data, by='id')
# 
# # Lets plot our countries now. 
# ggplot(countries.df) + 
#   aes(long,lat,group=group,fill=NAME) +
#   geom_polygon() + 
#   geom_path(color="white") +
#   coord_equal()

