library(geospaar)

red_2014 <- raster::raster("/Volumes/volume/GIS Projects/nightlight/phoenix/landsat_1405/b4.TIF")
nir_2014 <- raster::raster("/Volumes/volume/GIS Projects/nightlight/phoenix/landsat_1405/b5.TIF")
swir_2014 <- raster::raster("/Volumes/volume/GIS Projects/nightlight/phoenix/landsat_1405/b7.TIF")

brick_2014 <- brick(red_2014, nir_2014, swir_2014)

boundary <- st_read("/Volumes/volume/GIS Projects/nightlight/phoenix/city_boundary/City_Limit_Dark_Outline.shp") %>% st_as_sf() %>%
  st_transform(crs = crs(brick_2014))

brick_2014 <- crop(brick_2014, boundary)
brick_2014 <- mask(brick_2014, boundary)

ndvi_2014 <- (brick_2014[[2]] - brick_2014[[1]])/ (brick_2014[[2]] + brick_2014[[1]])
ndbi_2014 <- (brick_2014[[3]] - brick_2014[[2]])/ (brick_2014[[3]] + brick_2014[[2]])

writeRaster(ndvi_2014,
            "/Volumes/volume/GIS Projects/nightlight/phoenix/landsat_1405/ndvi_2014.TIF",
            "GTIFF",
            overwrite = T)

writeRaster(ndbi_2014,
            "/Volumes/volume/GIS Projects/nightlight/phoenix/landsat_1405/ndbi_2014.TIF",
            "GTIFF",
            overwrite = T)
