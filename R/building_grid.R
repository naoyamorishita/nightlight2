r <- raster("./data/total_mean.tif")

r[r >= 0] <- 0

g <- rasterToPolygons(r) %>%
  st_as_sf()

bld <- st_read("data/bldph_new.geojson") %>%
  st_as_sf()

bld <- bld[!duplicated(bld$ geometry),]

g <- st_transform(g, crs = st_crs(bld))

sf_use_s2(FALSE)

bld_area <- aggregate(bld %>% # aggregationg bld ph table
                       select(sqm), # selecting the area column as an aggreation target
                     g, # spatial aggregation into pop_res unit# ie census tract
                     sum)

bld_area$ g_area <- st_area(bld_area) %>%
  as.numeric

bld_area$ sqm <- bld_area$ sqm %>%
  replace_na(0)


bld_area$ dense <- bld_area$ sqm/ bld_area$ g_area * 100


bld_arear <- bld_area %>%
  st_transform(crs = crs(r)) %>%
  rasterize(y = r, field = "dense")

bld_arear %>%
  writeRaster("data/ph_density.tif", overwrite = T)
