library(sf)
library(raster)
library(sf)
library(tidyr)

createPovertyRateRaster <- function(
    pathToTractInfo,
    pathToRaster,
    outName){
  
  # Read Tract Information, Including Population & Poverty Population====
  SF <- read_sf(pathToTractInfo) %>% 
    st_as_sf() %>% 
    mutate(tractArea = st_area(.) %>% 
             as.numeric())
  # Read Raster====
  r <- raster::raster(pathToRaster)
  
  # Convert Raster to Polygon====
  p <- 
    rasterToPolygons(r) %>% 
    st_as_sf() %>% 
    dplyr::mutate(gridID = 1:nrow(.)) %>% 
    mutate(gridArea = st_area(.) %>% 
             as.numeric()) %>% 
    dplyr::select(gridID,
                  gridArea)
  
  # Make Grid with Poverty Rate====
  int <- st_intersection(SF, p) %>% 
    mutate(intArea = st_area(.) %>% 
             as.numeric) %>% 
    # Calculate weight based on areas within the tract----
    mutate(wgt = intArea/ tractArea) %>% 
    # Interpolate population & poverty population based on the weight----
    mutate(wgtPop = Population * wgt) %>% 
    mutate(wgtPov = est200PrcntPov * wgt) %>% 
    st_drop_geometry() %>% 
    # Summarize by grid----
    group_by(gridID) %>% 
    summarize(gridPop = sum(wgtPop),
              gridPov = sum(wgtPov)) %>% 
    # Calculate estimated grid poverty rate----
    mutate(gridPovRate = gridPov/ gridPop)
  
  # Combine with grid sf to get geometry----
  g <- inner_join(p, int, by = "gridID")
  
  # Convert polygon into raster and write it----
  gr <- raster::rasterize(g, r, field = "gridPovRate")
  writeRaster(gr,
              outName)
  
  
}
setwd("/Volumes/volume 1/GIS Projects/nightlight/nightlight2/miami")

data <- read_sf("miami_tract_info3.geojson")

r <- raster::raster("alanYearlyMean_miami.tif")

data <- data %>% 
  mutate(povRate = est200PrcntPov/ Population) %>% 
  mutate(tractArea = st_area(.) %>% 
           as.numeric(.))

p <- 
  rasterToPolygons(r) %>% 
  st_as_sf() %>% 
  dplyr::mutate(gridID = 1:nrow(.)) %>% 
  mutate(gridArea = st_area(.) %>% 
           as.numeric()) %>% 
  dplyr::select(gridID,
                gridArea)

int <- st_intersection(data, p) %>% 
  mutate(intArea = st_area(.) %>% 
           as.numeric) %>% 
  mutate(wgt = intArea/ tractArea) %>% 
  mutate(wgtPop = Population * wgt) %>% 
  mutate(wgtPov = est200PrcntPov * wgt) %>% 
  st_drop_geometry() %>% 
  group_by(gridID) %>% 
  summarize(gridPop = sum(wgtPop),
            gridPov = sum(wgtPov)) %>% 
  mutate(gridPovRate = gridPov/ gridPop)

g <- inner_join(p, int, by = "gridID")

g2 <- left_join(p, int, by = "gridID")

gr <- raster::rasterize(g, r, field = "gridPovRate")
writeRaster(gr,
            "povertyRate.tif")
