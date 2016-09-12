library(googlesheets)
library(shiny)
library(ggplot2)
library(timeDate)
library(zoo)

#read and preprocess data
source('readAndPreProcessData.R')

shinyServer(
  function(input, output) {
    observeEvent(input$updateData, {
      source('readAndPreProcessData.R')
    })

    #Dynamically set input date
    output$dateControls <- renderUI({
      dateRangeInput('financeDateRange',
                     'Временной промежуток для анализа',
                     start = minDateInData,
                     end = maxDateInData)
    })

    #Prepare subsets based on input date's
#    dataToPlot <- reactive({
#      plotData <- finance_combined[(finance_combined$date >= input$financeDateRange[1]) & (finance_combined$date <= input$financeDateRange[2]), ]
#      plotData$cumulativeNetInflow <- cumsum(plotData$netInflow)
#        return(plotData)
#    })

    dataToPlot <- reactive({
      plotData <- finance_combined[(finance_combined$date >= input$financeDateRange[1]) & (finance_combined$date <= input$financeDateRange[2]), ]
      plotData$cumulativeNetInflow <- cumsum(plotData$netInflow)
      return(plotData)
    })
 
 #calculate data summeries
    dataSummaries <- reactive({
      plotData <- dataToPlot()
      totals <- data.frame(sum(plotData$inflow), sum(plotData$outflow), sum(plotData$netInflow))
      colnames(totals) <- c("inflow", "outflow", "netInflow")
      
      daysInPeriod <- as.numeric(input$financeDateRange[2] - input$financeDateRange[1])
      averages <- totals * (as.numeric(input$averagingPeriod) / daysInPeriod)
      return(list(totals = totals, averages = averages))
    })

   
    #Plot Inflow/Outflow
     output$transactions <- renderPlot({
      ggplot(dataToPlot()) +
      geom_bar(aes(date, netInflow, fill = transactionType), stat = "identity", position = "dodge") + 
      geom_line(aes(date, cumulativeNetInflow))
    })
    

   #sum totals and print them 
    output$summaryTotalsText <- renderText(
      paste(
        'Totals over the period from ',
        input$financeDateRange[1],
        ' to ',
        input$financeDateRange[2],
        ':',
        sep = ''
      )
    )

    output$summaryAverages <- renderTable({
      dataSummaries()$averages
    })

                                        #Tut budut otdelnye grafiki dla nas dwoich + budet forma dla vvoda v tablicu. Nuzno prorabotat'
    

    output$textPointer <- renderText( ' Продолжение следут, я замучалсяэ')
}
)
    
