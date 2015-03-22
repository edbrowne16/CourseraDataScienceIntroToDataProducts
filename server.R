library(shiny)
library(boot)
library(polynom)
#From R's 'boot' dataset, "survival" is length of Survival of Rats after the specified radiation doses
x <- survival$dose
y <- survival$surv

# lm fits a linear model to the data to the desired degree (note that this form of modeling is called
# 'linear', even though the resultant model may be of any degree - quadratic, in this case)
linearModel <- lm( formula = y ~ x + I(x^2))

# confint gets us the confidence intervals for each parameter in the (quadratic) equation
edsDataframe <- confint(linearModel, level=0.95)
 
predict(linearModel, interval = "confidence")

#the 'linearModel' object contains, among other things, a named vector called 'coefficients'
coeff <- unname(linearModel$coefficients)
# coeff now contains only the coefficients without names, in ascending order of power (0,1,2)
# The polynomial function constructs a polynomial object from a vector of coefficients
mypoly <- polynomial(coeff)

# predict() (from lm package) evaluates the polynomial object at the given argument.
radiationSurvival <- function(radExposure) {
  predict(mypoly, radExposure)
}

shinyServer(
  function(input, output) {
    
    # The user input is in per cent, we need a decimal value for the calculations.  Note this is
    # a REACTIVE input source, and is used below to calculate the table of confidence intervals
    confLevelDecimal <- reactive({ 
      as.numeric(input$confidenceLevel)/100.0 
    })
    
    # First just echo back the user-specified radiation exposure.
    output$inputValue <- renderPrint({input$radExposure})
    
    # Use the model to predict survival time for an exposure not contained in the original data.
    output$prediction <- renderPrint({radiationSurvival(input$radExposure)})
    
    # To help the user understand the model, we plot both the raw data and the model
    
    # Plot the raw dataset, just the (x,y) points contained in the raw data
    output$rawplot <- renderPlot(
      plot(x,y, main = "Fig. 1 - Plot of raw 'survival' dataset", 
           xlab = "radiation exposure (in RAD)", 
           ylab = "Survival (in units of time)")
    )
    
    # Plot the curve which represents the linear model we fitted to the raw data.
    output$fittedplot <- renderPlot({
      plot(mypoly, main = "Fig. 2 - Plot of curve fitted to 'survival' dataset", 
           xlab = "radiation exposure (in RAD)", 
           ylab = "Survival (in units of time)")
    })
    
    # As an example of reactivity, we plot a table of the confidence intervals of each
    # of the parameters in the model (that is, the coefficients of the terms of each
    # degree - 0,1,2.)  Those confidence intervals depend on the confidence level
    # desired by the user, and that confidence level is a reactive variable (see above.)
    output$lmConfidenceTable = renderTable({
      edsDataframe <- confint(linearModel, level = confLevelDecimal())
      edsDataframe
    })
  }
)




