library(shiny)
library(shinythemes)
library(shinydashboard)

body <- dashboardBody(
 fluidRow(
   column(width=3,
      box(title="About", width=NULL, solidHeader = T, status="primary", collapsible = T, collapsed=T,
          "This Shiny App was developed to be used as an educational tool to understand common PK concepts. Adapted from PMX solutions."), 
      box(
       title = "Basic simulation information", width = NULL, solidHeader = TRUE, collapsible=T, collapsed=T,
       radioButtons(inputId = 'admin',
                    label = 'Route of administration',
                    choiceNames = list('I.V. bolus', 'Depot'),
                    choiceValues = list(1,2)),
       ## amount
       numericInput(inputId = 'dose',
                    label = 'Dose (mg)',
                    value = 100,
                    step = 100,
                    min = 0),
       ## frequency
       numericInput(inputId = 'freq',
                    label = 'Dosing frequency',
                    value = 24,
                    min = 0,
                    step = 4),
       ## sim time
       numericInput("simtime", label='Simulation time', value = 23.9,min=0,step=24)
     ),
     box(
       title = "PK Parameters", width = NULL, solidHeader = TRUE, collapsible=T,collapsed=T,
       #Thetas sliders
       ## clearance
       sliderInput(inputId='cl',
                   label = 'Clearance - CL (L/h)',
                   value = 50, min = 1, max = 100),
       ## volume
       sliderInput(inputId='v1',
                   label = 'Volume - Vc (L)',
                   value = 500, min = 10, max = 1000),
       ## ka
       sliderInput(inputId='ka',
                   label = 'Ka (1/h)',
                   value = 1, min = 0, max = 10,step=0.01),
       
       ## F
       sliderInput(inputId='f1',
                   label = 'Bioavailability (F)',
                   value = 1, min = 0, max = 1),
       #checkbox - 1 cmt or 2 cmt?
       numericInput("v2", label='Peripheral volume', value = 10,min=0),
       numericInput("q1", label='Inter-compartmental clearance', value = 10,min=0)
     ),
     box(
       title = "Variability", width = NULL, collapsible=T,collapsed=T,solidHeader = TRUE,
       numericInput("nsim", label='Number of virtual patients', value = 1,min=1,step=100),
       h5("Inter-individual variability (IIV)"),
       sliderInput("etacl", label='ETA CL', value = 0,min=0,max=1, step=0.01),
       sliderInput("etav1", label='ETA Vc', value = 0,min=0,max=1, step=0.01),
       sliderInput("etaf1", label='ETA F', value = 0,min=0,max=1, step=0.01),
       br(),
       h5("Residual Error"),
       numericInput("sigmaprop", label='Proportional error', value = 0,min=0,step=0.01),
       numericInput("sigmaadd", label='Additive error (mg/L)', value = 0,min=0,step=0.01)
     ),
     box(
       title = "Plot specifications", width=NULL, solidHeader = T,collapsible=T,collapsed=T,
       br(),
       h5("Predictive Interval"),
       numericInput("minprob", label='Minimal probability', value = 0.05,min=0,max=1,step=0.05),
       numericInput("maxprob", label='Maximal probability', value = 0.95,min=0,max=1,step=0.05),
       br(),
       h5("Units"),
       numericInput('convert', label = 'Drug MW (g/mol) (optional)',
                    value=0, min=0),
       radioButtons('uM', label = "convert to uM", choices = list("yes","no"), selected = list("no")),
       br(),
       h5("Aesthetics"),
       radioButtons('geom', label = "Linetype", choices = list("line","point"), selected = list("line")),
       numericInput('hline', label = 'Add cutoffs: y = ?',
                    value=0, min=0)
       #log y axis
       #drug concentration
       #draw cutoffs
     )
    ),
   column(width=5,
          box(
            title = "Simulated PK Profile", width = NULL, solidHeader = TRUE, status = "primary",collapsible = T,
            plotOutput("simPlot")
          ),
          box(title ="Download simulated data .csv",width=NULL,solidHeader = TRUE,collapsible = T,collapsed=T,
              downloadButton("downloadData", "Download .csv")
          )
        ),
   column(width=4,
          box(
            title = "Log-transformed PK Profile", width = NULL, solidHeader = TRUE, collapsible = T, status="primary",
            plotOutput("simPlot2")
          ),
          box(
            title = "Summary statistics", width = NULL, solidHeader = TRUE, collapsible = T, collapsed =T,
            dataTableOutput("sum_stat0")
          )
        )
      ))
    

# We'll save it in a variable `ui` so that we can preview it in the console
ui <- dashboardPage(skin="black",
  dashboardHeader(title = "PK simulator"),
  dashboardSidebar(disable=T),
  body
)










# Define UI for application that draws a histogram

###############################################
############ Load libraries
library(mrgsolve)
library(dplyr)
library(ggplot2)
library(shiny)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  sim_dataframe <- reactive({
    
    ###############################################
    ### Dosing
    if(input$admin == 2){
      oral <- T
    }else{
      oral <- F
    }
    
    dose <- input$dose
    
    
    ###############################################
    ## Parameter estimates 
    ka  <- input$ka # Absorption rate constant
    cl  <- input$cl # Clearance
    vd  <- input$v1 # Central distribution volume
    vd2 <- input$v2 # Peripheral distribution volume
    q1  <- input$q1 # Inter-compartmental clearance (set to 0 for 1-cmt model)
    f1  <- input$f1 # Bioavailability
    
    ###############################################
    ## Insert etas and sigmas
    
    etaka  <- 0 #input$etaka
    etacl  <- input$etacl
    etav1  <- input$etav1
    etav2  <- 0 #input$etav2
    etaq1  <- 0 #input$etaq1
    etaf1  <- input$etaf1
    
    #################################################
    ## Insert residual error
    
    sigmaprop <- input$sigmaprop # Proportional error
    sigmaadd  <- input$sigmaadd # Additive error
    
    
    ###############################3
    ## Simulation info
    
    nsamples <- input$nsim ### Number of simulated individuals
    sim_time <- input$simtime ## Time of simulation
    freq_ii <- input$freq
    
    ###################################################
    ############# Set Dosing objects
    
    # select_cmt <- 1
    # select_cmt <- input$admin
    # 
    # Administration <-  as.data.frame(ev(ID=1:nsamples,ii=freq_ii, cmt=1, addl=9999, amt=dose, rate = 0,time=0)) 
    
    if(oral){
      ## Oral dose
      Administration <-  as.data.frame(ev(ID=1:nsamples,ii=freq_ii, cmt=1, addl=9999, amt=dose, rate = 0,time=0))
    }else{
      ## IV BOLUS
      Administration <-  as.data.frame(ev(ID=1:nsamples,ii=freq_ii, cmt=2, addl=9999, amt=dose, rate = 0,time=0))
    }
    
    ## Sort by ID and time
    data <- Administration[order(Administration$ID,Administration$time),]
    
    
    ######################################################################
    ### Load in model for mrgsolve
    mod <- mread_cache("popPK")
    
    ## Specify the omegas and sigmas matrices
    omega <- cmat(etaka,
                  0, etacl,
                  0,0,etav1,
                  0,0,0,etav2,
                  0,0,0,0,etaq1,
                  0,0,0,0,0,etaf1)
    
    
    sigma <- cmat(sigmaprop,
                  0,sigmaadd)
    
    
    
    ## Set parameters in dataset
    data$TVKA <- ka
    data$TVCL <- cl
    data$TVVC <- vd
    data$TVVP1<- vd2
    data$TVQ1 <- q1
    data$TVF1 <- f1
    
    #################################################################
    ###### Perform simulation
    out <- mod %>%
      data_set(data) %>%
      omat(omega) %>%
      smat(sigma) %>%
      mrgsim(end=sim_time,obsonly=TRUE) # Simulate 100 observations, independent of the total simulated time
    
    # delta=sim_time/100, 
    ### Output of simulation to dataframe
    df <- as.data.frame(out)
    
    
    return(df)
  })

  sum_stat0 <- reactive({
    
    #################################################################  
    ## Calculate summary statistics
    
    #dose
    d <- input$dose
    
    # half-life
    thalf <- log(2)*input$v1/input$cl
    
    # auc
    auc <- input$dose*input$f1 / input$cl
    
    sum_stat0 <- data.frame("Dose" = d,
                            "AUC"  = auc,
                            "half.life" = thalf)
    return(sum_stat0)
    
  }) 
  
  output$sum_stat0 <- renderDataTable({sum_stat0()})
  
  sum_stat <- reactive({
    
    #################################################################  
    ## Calculate summary statistics
    
    
    # set probabilities of ribbon in figure
    minprobs=input$minprob
    maxprobs=input$maxprob
    
    
    sum_stat <- sim_dataframe() %>%
      group_by(time) %>%
      summarise(Median_C=median(DV),
                Low_percentile=quantile(DV,probs=minprobs),
                High_percentile=quantile(DV,probs=maxprobs)
      )  
    return(sum_stat)
    
  })
  
  
  output$simPlot <- renderPlot({
    
    ggplot(sum_stat(), aes(x=time,y=Median_C)) +
      
      ## Add ribbon for variability
      geom_ribbon(aes(ymin=Low_percentile, ymax=High_percentile, x=time), alpha = 0.3, linetype=0)+
      
      ## Add median line
      geom_line(size=2) +
      
      # scale_y_log10()+
      
      # Set axis and theme
      ylab(paste("Plasma Concentration (mg/L)",sep=""))+
      xlab("Time after dose (h)")+
      scale_x_continuous(breaks = seq(0,1000*24,24), limits = c(0.5,NA))+
      theme_bw(base_size = 14)+
      
      # Remove legend
      theme(legend.position="none")
    
  })
  
  output$simPlot2 <- renderPlot({
    
    ggplot(sum_stat(), aes(x=time,y=Median_C)) +
      
      ## Add ribbon for variability
      geom_ribbon(aes(ymin=Low_percentile, ymax=High_percentile, x=time), alpha = 0.3, linetype=0)+
      
      ## Add median line
      geom_line(size=2) +
      
      #ggtitle("log-scale simulation")+
      scale_y_log10()+
      
      # Set axis and theme
      ylab(paste("log10 Plasma Concentration (mg/L)",sep=""))+
      xlab("Time after dose (h)")+
      scale_x_continuous(breaks = seq(0,1000*24,24),limits = c(0.5,NA))+
      theme_bw(base_size=14)+
      
      # Remove legend
      theme(legend.position="none")
    
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      "Simulated_dataset.csv"
    },
    content = function(file) {
      write.csv(sim_dataframe(), file, row.names = FALSE)
    }
  )
  
}


shinyApp(ui=ui,server=server)
