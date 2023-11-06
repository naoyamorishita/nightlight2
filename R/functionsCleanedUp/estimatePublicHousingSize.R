library(geospaar)

estimatePublicHousingSize <- function(
    pathToBoundary,
    pathToPublicHousingLocation,
    gridSize,
    pathToBuildingFootPrint,
    epsg
){
  boundary <- st_read(pathToBoundary) %>%
    st_as_sf() %>%
    st_transform(epsg)

  ph <- st_read(pathToPublicHousingLocation) %>%
    st_as_sf() %>%
    st_transform(epsg)

  grid <- raaster(x = boundary,
                  res = (gridSize* gridSize)) %>%
    rasterToPolygons(.) %>%
    st_as_sf()

  gridId <- as_vector(unique(st_within(x = ph,
                                       y = grid)))

  gridPh <- grid[gridID, ]

  bld <- st_read(pathToBuildingFootPrint) %>%
    st_as_sf() %>%
    st_transform(epsg)

  bldID <- bldID <- as_vector(unique(st_intersects(x = gridPh, y = bld)))

  bld <- bld[bldID, ] # subsetting sf with row number of bld that are within the grid of ph

  gc()

  bld <- bld %>%
    mutate(area = st_area %>%
             as.numeric)

  bldph <- st_join(ph,
                   bld,
                   join = st_nearest_feature) %>%  # nearest neighbor join for adding information of public housing building
    st_write()

}
