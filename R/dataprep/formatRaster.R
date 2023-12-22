library(sf)
library(raster)
library(sf)
library(tidyr)

setwd("/Volumes/volume 1/GIS Projects/nightlight/nightlight2/miami")

boundary <- st_read("miami_boundary_3086.geojson") %>% 
  st_as_sf()

alan <- raster::raster("miami_nightlihgt_yearly/h09v06_meanAlan.tif")

boundary_4326 <- st_transform(boundary, "epsg: 4326")

alan <- alan %>% 
  crop(boundary_4326) %>% 
  mask(boundary_4326)

alan <- projectRaster(alan, 
                      crs = crs(boundary))

writeRaster(alan,
            "alanYearlyMean_miami.tif",
            overwrite = T)