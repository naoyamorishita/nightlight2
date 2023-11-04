# Setting Working Directory====
setwd("/Volumes/volume 1/GIS Projects/nightlight/providence/lights_tif")
outpath <- "/Volumes/volume 1/GIS Projects/nightlight/providence/light_final"

# Reading Files====
tifs <- list.files(pattern = "*.tif")

data <- lapply(tifs, function(x){
  raster::raster(x)
})

b <- brick(data)

m <- calc(b, mean)

writeRaster(m,
            file.path(outpath, "mean_all.tif"),
            "GTiff")
