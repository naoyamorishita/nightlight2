# PREPARATION####
library(geospaar)

# Reading Files====
bldr <- raster::raster("/Volumes/volume/GIS Projects/nightlight/phoenix/building_footprint/Arizona_avg.tif")
boundary <- st_read("data/grid.geojson") %>%
  st_as_sf() %>%
  st_transform(crs = crs(bldr))

r <- raster("/Users/naoyamorishita/Documents/working/nightlight/data/jan_mean.TIF")

# Clipping Raster====
bldr <- bldr %>%
  raster::crop(y = boundary) %>%
  raster::mask(mask = boundary)

# Aggregating Raster====
crs(bldr) <- crs(r)
extent(bldr) <- extent(r)
bldr <- aggregate(bldr, fact = raster::res(r)/ raster::res(bldr))
bldr <- resample(bldr, r)

# Finalizing Raster====
bldr %>%
  writeRaster("data/bldr.tif", overwrite = T)

