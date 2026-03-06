library(shiny)

ui <- fluidPage(
  titlePanel("Test App"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Number of points:", min = 10, max = 200, value = 50)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output) {
  output$plot <- renderPlot({
    x <- rnorm(input$n)
    hist(x, main = "Random Normal Distribution",
         col = "steelblue", border = "white")
  })
}

shinyApp(ui, server)
```

---

## Step 2: Take a screenshot

Run the app locally in RStudio, take a screenshot, and save it as:
```
img/test_app.png
