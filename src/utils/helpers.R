######################### helpers.r ############################################
# This file contains all of the helper functions required to make this project
# easier to maintain. 
################################################################################

############################# Utility Functions ################################

#### read.data.table.big
# Wrapper function for the read.table function. Use this if you wish to load
# a huge file. The workflow of the function is as follows:
#   1. Attempt to load file.blob
#     a. If no file.blob then load file
#     b. write file to file.blob
#   2. Return the loaded file.
# @PARAM Takes the same parameters as read.table
read.data.table.big <- function(file, header = FALSE, sep = "", quote = "\"'",
                         dec = ".", row.names, col.names,
                         as.is = !stringsAsFactors,
                         na.strings = "NA", colClasses = NA, nrows = -1,
                         skip = 0, check.names = TRUE, fill = !blank.lines.skip,
                         strip.white = FALSE, blank.lines.skip = TRUE,
                         comment.char = "#",
                         allowEscapes = FALSE, flush = FALSE,
                         stringsAsFactors = default.stringsAsFactors(),
                         fileEncoding = "", encoding = "unknown", text) {
  #First check for the file.  
  file.blob <- paste(file, ".blob", sep="")
  blob.exists <- file.exists(file.blob)
  if(blob.exists) {
    cat("Found", file.blob, "\n", sep=" ")
    table.data <- readRDS(file.blob)
    if(!is.data.table(table.data)) {
      cat("Converting into a data.table and updating", file.blob, "\n", sep=" ")
      table.data <- as.data.table(table.data)
      saveRDS(table.data, file=file.blob, compress=TRUE)
    }
  } else {
    cat("Failed to locate", file.blob, ".", "Attemping to load", file, "and write it as binary file.\n")
    table.data <- read.table(file, header=header, sep=sep, quote=quote, dec=dec, 
                             row.names, col.names, 
                             as.is=as.is, na.strings=na.strings, 
                             colClasses=colClasses, nrows=nrows,
                             skip=skip, check.names=check.names, fill=fill, 
                             strip.white=strip.white, 
                             blank.lines.skip=blank.lines.skip, 
                             comment.char=comment.char, 
                             allowEscapes=allowEscapes, 
                             flush=flush, stringsAsFactors=stringsAsFactors, 
                             fileEncoding=fileEncoding, encoding=encoding, 
                             text)
    cat("Converting into a data.table\n")
    table.data <- as.data.table(table.data)
    saveRDS(table.data, file=file.blob, compress=TRUE)
    cat("Wrote to ", file.blob, " the data.table object.")
  }
  
  return(table.data)
}

#### load.library 
# This function automatically downloads and loads libraries that are needed from 
# the list of supplied repositories in the function.
#
# @param name is the name of a single library to install.
load.library <- function(pkg) {
  installed.libs <- installed.packages()
  exists <- which(installed.libs %in% pkg)
  if(length(exists) == 0) {
    cat("Library ", pkg ," not found on this computer. Installing from CRAN \n")
    install.packages(c(pkg))
  }
  else {
    cat(pkg, "found on this computer. No need to install the library.\n", sep=" ")
  }
  library(pkg, character.only=TRUE)
} #END load.library

#### llibrary
# Takes in a list of libraries and attempts to load them. If the libary cannot be
# found then the libary is installed. 
# @PARAM a list of libraries to load. 
llibrary <- function(libs=NULL) {
  lapply(libs, function(pkg) {
    installed.libs <- installed.packages()
    exists <- which(installed.libs %in% pkg)
    if(length(exists) == 0) {
      cat("Library", pkg ,"not found on this computer. Installing from CRAN \n"
          ,sep=" ")
      install.packages(pkg)
    }
    else {
      cat(pkg, "found on this computer. No need to install the library.\n", 
          sep=" ")
    }
    library(pkg, character.only=TRUE)
  })  
}




