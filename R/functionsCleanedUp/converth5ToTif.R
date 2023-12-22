library(geospaar)

# CREATE FUNCTION####
convertH5ToAverageAlan <- function(
    folder,
    pathToTile,
    TileId
){
  setwd(folder)
  # Listing File of H5 in the Folder====
  h5s <- list.files(pattern = "*.h5")

  # Reading Tile to Retrieve Information====
  tile <<- st_read(pathToTile) %>%
    st_as_sf() 
  print(tile)
  
  print(TileId)
  
  print(TileId)
  
  tile <- tile%>% 
    filter(
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
        TileId,
        "_meanAlan.tif"
      ),
      overwrite = T
    )
}

convertH5ToAverageAlan(
  "/Volumes/volume 1/GIS Projects/nightlight/nightlight2/miami/miami_nightlihgt_yearly",
  "/Volumes/volume 1/GIS Projects/nightlight/nightlight2/BlackMarbleTiles/BlackMarbleTiles/BlackMarbleTiles.shp",
  TileId = "h09v06"
)
