# For Landsat 8 data, NDBI = (Band 6 – Band 5) / (Band 6 + Band 5)
# https://www.linkedin.com/pulse/ndvi-ndbi-ndwi-calculation-using-landsat-7-8-tek-bahadur-kshetri/

# Reading Files====
b5 <- raster::raster("/Volumes/volume 1/GIS Projects/nightlight/phoenix/landsat_2206/LC09_L2SP_037037_20220619_20230411_02_T1_SR_B5.TIF")
b6 <- raster::raster("/Volumes/volume 1/GIS Projects/nightlight/phoenix/landsat_2206/LC09_L2SP_037037_20220619_20230411_02_T1_SR_B6.TIF")
boundary <- st_read("./data/bld_grid.geojson") %>%
  st_as_sf() %>%
  st_transform(crs = crs(b5))

# Clipping Rasters====
b5 <- b5 %>%
  crop(., boundary) %>%
  mask(., boundary)

b6 <- b6 %>%
  crop(., boundary) %>%
  mask(., boundary)

# Calculating SAVI====
ndbi <- ((b6 - b5) / (b6 + b5))

# Writing Raster File====
writeRaster(ndbi,
            "/Volumes/volume 1/GIS Projects/nightlight/phoenix/landsat_2206/ndbi_2206.tif")
