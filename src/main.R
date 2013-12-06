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

# runApp('./', launch.browser=F) #Start the shiny application.

# Our test regions. 
sel.region.codes <- c('021')#c('019', '419', '021')
sel.year <- c('2009', '2009')
sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% sel.region.codes,]
child.regions <- un_regions4children_regions(sel.regions, UN_M.49_Regions)
sel.countries <- un_regions4children.countries(child.regions, UN_M.49_Countries)
sub.crime <- select.years.countries.crime(sel.year, sel.region.codes, 
                                          crime.data, UN_M.49_Regions, 
                                          UN_M.49_Countries)
sub.crime <- merge(sub.crime, UN_M.49_Countries, 
                   by.x='crmLocation', by.y='Name')

sub.countries.dp <- countries.dp.df[countries.dp.df$UN %in% as.integer(sel.countries$Code),]
sub.countries.dp$crmValue = NA
for(code in sub.crime$Code) {
  matching <- which(sub.countries.dp$UN == as.integer(code))
  sub.countries.dp[matching, 'crmValue'] = sub.crime[sub.crime$Code == code, 'crmValue']
}

sub.countries.dp[sub.countries.dp$NAME == 'Canada', 'crmValue'] = NA
choropleth <- ggplot(sub.countries.dp, aes(x=long, y=lat, group=group)) + 
  scale_fill_continuous('Rate Per 100,000', low='#C7E9C0', high='#114000') +
  geom_polygon(data=subset(sub.countries.dp, !is.na(crmValue)), aes(fill=crmValue)) + 
  geom_polygon(data=subset(sub.countries.dp, is.na(crmValue)), aes(fill=NA),
               linetype = 0, fill = "gray", alpha = 0.5) +
  xlab('Longitude') + ylab('Latitude') +
  coord_map()
print(choropleth)

choropleth.na <- ggplot(sub.countries.dp, aes(x=long, y=lat, group=group)) + 
  geom_polygon(data=subset(sub.countries.dp, is.na(crmValue)), aes(colour='NA'),
               linetype = 0, fill = "gray", alpha = 0.5)
print(choropleth.na)

##### OLD #######
# sub.countries.dp[sub.countries.dp$NAME == 'Canada', 'crmValue'] = NA
# sub.countries.dp.na <- sub.countries.dp[is.na(sub.countries.dp$crmValue),]
# sub.countries.dp.na$Color = 'white'
# sub.countries.dp <- sub.countries.dp[!is.na(sub.countries.dp$crmValue),]
# 
# choropleth <- ggplot(sub.countries.dp) + 
#   aes(long,lat,group=group, fill=crmValue) +
#   scale_fill_continuous('Rate Per 100,000', low='#C7E9C0', high='#114000') + 
#   geom_polygon() + 
#   geom_path(color="white", size=0.05) + 
#   coord_equal()
# choropleth <- choropleth + geom_polygon(data=sub.countries.dp.na, 
#                                         aes(x=long, y=lat, group=group, colour='UKN'), 
#                                         fill="gray", linetype='blank') 
# print(choropleth)
  

# print(choropleth + na.geoms + scale_colour_manual(values=c('white'='white', 'white'='white'), labels = c('UKN')))

# UN == Code 


############ SCRAP ##############
# Build a simple df of all of the countries and regions. 
# countries.and.regions <- UN_M.49_Countries[,]
# countries.and.regions$isRegion = F
# rgns <- UN_M.49_Regions[,c('Code', 'Name')]
# rgns$ISO_Alpha_3 <- NA
# rgns$isRegion <- T
# countries.and.regions <- rbind(countries.and.regions, rgns)

