library(raster)

r <- raster("/Volumes/volume/GIS Projects/nightlight/phoenix/VNP46A3.A2013001.h08v05.001.2021124163433.h5")

r[r == 65535] <- 0

r2 <- raster("/Volumes/volume/GIS Projects/nightlight/phoenix/VNP46A3.A2013001.h07v05.001.2021124163430.h5")
r2[r2 == 65535] <- 0

r3 <- raster("/Volumes/volume/GIS Projects/nightlight/phoenix/VNP46A3.A2014001.h06v05.001.2021124163744.h5")
plot(r3)
