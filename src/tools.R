#Contains all of the usefull functions needed by the program. 

# Takes in a UN_M.49_Regions dataframe from the ISOcodes package and a region 
# Code. It then returns all of the codes of the children associated with the 
# region. 
un_regions4children <- function(regions) {
  children <- regions$Children
  children <- sapply(children, FUN=function(x) {strsplit(x[1], split=',')})
  children <- as.vector(unlist(children))
  children <- sapply(children, FUN=trim)
  
  return(children)
}

un_regions4children.countries <- function(seed, regions, countries) {
  children <- un_regions4children(regions[regions$Code %in% seed,])
  all.regions <- rbind(UN_M.49_Regions[regions$Code %in% seed,],
                       UN_M.49_Regions[regions$Code %in% children,])
#   return(all.regions)
  children <- un_regions4children(all.regions)
  return(data.frame(chilren=children))
  countries[countries$Code %in% children, ]
  
  return(countries)
}

# Removes leading and trailing spaces from a string.
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

