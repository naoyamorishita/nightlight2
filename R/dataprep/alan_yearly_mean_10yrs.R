library(sf)
library(tidyr)
library(raster)

# CREATE FUNCTION####
convertH5ToAverageAlan <- function(
    folder,
    pathToTile, # download from https://blackmarble.gsfc.nasa.gov/Tools.html
    TileID
){
  setwd(folder)
  # Listing File of H5 in the Folder====
  h5s <- list.files(pattern = "*.h5")

  # Reading Tile to Retrieve Information====
  tile <<- sf::st_read(pathToTile) %>%
    st_as_sf() %>%
    dplyr::filter(
      TileID == TileID
    )
  print(tile)

  # Reading and Listing Each Raster from the Path=====
  data <- lapply(
    h5s,
    function(x){

      # Reading raster from the path----
      x <- raster::raster(x) # reading files as raster formet
    })
  # print(data)

  # Getting Meta Data to H5====
  for (i in 1:length(data)){
    # Getting extent from epsg 4326----
    extent(data[[i]]) <- extent(tile)

    # Getting crs from epsg 4326----
    crs(data[[i]]) <- crs(tile)

    # Assigning 0 to water surface----
    data[[i]][data[[i]] == 65535] <- 0
  }
  print(data)

  # Stacking Raster as Brick====
  b <- raster::brick(data)

  # Calculating Mean====
  meanAlan <- calc(b, fun = mean)

  # Exporting as Tif
  meanAlan %>%
    writeRaster(
      paste0(
        TileID,
        "_meanAlan.tif"
      ),
      overwrite = T
    )
}


convertH5ToAverageAlan(
  "G:/GIS Projects/nightlight/toBePublished/miami/miami_nightlihgt_yearly",
  "G:/GIS Projects/nightlight/toBePublished/BlackMarbleTiles/BlackMarbleTiles/BlackMarbleTiles.shp",
  "G09v06"
)
