library(shiny)
library(ggplot2)
library(dplyr)
library(DT)

shinyServer(function(input, output) {

  output$tabla1 <- DT::renderDataTable({
    DT::datatable(equipos,
                  extensions = 'Buttons',
                  options = list(pageLength = 10,
                                 lengthMenu = c(5, 10, 15),
                                 dom = 'Bfrtip',
                                 buttons = c('csv')),
                  filter = 'bottom'
                  
    ) 
  
  
  })
  
  output$graficagoles <- renderPlot({
     
      ggplot(goles_por_equipo, aes(x = "", y = goles, fill = Equipo )) +
      geom_bar(stat = "identity" , width = 1 , color= "white") +
      coord_polar("y" ,start = 0)+ 
      geom_text(aes(label = paste0(goles)), position = position_stack(vjust = 0.5))+
      theme_void()
    
    
  })
})
  
  #output$grafica_ggplot <- renderPlot({
   # equipos %>% 
    #  ggplot(aes(x=HomeTeam,y=FTHG, color=color))+
     # geom_point()+
      #ylab("Precio")+
      #xlab("Kilates")+
      #ggtitle("Precio diamantes")

  



