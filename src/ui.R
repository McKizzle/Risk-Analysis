library(shiny)

s.year.min <- 1990
s.year.max <- 2010
years.slider.args <- list('years.range', 'Years', s.year.min, s.year.max, 
                          value=c(s.year.min, s.year.max), step=1, 
                          format="####")
year.slider.args <- list('year.val', 'Year', s.year.min, s.year.max, 
                         value = floor(s.year.min + (s.year.max - s.year.min)/2),
                         step=1, format="####")


# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Crime Rates by Country."),
  
  sidebarPanel(
    h2('Global Filters'),
    do.call(sliderInput, years.slider.args),
    do.call(sliderInput, year.slider.args),
    
    h3('Crime Filters'),
      
    h3('Year Filters'),
      
    h3('Country Filters')  
    ),
  
  mainPanel()
))
