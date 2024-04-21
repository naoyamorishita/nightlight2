# READ LIBRARIES####
library(sf)
library(raster)
library(tidyr)

# DEFINE FUNCTION####
createDemographicRasters <- function(
    pathToNtlRaster,
    pathToTractLayer,
    outPathPop,
    outPathPov){

  # READ FILES####
  ntl <- raster::raster(pathToNtlRaster)

  # READ FILE FROM ADDINFOTOTRACT.R####
  tract <<- st_read(pathToTractLayer) %>%
    st_as_sf() %>%
    # Calculate Area====
    dplyr::mutate(tractArea = st_area(.) %>%
                    as.numeric(.))

  # POLYGONIZE THE RASTER####
  g <- ntl %>% rasterToPolygons(.) %>%
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
    dplyr::mutate(estCensusPop = CensusPop * ratio) %>%
    dplyr::mutate(estACSPop = ACSPop * ratio) %>%
    dplyr::mutate(estPov = Poverty * ratio) %>%
    # Drop Geometry so that Inner Join can be Done====
    st_drop_geometry(.)

  # SUMMARIZE POPULATION & POVERTY PER GRID####
  gUpdated <- int %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(gCPop = sum(estCensusPop),
                     gAPop = sum(estACSPop),
                     gPov = sum(estPov)) %>%
    # Estimate Poverty Rate====
    dplyr::mutate(povRate = (gPov/ gAPop)*100) %>%
    # Replace with 100 if exceeds 100%====
    dplyr::mutate(povRate = ifelse(povRate > 100,
                                   100,
                                   povRate))

  # ADD GEOMETRY BY LEFT JOIN####
  g <- g %>%
    # Keep Grid without Demographic Info (I am Expecting It does not Exist Though)=====
    dplyr::left_join(gUpdated,
                     by = "gridID")

  print(gUpdated[1:5,])

  # RASTERIZE GRID & EXPORT IT####
  popr <-
    # Project Grid's Population Layer to NTL Raster====
    rasterize(x = g,
              y = ntl,
              field = "gCPop")

  print(popr)
  raster::plot(popr)

  # Project Grid's Poverty Rate Layer to NTL Raster====
  povr <-
    rasterize(x =g,
              y = ntl,
              field = "povRate")
  print(povr)
  raster::plot(povr)

  # Export Population Raster====
  popr %>%
    writeRaster(x = .,
                outPathPop,
                overwrite = TRUE)

  # Export Poverty Rate Raster====
  povr %>%
    writeRaster(x = .,
                outPathPov,
                overwrite = TRUE)
}

# DEFINE FUNCTION TO RETURN FILE LOCATION OF DATA####
returnPath <- function(fileName){
  dataContainer = "C:/Users/nm200/Desktop/working/nightlight2/data/"
  return(paste0(dataContainer,
                fileName))
}

setwd("F:/GIS Projects/nightlight/nightlight2")

# APPLY FUNCTION####
createDemographicRasters(returnPath("nycNtl.tif"), "./nyc/census/censusTractNyc.shp", returnPath("nycPop.tif"), returnPath("nycPovRate.tif"))
createDemographicRasters(returnPath("laNtl.tif"), "./la/census/censusTractla.shp", returnPath("laPop.tif"), returnPath("laPovRate.tif"))
createDemographicRasters(returnPath("chicagoNtl.tif"), "./chicago/census/censusTractChicago.shp", returnPath("chicagoPop.tif"), returnPath("chicagoPovRate.tif"))
createDemographicRasters(returnPath("phillyNtl.tif"), "./philladelphia/census/censusTractphilly.shp", returnPath("phillyPop.tif"), returnPath("phillyPovRate.tif"))
createDemographicRasters(returnPath("phoenixNtl.tif"), "./phoenix/census/censusTractphoenix.shp", returnPath("phoenixPop.tif"), returnPath("phoenixPovRate.tif"))
createDemographicRasters(returnPath("providenceNtl.tif"), "./providence/census/censusTractprovidence.shp", returnPath("providencePop.tif"), returnPath("providencePovRate.tif"))
createDemographicRasters(returnPath("miamiNtl.tif"), "./miami/censusTractMiami.shp", returnPath("miamiPop.tif"), returnPath("miamiPovRate.tif"))
