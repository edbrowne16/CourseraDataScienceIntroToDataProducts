library(shiny)
shinyUI(
  pageWithSidebar(
    headerPanel("Prediction of survival time for given radiation exposure"),
    sidebarPanel(
      numericInput('radExposure', 'in units of radiation', 200, min = 0, max = 1500, step = 5),
     
      h4(""), # This line and next are just for spacing
      verbatimTextOutput("dummy_output"),
      
      h4("Reactive calculations below"),
      
      # confidenceLevel is a REACTIVE input source.  It is in percent, we convert it to
      # decimal in server.R in order to use it in our calculations
      numericInput('confidenceLevel', 'Desired Confidence Level (%)', 95, min = 0, max = 100, step = 5),
      
      submitButton('Submit'),
   
      h3(""),
      # Print the 2x3 table of confidence intervals for our model, one upper and lower bound for
      # each term (i.e. coefficent) in the model (i.e. equation), which is a function of the
      # model and the confidence level desired by the user.  Thus it is a REACTIVE endpoint.
      h5("Confidence interval, each parameter of the linear model"),
      tableOutput('lmConfidenceTable')
    ),
    mainPanel(
      # Use a tabset on the main panel to provide useful information to the user.  The first
      # tab contains the result of the prediction model, the other 2 provide useful documentation.
      tabsetPanel(type = "tabs",
                  tabPanel("Prediction Results",
                           h3('Results of prediction'),
                           h4('You entered a radiation exposure dose of'),
                           verbatimTextOutput("inputValue"),
                           h4('Which resulted in a prediction of survival duration of'),
                           verbatimTextOutput("prediction")
                  ),
                  tabPanel("About",
                           h3('Survival Prediction Analytic'),
                           h4('Version 1.0'),
                           h5('21 March 2015.')
                  ),
                  tabPanel("Documentation for 'Survival' prediction analytic", 
                           h4("Documentation of 'Survival' prediction analytic"),
                           p('The prediction analytic is based on the data from the "survival" dataset 
                             from R\'s "boot" package.  The dataset is shown in Figure 1.'),
                           plotOutput("rawplot"),
                           p("Applying the 'lm' package of R to the raw data, the data are
                             fitted optimally to a quadratic curve, shown in figure 2.  Using
                             this quadratic function, we are able to predict for any desired
                             value of radition exposure what will be the length of survival
                             of the subject rat."),
                           plotOutput("fittedplot")
                  ) 
      )           
    )
  )
)