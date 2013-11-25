# Set the working directory
prevwd = getwd()
cddir <- tryCatch({
  setwd('./utils/')
}, error=function(w) {
  cat("No need to set the working directory to the source folder.\n")
})
rm(cddir)

source("helpers.R")
llibrary('reshape')

crime.db.path <- "../../data/"
crime.db.name <- "violentcrimes.sqlite3"

crm.year.col <- 'crmYear'
crm.type.col <- 'crmType'
crm.isrt.col <- 'crmIsRate'
crm.locn.col <- 'crmLocation'
crm.valu.col <- 'crmValue'
crm.srce.col <- 'crmSource'

# Load Murder Rates from Different Sources for the Countries only. Lets only 
#   concern ourselves with general murders
crime.type = 'Homicide'

# 1: Load form FBI UCR
ucr.files <- c('StatesRate_Murder.csv')
ucr.files.path <- "../../data/orignal/UCR/Rates/"
data.source <- 'FBI UCR'


to.open <- paste(ucr.files.path, ucr.files[1], sep="")
command <- paste("./ucr2data.pl", "--file", to.open)
ucr.homicides.df <- read.csv(pipe(command), header=T, check.names=F)

ucr.homicides.df[[crm.type.col]] <- crime.type
ucr.homicides.df[[crm.isrt.col]] <- T
ucr.homicides.df[[crm.srce.col]] <- data.source
ucr.homicides.df <- melt(ucr.homicides.df, id=c("Year", crm.type.col, 
                                                crm.isrt.col, crm.srce.col))
colnames(ucr.homicides.df) <- c(crm.year.col, crm.type.col, crm.isrt.col, 
                                crm.srce.col, crm.locn.col, crm.valu.col)

# 2: Load from UNODC
unodc.files <- c('Homicide_Rates.csv') 
unodc.files.path <- c('../../data/orignal/UNODC/')
data.source <- 'UN Data'

to.open <- paste(unodc.files.path, unodc.files[1], sep="")
# command <- paste("./ucr2data.pl", "--file", to.open)
unodc.homicides.df <- read.csv(file=to.open, header=T, sep=',', quote="\"")

unodc.homicides.df$Count <- NULL
unodc.homicides.df$Source <- NULL
unodc.homicides.df$Source.Type <- NULL

unodc.homicides.df[[crm.type.col]] <- crime.type
unodc.homicides.df[[crm.isrt.col]] <- T
unodc.homicides.df[[crm.srce.col]] <- data.source
colnames(unodc.homicides.df) <- c(crm.locn.col, crm.year.col, crm.valu.col, 
                                 crm.type.col, crm.isrt.col, crm.srce.col)

# 3: Load form Eurostat
eurostat.files <- c('crim_gen_1_Data.csv')
eurostat.files.path <- c('../../data/orignal/Eurostat/')
data.source <- 'Eurostat'

to.open <- paste(eurostat.files.path, eurostat.files[1], sep="")
eurostat.homicides.df <- read.csv(file=to.open, header=T, sep=',', quote="\"")

eurostat.homicides.df$Flag.and.Footnotes <- NULL
eurostat.homicides.df$UNIT <- NULL
eurostat.homicides.df <- eurostat.homicides.df[eurostat.homicides.df$CRIM == 'Homicide',]
eurostat.homicides.df$CRIM <- NULL
row.names(eurostat.homicides.df) <- NULL

eurostat.homicides.df[[crm.type.col]] <- crime.type
eurostat.homicides.df[[crm.isrt.col]] <- F
eurostat.homicides.df[[crm.srce.col]] <- data.source
colnames(eurostat.homicides.df) <-  c(crm.year.col, crm.locn.col, crm.valu.col,
                                    crm.type.col, crm.isrt.col, crm.srce.col)

setwd(prevwd)








