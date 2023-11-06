library(geospaar)
createNDVI <- function(
  pathToRed,
  pathToNIR,
  boundary,
  epsg,
  city
){
 red  <- raster::raster(pathToRed)
 crs(red) <- epsg
 nir <- raster::raster(pathToNIR)
 crs(nir) <- epsg
 boundary <- st_read(boundary) %>%
   st_transform(red)

 b <- raster::brick(red, nir)

 b <- b %>%
   raster::mask(boundary) %>%
   raster::crop(boundary)

 ndvi <- (b[2]-b[1])/ (b[2]+b[1])

 ndvi %>%
   plot_noaxes()

 n <- paste0(city,
             "_ndvi.tif")
 writeRaster(ndvi,
             paste0("data/",
                    n),
             overwrite = T)
}
