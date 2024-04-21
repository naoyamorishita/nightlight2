# READ LIBRARIES####
library(sf)
library(raster)
library(tidyr)

# DEFINE FUNCTION####
createNDVI <- function(
    pathToRed,
    pathToNIR,
    pathToboundary,
    city,
    outpath
){
  gc()
  # Read Files====
  red  <- raster::raster(pathToRed)
  nir <- raster::raster(pathToNIR)

  # Read Boundary====
  boundary <- st_read(pathToboundary) %>%
    # Align CRS: We are using landsat so I am expecting UTM Zone is "right"====
    st_transform(crs = crs(red))

  # Reduce File Size by Masking Raster by Boundary====
  b <- raster::brick(red, nir)

  b <- raster::mask(x = b,
                    mask = boundary)

  b <- raster::crop(x = b,
                    y = boundary)

  # Calculate NDVI by (Band5 - Band 4)/ (Band5 + Band4) of Landsat8 and 9====
  ndvi <- (b[[2]]-b[[1]])/ (b[[2]]+b[[1]])

  # Check Output====
  ndvi %>%
    plot()

  # Clarify Cities and NDVI in the File Name====
  n <- paste0("/",
              city,
              "_ndvi.tif")

  # Write Raster File====
  writeRaster(ndvi,
              paste0(outpath,
                     n),
              overwrite = T)
  gc()
}

# Define File Locations====
setwd("F:/GIS Projects/nightlight/nightlight2")

# Apply Function to Each City====
createNDVI(
  "./nyc/LandsatSr/LC08_L2SP_013032_20230809_20230812_02_T1_SR_B4.TIF",
  "./nyc/LandsatSr/LC08_L2SP_013032_20230809_20230812_02_T1_SR_B5.TIF",
  "./nyc/Borough Boundaries.geojson",
  "nyc",
  "./nyc"
)

createNDVI(
  "./la/landsat/LC09_L2SP_041036_20220802_20230405_02_T1_SR_B4.TIF",
  "./la/Landsat/LC09_L2SP_041036_20220802_20230405_02_T1_SR_B5.TIF",
  "./la/City_Boundary.geojson",
  "la",
  "./la"
)

createNDVI(
  "./chicago/landsat/LC09_L2SP_023031_20220703_20230408_02_T1_SR_B4.TIF",
  "./chicago/Landsat/LC09_L2SP_023031_20220703_20230408_02_T1_SR_B5.TIF",
  "./chicago/Boundaries - City.geojson",
  "chicago",
  "./chicago"
)

createNDVI(
  "./philladelphia/landsat/LC09_L2SP_014032_20220704_20230408_02_T1_SR_B4.TIF",
  "./philladelphia/landsat/LC09_L2SP_014032_20220704_20230408_02_T1_SR_B5.TIF",
  "./philladelphia/City_Limits.geojson",
  "philly",
  "./philladelphia"
)

createNDVI(
  "./phoenix/landsat/LC09_L2SP_037037_20220806_20230404_02_T1_SR_B4.TIF",
  "./phoenix/landsat/LC09_L2SP_037037_20220806_20230404_02_T1_SR_B5.TIF",
  "./phoenix/City_Limit_Dark_Outline.geojson",
  "phoenix",
  "./phoenix"
)

createNDVI(
  "./providence/landsat/LC09_L2SP_012031_20220722_20230406_02_T1_SR_B4.TIF",
  "./providence/landsat/LC09_L2SP_012031_20220722_20230406_02_T1_SR_B5.TIF",
  "./providence/Nhoods/Nhoods.shp",
  "providence",
  "./providence"
)

createNDVI("./miami/LC08_L2SP_015042_20230503_20230509_02_T1_SR_B4.TIF",
           "./miami/LC08_L2SP_015042_20230503_20230509_02_T1_SR_B5.TIF",
           "./miami/miami_boundary.geojson",
           "miami",
           "./miami"
           )
