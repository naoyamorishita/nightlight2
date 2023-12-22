library(sf)
library(raster)
library(sf)
library(tidyr)

setwd("/Volumes/volume 1/GIS Projects/nightlight/nightlight2/miami")

# boundary <- st_read("miami_boundary_3086.geojson") %>% 
#   st_as_sf()
# 
# alan <- raster::raster("miami_nightlihgt_yearly/h09v06_meanAlan.tif")
# 
# boundary_4326 <- st_transform(boundary, "epsg: 4326")
# 
# alan <- alan %>% 
#   crop(boundary_4326) %>% 
#   mask(boundary_4326)
# 
# alan <- projectRaster(alan, 
#                       crs = crs(boundary))
# 
# writeRaster(alan,
#             "alanYearlyMean_miami.tif",
#             overwrite = T)

formatAlan <- function(
    pathToAlan,
    pathToboundary,
    outPath
){
  b <- st_read(pathToboundary)
  b4326 <- st_transform(boundary, 
                        "epsg: 4326")
  
  alan <- raster::raster(pathToAlan) %>% 
    crop(b4326) %>% 
    mask(b4326) %>% 
    projectRaster(crs = crs(b))
  
  writeRaster(alan,
              outPath,
              overwrite = T)
}

formatRasterToAlan <- function(
    pathToRaster,
    pathToAlan,
    outPath
){
  r <- raster::raster(pathToRaster)
  alan <- raster::raster(pathToAlan)
  
  r <-
  r %>% 
    projectRaster(crs = crs(alan)) %>% 
    resample(y = alan)
  
  print(r)
  plot(r)
  
  writeRaster(r,
              outPath,
              overwrite = T)
}

formatRasterToAlan("miami_ndvi.tif",
                   "alanYearlyMean_miami.tif",
                   "ndvi_coarsened.tif")