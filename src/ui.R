library(shiny)

regions.names2codes <- UN_M.49_Regions$Code
names(regions.names2codes) <- UN_M.49_Regions$Name
checkboxGroupInput.args <- list('regions', 'Regions', regions.names2codes)


shinyUI(basicPage(
  headerPanel("Crime Rates by Country"),
  div(
    tabsetPanel(
      tabPanel('Plots',
               checkboxInput('enable.violin', label='Violin Plot', value=F),
               plotOutput('box.plot', width='1024px', height='768px'),
               plotOutput('trends.plot', width='1024px', height='768px')
      ),
      tabPanel('Map', 
               plotOutput('choropleth.map', width='1024px', height='768px')),
      tabPanel('Selections',
               sidebarPanel(
                 h2('Global Filters'),
                 h3('Crime Filters'),
                 h3('Year Filters'),
                 uiOutput('choose_years'),
                 uiOutput('choose_year'),
                 checkboxInput(inputId='ave.all.years', label='Average Years', value=T),
                 h3('Country Filters'),
                 do.call(checkboxGroupInput, checkboxGroupInput.args)
                ), 
               div(
                 tabsetPanel(
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
                    tabPanel('Selected Data',
                             h4("Data for Multiple Years"),
                             tableOutput('sel.yrs.data'),
                             h4("Data for Single Year"),
                             tableOutput('sel.yr.data')
                             )
                    ), #END tabsetPanel
                 class='span7'
               )
                 ) #END tabPanel
      ), #END tabsetPanel
    class='span12'
    ) #END div
  )) #END shinyUI
