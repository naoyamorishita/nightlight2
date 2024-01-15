library(sf)
library(raster)
library(tidyr)

# CREATE FUNCTION####
convertH5ToAverageAlan <- function(
    folder,
    pathToTile,
    TileId,
    outPath
){
  # Listing File of H5 in the Folder====
  h5s <- list.files(path = folder,
                    pattern = "*.h5",
                    full.names = T)

  # Reading Tile to Retrieve Information====
  tile <- st_read(pathToTile) %>%
    st_as_sf()

  tile <- tile%>%
    dplyr::filter(
      TileID == TileId
    )
  print(tile)

  # Reading and Listing Each Raster from the Path=====
  data <- lapply(
    h5s,
    function(x){
      # Reading raster from the path----
      x <- raster::raster(x) # reading files as raster formet
  })
  print(data)

  # Getting Meta Data to H5====
  for (i in 1:length(data)){
    # Getting extent from epsg 4326----
    extent(data[[i]]) <- extent(tile)

    # Getting crs from epsg 4326----
    crs(data[[i]]) <- crs(tile)

    # Assigning 0 to water surface----
    data[[i]][data[[i]] == 65535] <- 0
  }

  # Stacking Raster as Brick====
  b <- raster::brick(data)

  # Calculating Mean for Generating a Single Tif====
  meanAlan <- calc(b, fun = mean)

  print(meanAlan)

  # Exporting as Tif====
  meanAlan %>%
    writeRaster(
      paste0(
        "./data/",
        TileId,
        "_meanAlan.tif"
      ),
      overwrite = T
    )
  gc()
}

# Apply the Function====
# Set file locations----
setwd("G:/GIS Projects/nightlight/nightlight2")
tileLoc <- "/BlackMarbleTiles/BlackMarbleTiles/BlackMarbleTiles.shp"

# Apply functions to each raster file----
convertH5ToAverageAlan("./nyc/ntl", tileLoc, "h10v04")
convertH5ToAverageAlan("./la/nightlight", tileLoc, "h06v05")
convertH5ToAverageAlan("./chicago/nightlight", tileLoc, "h09v04")
convertH5ToAverageAlan("./philladelphia/nighlight_h10v05", tileLoc, "h10v05")
convertH5ToAverageAlan("G:/GIS Projects/nightlight/nightlight2/miami/ntl",
                       "G:/GIS Projects/nightlight/nightlight2/BlackMarbleTiles/BlackMarbleTiles/BlackMarbleTiles.shp",
                       "h09v06")


gc()
