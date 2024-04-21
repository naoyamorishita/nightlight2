# IMPORT LIBRARIES####
library(sf)
library(raster)
library(tidyr)

# DEFINE FUNCTION####
alignRaster <- function(
    pathToRasterAligned,
    pathToReferenceRaster,
    outPath
){
  # Read File====
  r <- raster::raster(pathToRasterAligned)
  ref <- raster::raster(pathToReferenceRaster)

  # Repoject and Resample Raster====
  r <-
    r %>%
    projectRaster(crs = crs(ref)) %>%
    resample(y = ref)

  print(r)

  # Export Raster====
  writeRaster(r,
              outPath,
              overwrite = T)
}

# SET UP FILE LOCATIONS####
setwd("G:/GIS Projects/nightlight/nightlight2")

# Make a Function to Return File Location====
fileLoc <- function(fileName){
  return(
    # Return file location by combining path and file name----
    paste0("C:/Users/NMorishita/Documents/GitHub/nightlight2/data/",
           fileName))
}

# APPLY FUNCTION####
alignRaster("./nyc/nyc_ndvi.tif", fileLoc("nycNtl.tif"), fileLoc("nycNdvi.tif"))
alignRaster("./la/la_ndvi.tif", fileLoc("laNtl.tif"), fileLoc("laNdvi.tif"))
alignRaster("./chicago/chicago_ndvi.tif", fileLoc("chicagoNtl.tif"), fileLoc("chicagoNdvi.tif"))
alignRaster("./philladelphia/philly_ndvi.tif", fileLoc("phillyNtl.tif"), fileLoc("phillyNdvi.tif"))
alignRaster("./phoenix/phoenix_ndvi.tif", fileLoc("phoenixNtl.tif"), fileLoc("phoenixNdvi.tif"))
alignRaster("./providence/providence_ndvi.tif", fileLoc("providenceNtl.tif"), fileLoc("providenceNdvi.tif"))
alignRaster("./miami/miami_ndvi.tif", fileLoc("miamiNtl.tif"), fileLoc("miamiNdvi.tif"))
