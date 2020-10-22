library(shiny)

library(ggplot2)

library(DT)

library(dplyr)

jugadores <- read_delim("laliga_player_stats_spanish.csv", ";")
jugadores <- na.omit(jugadores)

shinyServer(function(input, output, session) {
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
  
  # cambiar jugadores por equipo
  observeEvent(input$player_team, {
    newPlayers <- jugadores %>% select(Equipo, Nombre, Posicion) %>% filter(Equipo==input$player_team) %>% filter(Posicion==input$player_type)
    updateSelectInput(session, 'players_select', choices=newPlayers$Nombre, selected=newPlayers$Nombre[1])
  })
  
  # cambiar jugadores por posicion
  observeEvent(input$player_type, {
    newPlayers <- jugadores %>% select(Posicion, Nombre, Equipo) %>% filter(Posicion==input$player_type) %>% filter(Equipo==input$player_team)
    updateSelectInput(session, 'players_select', choices=newPlayers$Nombre, selected=newPlayers$Nombre[1])
  })
  
  output$jugador <- renderText({input$players_select})
  
  # cambiar dorsal
  dorsal <- reactiveVal() 
  observeEvent(input$players_select, {
    newDorsal <- jugadores %>% select(Dorsal, Nombre) %>% filter(Nombre==input$players_select)
    dorsal(newDorsal$Dorsal) 
  })
  output$dorsal <- renderText({paste0("Dorsal: ", dorsal())})
  
  # cambiar minutos
  minutos <- reactiveVal() 
  observeEvent(input$players_select, {
    newDorsal <- jugadores %>% select(`Minutos jugados`, Nombre) %>% filter(Nombre==input$players_select)
    minutos(newDorsal$`Minutos jugados`) 
  })
  output$minutos <- renderText({paste0("Minutos jugados: ", minutos())})
  
  # tarjetas amarillas y rojas NOT WORKING
  output$distCards <- renderPlot({
    cards <- jugadores %>% select(Nombre, `Tarjetas amarillas`, `Tarjetas rojas`) %>% filter(Nombre==input$players_select)
    
    vals<-c(cards$`Tarjetas amarillas`, cards$`Tarjetas rojas`)
    guias<-c("Tarjetas amarillas", "Tarjetas rojas")
    myDf <- data.frame(vals, guias)
    
    hist(c(1,2), main="Tarjetas rojas y amarillas")
  })
  
  output$distPie <- renderPlot({
    perc <- jugadores %>% select(`Porcentaje de Partidos jugados enteros`, Nombre) %>% filter(Nombre==input$players_select)
    myNum <- str_replace(sub("%", "",as.character(perc)), ',', '.')
    useNum <- as.numeric(myNum[1])/100
    
    vals<-c(useNum,1-useNum)
    guias<-c("Partidos jugados", "Partidos no jugados")
    myDf <- data.frame(vals, guias)
    
    pie(myDf$vals, main = "Porcentaje de partidos jugados enteros", labels=myDf$guias)
  })
  
  # logo del equipo
  output$team <- renderImage({
    if (is.null(input$player_team))
      return(NULL)
    
    if (!is.null(input$player_team)) {
      return(list(
        src = paste0("www/",input$player_team, ".png"),
        contentType = "image/png"
      ))
    }
  }, deleteFile = FALSE)
})

