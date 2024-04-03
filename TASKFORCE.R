###################################  YOUR TASK NUMBER ONE
# To install Leaflet package, run this command at your R prompt:
install.packages("leaflet")

# We will also need this widget to make pretty maps:
install.packages("htmlwidget")

# Activate the libraries
library(leaflet)
library(htmlwidgets)

# TASK 1: Create a Danish equivalent of AUSmap with esri layers, 
# but call it DANmap

DKmap <- DANmap %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright")

DKmap

########## ADD DATA TO LEAFLET

# In this section you will manually create machine-readable spatial
# data from GoogleMaps: 

### First, go to https://bit.ly/CreateCoordinates1
### Enter the coordinates of your favorite leisure places in Denmark 
# extracting them from the URL in googlemaps, adding name and type of monument.
# Remember to copy the coordinates as a string, as just two decimal numbers separated by comma. 

# Caveats: Do NOT edit the grey columns! They populate automatically!

### Second, read the sheet into R. You will need gmail login information. 
# watch the console, it may ask you to authenticate or put in the number 
# that corresponds to the account you wish to use.

# Libraries
library(tidyverse)
library(googlesheets4)
library(leaflet)

# Read in a Google sheet
places <- read_sheet("https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=124710918",
                     col_types = "cccnncnc")
glimpse(places)
#^Seemingly this does not work, so i'm downloading the document as a CSV-file instead, and will paste it here:
CSV_places <- read_csv("CSV_places.csv")
glimpse(CSV_places)

# load the coordinates in the map and check: are any points missing? Why?
leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = CSV_places$Longitude, 
             lat = CSV_places$Latitude,
             popup = CSV_places$Description)
#IT WORKS! But it's missing 8 rows of data, which is really unfortunate...


# Task 2: Read in the googlesheet data you and your colleaguespopulated with data into the DANmap object you created in Task 1.

DKmap <- DANmap %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright") %>% 
  addTiles() %>% 
  addMarkers(lng = CSV_places$Longitude, 
             lat = CSV_places$Latitude,
             popup = CSV_places$Description)

DKmap

# Task 3: Can you cluster the points in Leaflet? Google "clustering options in Leaflet"
DKmap %>% 
  addTiles() %>% 
  addMarkers(lng = CSV_places$Longitude, 
             lat = CSV_places$Latitude,
             popup = CSV_places$Description, 
  clusterOptions = markerClusterOptions())

# Task 4: Look at the map and consider what it is good for and what not.

#Det er godt til at kunne bedømme hvilke byer/regioner af Danmark der er gode, og hvilke der er dårlige - f.eks. er Aarhus området rigtig godt, fordi der er mange ‘leisure’ områder herved. Men hele Limfjordsområdet er mega kedeligt, da der tilsyneladende ingen form for nydelse er her. 
#Desuden er København, iflg. kortets cluster-funktion, også mega boring.
#Måske er der lige lidt i Skive alligevel og Hanstholm. Så den bliver måske lidt generaliserende.
#Faktisk er det alt sammen ud fra dataen, der bedømmer hvordan cluster funktionen reelt fungerer - dataen kodet ind i Spreadsheetet er tydeligvist Aarhus-centrisk, hvilket er årsagen til, at der er helt vildt mange ‘leisure’ områder her. Der er jo masser af nydelse i f.eks. København, trods dens ‘cluster’ af sammenlagt 5 punkter - sammenlignet med Aarhus’ 30 punkter…
#Men den er godt til at danne et overskueligt og interaktivt blik over ‘leisure’-punkterne i Danmark.



# Task 5: Find out how to display notes and classifications in the map.
#Det er ved at klikke på punkterne, og se hvad displays angiver

saveWidget(DKmap, "DKmap.html", selfcontained = TRUE)
