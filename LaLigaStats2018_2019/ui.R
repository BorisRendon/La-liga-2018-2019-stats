## ui.R ##
library(shinythemes)
library(readr)
library(shinyWidgets)

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
posiciones_jugadores <- unique(jugadores$Posicion)
equipos_jugadores <- unique(jugadores$Equipo)

fluidPage(theme = shinytheme("united"),
          setBackgroundColor("ghostwhite"),
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
                         radioButtons("player_type", "Posición", choices=posiciones_jugadores, selected="Delantero"),
                         selectInput("players_select",
                                     "Seleccionar jugador",
                                     choices=nombres_jugadores,
                                     selected="Hodei Oleaga"),
                         radioButtons("player_team", "Equipo", choices=equipos_jugadores),
                       ),
                       mainPanel(fluidRow(
                                   column(3,imageOutput("team", height = 100)), 
                                   column(9, list(verbatimTextOutput("jugador"), verbatimTextOutput("dorsal")))
                                 ),
                                 br(),
                                 div(style="background-color:orange; border-radius:50px; width:100px; text-align:center; color:white",
                                     "Comparar"),
                                 br(),
                                 h4("Minutos jugados"),
                                 plotOutput("distCards"),
                                 plotOutput("distPie")
                                 )
                       )
          )
        )
)
