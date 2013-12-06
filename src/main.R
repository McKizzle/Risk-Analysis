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
llibrary('RColorBrewer')

# get the countries in the UN_M ISO and extract teh set of countries that match
# the map_data countries. 
data("UN_M.49_Countries")
data("UN_M.49_Regions")
developing.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% c('199', '432', '722'),]
trans.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% c('778'),]
dev.child.regions <- un_regions4children_regions(developing.regions, UN_M.49_Regions)
trans.child.regions <- un_regions4children_regions(trans.regions, UN_M.49_Regions)
dev.child.countries <- un_regions4children.countries(dev.child.regions, 
                                                 UN_M.49_Countries)
trans.child.countries <- un_regions4children.countries(trans.child.regions, 
                                                       UN_M.49_Countries)

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

crime.data <- unodc.homicides.df

runApp('./', launch.browser=T) #Start the shiny application.

# Our test regions. 
cat('Extracting Regions and Countries\n', file=stdout())
sel.region.codes <- c('001', '432', '722', '788')#c('019', '419', '021')
sel.year <- c('1995', '2011')
sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% sel.region.codes,]
sel.regions <- rbind(sel.regions, un_regions4children_regions(sel.regions, UN_M.49_Regions))
sel.countries <- un_regions4children.countries(sel.regions, UN_M.49_Countries)
sel.dev.child.countries <- dev.child.countries[dev.child.countries$Code %in% sel.countries$Code,]
sel.trans.child.countries <- trans.child.countries[trans.child.countries$Code %in% sel.countries$Code,]

cat('Extracting Crime Stats\n', file=stdout())
sub.crime <- select.years.countries.crime(sel.year, sel.countries, 
                                          crime.data, UN_M.49_Countries)
sub.crime <- merge(sub.crime, UN_M.49_Countries, 
                   by.x='crmLocation', by.y='Name')

cat('Merge Crime With Map Data\n', file=stdout())
sub.countries.dp <- countries.dp.df[!(countries.dp.df$NAME == 'Antarctica'),]
sub.countries.dp$crmValue = NA
sub.countries.dp$isDeveloping = F
sub.countries.dp$isTransitioning = F
for(code in sub.crime$Code) {
  matching <- which(sub.countries.dp$UN == as.integer(code))
  sub.countries.dp[matching, 'crmValue'] = mean(sub.crime[sub.crime$Code == code, 'crmValue'])
}

# Now loop another time and try to get rid of NA's by searching names instead of codes
cat('Get Rid of Additional NAs\n', file=stdout())
sub.countries.nas <- unique(subset(sub.countries.dp, is.na(crmValue))$NAME)
sub.countries.nas <- sub.countries.nas[sub.countries.nas %in% sel.countries$Name]
for(name in sub.countries.nas) {
  matching <- which(sub.countries.dp$NAME == name)
  sub.countries.dp[matching, 'crmValue'] = mean(sub.crime[sub.crime$crmLocation == name, 'crmValue'])
}

# Now loop through and label countries as developing
cat('Label Developing Countries.\n', file=stdout())
for(code in sel.dev.child.countries$Code) {
  matching <- which(sub.countries.dp$UN == as.integer(code))
  sub.countries.dp[matching, 'isDeveloping'] = T
}

# Now loop through and label countries as transitioning
cat('Label Transitioning Countries.\n', file=stdout())
for(code in sel.trans.child.countries$Code) {
  matching <- which(sub.countries.dp$UN == as.integer(code))
  sub.countries.dp[matching, 'isTransitioning'] = T
}

cat('Plotting the Data.\n', file=stdout())
crmValueRange <- range(unodc.homicides.df$crmValue)
colours <- c('#C7E9C0', '#A1D99B', '#74C476', '#31A354', '#006D2C')
choropleth <- ggplot(sub.countries.dp, aes(x=long, y=lat, group=group)) + 
  ggtitle("Homicide Rates") + 
#   scale_fill_gradientn('Rate Per 100,000', colours=colours) + 
  scale_fill_continuous('Rate Per 100,000', low='#C7E9C0', high='#114000') +
  geom_polygon(data=subset(sub.countries.dp, !is.na(crmValue)), aes(fill=crmValue)) + 
  geom_polygon(data=subset(sub.countries.dp, is.na(crmValue)), aes(fill=NA),
               linetype = 0, fill = "gray", alpha = 0.5) + 
  geom_path(data=subset(sub.countries.dp, isDeveloping), color='red', width=0.125) +
  geom_path(data=subset(sub.countries.dp, isTransitioning), color='yellow', width=0.125) +
  xlab('Longitude') + ylab('Latitude') +
  coord_map()
print(choropleth)

