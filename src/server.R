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
    
    if((yr[2] - yr[1]) == 0 || input$ave.all.years) {
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
    child.countries <- un_regions4children.countries(rbind(child.regions, sel.regions),
                                                     UN_M.49_Countries)
  }) 
  
  # Render the selected data. 
  output$sel.yrs.data <- renderTable({
    yrs <- input$years.range.slider
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    sel.regions <- rbind(sel.regions, un_regions4children_regions(sel.regions, UN_M.49_Regions))
    child.countries <- un_regions4children.countries(sel.regions,
                                                     UN_M.49_Countries)
    sub.crime <- select.years.countries.crime(yrs, child.countries, 
                                              crime.data, UN_M.49_Countries)
  })
  
  # Render the selected data for the single year.
  output$sel.yr.data <- renderTable({
    yrs <- selected.year(input)
    yrs <- c(yrs, yrs)
    
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    sel.regions <- rbind(sel.regions, un_regions4children_regions(sel.regions, UN_M.49_Regions))
    child.countries <- un_regions4children.countries(sel.regions,
                                                     UN_M.49_Countries)
    sub.crime <- select.years.countries.crime(yrs, child.countries, 
                                              crime.data, UN_M.49_Countries)
  })
  
  #Render a year scatter plot that displays the crime rates.
  output$box.plot <- renderPlot({
    cat('Rendering a box plot\n', file=stdout())
    if(!input$ave.all.years) {
      cat('Single Year to Average\n', file=stdout())
      sel.year <- selected.year(input)
      sel.year <- c(sel.year, sel.year)
    } else if(!is.null(input$years.range.slider)) {
      cat('Multiple Years to Average\n', file=stdout())
      sel.year <- input$years.range.slider
    } else {
      sel.year <- range(crime.data$crmYear)
    }
    
    cat('Extracting Regions and Countries\n', file=stdout())
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    sel.regions <- rbind(sel.regions, un_regions4children_regions(sel.regions, UN_M.49_Regions))
    child.countries <- un_regions4children.countries(sel.regions,
                                                     UN_M.49_Countries)
    sel.dev.child.countries <- dev.child.countries[dev.child.countries$Code %in% child.countries$Code,]
    sel.trans.child.countries <- trans.child.countries[trans.child.countries$Code %in% child.countries$Code,]
    
    
    cat('Extracting Crime Stats\n', file=stdout())
    sub.crime <- select.years.countries.crime(sel.year, child.countries, 
                                              crime.data, UN_M.49_Countries)
    sub.crime <- merge(sub.crime, UN_M.49_Countries, 
                       by.x='crmLocation', by.y='Name')
    
    cat('Setting Status', file=stdout())
    sub.crime$cntryStatus = 'Developed'
    if(dim(sub.crime[sub.crime$Code %in% sel.dev.child.countries$Code,])[1] > 0) {
      sub.crime[sub.crime$Code %in% sel.dev.child.countries$Code, 'cntryStatus'] = 'Developing'
    }
    if(dim(sub.crime[sub.crime$Code %in% sel.trans.child.countries$Code,])[1] > 0) {
      sub.crime[sub.crime$Code %in% sel.trans.child.countries$Code, 'cntryStatus'] = 'Transitioning'
    }
    
    plot <- ggplot(sub.crime, aes(factor(cntryStatus), crmValue)) +
      ggtitle(paste('Homicides Distribution vs Development State (', sel.year[1], '-', sel.year[2], ')', sep='')) + 
      ylab('Homicides (per 100,000)') + xlab('State')
    
    if(input$enable.violin) {
      plot <- plot + geom_violin()
    } else {
      plot <- plot + geom_boxplot()
    }
    print(plot)
  })
  
  #Render a trends plot to view the changes in crime over time. 
  output$trends.plot <- renderPlot({
    cat('Rendering a box plot\n', file=stdout())
    if(!input$ave.all.years) {
      cat('Single Year to Average\n', file=stdout())
      sel.year <- selected.year(input)
      sel.year <- c(sel.year, sel.year)
    } else if(!is.null(input$years.range.slider)) {
      cat('Multiple Years to Average\n', file=stdout())
      sel.year <- input$years.range.slider
    } else {
      sel.year <- range(crime.data$crmYear)
    }
    
    cat('Extracting Regions and Countries\n', file=stdout())
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    sel.regions <- rbind(sel.regions, un_regions4children_regions(sel.regions, UN_M.49_Regions))
    child.countries <- un_regions4children.countries(sel.regions,
                                                     UN_M.49_Countries)
    sel.dev.child.countries <- dev.child.countries[dev.child.countries$Code %in% child.countries$Code,]
    sel.trans.child.countries <- trans.child.countries[trans.child.countries$Code %in% child.countries$Code,]
    
    
    cat('Extracting Crime Stats\n', file=stdout())
    sub.crime <- select.years.countries.crime(sel.year, child.countries, 
                                              crime.data, UN_M.49_Countries)
    sub.crime <- merge(sub.crime, UN_M.49_Countries, 
                       by.x='crmLocation', by.y='Name')
    
    cat('Setting Status', file=stdout())
    sub.crime$cntryStatus = 'Developed'
    sub.crime$cntryColor = 'black'
    if(dim(sub.crime[sub.crime$Code %in% sel.dev.child.countries$Code,])[1] > 0) {
      sub.crime[sub.crime$Code %in% sel.dev.child.countries$Code, 'cntryStatus'] = 'Developing'
      sub.crime[sub.crime$Code %in% sel.dev.child.countries$Code, 'cntryColor'] = 'red'
    }
    if(dim(sub.crime[sub.crime$Code %in% sel.trans.child.countries$Code,])[1] > 0) {
      sub.crime[sub.crime$Code %in% sel.trans.child.countries$Code, 'cntryStatus'] = 'Transitioning'
      sub.crime[sub.crime$Code %in% sel.dev.child.countries$Code, 'cntryColor'] = 'yellow'
    }
    
    cat('Drawing Plot\n', file=stdout())
    plot <- ggplot(sub.crime, aes(x=crmYear, y=crmValue, group=cntryStatus)) + 
      ggtitle('Homicides by Year vs Development State') + 
      ylab('Homicides (per 100,000)') + xlab('Year') + 
      scale_color_manual('Country Status', values=c('black', 'red', 'orange'))
    plot <- plot + stat_summary(fun.y=mean, geom='line', size=2,
                                mapping=aes(colour = cntryStatus))
    print(plot)
  })
    
  ##### Rendering Plot Zone
  output$choropleth.map <- renderPlot({    
    cat('Generating Plot\n', file=stdout())
    if(!input$ave.all.years) {
      cat('Single Year to Average\n', file=stdout())
      sel.year <- selected.year(input)
      sel.year <- c(sel.year, sel.year)
    } else if(!is.null(input$years.range.slider)) {
      cat('Multiple Years to Average\n', file=stdout())
      sel.year <- input$years.range.slider
    } else {
      sel.year <- range(crime.data$crmYear)
    }
    
    # First get all of the selected countries. 
    cat('Extracting Regions and Countries\n', file=stdout())
    sel.regions <- UN_M.49_Regions[UN_M.49_Regions$Code %in% input$regions,]
    sel.regions <- rbind(sel.regions, un_regions4children_regions(sel.regions, UN_M.49_Regions))
    child.countries <- un_regions4children.countries(sel.regions,
                                                     UN_M.49_Countries)
    sel.dev.child.countries <- dev.child.countries[dev.child.countries$Code %in% child.countries$Code,]
    sel.trans.child.countries <- trans.child.countries[trans.child.countries$Code %in% child.countries$Code,]
    
    cat('Extracting Crime Stats\n', file=stdout())
    sub.crime <- select.years.countries.crime(sel.year, child.countries, 
                                              crime.data, UN_M.49_Countries)
    sub.crime <- merge(sub.crime, UN_M.49_Countries, 
                       by.x='crmLocation', by.y='Name')
    
    cat('Merge Crime With Map Data\n', file=stdout())
    sub.countries.dp <- countries.dp.df[!(countries.dp.df$NAME == 'Antarctica'),]
    sub.countries.dp$crmValue = NA
    sub.countries.dp$isDeveloping = F
    sub.countries.dp$isTransitioning = F
    for(code in sub.crime$Code) {
      matching <- which(sub.countries.dp$UN == as.integer(code))
      sub.countries.dp[matching, 'crmValue'] = mean(sub.crime[sub.crime$Code == code, 'crmValue'])
    }
    
    # Now loop another time and try to get rid of NA's by searching names instead of codes
    cat('Get Rid of Additional NAs\n', file=stdout())
    sub.countries.nas <- unique(subset(sub.countries.dp, is.na(crmValue))$NAME)
    sub.countries.nas <- sub.countries.nas[sub.countries.nas %in% child.countries$Name]
    for(name in sub.countries.nas) {
      matching <- which(sub.countries.dp$NAME == name)
      sub.countries.dp[matching, 'crmValue'] = mean(sub.crime[sub.crime$crmLocation == name, 'crmValue'])
    }
    
    # Now loop through and label countries as developing
    cat('Label Developing Countries.\n', file=stdout())
    for(code in sel.dev.child.countries$Code) {
      matching <- which(sub.countries.dp$UN == as.integer(code))
      sub.countries.dp[matching, 'isDeveloping'] = T
    }
    # Now loop through and label countries as transitioning
    cat('Label Transitioning Countries.\n', file=stdout())
    for(code in sel.trans.child.countries$Code) {
      matching <- which(sub.countries.dp$UN == as.integer(code))
      sub.countries.dp[matching, 'isTransitioning'] = T
    }
    
    cat('Plotting the Data.\n', file=stdout())
    choropleth <- ggplot(sub.countries.dp, aes(x=long, y=lat, group=group)) + 
      ggtitle("Homicide Rates") +
      scale_fill_continuous('Rate Per 100,000', low='#C7E9C0', high='#114000') +
      geom_polygon(data=subset(sub.countries.dp, !is.na(crmValue)), aes(fill=crmValue)) + 
      geom_polygon(data=subset(sub.countries.dp, is.na(crmValue)), aes(fill=NA),
                   linetype = 0, fill = "gray", alpha = 0.5) +
      xlab('Longitude') + ylab('Latitude') + coord_map()
    if(dim(subset(sub.countries.dp, isDeveloping))[1] > 0) {
      choropleth <- choropleth + 
        geom_path(data=subset(sub.countries.dp, isDeveloping), 
                  color='red', width=0.125)
        
    }
    if(dim(subset(sub.countries.dp, isTransitioning))[1] > 0) {
      choropleth <- choropleth + 
        geom_path(data=subset(sub.countries.dp, isTransitioning), 
                  color='yellow', width=0.125)
      
    }
    print(choropleth)
    cat('Done\n', file=stdout())
  })
})

# Extract the selected year. 
selected.year <- function(input) {
  yr <- input$years.range.slider  
  sel.year = yr[1]
  if(((yr[2] - yr[1]) != 0) && !input$ave.all.years) {
    sel.year = input$year.val.slider  
  }
  
  return(sel.year)
}

