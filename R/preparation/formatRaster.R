# READ LIBRARIES####
library(sf)
library(raster)
library(tidyr)

# DEFINE FUNCTION####
formatAlan <- function(
    pathToAlan,
    pathToboundary,
    epsg,
    outPath
){
  # Read Boundary File and Transform CRS====
  b <- st_read(pathToboundary) %>%
    st_transform(crs = epsg)
  b4326 <- st_transform(b,
                        "epsg: 4326")

  # alan <- raster::raster(pathToAlan) %>%
  #   crop(b4326) %>%
  #   mask(b4326) %>%
  #   projectRaster(crs = crs(b))

  # Read NTL Data, Reproject it, and Crop and Mask the Layer by the Bounadry====
  # If this does not work, try the codes above----
  alan <- raster::raster(pathToAlan) %>%
    projectRaster(crs = crs(b)) %>%
    crop(b) %>%
    mask(b)

  # Export the Masked Layer====
  writeRaster(alan,
              outPath,
              overwrite = T)
}

# Set Up Folders====
outFolder <- "C:/Users/NMorishita/Documents/GitHub/nightlight2/data/"
setwd("G:/GIS Projects/nightlight/nightlight2")

# Apply Function to Each City====
formatAlan("./nyc/ntl/h10v04_meanAlan.tif",
           "./nyc/Borough Boundaries.geojson",
           "epsg:32618", # UTM ZONE 18N: https://epsg.io/32618
           paste0(outFolder,
                  "nycNtl.tif"))

formatAlan("./la/nightlight/h06v05_meanAlan.tif",
           "./la/City_Boundary.geojson",
           "epsg:32611", # UTM ZONE 11N: https://epsg.io/32611
           paste0(outFolder,
                  "laNtl.tif"))

formatAlan("./chicago/nightlight/h09v04_meanAlan.tif",
           "./chicago/Boundaries - City.geojson",
           "epsg:32616", # UTM ZONE 16N: https://epsg.io/32616
           paste0(outFolder,
                  "chicagoNtl.tif"))

formatAlan("./chicago/nightlight/h09v04_meanAlan.tif",
           "./chicago/Boundaries - City.geojson",
           "epsg:32616", # UTM ZONE 16N: https://epsg.io/32616
           paste0(outFolder,
                  "chicagoNtl.tif"))

# Mosaic raster for philladelphia----
raster::raster("./nyc/ntl/h10v04_meanAlan.tif") %>%
  raster::merge(raster::raster("./philladelphia/nighlight_h10v05/h10v05_meanAlan.tif")) %>%
  raster::writeRaster(.,
                      filename = "./philladelphia/ntlMosaic.tif")
# Apply Functions====
formatAlan("./philladelphia/ntlMosaic.tif",
           "./philladelphia/City_Limits.geojson",
           "epsg: 32618", #
           paste0(outFolder,
                  "phillyNtl.tif"))

formatAlan("./la/nightlight/h06v05_meanAlan.tif",
           "./phoenix/City_Limit_Dark_Outline.geojson",
           "epsg: 32612",
           paste0(outFolder,
                  "phoenixNtl.tif"))

formatAlan("./nyc/ntl/h10v04_meanAlan.tif",
           "./providence/Nhoods/Nhoods.shp",
           "epsg: 32619",
           paste0(outFolder,
                  "providenceNtl.tif"))

formatAlan("./miami/ntl/h09v06_meanAlan.tif",
           "./miami/miami_boundary_3086.geojson",
           "epsg: 32617",
           paste0(outFolder,
                  "miamiNtl.tif"))
