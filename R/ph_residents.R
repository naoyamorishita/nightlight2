library(geospaar)
ph_all <- st_read("/Volumes/volume/GIS Projects/nightlight/Public_Housing_Buildings.geojson") %>%
  st_as_sf
ph_all <- ph_all %>% select(OBJECTID,TOTAL_OCCUPIED, geometry)

g <- st_read("./data/grid.geojson")
boundary <- boundary <- st_read("/Volumes/volume/GIS Projects/nightlight/phoenix/city_boundary/City_Limit_Dark_Outline.shp") %>%
  st_as_sf() %>%
  st_transform(crs = st_crs(ph_all))
sf_use_s2(FALSE)

# Clipping Public Housing Layer by City Boundary====
ph_phoenix <- st_intersection(ph_all, boundary)

# Counting Num of Ph in Grids====
ph_unit <- aggregate(ph_phoenix %>%
                       select(TOTAL_OCCUPIED),
                     g,
                     sum)

ph_unit[is.na(ph_unit)] <- 0

# Counting Num of Ph in Grids====
ph_phoenix$ count <- 1 # dummy number for counting houses

ph_count <- aggregate(ph_phoenix %>%
                        select(count),
                     g,
                     sum)
ph_count[is.na(ph_count)] <- 0

# Rasterizing the Grids====
r <- raster("./data/total_mean.tif")

r[r >= 0] <- 0

ph_count <- st_transform(ph_count, crs = crs(r))
ph_unit <- st_transform(ph_unit, crs = crs(r))

ph_countr <- rasterize(ph_count, r, field = "count")
ph_unitr <- rasterize(ph_unit, r, field = "TOTAL_OCCUPIED")

writeRaster(ph_countr,
            "./data/ph_countr.tif")
writeRaster(ph_unitr,
            "./data/ph_unitr.tif")
st_write(boundary, "./data/boundary.geojson")

st_write(ph_phoenix, "./data/ph_phoenix.geojson")
