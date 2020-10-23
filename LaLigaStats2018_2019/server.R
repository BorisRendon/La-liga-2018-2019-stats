library(shiny)

library(ggplot2)

library(DT)

library(dplyr)

jugadores <- read_delim("laliga_player_stats_spanish.csv", ";")
jugadores <- na.omit(jugadores)

shinyServer(function(input, output, session) {
  
  
  observe({
    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query[['bins']])) {
     # updateSelectInput(session, "bins", value = query[['bins']])
    }
    #if(!is.null(query[['bar_col']])){
     # updateSelectInput(session, "set_col" , selected =query[['bar_col']] )
    #}
  })
  
  ## Equipos
  output$tabla1 <- DT::renderDataTable({
    DT::datatable(equipos,
                  extensions = 'Buttons',
                  options = list(pageLength = 10,
                                 lengthMenu = c(5, 10, 15),
                                 dom = 'Bfrtip',
                                 buttons = c('csv'), search = list(regex = TRUE, caseInsensitive = FALSE, search = 'Barcelona')),
                  filter = 'bottom',
                  selection='single' 
    ) 
  })
  
  output$graficagoles <- renderPlot({
      ggplot(goles_por_equipo, aes(x = "", y = goles, fill = Equipo )) +
      geom_bar(stat = "identity" , width = 1 , color= "white") +
      coord_polar("y" ,start = 0)+ 
      geom_text(aes(label = paste0(goles)), position = position_stack(vjust = 0.5))+
      theme_void()
  })
  
  output$homeTeam <- renderImage({
    if (is.null(input$tabla1_rows_selected))
      return(list(
        src = paste0("www/teams.png"),
        contentType = "image/png"
      ))
    
    if (!is.null(input$tabla1_rows_selected)) {
      win <- equipos$FTR[input$tabla1_rows_selected]
      if(win=='H'){
        return(list(
          src = paste0("www/", equipos$HomeTeam[input$tabla1_rows_selected], ".png"),
          contentType = "image/png"
        ))
      }else{
        if(win=='A'){
          return(list(
            src = paste0("www/", equipos$AwayTeam[input$tabla1_rows_selected], ".png"),
            contentType = "image/png"
          ))
        }else{
          return(list(
            src = paste0("www/tie.png"),
            contentType = "image/png"
          ))
        }
      }
      
    }
  }, deleteFile = FALSE)
  
  resultado <- reactiveVal() 
  observeEvent(input$tabla1_rows_selected, {
    hteam <- equipos$FTHG[input$tabla1_rows_selected]
    ateam <- equipos$FTAG[input$tabla1_rows_selected]
    resultado(paste0(hteam, " - ", ateam)) 
  })
  output$resultado <- renderText({resultado()})
  
  ## Jugadores
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
  output$minutos <- renderText({paste0(minutos(), " minutos jugados")})
  
  # cambiar goles
  golesAnotados <- reactiveVal() 
  observeEvent(input$players_select, {
    newGoles <- jugadores %>% 
      select(`Goles marcados desde dentro del área`, `Goles marcados desde fuera del área`,
             `Goles marcados con el pie izquierdo`, `Goles marcados con el pie derecho`, 
             `Goles marcados de penalti`, `Goles marcados de cabeza`, `Goles marcados de jugada a balón parado`,
             `Goles marcados en propia puerta`, Nombre) %>% 
      filter(Nombre==input$players_select) %>% 
      mutate(goles=as.numeric(`Goles marcados desde dentro del área`)+as.numeric(`Goles marcados desde fuera del área`)+
             as.numeric(`Goles marcados con el pie izquierdo`)+as.numeric(`Goles marcados con el pie derecho`)+
             as.numeric(`Goles marcados de penalti`)+as.numeric(`Goles marcados de cabeza`)+as.numeric(`Goles marcados de jugada a balón parado`)+
             as.numeric(`Goles marcados en propia puerta`))
    golesAnotados(newGoles$goles) 
  })
  output$golesAnotados <- renderText({paste0("Goles anotados: ", golesAnotados())})
  
  # tarjetas amarillas y rojas
  rojas <- reactiveVal() 
  amarillas <- reactiveVal()
  observeEvent(input$players_select, {
    newCards <- jugadores %>% select(`Tarjetas amarillas`, `Tarjetas rojas`, Nombre) %>% filter(Nombre==input$players_select)
    rojas(newCards$`Tarjetas rojas`) 
    amarillas(newCards$`Tarjetas amarillas`) 
  })
  output$cards <- renderText({paste0(rojas(), " tarjetas rojas y ", amarillas(), " amarillas")})
  
  # porcentaje partidos jugados
  output$distPie <- renderPlot({
    perc <- jugadores %>% select(`Porcentaje de Partidos jugados enteros`, Nombre) %>% filter(Nombre==input$players_select)
    myNum <- str_replace(sub("%", "",as.character(perc)), ',', '.')
    useNum <- as.numeric(myNum[1])/100
    
    vals<-c(useNum,1-useNum)
    guias<-c("Partidos jugados enteros", "Partidos no jugados enteros")
    myDf <- data.frame(vals, guias)
    
    pie(myDf$vals, main = "Porcentaje de partidos jugados enteros", labels=myDf$guias)
  })
  
  # duelos
  output$distDuelos <- renderPlot({
    duelos <- jugadores %>% select(`Duelos con éxito`, `Duelos fallidos`, Nombre) %>% filter(Nombre==input$players_select)
    
    vals<-c(duelos$`Duelos con éxito`, duelos$`Duelos fallidos`)
    guias<-c("Duelos con éxito", "Duelos fallidos")
    myDf <- data.frame(vals, guias)
    
    ggplot(data=myDf, aes(x=vals, y=vals, fill=vals, label=guias)) +
      geom_bar(colour="black", fill="#DD8888", stat="identity") +
      xlab("Tipo de duelo") + ylab("Cantidad") +
      ggtitle("Duelos jugados con éxito y fallidos") +
      geom_label(aes(fill = factor(myDf)), fontface = "bold") +
      theme(legend.position = 'none')
    
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
  
  output$tablajugadores <- DT::renderDataTable({
    infojugador <- jugadores %>% filter(Nombre==input$players_select)
    infojugador$Nombre <- NULL
    infojugador$Equipo <- NULL
    infojugador$Posicion <- NULL
    infojugador$Dorsal <- NULL
    infojugador$`Minutos jugados` <- NULL
    infojugador$`Porcentaje de Partidos jugados enteros` <- NULL
    infojugador$`Porcentaje de Partidos jugados` <- NULL
    infojugador$`Segunda tarjeta amarilla` <- NULL
    infojugador$`Duelos con éxito` <- NULL
    infojugador$`Duelos fallidos` <- NULL
    DT::datatable(infojugador, options=list(dom = 't')) 
  })
})

