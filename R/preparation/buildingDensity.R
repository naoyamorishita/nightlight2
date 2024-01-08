# IMPORT LIBRARIES####
library(sf)
library(raster)
library(tidyr)

# CREATE FUNCTION####
createBuildDensityRaster(
  pathToRaster,
  pathToBuildingLayer,
  pathToCityBoundary,
  outPath
){
  r <- raster::raster(pathToRaster)

  g <- r %>%
    rasterToPolygons(.) %>%
    st_as_sf(.) %>%
    dplyr::mutate(gridID = 1:nrow(.)) %>%
    dplyr::mutate(garea = st_area(.) %>%
                    as.numeric(.))
    dplyr::select(gridID, geometry)

  coodRef <- st_crs(g)

  city <- st_read(pathToCityboundary) %>%
    st_as_sf() %>%
    st_transform(coodRef) %>%
    dplyr::mutate(dummyID = 1) %>%
    dplyr::group_by(dummyID) %>%
    summarize(dummyID = sum(dummyID)) %>%
    dplyr::select(dummyID)
  gc()

  bld <- st_read(pathToBuildingLayer) %>%
    st_as_sf() %>%
    dplyr::select(gemetry) %>%
    st_transform(coodRef) %>%
    dplyr::slice(st_intersects(x = city,
                               y = .)[[1]]) %>%
    dplyr::mutate(barea = st_area(.) %>%
                    as.numeric(.))
  gc()

  int <- st_intersectino(bld, g) %>%
    dplyr::mutate(iarea = st_area(.) %>%
                    as.numeric(.)) %>%
    st_drop_geometry(.)
  rm(bld)
  gc()

  gdf <- int %>%
    dplyr::group_by(gridID) %>%
    dplyr::summary(bldSum = sum(iarea)) %>%
    dplyr::mutate(bratio = bldSum/ garea)

  bldr <- dplyr::inner_join(g,
                            gdf,
                            by = "gridID") %>%
    rasterize(r,
              field = "bratio")
  print(bldr)
  plot(bldr)

  writeRaster(bldr,
              outPath,
              overwrite = T)
  rm(ls())
  gc()
}
