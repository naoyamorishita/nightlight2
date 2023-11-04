library(geospaar)

# POPULATION TILE FUNCTION####
createPopulationTile <- function(
    pathToPopulationCsv,
    pathToCensusTractData,
    pathToCityBoundary,
    pathToAlanRaster,
    epsg,
    keyForJoin = "NAME", # Write a code for inner join if needed
    populationColumn
){
  # Reading Population CSV FIlE####
  # Reading Population CSV====
  popCsv <- read_csv(pathToPopulationCSV) %>%
    # Converting into tibble----
    tibble::as.tibble()

  # Reading Census Tract File====
  tracts <- st_read(pathToCensusTractData) %>%
    st_as_sf() %>%

    # Transforming crs----
    st_transform(crs = epsg) %>%

    # Joining with population data to gain the numbers----
    inner_join(popCsv,
               by = keyForJoin) %>%

    # Creating an area column for areal interpolation----
    mutate(tractArea = st_area(.) %>%
             as.numeric())

  # Reading City Boundary Data====
  boundary <- st_read(pathToCensusTractData) %>%
    st_as_sf() %>%

    # Converting crs----
    st_transform(crs = epsg)

  # Reading Alan Data====
  r <- raster(pathToAlanRaster)
  grid <- raster(pathToAlanRaster) %>%

    # Converting raster to polygon----
    rasterToPolygons() %>%

    # Removing na values----
    na.omit() %>%
    st_as_sf() %>%

    # Converting crs for alignment----
    st_transform(crs = epsg) %>%
    # Exrtracting grids within a city----
    slice(st_intersects(x = boundary,
                       y = .)[[1]]) %>%
    # Calculating area of grids----
    mutate(gridArea = st_area(.) %>%
             as.numeric()) %>%

    # Assigning row id for joining later----
    mutate(gridID = 1:nrow())

  # Estimating Population using Areal Interpolation====
  tractsPlusGrid <- st_intersection(x = tracts,
                                    y = grid) %>%

    # Calculating area of intersection----
    mutate(intersectedArea = st_area() %>%
             as.numeric) %>%

    # Estimating population using ratio of areas----
    mutate(estimatedPopulation = as.numeric(populationColumn)/ tractArea* intersectedArea) %>%

    # Grouping by grid to add up the population by the grid----
    group_by(gridID) %>%

    # Dropping geometry for summarizing function----
    st_drop_geometry() %>%

    # Calculating population within a grid----
    summarise(.,
              gridPopulation = sum(estimatedPopulation,
                                   na.rm = TRUE))

  # Creating a Raster of Population====
  gridPopulationRaster <- grid %>%
    inner_join(tractsPlusGrid,
               by = "gridID") %>%
    rasterize(r,
              gridPopulation)

  plot_noaxes(gridPopulationSf)

  writeRaster(
    gridPopulationRaster,
    paste0(
      epsg,
      "PopulationRaster.tif"),
    overwrite = TRUE
  )
}
