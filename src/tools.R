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

# Get all of the children regions. 
un_regions4children_regions <- function(regions) {
  children <- un_regions4children(regions)
  child.regions <- regions[regions$Code == children,]
  
  if(dim(child.regions)[1] > 0) {
    return(
      rbind(child.regions, un_regions4children_regions(regions))
      )
  }
}

# Extract all of the children countries associated with a set of regions. If there
# exists a child region then extract all of its children countries.
un_regions4children.countries <- function(seed, regions, countries) {
  children <- un_regions4children(regions[regions$Code %in% seed,])
  all.regions <- rbind(regions[regions$Code %in% seed,],
                       regions[regions$Code %in% children,])
  children <- un_regions4children(all.regions)
  
  return(countries[countries$Code %in% children, ])
}

# Removes leading and trailing spaces from a string.
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

