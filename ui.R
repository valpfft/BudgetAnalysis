                                        #ui.R
shinyUI(fluidPage(
  titlePanel('Сумарный приход и уход'),

  sidebarPanel(
    helpText('Что-то, что поможет нам понять куда мы тратим деньги.'),

    uiOutput('dateControls'),

    br(),

    conditionalPanel(
      condition = "input.financePanels == 'panelInOut'",
      radioButtons('averagingPeriod',
                   'Выберите период для средней из:',
                   c('Daily' = 1,
                     'Weekly' = 7,
                     'TwoWeek' = 14,
                     'Monthly' = 30.42,
                     'Yearly' = 365)
                   ),
      br(),
      br()
    ),

    conditionalPanel(
      condition = "input.financePanels == 'panelExpenditure'",
      actionButton('bar', 'Bar'),
      br(),
      br()
    ),

    actionButton('updateData', 'Refresh Data')
  ),

  mainPanel(
    tabsetPanel(id = 'financePanels',
                tabPanel(title = 'Приход/Уход', value = 'panelInOut',
                         plotOutput('transactions'),
                         br(),
                         textOutput('summaryTotalsText'),
                         br(),
                         tableOutput('summaryTotals'),
                         br(),
                         textOutput('summaryAveragesText'),
                         br(),
                         tableOutput('summaryAverages')
                         ),
                tabPanel(title = 'Отслеживаемое время', value = 'panelExpenditure',
                         textOutput('textPointer')
                         )
                )
  )
)
)
                                    
