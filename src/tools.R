#Contains all of the usefull functions needed by the program. 

# Takes in a UN_M.49_Regions dataframe from the ISOcodes package and a region 
# Code. It then returns all of the codes of the children associated with the 
# region. 
un_region4children <- function(region.code, regions) {
  region <- regions[regions$Code == region.code,]
  children <- strsplit(region$Children, ",")[[1]]
  return(children)  
}

# Takes in a set of codes and returns all of the rows associated with them.
# 
un_codes4rows <- function(codes, regions.countries) {
  return(0)    
}

# Return a list of checkboxes based on a dataframe. 
data.frame4checkboxInputs <- function(df, key.col, label.col, def.val=F) {
  for(row in df) {
    cat('--------------------\n')
    print(row)
  }
}

