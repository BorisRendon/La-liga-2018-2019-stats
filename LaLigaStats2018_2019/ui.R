## ui.R ##
library(shinythemes)
library(readr)

# equipos dataset
equipos <- read_delim("laliga_partidos_2018-2019.csv", ";")
nombres_equipos <- unique(equipos$AwayTeam)
# FTHG = Full Time Home Team Goals
# FTAG = Full Time Away Team Goals
# FTR = Full Time Result (H=Home Win, D=Draw, A=Away Win)
# HTHG = Half Time Home Team Goals
# HTAG = Half Time Away Team Goals


# jugadores dataset
jugadores <- read_delim("laliga_player_stats_spanish.csv", ";")
nombres_jugadores <- unique(jugadores$Nombre)

fluidPage(theme = shinytheme("united"),
          mainPanel(
            tabsetPanel(
              tabPanel("Inicio",
                       # Numero de equipos y de jugadores
                       # Top 5 equipos con mas goles
                       # Top 5 mejores jugadores > en posiciones
                       # Campeon de la temporada 2018 - 2019
                       # Total de goles en la temporada
                       # Total de tarjetas amarillas y rojas en la temporada
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
                                fluidRow("data"))
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
