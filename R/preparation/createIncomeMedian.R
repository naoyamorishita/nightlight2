library(sf)
library(raster)
library(tidyr)

createDemographicRasters <- function(
    pathToNtlRaster,
    # Use Layer from addInfoToTract.R====
    pathToTractLayer,
    outPathPop,
    outPathPov){

  # READ FILES####
  ntl <- raster::raster(pathToNtlRaster)
  tract <- st_read(pathToTractLayer) %>%
    st_as_sf() %>%
    # Calculate Area====
    dplyr::mutate(tractArea = st_area(.) %>%
                    as.numeric(.))

  # POLYGONIZE THE RASTER####
  g <<- ntl %>% rasterToPolygons(.) %>%
    st_as_sf() %>%
    # Assign Grid ID for Summary Later====
    dplyr::mutate(gridID = 1:nrow(.)) %>%
    # Make Sure CRS is the Same====
    st_transform(crs = st_crs(tract)) %>%
    # Calculate Area====
    dplyr::mutate(gridArea = st_area(.) %>%
                    as.numeric(.))

  # MAKE AN INTERSECTION LAYER####
  int <- st_intersection(tract, g) %>%
    # Calculate Area of Intersection====
    dplyr::mutate(intArea = st_area(.) %>%
                    as.numeric(.)) %>%
    # Calculate Area Ratio of Intersection/ Tract so that Population is Interpolated====
    dplyr::mutate(ratio = intArea/ tractArea) %>%
    # Interpolate Population & Poverty Population of Intersected Area with the Ratio====
    dplyr::mutate(estPop = Population * ratio) %>%
    dplyr::mutate(estPov = Poverty * ratio) %>%
    # Drop Geometry so that Inner Join can be Done====
    st_drop_geometry(.)

  # SUMMARIZE POPULATION & POVERTY PER GRID####
  gUpdated <- int %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(gPop = sum(estPop),
                     gPov = sum(estPov)) %>%
    # Estimate Poverty Rate====
    dplyr::mutate(povRate = gPov/ gPop)

  # ADD GEOMETRY BY LEFT JOIN####
  g <<- g %>%
    dplyr::left_join(gUpdated,
                     by = "gridID")

  print(gUpdated[1:5,])

  # RASTERIZE GRID & EXPORT IT####
  popr <<-
    rasterize(x = g,
              y = ntl,
              field = "gPop")

  print(popr)

  povr <<-
    rasterize(x =g,
              y = ntl,
              filed = "gPov")
  print(povr)

  # Export Population Raster====

  popr %>%
    writeRaster(x = .,
                outPathPop,
                overWrite = T)

  # Export Poverty Rate Raster====
  povr %>%
    writeRaster(x = .,
                outPathPov,
                overWrite = T)
}

# DEFINE FUNCTION TO RETURN FILE LOCATION OF DATA####
returnPath <- function(fileName){
  dataContainer = "C:/Users/nm200/Desktop/working/nightlight2/data/"
  return(paste0(dataContainer,
                fileName))
}

setwd("F:/GIS Projects/nightlight/nightlight2")

# APPLY FUNCTION####
# Create Layer for NYC====
createDemographicRasters(returnPath("nycNtl.tif"), "./nyc/census/censusTractNyc.shp", returnPath("nycPop.tif"), returnPath("nycPov.tif"))
