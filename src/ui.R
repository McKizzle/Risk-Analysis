library(shiny)

s.year.min <- 1990
s.year.max <- 2010
years.slider.args <- list('years.range.slider', 'Years', s.year.min, s.year.max, 
                          value=c(s.year.min, s.year.max), step=1, 
                          format="####")
year.slider.args <- list('year.val.slider', 'Year', s.year.min, s.year.max, 
                         value = floor(s.year.min + (s.year.max - s.year.min)/2),
                         step=1, format="####")

regions.names2codes <- UN_M.49_Regions$Code
names(regions.names2codes) <- UN_M.49_Regions$Name
checkboxGroupInput.args <- list('regions', 'Regions', regions.names2codes)



# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Crime Rates by Country"),
  
  sidebarPanel(
    h2('Global Filters'),
    h3('Crime Filters'),
    h3('Year Filters'),
    do.call(sliderInput, years.slider.args),
    uiOutput('choose_year'),
    h3('Country Filters'),
    # Generate the regions to select. 
    do.call(checkboxGroupInput, checkboxGroupInput.args)
    ),
  
  mainPanel(
    tabsetPanel(
      tabPanel('Map', plotOutput('data.map')),
      tabPanel('Selected Filters',
               h4('Year Filter'),
               tableOutput('year.range'),
               h4('Regions Filters'),
               tableOutput('sel.regions'),
               h4('Child Regions'), 
               tableOutput('sel.child.regions'),
               h4('Child Countries'),
               tableOutput('sel.child.countries')
               ),
      tabPanel('Selected Data', tableOutput('sel.data'))
    ))
))
