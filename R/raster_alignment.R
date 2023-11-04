library(geospaar)

# Reading Reference Raster Layer====
r <- raster("/Users/naoyamorishita/Documents/working/nightlight/data/providence_ri/jan_mean.TIF")

r[r >= 0] <- 0

# Reading Edited Layer====
e_raster <- raster::raster("/Users/naoyamorishita/Documents/working/nightlight/data/providence_ri/ndvi.tif")

# Changing CRS & Extent====
crs(e_raster) <- crs(r)
extent(e_raster) <- extent(r)

# Aggregating & Resampling Rasters====
e_raster <- aggregate(e_raster, fact = raster::res(r)/raster::res(e_raster))
e_raster <- resample(x = e_raster, y = r)
plot(e_raster)

# Writing Rasters====
writeRaster(e_raster,
            "/Users/naoyamorishita/Documents/working/nightlight/data/providence_ri/ndvi.ti",
            "GTiff",
            overwrite = T)
