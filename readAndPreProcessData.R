#Change working directory
setwd('/home/elpy_d/Programming/R/Personal_finance/')

#load google sheets project
require(googlesheets)

#PART 1 - read in data
# -- ------------------------------------------------------------------

finance <- gs_title('Personal_finance_2016')

finance_valik <- gs_read(finance, ws = 'Valik')
finance_sasha <- gs_read(finance, ws = 'Sasha')

#PART 2 - column names
#----------------------------------------------------------------------

colnames(finance_valik) <- c('date', 'detailedDescription', 'counterparty', 'category1', 'category2',
                             'category3', 'category4', 'cash', 'card', 'paid',  'undrawn', 'drawn', 'income', 'comment')
colnames(finance_sasha) <- c('date', 'detailedDescription', 'counterparty', 'category1', 'category2',
                             'category3', 'category4', 'cash', 'card', 'paid',  'undrawn', 'drawn', 'income', 'comment')

#PART 3 - remove superfluous rows
#-----------------------------------------------------------------------

finance_valik <- finance_valik[!(finance_valik$date==""|is.na(finance_valik$date)), ]
finance_sasha <- finance_sasha[!(finance_sasha$date==""|is.na(finance_sasha$date)), ]

#PART 4 - convert date from str to dates
#-----------------------------------------------------------------------

finance_valik$date <- as.Date(finance_valik$date, "%d/%m/%Y")
finance_sasha$date <- as.Date(finance_sasha$date, "%d/%m/%Y")

#PART 5 - Replace numeric's NA with 0 and numbers than have been stored as factors
                                        #Valik paid

finance_valik$cash <- as.numeric(gsub(",", "", as.character(finance_valik$cash)))
finance_valik$cash <- ifelse(is.na(finance_valik$cash), 0, finance_valik$cash)
finance_valik$card <- as.numeric(gsub(",", "", as.character(finance_valik$card)))
finance_valik$card <- ifelse(is.na(finance_valik$card), 0, finance_valik$card)
finance_valik$paid <- as.numeric(gsub(",", "", as.character(finance_valik$paid)))
finance_valik$paid <- ifelse(is.na(finance_valik$paid), 0, finance_valik$paid)
finance_valik$undrawn <- as.numeric(gsub(",", "", as.character(finance_valik$undrawn)))
finance_valik$undrawn <- ifelse(is.na(finance_valik$undrawn), 0, finance_valik$undrawn)
finance_valik$drawn <- as.numeric(gsub(",", "", as.character(finance_valik$drawn)))
finance_valik$drawn <- ifelse(is.na(finance_valik$drawn), 0, finance_valik$drawn)
finance_valik$income <- as.numeric(gsub(",", "", as.character(finance_valik$income)))
finance_valik$income <- ifelse(is.na(finance_valik$income), 0, finance_valik$income)




                                        #Sasha paid

finance_sasha$cash <- as.numeric(gsub(",", "", as.character(finance_sasha$cash)))
finance_sasha$cash <- ifelse(is.na(finance_sasha$cash), 0, finance_sasha$cash)
finance_sasha$card <- as.numeric(gsub(",", "", as.character(finance_sasha$card)))
finance_sasha$card <- ifelse(is.na(finance_sasha$card), 0, finance_sasha$card)
finance_sasha$paid <- as.numeric(gsub(",", "", as.character(finance_sasha$paid)))
finance_sasha$paid <- ifelse(is.na(finance_sasha$paid), 0, finance_sasha$paid)
finance_sasha$undrawn <- as.numeric(gsub(",", "", as.character(finance_sasha$undrawn)))
finance_sasha$undrawn <- ifelse(is.na(finance_sasha$undrawn), 0, finance_sasha$undrawn)
finance_sasha$drawn <- as.numeric(gsub(",", "", as.character(finance_sasha$drawn)))
finance_sasha$drawn <- ifelse(is.na(finance_sasha$drawn), 0, finance_sasha$drawn)
finance_sasha$income <- as.numeric(gsub(",", "", as.character(finance_sasha$income)))
finance_sasha$income <- ifelse(is.na(finance_sasha$income), 0, finance_sasha$income)





                                        #PART 6 - Create transaction source field
#---------------------------------------------------------------------------------
finance_valik$transactionSource <- as.factor(c('Valik'))
finance_sasha$transactionSource <- as.factor(c('Sasha'))

#PART 7 - aggregate transaction
#---------------------------------------------------------------------------------
#stack data sets

fieldsToRetain <- c('date','detailedDescription', 'counterparty', 'category1', 'category2', 'category3','category4',
                    'cash', 'card', 'paid', 'undrawn', 'drawn', 'income', 'comment', 'transactionSource')


finance_combined <- rbind(finance_valik[, fieldsToRetain],
                          finance_sasha[, fieldsToRetain])
#rename paid and income fields
colnames(finance_combined)[colnames(finance_combined) == c('paid')] <- 'outflow'
colnames(finance_combined)[colnames(finance_combined) == c('income')] <- 'inflow'

#create new inflow field
finance_combined$netInflow <- finance_combined$inflow - finance_combined$outflow

#order by date of rows
finance_combined <- finance_combined[order(finance_combined$date), ]

#cumulative netInFlow calc
finance_combined$cumulativeNetInflow <- cumsum(finance_combined$netInflow)


#truncated monthly values
finance_combined$monthOfTransaction <- as.Date(format(finance_combined$date, format = '%Y-%m-01'))

#create inflow/outflow fields
finance_combined$transactionType <- ifelse(finance_combined$inflow==0, 'outflow', 'inflow')

#declare fields as factors
finance_combined$counterparty <- as.factor(finance_combined$counterparty)
finance_combined$category1 <- as.factor(finance_combined$category1)
finance_combined$category2 <- as.factor(finance_combined$category2)
finance_combined$category3 <- as.factor(finance_combined$category3)
finance_combined$category4 <- as.factor(finance_combined$category4)
finance_combined$transactionType <- as.factor(finance_combined$transactionType)
finance_combined$comment <- as.factor(finance_combined$comment)

#PART 8 - determine the min/max dates in the data as well as most recent month of data possible
minDateInData <- min(finance_combined$date, na.rm = TRUE)
maxDateInData <- max(finance_combined$date, na.rm = TRUE)

currentDate <- Sys.Date()

if (currentDate == as.Date(timeLastDayInMonth(currentDate))){
  latestMonth = as.Date(format(currentDate, format = '%Y-%m-01'))
} else {
  latestMonth = as.Date(as.yearmon(currentDate) - (1/12), frac = 0)
  }
                                           
