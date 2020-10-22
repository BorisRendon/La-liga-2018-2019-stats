## ui.R ##
library(shinythemes)
library(readr)
library(tidyverse)
library(shiny)



# equipos dataset
equipos <- read_delim("laliga_partidos_2018-2019.csv", ";")
nombres_equipos <- unique(equipos$AwayTeam)
equipos %>% 
  summarise(AwayTeam)
# FTHG = Full Time Home Team Goals
# FTAG = Full Time Away Team Goals
# FTR = Full Time Result (H=Home Win, D=Draw, A=Away Win)
# HTHG = Half Time Home Team Goals
# HTAG = Half Time Away Team Goals


# jugadores dataset
jugadores <- read_delim("laliga_player_stats_spanish.csv", ";")
nombres_jugadores <- unique(jugadores$Nombre)






total_equipos <- equipos %>% 
  summarise(Cantidad_equipos = n_distinct(HomeTeam))

total_jugadores <- jugadores %>% 
  summarise(jugadores_distintos = n_distinct(Nombre))

total_golesaway <- equipos %>% 
  summarise(sum(equipos$FTHG))

total_goleshome <- equipos %>% 
  summarise(sum(equipos$FTAG))

total_goles <- total_golesaway + total_goleshome

total_amarillas <- jugadores %>% 
  summarise(sum(jugadores$`Tarjetas amarillas`))

total_rojas <- jugadores %>% 
  summarise(sum(jugadores$`Tarjetas rojas`))

goles_por_equipo <- jugadores %>% 
  select(Equipo,`Goles marcados`) %>% 
  group_by(Equipo) %>% 
  summarise(Equipo=Equipo,goles = sum(`Goles marcados`)) %>% 
  arrange(desc(goles))

goles_por_equipo <-unique(goles_por_equipo)
  
  
 

fluidPage(theme = shinytheme("united"),
          mainPanel(
            tabsetPanel(
              tabPanel("Inicio",
                       
                       h5("Hay un total de ",total_equipos , "equipos en LaLiga"),
                       h5("Hay un total de ",total_jugadores , "jugadores inscritos en LaLiga"),
                       h5("Hay un total de ",total_goles , "goles anotados en LaLiga"),
                       h5("Hay un total de ",total_amarillas , "tarjetas amarillas en LaLiga"),
                       h5("Hay un total de ",total_rojas , "tarjetas rojas en LaLiga"),
                       
                       plotOutput('graficagoles')
                       
                       
                       # Numero de equipos y de jugadores // 
                       # Top 5 equipos con mas goles
                       # Top 5 mejores jugadores > en posiciones
                       # Campeon de la temporada 2018 - 2019
                       # Total de goles en la temporada//
                       # Total de tarjetas amarillas y rojas en la temporada//
                       
                       
                       
                       
                       ),
              # feature: comparar equipos y jugadores
              tabPanel("Equipos",
                       br(),
                       sidebarPanel(
                         selectInput("equipos_select",
                                     "Seleccionar equipo",
                                     choices=nombres_equipos)
                         
                       ),
                       mainPanel(h2("Equipos"), 
                                fluidRow(fluidRow(column(6,DT::dataTableOutput('tabla1')))))
                       ),
              tabPanel("Jugadores",
                       br(),
                       sidebarPanel(
                         selectInput("equipos_select",
                                     "Seleccionar jugador",
                                     choices=nombres_jugadores)
                       ),
                       mainPanel(h2("Jugadores"), 
                                fluidRow("data"))
                       )
          )
        )
)
