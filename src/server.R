library(shiny)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  output$choose_year <- renderUI({
    yr <- input$years.range.slider
    sliderInput('year.val.slider', 'Year', yr[1], yr[2], 
                floor(yr[1] + (yr[2] - yr[1]) / 2), format="####")
  })
  
  sel.regions <- reactive({ 
    input$regions
    })
  
  output$year.range <- renderTable({
    data.frame(min=input$years.range.slider[1], max=input$years.range.slider[2], 
               selected=input$year.val.slider)
    
    })
    
  output$sel.regions <- renderTable({
    UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions, ]
  })
  
  output$sel.child.regions <- renderTable({
    # Extract all of the regions that where selected. 
    children <- un_regions4children(
      UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
      )
    
    UN_M.49_Regions[UN_M.49_Regions$Code %in% children,]
  })
  
  output$sel.child.countries <- renderTable({
#     children <- un_regions4children(
#       UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
#     )
#     all.regions <- rbind(UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,],
#                          UN_M.49_Regions[UN_M.49_Regions$Code %in% children,])
#     children <- un_regions4children(all.regions)
#     UN_M.49_Countries[UN_M.49_Countries$Code %in% children, ]
    un_regions4children.countries(input$regions, UN_M.49_Regions, UN_M.49_Countries)
  })
})
