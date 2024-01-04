# READ DATA####
library(sf)
library(raster)
library(tidyr)

# Read Boundary Data====
createTractLayer <- function(
    pathToBoundary,
    pathToTract,
    crsUsed,
    pathToPopulationCSV,
    pathToPovertyFile,
    colsRetainedInPop,
    colsRetainedInPov,
    key,
    prefixRemovedFromKeyInPop,
    prefixRemovedFromKeyInPov,
    outPath
  ){

  # Read Boundary File with Specified CRS====
  b <<- st_read(pathToBoundary) %>%
    st_as_sf() %>%
    st_transform(crs = crsUsed) %>%
    # Dissolve the layer with calculating the total area of nyc to solve a logical error----
    dplyr::mutate(a = st_area(.) %>%
                     as.numeric(.)) %>%
    dplyr::summarize(total_area = sum(a))

  # Read Tract File with Specified CRS====
  trc <<- st_read(pathToTract) %>%
    st_as_sf() %>%
    st_transform(crs = crsUsed)
    # Extract tracts intersecting with the boundary----
  tr <<- dplyr::slice(trc,
                      st_intersects(x = b,
                               y = trc)[[1]]) %>%
    dplyr::select(GEOID)

  # Read Population File====
  popDF <- read.csv(pathToPopulationCSV) %>%
    # Place tracts names in the row by transpose----
    as.data.frame()

  # Read Poverty File==== %>%
  povDF <- read.csv(pathToPovertyFile) %>%
    as.data.frame()

  # Remove Unnecessary Columns and Rows====
  popDF <- popDF[-1, c(key, colsRetainedInPop)]
  povDF <- povDF[-1, c(key, colsRetainedInPov)]

  # Make Sure the Key Column Has the Same Name for Inner Join====
  colnames(popDF) <- c("GEOID", "Population")
  colnames(povDF) <- c("GEOID", "Poverty")

  popDF1 <<- popDF
  povDF1 <<- povDF

  # Remove "," in Numbers====
  popDF$ Population <- as.integer(gsub(",",
                                       "",
                                       popDF$ Population))

  povDF$ Poverty <- as.integer(gsub(",",
                                    "",
                                    povDF$ Poverty))



  # Format Tract Names====
  popDF$ GEOID <- gsub(prefixRemovedFromKeyInPop,
                      "",
                      popDF$ GEOID)
  povDF$ GEOID <- gsub(prefixRemovedFromKeyInPop,
                      "",
                      povDF$ GEOID)



  # Join the DataFrames to Tract====
  tract <<- tr %>%
    dplyr::inner_join(popDF,
               by = "GEOID") %>%
    dplyr::inner_join(povDF,
                      by = "GEOID")

  # Check Result====
  plot(tract %>%
         st_geometry())

  print(tract[1:5,])

  # Write the File====
  tract %>%
    st_write(outPath)
}

# APPLY THE FUNCTION####
setwd("F:/GIS Projects/nightlight/nightlight2")

nyc <-
createTractLayer(
  "./nyc/Borough Boundaries.geojson",
  "./nyc/census/tl_2022_36_tract/tl_2022_36_tract.shp",
  "epsg:32618",
  "./nyc/census/DECENNIALPL2020.P1_2023-12-27T184442/DECENNIALPL2020.P1-Data.csv",
  "./nyc/census/ACSST5Y2020.S1701_2023-12-27T184707/ACSST5Y2020.S1701-Data.csv",
  "P1_001N",
  "S1701_C01_042E",
  "GEO_ID",
  "1400000US",
  "1400000US",
  "./nyc/census/censusTractNyc.shp")
