library(sf)
library(raster)
library(sf)
library(tidyr)

createIncomeMedianRaster<-
  function(
    pathToPopulationCsv,
    pathToCensusTractData,
    pathToCityBoundary,
    pathToAlanRaster,
    epsg,
    keyForJoin = "NAME", # Write a code for inner join if needed
    populationColumn
){
  # Reading CSV====
  medianIncomeDf <- read_csv(pathToPopulationCsv) %>%
    tibble::as.tibble()

  # Reading Tract====
  tracts <- st_read(pathToCensusTractData) %>%
    st_as_sf() %>%
    st_transform(epsg) %>%
    inner_join(medianIncomeDf,
               keyForJoin) %>%
    mutate(tractArea = st_area() %>%
             as.numeric())

  # Reading City Boundary Data====
  boundary <- st_read(pathToCensusTractData) %>%
    st_as_sf() %>%
    # Converting crs----
    st_transform(crs = epsg) %>%

  r <- raster(pathToAlanRaster)
  grid <- raster(r) %>%
    slice(st_intersects(x = boundary,
                       y = .)[[1]]) %>%
    # Calculating area of grids----
    mutate(gridArea = st_area(.) %>%
           as.numeric()) %>%

    # Assigning row id for joining later----
    mutate(gridID = 1:nrow())

  # Estimating Income within A Cell====
  gridIncome <- st_intersection(x = tracts,
                                y = grid) %>%
    mutate(intersectedArea = st_area() %>%
             as.numeric) %>%
    mutate(areaPercentageToTract = intersectedArea/ tractArea %>%
                         as.numeric()) %>%
    mutate(intAreaIncomePortion = incomeMedianColumn * areaPercentageToTract) %>%

    # Grouping by grid to add up the population by the grid----
  group_by(gridID) %>%

    # Dropping geometry for summarizing function----
  st_drop_geometry() %>%

    # Calculating population within a grid----
  summarise(.,
            griddedIncome = sum(intAreaIncomePortion,
                                na.rm = TRUE))

  gridIncomeRaster <- grid %>%
    inner_join(gridIncome,
               by = "gridID") %>%
    rasterize(r,
              griddedIncome)

  plot_noaxes(gridPopulationSf)

  writeRaster(gridIncomeRaster,
    paste0(
      epsg,
      "PopulationRaster.tif"),
    overwrite = TRUE)
  }

setwd("G:\GIS Projects\nightlight\nightlight2\miami")
createIncomeMedianRaster(
  "miami_population.csv",
  "florida_tract\cb_2020_12_tract_500k.shp",

)
