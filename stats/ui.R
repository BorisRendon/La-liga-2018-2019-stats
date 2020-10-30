## ui.R ##
library(shinythemes)
library(readr)
library(tidyverse)
library(shiny)
library(shinyWidgets)

options(shiny.sanitize.errors = FALSE)
# equipos dataset
equipos <- read_delim("laliga_partidos_2018-2019.csv", ";")
nombres_equipos <- unique(equipos$AwayTeam)
equipos$Season <- NULL

# jugadores dataset
jugadores <- read_delim("laliga_player_stats_spanish.csv", ";")
nombres_jugadores <- unique(jugadores$Nombre)
posiciones_jugadores <- unique(jugadores$Posicion)
equipos_jugadores <- unique(jugadores$Equipo)


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
  
campeon <- goles_por_equipo$Equipo[1]


fluidPage(theme = shinytheme("united"),
          #setBackgroundImage(src = "elbicho.png"),
          titlePanel(h2(style="text-align:center;", "La liga 2018-2019 stats"),),
          mainPanel(
            tabsetPanel(
              tabPanel("Inicio",
                       br(),
                       fluidRow(
                         column(6, div(style="background-color:#ff9a76; text-align:center; border-radius:5px; height:22px", h4(total_jugadores , " jugadores inscritos"))),
                         column(6, div(style="background-color:#ff9a76; text-align:center; border-radius:5px; height:22px", h4(total_equipos , " equipos")))
                       ),
                       fluidRow(
                         column(6, div(style="background-color:#ff9a76; text-align:center; border-radius:5px; height:22px", h4(total_goles , " goles anotados"))),
                         column(6, div(style="background-color:#ff9a76; text-align:center; border-radius:5px; height:22px", h4(total_amarillas , "tarjetas amarillas y ", total_rojas, "rojas")))
                       ),
                       br(),
                       div(style="text-align:center",
                           h4("Goles por equipo"),
                           plotOutput('graficagoles')),
                       br(),
                       fluidRow(
                         column(3, img(src="winner.png", height = "150px")),
                         column(9, h2(style="text-align:left;", "El campeón de la temporada fue ", campeon),)),
                       br(),
                       ),
              tabPanel("Equipos",
                       br(),
                       sidebarPanel(
                         h3("Resultado"),
                         div(style="font-size:x-large", textOutput('resultado')),
                         h3("Ganador del partido"),
                         imageOutput("homeTeam"),
                         selectInput("bins",
                                     "Buscar por equipo:",
                                     choices = nombres_equipos,
                                     selected = "FC Barcelona"
                         )
                       ),
                       mainPanel(h2("Equipos"), 
                                 div(
                                   style="font-style: italic;",
                                   tags$ul(
                                     tags$li("FTHG = Full Time Home Team Goals"),
                                     tags$li("FTAG = Full Time Away Team Goals"),
                                     tags$li("FTR = Full Time Result (H=Home Win, D=Draw, A=Away Win)"),
                                     tags$li("HTHG = Half Time Home Team Goals"),
                                     tags$li("HTAG = Half Time Away Team Goals"),
                                     tags$li("HTR = Half Time Result (H=Home Win, D=Draw, A=Away Win)
")
                                   )
                                 ),
                                 br(),
                                 fluidRow(fluidRow(column(6,DT::dataTableOutput('tabla1'))),
                                          sidebarLayout(sidebarPanel(
                                            ),
                                            mainPanel()
                                            
                                          )),
                                 
                                 )
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
                                   column(9, list(
                                     div(style="font-size:x-large", textOutput("jugador")), 
                                     br(),
                                     div(style="font-size:medium", textOutput("dorsal")),
                                     br(),
                                     div(style="font-size:medium", textOutput("golesAnotados"))
                                    ))
                                 ),
                                 br(),
                                 div(style="font-style: italic; display:inline-block", textOutput("minutos"), textOutput("cards")),
                                 br(),
                                 plotOutput("distPie"),
                                 plotOutput("distDuelos"),
                                 br(),
                                 p("Información adicional del jugador:"),
                                 DT::dataTableOutput('tablajugadores')
                                 )
                       )
          )
        )
)


