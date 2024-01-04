alignRaster <- function(
    pathToRasterAligned,
    pathToReferenceRaster,
    outPath
){
  # Read File====
  r <- raster::raster(pathToRasterAligned)
  ref <- raster::raster(pathToReferenceRaster)

  r <-
    r %>%
    projectRaster(crs = crs(ref)) %>%
    resample(y = ref)

  print(r)
  plot(r)

  writeRaster(r,
              outPath,
              overwrite = T)
}

# APPLY FUNCTION####
