library(geospaar)
bldph <- st_read("./data/bldph.geojson") %>%
  select(geometry, area)
g <- st_read("./data/grid.geojson") %>%
  st_transform(crs = st_crs(bldph)) %>%
  mutate(g_area = st_area(.) %>%
           as.numeric)

bldphg <- st_join(bldph, g, join = st_within)

bldphgs <- aggregate(bldph %>% select(area), g, FUN = sum)

bldphgs[is.na(bldphgs)] <- 0

bldphgs$ g_area <- st_area(bldphgs) %>%
  as.numeric
bldphgs$ density <- bldphgs$ area/ bldphgs$ g_area

st_write(bldphgs, "./data/bldph_grid.geojson")
