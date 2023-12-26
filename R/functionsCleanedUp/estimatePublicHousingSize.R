library(geospaar)

createPhAreaRaster <- function(pathToCityBoundary,
                               pathToPhPoint,
                               pathToRaster,
                               pathToBldFootprint){
  boundary <- st_read(pathToCityBoundary) %>%
    st_as_sf()

  ph <- st_read(pathToPhPoint) %>%
    st_as_sf() %>%
    st_transform(crs = st_crs(boundary)) %>%
    st_intersection(boundary)

  r <- raster::raster(pathToRaster)

  g <- r %>%
    rasterToPolygons(.) %>%
    st_as_sf() %>%
    mutate(gridID = 1:nrow(.)) %>%
    st_transform(crs = st_crs(boudnary))

  # Extract Grids with Public Housing====
  phg <- st_join(ph, r, st_intersects)

  # Get Grid Id with Public Housing====
  gridIDUnique <- unique(phg$ gridID)

  # Extract Grids Having the ID====
  gridPh <- r[r$ gridID %in% gridIDUnique]
  gc()

  # Read Building Footprint====
  bld <- st_read(pathToBldFootprint) %>%
    st_as_sf() %>%
    st_transform(st_crs(boundary))

  # Drop Out of the Grid with Ph by Inner Join====
  bldg <- st_join(bld,
                  gridPh,
                  st_intersects,
                  left = FALSE) %>%
    # Calculate area of buildings----
    mutate(bldArea = st_area(.) %>%
             as.numeric(.))
  rm(bld)
  gc()

  # Estimate Building Area by Nearest Neighbor Join====
  phbld <- st_join(ph,
                   bldg,
                   st_nearest_features) %>%
    # Reduce file size by dropping geometry----
    st_drop_geometry() %>%
    # Summing up ph area within the same grid----
    group_by(gridID) %>%
    summarize(sumPhArea = sum(bldArea))

  # Create a Grid Spatial File Having the Sum of the Area====
  g <- left_join(g,
                 phbld,
                 by = "gridID")

  # Insert 0 to NA====
  g[is.na(g)] <- 0

  # Rasterize the Grid and Write the Raster File====
  g %>%
    rasterize(r,
              field = "sumPhArea") %>%
    writeRaster("phbld.tif",
                overwrite = T)
}

setwd("/Volumes/volume 1/GIS Projects/nightlight/nightlight2/miami")
# b <- st_read("miami_boundary_3086.geojson") %>%
#   st_as_sf()
#
# ph <- st_read("miami_ph.geojson") %>%
#   st_as_sf() %>%
#   st_transform(crs = st_crs(b)) %>%
#   st_intersection(b)
#
# rst <- raster::raster("alanYearlyMean_miami.tif")
#
# r <- rst %>%
#   rasterToPolygons(.) %>%
#   st_as_sf() %>%
#   mutate(gridID = 1:nrow(.))
#
# phg <- st_join(ph, r, st_intersects)
#
# gridIDUnique <- unique(phg$ gridID)
#
# gridPh <- r[r$gridID %in% gridIDUnique,]
# gc()
#
# bld <- st_read("miami_bld.geojson") %>%
#   st_as_sf() %>%
#   st_transform(st_crs(b))
#
# bldg <- st_join(bld,
#                gridPh,
#                st_intersects,
#                left = FALSE) %>%
#   mutate(bldArea = st_area(.) %>%
#            as.numeric(.))
#
# rm(bld)
# gc()
#
# phbld <- st_join(ph,
#                  bldg,
#                  st_nearest_feature)
#
#
# gph <-
# bldg %>%
#   st_drop_geometry() %>%
#   group_by(gridID) %>%
#   summarize(sumPhArea = sum(bldArea))
#
# g <- left_join(r,
#                gph,
#                "gridID")
# g[is.na(g)] <- 0
#
# g %>%
#   rasterize(rst,
#             field = "sumPhArea") %>%
#   writeRaster("phbld.tif",
#               overwrite = T)
