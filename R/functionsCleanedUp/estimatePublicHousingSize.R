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

setwd("/Volumes/volume 1/GIS Projects/nightlight/nightlight2/miami")
b <- st_read("miami_boundary_3086.geojson") %>%
  st_as_sf()

ph <- st_read("miami_ph.geojson") %>%
  st_as_sf() %>%
  st_transform(crs = st_crs(b)) %>%
  st_intersection(b)

rst <- raster::raster("alanYearlyMean_miami.tif")

r <- rst %>%
  rasterToPolygons(.) %>%
  st_as_sf() %>%
  mutate(gridID = 1:nrow(.))

phg <- st_join(ph, r, st_intersects)

gridIDUnique <- unique(phg$ gridID)

gridPh <- r[r$gridID %in% gridIDUnique,]
gc()

bld <- st_read("miami_bld.geojson") %>%
  st_as_sf() %>%
  st_transform(st_crs(b))

bldg <- st_join(bld,
               gridPh,
               st_intersects,
               left = FALSE) %>%
  mutate(bldArea = st_area(.) %>%
           as.numeric(.))

rm(bld)
gc()

phbld <- st_join(ph,
                 bldg,
                 st_nearest_feature)


gph <-
bldg %>%
  st_drop_geometry() %>%
  group_by(gridID) %>%
  summarize(sumPhArea = sum(bldArea))

g <- left_join(r,
               gph,
               "gridID")
g[is.na(g)] <- 0

g %>%
  rasterize(rst,
            field = "sumPhArea") %>%
  writeRaster("phbld.tif",
              overwrite = T)
