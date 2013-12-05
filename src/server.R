library(shiny)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {  
  # Allow the user to subset the year range to use.
  output$choose_years <- renderUI({
    crmYearRange <- range(crime.data$crmYear)
    sliderInput('years.range.slider', 'Years', crmYearRange[1], crmYearRange[2], 
                value=crmYearRange, format="####", step=1)
  })
  
  # Allow the user to select a single year of the range. 
  output$choose_year <- renderUI({
    yr <- input$years.range.slider
    
    if((yr[2] - yr[1]) == 0) {
      #p(paste(yr[1], " to ", yr[2], " is an invalid range.", sep=""))
    } else {
      sliderInput('year.val.slider', 'Year', yr[1], yr[2], 
                  floor(yr[1] + (yr[2] - yr[1]) / 2), 
                  format="####", step=1
                  )
    }
  })
      
  # Render a data frame of the selected year range and teh selected year. 
  output$year.range <- renderTable({
    yr <- input$years.range.slider  
    sel.year <- selected.year(input)
    data.frame(min=yr[1], max=yr[2], 
               selected=sel.year)
    
    })
  
  # Render data.frame of selected regions. 
  output$sel.regions <- renderTable({
    UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions, ]
  })

  # Render data.frame of child regions
  output$sel.child.regions <- renderTable({
    # Extract all of the regions that where inadvertantly selecected. 
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    child.regions <- un_regions4children_regions(sel.regions, UN_M.49_Regions)
    
    child.regions[!(child.regions$Code %in% sel.regions$Code),]
  })
  
  # Render data.frame of child countries. 
  output$sel.child.countries <- renderTable({
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    child.regions <- un_regions4children_regions(sel.regions, UN_M.49_Regions)
    child.countries <- un_regions4children.countries(child.regions, 
                                                     UN_M.49_Countries)
  }) 
  
  # Render the selected data. 
  output$sel.yrs.data <- renderTable({
    yrs <- input$years.range.slider
    crime.sub <- select.years.countries.crime(yrs, input$regions, 
                                              crime.data, UN_M.49_Regions, 
                                              UN_M.49_Countries)
  })
  
  # Render the selected data for the single year.
  output$sel.yr.data <- renderTable({
    yr <- selected.year(input)
    yr <- c(yr, yr)
    
    crime.sub <- select.years.countries.crime(yr, input$regions, 
                                              crime.data, UN_M.49_Regions, 
                                              UN_M.49_Countries)
  })
  
  
  ##### Rendering Plot Zone ####
  output$data.map <- renderPlot({
    datamap <- ggplot(countries.dp.df) + 
      aes(long,lat,group=group,fill=NAME) +
      geom_polygon() + 
      geom_path(color="white") +
      coord_equal()
    print(datamap)
#     plot(countries.dp)
  })
})

# Extract the selected year. 
selected.year <- function(input) {
  yr <- input$years.range.slider  
  sel.year = yr[1]
  if((yr[2] - yr[1]) != 0) {
    sel.year = input$year.val.slider  
  }
  
  return(sel.year)
}

