
library(shiny)
library(dplyr)

jugadores <- read_delim("laliga_player_stats_spanish.csv", ";")

shinyServer(function(input, output, session) {
  
  # cambiar equipo
  observeEvent(input$players_select, {
    newTeam <- jugadores %>% select(Equipo, Nombre) %>% filter(Nombre==input$players_select)
    updateRadioButtons(session, 'player_team', selected=newTeam$Equipo)
  })
  
  # cambiar jugadores por equipo
  observeEvent(input$player_team, {
    newPlayers <- jugadores %>% select(Equipo, Nombre) %>% filter(Equipo==input$player_team)
    print(newPlayers$Nombre[1])
    updateSelectInput(session, 'players_select',choices=newPlayers, selected=newPlayers$Nombre[1])
  })
  
  # falta cambiar jugadores por posicion
  
  # cambiar posicion
  observeEvent(input$players_select, {
    newPosition <- jugadores %>% select(Posicion, Nombre) %>% filter(Nombre==input$players_select)
    updateSelectInput(session, 'player_type', selected=newPosition$Posicion)
  })
  
  output$distPie <- renderPlot({
    # en el vector poner variable de porcentaje de partidos jugados enteros
    pie(c(0.2,0.8), main = "Porcentaje de partidos jugados enteros")
  })
  
  output$jugador <- renderText({input$players_select})
  
  output$dorsal <- renderText({paste0("Dorsal: ", input$players_select)})
  
  output$distCards <- renderPlot({
    hist(c(1,2), col = 'darkgray', border = 'white', main="Tarjetas rojas y amarillas")
  })
  
  output$team <- renderImage({
    if (is.null(input$player_team))
      return(NULL)
    
    print(input$player_team)
    if (!is.null(input$player_team)) {
      return(list(
        src = paste0("www/",input$player_team, ".png"),
        contentType = "image/png"
      ))
    }
  
    
  }, deleteFile = FALSE)
  
})
