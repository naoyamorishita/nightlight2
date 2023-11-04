library(raster)
library(sf)
library(dplyr)

r <- raster("/Volumes/volume 1/GIS Projects/nightlight/providence/light_final/mean_all.tif")
plot(r)

r[r >= 0] <- 0
plot(r)

r[] <- 1:ncell(r)

boundary <- st_read("/Volumes/volume 1/GIS Projects/nightlight/providence/Nhoods/Nhoods.shp") %>%
  st_as_sf() %>%
  st_transform(crs = crs(r))

r <- mask(r, boundary)

p <- rasterToPolygons(r) %>%
  st_as_sf() %>%
  dplyr::select(id = layer)

st_write(p,
         "/Volumes/volume 1/GIS Projects/nightlight/providence/final/grid.geojson")
