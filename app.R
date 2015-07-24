library(shiny)
library(car)
library(ggplot2)
data(mtcars)
mtcars$cyl <- factor(mtcars$cyl)
mtcars$vs <- factor(mtcars$vs)
mtcars$gear <- factor(mtcars$gear)
mtcars$carb <- factor(mtcars$carb)
mtcars$am <- factor(mtcars$am,labels=c('Auto','Manual'))


###################################################################################
## User Interface

ui <- fluidPage(
  
  
  headerPanel("EXPLORATORY ANALYSIS"),
  
  ## Mean mpg UI
  
  sidebarPanel(
    sliderInput('mpg', 'Select mpg',value = 15, min = 10, max = 35, step = 1)
  ),
  mainPanel(
    plotOutput('hist')
  ),

  ## By cyl mpg and regression UI
  sidebarPanel(
  checkboxGroupInput("checkGroup", label = h3("Num. Cylinders to graph"), 
                     choices = list("6 Cyl" = 6, "8 Cyl" = 8),
                     selected = 6)
  ),
  hr(),
 
  
  mainPanel(
    plotOutput('grp1'),
    plotOutput('grp2')
  ),
  
  ## Table and Regression UI
  headerPanel("MODEL-PREDICTION"),
  
  titlePanel(
    h3("mpg prediction - Compare to Table below")
       ),
  
  #display
  fluidRow(column(4, verbatimTextOutput("value2"))),
  
  # mpg prediction input
  sidebarPanel(
    numericInput('i.wt', 'Input weight', 3.44, min = 1, max = 5, step = 0.01),
    numericInput('i.hp', 'Input hp', 175, min = 80, max = 300, step = 1)
  ),
  
  #RadioButtons for model
  mainPanel(
  radioButtons("cyl", "Select Num. Cylinders to Model",
               c("4cyl" = 4,
                 "6cyl" = 6,
                 "8cyl" = 8))
  ),
  
  # Create a table
  fluidRow(
    column(8, 
           selectInput("trans", 
                       "Transmission:", 
                       c("All", 
                         unique(as.character(mtcars$am))))
    ),
    column(8, 
           selectInput("gear", 
                       "gears:", 
                       c("All", 
                         unique(as.character(mtcars$gear))))
    )        
  ),
  
  #DisplayTable
  fluidRow(
    dataTableOutput(outputId="table")
  )
  
  
  
)


####################################################################################
## SERVER

server <- function(input, output) {
  output$hist <- renderPlot({
    
    mpg <- input$mpg
    p1 <- qplot(mpg, data=mtcars, geom="density", fill=cyl, alpha=I(.5),
                main="Distribution of Gas Milage", xlab="Miles Per Gallon",
                ylab="Density")
    p1 + geom_vline(xintercept = mpg)
    
    
  })
  
  ## By cyl mpg exploratory and 
  ## regression
  
  output$value <- renderPrint({ input$checkGroup })
  
  mtdata <- reactive ({
    
    subset(mtcars, cyl==4 | cyl==as.numeric(input$checkGroup))
    
  })
  
  output$grp1 <- renderPlot({
    
    qplot(cyl, mpg, data=mtdata(), geom=c("boxplot", "jitter"),
          fill=cyl, main="Mileage by Cyl Number",
          xlab="", ylab="Miles per Gallon")  
  })
  
  output$grp2 <- renderPlot({
    
    fc <- mtdata()$wt #wt
    v <- "wt" #wt
    tx <- paste("Regression of MPG on", v, sep=" ")
    # Separate regressions of mpg on weight for each number of cylinders
    qplot(fc, mpg, data=mtdata(), geom=c("point", "smooth"),
          method="lm", formula=y~x, color=cyl,
          main=tx,     
          xlab=v, ylab="Miles per Gallon")  
  })     
  
  # Prediction based on 
  #table election and cyl
  
  # Filter data based on selections
  output$table <- renderDataTable({
    data <- mtcars
    if (input$gear != "All"){
      data <- data[data$gear == input$gear,]
    }
    
    if (input$trans != "All"){
      data <- data[data$am == input$trans,]
    }
    data
  })
  
  pred <- reactive ({
    
    if(as.numeric(input$cyl)=="4"){
      35.84 - 3.18140*input$i.wt - 0.02312*input$i.hp
    }
    else if(as.numeric(input$cyl)=="6"){
      35.84 - 3.18140*input$i.wt - 0.02312*input$i.hp - 3.35902
    }
    else if(as.numeric(input$cyl)=="8"){
      35.84 - 3.18140*input$i.wt - 0.02312*input$i.hp - 3.18588
    }
    
  })
  
  output$value2 <- renderPrint({ pred() })
  output$value1 <- renderPrint({ input$cyl })
  output$inputValue <- renderPrint({input$glucose})
  output$prediction <- renderPrint({diabetesRisk(input$glucose)})
  
  
  
}

shinyApp(server=server, ui=ui)

# library(shinyapps)
# shinyapps::deployApp('C:/Users/zgomez/Documents/app-DDPProject')

