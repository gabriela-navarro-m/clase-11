#==============================================================================#
# Autor(es): Eduard Martinez
# Colaboradores: 
# Fecha creacion: 10/08/2019
# Fecha modificacion: 12/04/2021
# Version de R: 4.0.3.
#==============================================================================#

# intial configuration
rm(list = ls()) # limpia el entorno de R
pacman::p_load(tidyverse,sf,raster,leaflet) # cargar y/o instalar paquetes a usar

#-------------#
# librería sf #
#-------------#

# sp vs sf (Edzer Pebesma)
rstudioapi::viewer(url = "help/Applied Spatial Data Analysis with R.pdf") # Libro
browseURL(url = "https://github.com/edzer", browser = getOption("browser")) # Edzer Pebesma

# sf en github
browseURL(url = 'https://github.com/r-spatial/sf', browser = getOption("browser")) # Paquete SF en GitHub
browseURL(url = 'https://cran.r-project.org/web/packages/sf/sf.pdf', browser = getOption("browser")) # Paquete SF

#------------------------#
# 1. Importar shapefiles #
#------------------------#

#### 1.1. Importar un shapefile con Polygonos
quilla = st_read(dsn = 'data/input/',layer='neigh_barranquilla')
quilla # veamos lo que contiene el objeto
class(quilla) # Tipo de objeto

#### 1.1.2. Visuaizar con ggplot
ggplot() + geom_sf(data = quilla,color='red')
ggplot() + geom_sf(data = quilla[1,],color='blue')

#### 1.1.2. Geometria del objeto
quilla$geometry[[1]]
quilla$geometry[[1]][1]
ggplot() + geom_sf(data = quilla[1,],color='red')

#### 1.1.3. Otros atributos
st_bbox(quilla[1,]) # Caja de coordenadas
quilla %>% str() # Atributo de cada variable

#### 1.1.5. Obtener el CRS del objeto
st_crs(quilla) 
crs(quilla)

#### 1.2. Importar un shapefile con Lineas
vias <- st_read(dsn = 'data/input/Viaferrea.shp') # Observen que no es necesario indicar que es una capa de lineas
vias
class(vias)
ggplot() + geom_sf(data = vias,color='gray')

#### 1.3. Importar un shapefile con puntos
points <- st_read(dsn = 'data/input/points_barranquilla.shp',stringsAsFactors=F) # La opcion stringsAsFactors a veces es necesaria
points
class(points)
ggplot() + geom_sf(data = points[1:10,],color='gray')
ggplot() + geom_sf(data = points,color='gray')

#### 1.4. Visuaizar con leaflet
leaflet() %>% addTiles() %>% 
addCircleMarkers(data = points,color = "red", radius = 0.5)

#-------------------------#
# 2. Generar un shapefile #
#-------------------------#

#### 2.1. Convertir un dataframe con puntos en un objeto sf
cat("obtener datos de google maps")
browseURL(url = 'https://www.google.es/maps/?hl=es', browser = getOption("browser")) # Google maps

#### 2.1.1. Creando dataframe
data = data.frame(name = c('Universidad de los Andes','Portal del Norte') , long = c(-74.0673157,-74.0534864) , lat = c(4.6024665,4.7561092))

#### 2.1.2. Convertir de dataframe a sf
data_sf <- st_as_sf(x = data, coords = c("long", "lat"), crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

#### 2.1.3. Veamos que tenemos
ggplot() + geom_sf(data = data_sf,color = 'red') + theme_bw()
ggplot() + geom_sf(data = st_read(dsn = 'data/input/sec_bogota.shp'),color='#7fc0ff') + 
           geom_sf(data = data_sf,color = 'red') + theme_bw()

#### 2.1.4. Exportar un shpefile
st_write(obj = data_sf,dsn = 'data/output/Puntos Bogota.shp',driver='ESRI Shapefile',delete_layer = T)
saveRDS(object = data_sf,file = 'data/output/Puntos Bogota.rds') 

#---------------------#
# 3. Reasignar un CRS #
#---------------------#

#### 3.0. Veamos la intuicion
dev.off()
grid.raster(readPNG('help/graphs/Proyeccion errada.png')) 

#### 3.1. Veamos un ejemplo
cundinamarca = st_read(dsn = 'data/input/Colombia_wgs84.shp',stringsAsFactors=F) %>% 
               subset(name_dpto == 'Cundinamarca')
cundinamarca
ggplot() + geom_sf(data = cundinamarca,color='gray')

#### 3.2. Veamos las CRS de cada objeto
crs(vias)
crs(cundinamarca)

#### 3.3. Cambiemos la CRS de vias
vias$geometry[[1]]
vias <- st_transform(x = vias,crs = crs(cundinamarca))
vias$geometry[[1]]

#### 3.4. Veamos nuevamente las CRS de cada objeto
crs(vias)
crs(cundinamarca)

#### 3.5. Vias en ferreas en Cundinamarca
ggplot() + geom_sf(data = cundinamarca,color='gray') + geom_sf(data = vias,color='red') + theme_bw()

