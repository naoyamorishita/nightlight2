# IMPORT LIBRARIES####
library(sf)
library(raster)
library(tidyr)

# CREATE FUNCTION####
createBuildDensityRaster <- function(
  pathToRaster,
  pathToBuildingLayer,
  pathToCityBoundary,
  outPath
){
  # Import Data====
  r <- raster::raster(pathToRaster)

  # Convert Raster to Polygon====
  g <- r %>%
    rasterToPolygons(.) %>%
    st_as_sf(.) %>%
    # Add grid id so that I can join layers----
    dplyr::mutate(gridID = 1:nrow(.)) %>%
    # Calculate area so that I can calculate ratio----
    dplyr::mutate(garea = st_area(.) %>%
                    as.numeric(.)) %>%
    # Reduce file size by preserving important columns----
    dplyr::select(gridID, garea, geometry)

  # Save CRS====
  coodRef <- st_crs(g)

  # Import City Layer====
  city <- st_read(pathToCityBoundary) %>%
    st_as_sf() %>%
    # Make sure layers have the same crs----
    st_transform(coodRef) %>%
    # Dissolving layers by calculating summing up dummy id with records sharing the id----
    dplyr::mutate(dummyID = 1) %>%
    dplyr::group_by(dummyID) %>%
    dplyr::summarize(dummyID = sum(dummyID))
  gc()

  # Import Building Layer====
  bld <- st_read(pathToBuildingLayer) %>%
    st_as_sf() %>%
    # Reduce variables by only selecting a dummy column----
    dplyr::mutate(bldId = 1:nrow(.)) %>%
    dplyr::select(bldId) %>%
    # Make sure layers have the same crs----
    st_transform(coodRef) %>%
    # Extract only those in the city boundary----
    dplyr::slice(st_intersects(x = city,
                               y = .)[[1]]) %>%
    # Calculate an area of each building----
    dplyr::mutate(barea = st_area(.) %>%
                    as.numeric(.))
  print(bld[1:5, ])
  gc()

  # Calculate Area of Intersection of Grid & Building====
  int <<- st_intersection(bld, g) %>%
    dplyr::mutate(iarea = st_area(.) %>%
                    as.numeric(.)) %>%
    st_drop_geometry(.)
  rm(bld)
  gc()

  # Sum up Area of Buildings within Grid====
  gdf <- int %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(bldSum = sum(iarea))

  # Add Geometry by Joining Grid====
  bld <- dplyr::left_join(g,
                          gdf,
                          by = "gridID") %>%
    # Insert 0 if building area is na----
    dplyr::mutate(bldSum = ifelse(is.na(bldSum),
                                  0,
                                  bldSum)) %>%
    # Calculate ratio of building areas----
    dplyr::mutate(bldRatio = bldSum/ garea)

  # Rasterize the Building Area Grid====
  bldr <- bld %>%
    rasterize(r,
              field = "bldRatio")
  print(bldr)
  plot(bldr)

  # Export Raster====
  writeRaster(bldr,
              outPath,
              overwrite = T)

  # Clean Up File and Memory=====
  rm(ls())
  gc()
}

# DEFINE A FUNCTION TO RETURN SAVE PATH####
returnFullPath <- function(fileName){
  return(paste0("/Users/naoyamorishita/Documents/working/nightlight2/data/",
                fileName)
         )
}

# APPLY FUNCTION####
setwd("/Volumes/volume 1/GIS Projects/nightlight/nightlight2")
createBuildDensityRaster(returnFullPath("providenceNtl.tif"), "./providence/Buildings/Buildings.shp", "./providence/Nhoods/Nhoods.shp",returnFullPath("providenceBld.tif"))

