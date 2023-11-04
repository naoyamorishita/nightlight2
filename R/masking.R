# Importing Necessary Libraries====
library(sf)
library(raster)

# Specifying Working Directory ====
path = "/Volumes/volume/GIS Projects/nightlight/phoenix/nightlight_tif"
setwd("/Volumes/volume/GIS Projects/nightlight/phoenix/nightlight_original") # folder your files are located

# Listing the Night Light Files====
tifs <- list.files(pattern = "*.tif|*.TIF")



data <- lapply(tifs, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

# Reading Boundary File====
boundary <- st_read("/Volumes/volume/GIS Projects/nightlight/phoenix/city_boundary/City_Limit_Dark_Outline.shp") %>% st_as_sf() %>%
  st_transform(crs = crs(data[[1]]))

for (i in 1:length(data)){ # for all data in the raster objects list
  data[[i]] <- crop(data[[i]], boundary)
  data[[i]] <- mask(data[[i]], boundary)
}
for (i in 1:length(data)){
  writeRaster(data[[i]], # the first raster only
              filename = file.path(path, tifs[[i]]), # exporting to the current working dir # with name of "ref_tif.tif"
              format = "GTiff", # GTiff format
              overwrite = T) # if the same file exist, overriteit
}
