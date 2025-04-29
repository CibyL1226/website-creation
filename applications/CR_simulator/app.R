library(shiny)
library(shinythemes)
library(shinydashboard)
library(dplyr)
library(ggplot2)

body <- dashboardBody(
  fluidRow(
    box(width=6,
        plotOutput("plot1")
    ),
    box(width=6,
        plotOutput("plot2")
    )
  ),
  fluidRow(
    box(title = "Line 1 Parameters",width =4,
        sliderInput("emax_1", label='Emax', value = 1,min=0,max=1, step=0.01),
        sliderInput("ec50_1", label='EC50 (log10)', value = 0,min=-3,max=3, step=0.25),
        sliderInput("gam_1", label='gamma', value = 1,min=0,max=10, step=0.1)
    ),
    box(title = "Line 2 Parameters",width =4,
        sliderInput("emax_2", label='Emax', value = 1,min=0,max=1, step=0.01),
        sliderInput("ec50_2", label='EC50 (log10)', value = 0,min=-3,max=3, step=0.25),
        sliderInput("gam_2", label='gamma', value = 1,min=0,max=10, step=0.1)
    ),
    box(title = "Line 3 Parameters", width =4,
        sliderInput("emax_3", label='Emax', value = 1,min=0,max=1, step=0.01),
        sliderInput("ec50_3", label='EC50 (log10)', value = 0,min=-3,max=3, step=0.25),
        sliderInput("gam_3", label='gamma', value = 1,min=0,max=10, step=0.1)
    )
  )
)

ui <- dashboardPage(skin="black",
                    dashboardHeader(title = "Concentration-Response Simulator",
                                    titleWidth = 450),
                    dashboardSidebar(disable=T),
                    body
)

server <- function(input, output) {
  
  sig_fun_1 <- reactive({
    #input 1
    emax_1 = input$emax_1
    ec50_1 = 10^input$ec50_1
    gam_1  = input$gam_1
    
    #create function
    sig_fun_1 <- function(CONC){
      (emax_1*(CONC**gam_1))/(ec50_1**gam_1+CONC**gam_1)
    }
  
  return(sig_fun_1)
  })
  
  sig_fun_2 <- reactive({
    #input 2
    emax_2 = input$emax_2
    ec50_2 = 10^input$ec50_2
    gam_2  = input$gam_2
    
    #create function
    sig_fun_2 <- function(CONC){
      (emax_2*(CONC**gam_2))/(ec50_2**gam_2+CONC**gam_2)
    }
    
    return(sig_fun_2)
  })
  
  sig_fun_3 <- reactive({
    #input 3
    emax_3 = input$emax_3
    ec50_3 = 10^input$ec50_3
    gam_3  = input$gam_3
    
    #create function
    sig_fun_3 <- function(CONC){
      (emax_3*(CONC**gam_3))/(ec50_3**gam_3+CONC**gam_3)
    }
    
    return(sig_fun_3)
  })
  
  
  
  output$plot1 <- renderPlot({
    
    
    ggplot(data.frame(CONC = c(0.0001,1000)), aes(CONC))+
      stat_function(fun=sig_fun_3(),color="red",size=1)+
      stat_function(fun=sig_fun_2(),color="blue",size=1)+
      stat_function(fun=sig_fun_1(),color="black",size=1)+
      xlab("Concentration")+
      ylab("Response")+
      theme_bw(base_size=16)
  })
 
  output$plot2 <- renderPlot({
    ec50_1 = signif(10^input$ec50_1)
    ec50_2 = signif(10^input$ec50_2)
    ec50_3 = signif(10^input$ec50_3)
    ggplot(data.frame(CONC = c(0.0001,1000)), aes(CONC))+
      stat_function(fun=sig_fun_3(),color="red",size=1)+
      stat_function(fun=sig_fun_2(),color="blue",size=1)+
      stat_function(fun=sig_fun_1(),color="black",size=1)+
      annotate("text",hjust=0,x=30,y=0.15,label=paste("EC50 =",ec50_3),color="red",size=5)+
      annotate("text",hjust=0,x=30,y=0.08,label=paste("EC50 =",ec50_2),color="blue",size=5)+
      annotate("text",hjust=0,x=30,y=0.01,label=paste("EC50 =",ec50_1),color="black",size=5)+
      scale_x_log10()+
      xlab("log10 Concentration")+
      ylab("Response")+
      theme_bw(base_size=16)
  })
  
}

shinyApp(ui=ui, server=server)
