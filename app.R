library(shiny)
library(DT)
df <- read.csv("amd_table.csv")
#Create the shiny app 
ui <- fluidPage(
    h2("AMD Ryzen and Threadripper CPU's"),
    DT::dataTableOutput("mytable")
)

server <- function(input, output) {
    output$mytable = DT::renderDataTable({
        df <- datatable(df, colnames=c("Model","Core Count","Core Clock (GHz)","Boost Clock (Ghz)","TDP (Watts)","Integrated Graphics","SMT","Price","Family","Line","Launch Date",
                                               "L1 Cache (KB)","L2 Cache (MB)","L3 Cache (MB)")) %>% formatCurrency("Price",'$')
        df
    })
}

shinyApp(ui, server)
