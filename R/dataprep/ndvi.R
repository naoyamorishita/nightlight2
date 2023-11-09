library(geospaar)

createNDVI <- function(
    pathToRed,
    pathToNIR,
    pathToboundary,
    city,
    outpath
){
  gc()
  red  <- raster::raster(pathToRed)
  nir <- raster::raster(pathToNIR)
  boundary <- st_read(pathToboundary) %>%
    st_transform(crs = crs(red))

  b <- raster::brick(red, nir)

  b <- raster::mask(x = b,
                    mask = boundary)
  b <- raster::crop(x = b,
                    y = boundary)

  ndvi <- (b[[2]]-b[[1]])/ (b[[2]]+b[[1]])

  ndvi %>%
    plot_noaxes()

  n <- paste0(city,
              "_ndvi.tif")

  writeRaster(ndvi,
              paste0(outpath,
                     n),
              overwrite = T)
  gc()
}

createNDVI(
  "F:/GIS Projects/nightlight/toBePublished/miami/miami_red.tif",
  "F:/GIS Projects/nightlight/toBePublished/miami/miami_nir.tif",
  "F:/GIS Projects/nightlight/toBePublished/miami/miami_boundary.geojson",
  "miami",
  "F:/GIS Projects/nightlight/toBePublished/miami/"
)
