library(geospaar)
setwd("/Volumes/volume 1/GIS Projects/nightlight/providence/landsat")

b2 <- raster::raster("LC08_L2SP_012031_20230530_20230607_02_T1_SR_B2.TIF")
b4 <- raster::raster("LC08_L2SP_012031_20230530_20230607_02_T1_SR_B4.TIF")
b5 <- raster::raster("LC08_L2SP_012031_20230530_20230607_02_T1_SR_B5")

rasters <- brick(b2, b4, b5)

b <- st_read("/Volumes/volume 1/GIS Projects/nightlight/providence/Nhoods/Nhoods.shp") %>%
  st_as_sf() %>%
  st_transform(crs = crs(rasters))

rasters <- crop(rasters, b)
rasters <- mask(rasters, b)

rm(boundary, nir_2022, red_2022, swir_2022)
gc()

# EVI = G * ((NIR - R) / (NIR + C1 * R – C2 * B + L))
# In Landsat 8-9, EVI = 2.5 * ((Band 5 – Band 4) / (Band 5 + 6 * Band 4 – 7.5 * Band 2 + 1)).
# ndvi_2022 <- (rasters[[2]] - brick_2022[[1]])/ (brick_2022[[2]] + brick_2022[[1]])
# ndbi_2022 <- (brick_2022[[3]] - brick_2022[[2]])/ (brick_2022[[3]] + brick_2022[[2]])

evi <- 2.5* ((rasters[[3]] - rasters[[2]])/ (rasters[[3]] + 6*rasters[[2]] - 7.5*rasters[[1]] + 1))

ndvi <- (rasters[[3]] - rasters[[2]])/ (rasters[[3]] + rasters[[2]])
evi[evi < -1 || evi > 1] <- 0

writeRaster(ndvi,
            "/Volumes/volume 1/GIS Projects/nightlight/providence/final/ndvi.tif",
            "GTIFF",
            overwrite = T)

# writeRaster(ndbi_2022,
#             "/Volumes/volume/GIS Projects/nightlight/phoenix/landsat_2205/ndbi_2022.TIF",
#             "GTIFF",
#             overwrite = T)
