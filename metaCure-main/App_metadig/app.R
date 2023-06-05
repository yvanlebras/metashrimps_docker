


library(shiny)
library(xml2)
library(metadig)
library(ggplot2)
library(broman)
library(dplyr)
library(DT)
library(shinycssloaders)
library(rmarkdown)
library(utils)

source("../App_metadig/Function_url_exists.R")
source("../R/Fair_representation.R")
source("../R/eml_down.R")
setwd("../App_metadig")
dirXML = "../checks"
suite = "../Suite/Suite.xml"



# Define UI ----
ui <- fluidPage(
  #application style
  tags$head(includeCSS("www/styles.css")),
  tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com")
  ),
  tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com")
  ),
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Manrope:wght@300&family=Roboto:wght@100&display=swap")
  ) ,
  tags$head(
    tags$link(rel = "stylesheet", href = "http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css")
  ) ,
  tags$head(
    tags$link(rel = "stylesheet", href = "http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js")
  ) ,
  withTags({
    div(
      class = "header",
      checked = NA,
      h1(
        img(
          width = 200,
          src = "https://www.pndb.fr/static/images/PNDB_logo_bandeau.png",
          class = "topleft"
        )
      ),
      h2("Assessment Report"),
      h3("FAIR score")
    )
  }),
  navbarPage(
    "Menu",
    #add upload button
    tabPanel(
      "Upload data",
      div(
        class = "button",
        fileInput(
          "file",
          h3("Select Metadata"),
          width = "40%",
          placeholder = "No Metada selected"
        )
      ),
      actionButton("do", "Execute")
    ),
    #dataPaper
    tabPanel(
      "Draft of Data Paper",
      fluidRow(
        downloadButton("paper", label="Download HTML"),
        downloadButton("docx", label="Download editable file")
      ),
      br(),
      br(),
      withSpinner(htmlOutput("html"), type = 6)
    ),
    #Add Fair quality Represntations
    tabPanel(
      "Fair Assessment",
      withSpinner(plotOutput("barchart", width = "80%"), type =
                    6),
      plotOutput("piechart", width = "100%"),
      DTOutput("table")
    )
  )
)


# Define server logic ----
# Define server logic ----
server <- function(input, output) {
  output$barchart <- renderPlot(NULL)
  output$html <- renderUI(NULL)
  
  observeEvent(input$do, {
    output$barchart <- renderPlot({
      try(Fair_scores(runSuite(suite, dirXML, input$file$datapath)), silent =
            TRUE)
    })
    
    output$piechart <- renderPlot({
      try(Fair_pie(runSuite(suite, dirXML, input$file$datapath)), silent =
            TRUE)
    })
    output$table <- renderDT({
      if (is.character(input$file$datapath)) {
        data <- Fair_table(runSuite(suite, dirXML, input$file$datapath))
        data <- data %>%
          datatable(rownames = FALSE) %>%
          formatStyle(
            columns = 'Status',
            target = 'row',
            backgroundColor = styleEqual(
              unique(data$Status),
              c('#fc6847', 'lightgreen', "#f5b42a")
            )
          )
        data
        
      }
    })
    output$html <- renderUI({
      html <- render_eml(input$file$datapath)
      try(list(includeHTML(html), includeCSS("custom.css")))
    })
    output$docx<-downloadHandler(
      filename <- paste0("Datapaper",format(Sys.time(), "%s"),".docx"),
      content <-function(file) {
        rmarkdown::pandoc_convert("DataPaper.html", output ="DataPaper.docx")
        file.copy("DataPaper.docx",file)
      }
    )
    output$paper<-downloadHandler(
      filename <- paste0("Datapaper_",format(Sys.time(), "%s"),".zip"),
      content <- function(file) {
        file.copy("www/map.html",".")
        zip(file, files=c("map.html","DataPaper.html"))
      }
    )
    
  })
  
}


# Run the app ----d
shinyApp(ui = ui, server = server)

#runApp("App_metadig")
