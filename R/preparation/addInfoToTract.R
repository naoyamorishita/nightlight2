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
  bOriginal <- st_read(pathToBoundary) %>%
    st_as_sf() %>%
    st_transform(crs = crsUsed)

  # Dissolve the Layer so that All Census Tracts within the Boundary Extracted====
  b <- bOriginal %>%
    dplyr::mutate(a = st_area(.) %>%
                     as.numeric(.)) %>%
    dplyr::summarize(total_area = sum(a))

  # Read Tract File with Specified CRS====
  trc <- st_read(pathToTract) %>%
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

  print(popDF[1:5, ])
  print(povDF[1:5, ])

  # Make Sure the Key Column Has the Same Name for Inner Join====
  colnames(popDF) <- c("GEOID", "Population")
  colnames(povDF) <- c("GEOID", "Poverty")

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

  print(popDF[1:5, ])

  povDF$ GEOID <- gsub(prefixRemovedFromKeyInPop,
                      "",
                      povDF$ GEOID)
  print(povDF[1:5, ])

  popDF <<- popDF
  povDF <<- povDF



  # Join the DataFrames to Tract====
  tract <<- tr %>%
    dplyr::inner_join(popDF,
               by = "GEOID") %>%
    dplyr::inner_join(povDF,
                      by = "GEOID") %>%
    dplyr::mutate(povRate = Poverty/ Population)

  # Check Result====
  print(tract[1:5,])

  plot(tract %>%
         st_geometry)
  plot(b %>%
         st_geometry,
       col = "red",
       add = T)




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

la <- createTractLayer(
  "./la/City_Boundary.geojson",
  "./la/cb_2020_06_tract_500k/cb_2020_06_tract_500k.shp",
  "epsg:32611",
  "./la/DECENNIALPL2020.P1_2023-12-30T190657/DECENNIALPL2020.P1-Data.csv",
  "./la/ACSST5Y2020.S1701_2023-12-30T190610/ACSST5Y2020.S1701-Data.csv",
  "P1_001N",
  "S1701_C01_042E",
  "GEO_ID",
  "1400000US",
  "1400000US",
  "./la/census/censusTractLa.shp"
)

chicago <- createTractLayer(
  "./chicago/Boundaries - City.geojson",
  "./chicago/cb_2020_17_tract_500k/cb_2020_17_tract_500k.shp",
  "epsg:32616",
  "./chicago/DECENNIALPL2020.P1_2024-01-01T114210/DECENNIALPL2020.P1-Data.csv",
  "./chicago/ACSST5Y2020.S1701_2024-01-01T114342/ACSST5Y2020.S1701-Data.csv",
  "P1_001N",
  "S1701_C01_042E",
  "GEO_ID",
  "1400000US",
  "1400000US",
  "./chicago/censusTractChicago.shp"
)

philly <- createTractLayer(
  "./philladelphia/City_Limits.geojson",
  "./philladelphia/cb_2020_42_tract_500k/cb_2020_42_tract_500k.shp",
  "epsg: 32618",
  "./philladelphia/DECENNIALPL2020.P1_2024-01-01T115033/DECENNIALPL2020.P1-Data.csv",
  "./philladelphia/ACSST5Y2020.S1701_2024-01-01T114944/ACSST5Y2020.S1701-Data.csv",
  "P1_001N",
  "S1701_C01_042E",
  "GEO_ID",
  "1400000US",
  "1400000US",
  "./philladelphia/census/censusTractphilly.shp"
)

phoenix <- createTractLayer(
  "./phoenix/City_Limit_Dark_Outline.geojson",
  "./phoenix/cb_2020_04_tract_500k/cb_2020_04_tract_500k.shp",
  "epsg: 32612",
  "./phoenix/DECENNIALPL2020.P1_2023-12-31T163121/DECENNIALPL2020.P1-Data.csv",
  "./phoenix/ACSST5Y2020.S1701_2023-12-31T163239/ACSST5Y2020.S1701-Data.csv",
  "P1_001N",
  "S1701_C01_042E",
  "GEO_ID",
  "1400000US",
  "1400000US",
  "./phoenix/census/censusTractPhoenix.shp"
)

providence <- createTractLayer(
  "./providence/Nhoods/Nhoods.shp",
  "./providence/cb_2020_44_tract_500k/cb_2020_44_tract_500k.shp",
  "epsg: 32619",
  "./providence/DECENNIALPL2020.P1_2024-01-06T100802/DECENNIALPL2020.P1-Data.csv",
  "./providence/ACSST5Y2020.S1701_2023-12-31T164307/ACSST5Y2020.S1701-Data.csv",
  "P1_001N",
  "S1701_C01_042E",
  "GEO_ID",
  "1400000US",
  "1400000US",
  "./providence/census/censusTractProvidence.shp"
)
