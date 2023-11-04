library(raster)

setwd("/Volumes/volume 1/GIS Projects/nightlight/providence/lights_tif") # folder your files are located
outpath <- "/Volumes/volume 1/GIS Projects/nightlight/providence/light_final"

# January====
tifs_jan <- list.files(pattern = "*001.tif|*002.tif") # change "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_jan <- lapply(tifs_jan, function(x){
  paste0(substr(x, 1, 8),
         "-1")# creating a list of shortened file names # like "A2019335"
})

data_jan <- lapply(tifs_jan, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_jan)<- as.vector(tif_names_jan)

jan <- brick(data_jan) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "jan_mean.TIF"),
              "GTIFF",
              overwrite = T)

# February====
tifs_feb <- list.files(pattern = "*032.tif|*033.tif") # change "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_feb <- lapply(tifs_feb, function(x){
  paste0(substr(x, 1, 8),
         "-2")# creating a list of shortened file names # like "A2019335"
})

data_feb <- lapply(tifs_feb, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_feb)<- as.vector(tif_names_feb)

feb <- brick(data_feb) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "feb_mean.TIF"),
              "GTIFF",
              overwrite = T)

# March====
tifs_Mar <- list.files(pattern = "*060.tif|*061.tif") # change "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_Mar <- lapply(tifs_Mar, function(x){
  paste0(substr(x, 1, 8),
         "-3")# creating a list of shortened file names # like "A2019335"
})

data_Mar <- lapply(tifs_Mar, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_Mar)<- as.vector(tif_names_Mar)

mar <- brick(data_Mar) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "mar_mean.TIF"),
              "GTIFF",
              overwrite = T)

# April====
tifs_apr <- list.files(pattern = "*091.tif|*092.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_apr <- lapply(tifs_apr, function(x){
  paste0(substr(x, 1, 8),
         "-4")# creating a list of shortened file names # like "A2019335"
})

data_apr <- lapply(tifs_apr, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_apr)<- as.vector(tif_names_apr)

apr <- brick(data_apr) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "apr_mean.TIF"),
              "GTIFF",
              overwrite = T)

# May====
tifs_may <- list.files(pattern = "*121.tif|*122.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_may <- lapply(tifs_may, function(x){
  paste0(substr(x, 1, 8),
         "-5")# creating a list of shortened file names # like "A2019335"
})

data_may <- lapply(tifs_may, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_may)<- as.vector(tif_names_may)

may <- brick(data_may) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "may_mean.TIF"),
              "GTIFF",
              overwrite = T)

# Jun====
tifs_jun <- list.files(pattern = "*152.tif|*153.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_jun <- lapply(tifs_jun, function(x){
  paste0(substr(x, 1, 8),
         "-6")# creating a list of shortened file names # like "A2019335"
})

data_jun <- lapply(tifs_jun, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_jun)<- as.vector(tif_names_jun)

jun <- brick(data_jun) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "jun_mean.TIF"),
              "GTIFF",
              overwrite = T)

# July====
tifs_jul <- list.files(pattern = "*182.tif|*183.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_jul <- lapply(tifs_jul, function(x){
  paste0(substr(x, 1, 8),
         "-7")# creating a list of shortened file names # like "A2019335"
})

data_jul <- lapply(tifs_jul, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_jul)<- as.vector(tif_names_jul)

jul <- brick(data_jul) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "jul_mean.TIF"),
              "GTIFF",
              overwrite = T)

# August====
tifs_aug <- list.files(pattern = "*213.tif| *214.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_aug <- lapply(tifs_aug, function(x){
  paste0(substr(x, 1, 8),
         "-8")# creating a list of shortened file names # like "A2019335"
})

data_aug <- lapply(tifs_aug, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_aug)<- as.vector(tif_names_aug)

aug <- brick(data_aug) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "aug_mean.TIF"),
              "GTIFF",
              overwrite = T)

# September====
tifs_sep <- list.files(pattern = "*244.tif|*245.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_sep <- lapply(tifs_sep, function(x){
  paste0(substr(x, 1, 8),
         "-9")# creating a list of shortened file names # like "A2019335"
})

data_sep <- lapply(tifs_sep, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_sep)<- as.vector(tif_names_sep)

sep <- brick(data_sep) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "sep_mean.TIF"),
              "GTIFF",
              overwrite = T)

# October====
tifs_oct <- list.files(pattern = "*274.tif|*275.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_oct <- lapply(tifs_oct, function(x){
  paste0(substr(x, 1, 8),
         "-10")# creating a list of shortened file names # like "A2019335"
})

data_oct <- lapply(tifs_oct, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_oct)<- as.vector(tif_names_oct)

oct <- brick(data_oct) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "oct_mean.TIF"),
              "GTIFF",
              overwrite = T)

# Novermber====
tifs_nov <- list.files(pattern = "*305.tif|*306.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_nov <- lapply(tifs_nov, function(x){
  paste0(substr(x, 1, 8),
         "-11")# creating a list of shortened file names # like "A2019335"
})

data_nov <- lapply(tifs_nov, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_nov)<- as.vector(tif_names_nov)

nov <- brick(data_nov) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "nov_mean.TIF"),
              "GTIFF",
              overwrite = T)

# December====
tifs_dec <- list.files(pattern = "*335.tif|*336.tif") # CHANGE "001" to some other codes if needed! # list objects with extension of ".h5"
tif_names_dec <- lapply(tifs_dec, function(x){
  paste0(substr(x, 1, 8),
         "-12")# creating a list of shortened file names # like "A2019335"
})

data_dec <- lapply(tifs_dec, function(x){ # creating a list with
  x <- raster::raster(x) # reading files as raster formet
})

names(data_dec)<- as.vector(tif_names_dec)

dec <- brick(data_dec) %>%
  calc(., mean) %>%
  writeRaster(.,
              file.path(outpath, "dec_mean.TIF"),
              "GTIFF",
              overwrite = T)

