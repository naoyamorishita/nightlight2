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
    # Dissolving layers by calculating summing up dummy id with records sharing the id: remove subregions in a city if it has----
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
  # Added st_make_valid to handle invalid geometry in philly building data----
  int <- st_intersection(bld %>%
                            st_make_valid(.),
                          g) %>%
    # Calculate intersection area of building and grid----
    dplyr::mutate(iarea = st_area(.) %>%
                    as.numeric(.)) %>%
    # Remove geometry for non- spatial join----
    st_drop_geometry(.)
  rm(bld)
  gc()

  # Sum up Area of Buildings within Grid====
  gdf <- int %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(bldSum = sum(iarea))

  # Add Geometry by Joining Grid====
  # Keep grids without buildings by left join----
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
    # Use the reference raster and use values of building area ratio----
    rasterize(r,
              field = "bldRatio")
  print(bldr)
  plot(bldr)

  # Export Raster====
  writeRaster(bldr,
              outPath,
              overwrite = T)

  # Clean Up File and Memory=====
  gc()
}

# DEFINE A FUNCTION TO RETURN SAVE PATH####
returnFullPath <- function(fileName){
  return(paste0("C:/Users/NMorishita/Documents/GitHub/nightlight2/data/",
                fileName)
         )
}

# APPLY FUNCTION####
setwd("G:/GIS Projects/nightlight/nightlight2")
createBuildDensityRaster(returnFullPath("providenceNtl.tif"), "./providence/Buildings/Buildings.shp", "./providence/Nhoods/Nhoods.shp",returnFullPath("providenceBld.tif"))
createBuildDensityRaster(returnFullPath("laNtl.tif"), "./la/Building_Footprints.geojson", "./la/City_Boundary.geojson", returnFullPath("laBld.tif"))
createBuildDensityRaster(returnFullPath("chicagoNtl.tif"), "./chicago/Building Footprints (current).geojson", "./chicago/Boundaries - City.geojson", returnFullPath("chicagoBld.tif"))
createBuildDensityRaster(returnFullPath("phillyNtl.tif"), "./philladelphia/LI_BUILDING_FOOTPRINTS.geojson", "./philladelphia/City_Limits.geojson", returnFullPath("phillyBld.tif"))
createBuildDensityRaster(returnFullPath("phoenixNtl.tif"), "./phoenix/Arizona.geojson", "./phoenix/City_Limit_Dark_Outline.geojson", returnFullPath("phoenixBld.tif"))
createBuildDensityRaster(returnFullPath("nycNtl.tif"), "./nyc/Building Footprints.geojson", "./nyc/Borough Boundaries.geojson", returnFullPath("nycBld.tif"))
createBuildDensityRaster(returnFullPath("miamiNtl.tif"), "./miami/miami_bld.geojson", "./miami/miami_boundary_3086.geojson", returnFullPath("miamiBld.tif"))
