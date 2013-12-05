library(shiny)

regions.names2codes <- UN_M.49_Regions$Code
names(regions.names2codes) <- UN_M.49_Regions$Name
checkboxGroupInput.args <- list('regions', 'Regions', regions.names2codes)


shinyUI(basicPage(
  headerPanel("Crime Rates by Country"),
  div(
    tabsetPanel(
      tabPanel('Other Stuff'),
      tabPanel('Map', plotOutput('data.map', width='100%')),
      tabPanel('Plots'),
      tabPanel('Selections',
               sidebarPanel(
                 h2('Global Filters'),
                 h3('Crime Filters'),
                 h3('Year Filters'),
                 uiOutput('choose_years'),
                 uiOutput('choose_year'),
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
                             tableOutput('sel.yrs.data'),
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


# # Define UI for miles per gallon application
# shinyUI(pageWithSidebar(
#   
#   # Application title
#   headerPanel("Crime Rates by Country"),
#   
#   
#   sidebarPanel(
#     h2('Global Filters'),
#     h3('Crime Filters'),
#     h3('Year Filters'),
#     uiOutput('choose_years'),
#     uiOutput('choose_year'),
#     h3('Country Filters'),
#     # Generate the regions to select. 
#     do.call(checkboxGroupInput, checkboxGroupInput.args)
#     ),
#   
#   mainPanel(
#     tabsetPanel(
#       tabPanel('Map', plotOutput('data.map')),
#       tabPanel('Selected Filters',
#                h4('Year Filter'),
#                tableOutput('year.range'),
#                h4('Regions Filters'),
#                tableOutput('sel.regions'),
#                h4('Child Regions'), 
#                tableOutput('sel.child.regions'),
#                h4('Child Countries'),
#                tableOutput('sel.child.countries')
#                ),
#       tabPanel('Selected Data', tableOutput('sel.data'))
#     ))
# ))
