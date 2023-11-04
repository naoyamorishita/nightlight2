library(geospaar)

# CREATE FUNCTION####
convertH5ToAverageAlan <- function(
    folder,
    pathToTile,
    tileID
){
  setwd(folder)
  # Listing File of H5 in the Folder====
  h5s <- list.files(pattern = "*.h5")

  # Reading Tile to Retrieve Information====
  tile <- st_read(pathToTile) %>%
    st_as_sf() %>%
    filter(
      tileID == tileID
    )

  # Reading and Listing Each Raster from the Path=====
  data <- lapply(
    h5s,
    function(x){

      # Reading raster from the path----
      x <- raster::raster(x) # reading files as raster formet
  })

  # Getting Meta Data to H5====
  for (i in 1:length(data)){
    # Getting extent from epsg 4326----
    extent(data[[i]]) <- extent(ref)

    # Getting crs from epsg 4326----
    crs(data[[i]]) <- crs(ref)

    # Assigning 0 to water surface----
    data[[i]][data[[i]] == 65535] <- 0
  }

  # Stacking Raster as Brick====
  b <- raster::brick(data)

  # Calculating Mean====
  meanAlan <- calc(b, fun = "mean")

  # Exporting as Tif
  meanAlan %>%
    writeRaster(
      paste0(
        tileID,
        "_meanAlan.tif"
      ),
      overwrite = T
    )
}
