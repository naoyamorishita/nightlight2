# In Landsat 8-9, SAVI = ((Band 5 – Band 4) / (Band 5 + Band 4 + 0.5)) * (1.5).
# https://www.usgs.gov/landsat-missions/landsat-soil-adjusted-vegetation-index
library(geospaar)

# Reading Files====
b4 <- raster::raster("/Volumes/volume 1/GIS Projects/nightlight/phoenix/landsat_1406/LC08_L2SP_037037_20130618_20200912_02_T1_SR_B4.TIF")
b5 <- raster::raster("/Volumes/volume 1/GIS Projects/nightlight/phoenix/landsat_1406/LC08_L2SP_037037_20130618_20200912_02_T1_SR_B5.TIF")
boundary <- st_read("./data/bld_grid.geojson") %>%
  st_as_sf() %>%
  st_transform(crs = crs(b5))

# Clipping Rasters====
b4 <- b4 %>%
  crop(., boundary) %>%
  mask(., boundary)

b5 <- b5 %>%
  crop(., boundary) %>%
  mask(., boundary)

# Calculating SAVI====
savi <- ((b5 - b4) / (b5 + b4 + 0.5)) * (1.5)

# Writing Raster File====
writeRaster(savi,
            "/Volumes/volume 1/GIS Projects/nightlight/phoenix/landsat_1406/savi_1406.tif")
