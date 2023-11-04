library(geospaar)
setwd("/Volumes/volume 1/GIS Projects/nightlight/providence/final")

# Reading Reference Raster Layer====
r <- raster("sep_mean.TIF")

r[r >= 0] <- 0

# Reading Edited Layer====
p <- st_read("ph_res_grid.geojson") %>% st_as_sf %>%
  st_transform(crs = crs(r))

# Writing Rasters
ras <- rasterize(p, r, field = "TOTAL_OCCUPIED")
plot(ras)

writeRaster(ras,
            "ph_res_grid.tif")
