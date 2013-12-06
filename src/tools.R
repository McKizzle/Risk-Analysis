#Contains all of the usefull functions needed by the program. 
# Terrible commenting!!

# Takes in a UN_M.49_Regions dataframe from the ISOcodes package and a region 
# Code. It then returns all of the codes of the children associated with the 
# region. 
#   @PARAM a sub data.frame of UN_M.49_Regions
un_regions4children <- function(regions) {
  children <- regions$Children
  children <- sapply(children, FUN=function(x) {strsplit(x[1], split=',')})
  children <- as.vector(unlist(children))
  children <- sapply(children, FUN=trim)
  
  return(children)
}

# Recursively aquire all of the regions.  
un_regions4children_regions <- function(sel.regions, regions) {
  children <- un_regions4children(sel.regions)
  child.regions <- regions[regions$Code %in% c(children),]
  
  if(dim(child.regions)[1] > 0) {
    child.regions <- rbind(child.regions, 
                           un_regions4children_regions(child.regions, regions))
    child.regions <- child.regions[!duplicated(child.regions),]
    return(child.regions)
  } else {
    return(sel.regions)
  }
}

# Extract all of the children countries associated with a set of regions. If there
# exists a child region then extract all of its children countries.
#   @PARAM a sub data.frame of UN_M.49_Regions
un_regions4children.countries <- function(sel.regions, countries) {
  children <- un_regions4children(sel.regions)
  return(countries[countries$Code %in% children, ])
}

# Extract a subset of a crime data.frame by the crime years. 
crime.subset.by.year <- function(yr.rng, crime.df) {
  return(crime.df[crime.df$crmYear %in% c(yr.rng[1]:yr.rng[2]),])
}

# Extract a subset of a crime data.frame by the crime regions (countries)
crime.subset.by.countries <- function (sel.countries, crime.df) {
  return(crime.df[crime.df$crmLocation %in% sel.countries$Name,])
}

# Select a subset from the crimes data.frame by year and a set of regions. 
select.years.countries.crime <- function(years.rng, sel.countries, 
                                         crime.df, countries) {
  crime.sub <- crime.subset.by.year(years.rng, crime.df)
  crime.sub <- crime.subset.by.countries(sel.countries, crime.sub)
  
  return(crime.sub)
}

# Removes leading and trailing spaces from a string.
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

