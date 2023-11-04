library(geospaar)
# Reading Population Data====
pop <- st_read("/Volumes/volume 1/GIS Projects/nightlight/providence/final/population_tract.geojson") %>%
  st_as_sf()

# Calculating the area----
pop$ t_area <- st_area(pop) %>%
  as.numeric()

# Reading Grid Data====
grid <- st_read("/Volumes/volume 1/GIS Projects/nightlight/providence/final/grid.geojson") %>%
  st_as_sf() %>%
  st_transform(crs = st_crs(pop))

# Calculating the area----
grid$ g_area <- st_area(grid) %>%
  as.numeric()

# Estimating Grid Population with Areal Interpolation====
int_pop <- st_intersection(x = pop, y = grid)
int_pop$ i_area <- st_area(int_pop) %>%
  as.numeric()

int_pop <- int_pop %>%
  mutate(est_pop = total %>% as.numeric()/ t_area * i_area)

cell_pop_df <- int_pop %>% group_by(id) %>% # grouping by cell id
  st_drop_geometry() %>% # sf to df
  summarise(., pop = sum(est_pop, na.rm = TRUE))

g <- inner_join(cell_pop_df, grid, by = "id") %>% st_as_sf

# Rasterizing the Population Grid====
r <- raster("/Volumes/volume 1/GIS Projects/nightlight/providence/final/apr_mean.TIF")
crs(r) <- crs(g)
extent(r) <- extent(g)
r[r >= 0] <- 0

ras <- rasterize(g, r, field = "pop")

writeRaster(ras,
            "/Volumes/volume 1/GIS Projects/nightlight/providence/final/pop_grid.tif")
