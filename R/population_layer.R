library(geospaar) # reading library

setwd("/Volumes/volume 1/GIS Projects/nightlight/providence")

population <- read_csv("DECENNIALPL2020.P1-2023-06-02T163951.csv", col_names = TRUE) %>%
  t() %>%
  as_tibble(., rownames = "NAME")

population <- population[-1, 1:2] %>%
  rename(total = V1)

census_tract <- read_sf("./tl_2020_44_tract/tl_2020_44_tract.shp") %>% st_as_sf()

boundary <- read_sf("./Nhoods/Nhoods.shp") %>% st_as_sf()

census_tract <- st_transform(census_tract, crs = 32130)

boundary <- st_transform(boundary, crs = 32130)

boundary_d <- boundary %>%
  mutate(area = as.numeric(units::set_units(st_area(.), "km^2"))) %>%
  summarize(area = mean(area))

providence_tract <- census_tract %>% slice(unique(as_vector(st_within(x = boundary, y = census_tract))))

population$ NAME <- sub("Census Tract ", "", population$ NAME)
population$ NAME <- sub(", Providence County, Rhode Island", "", population$ NAME)

tract_population <- left_join(providence_tract, population, by = "NAME")

st_write(tract_population, "/Volumes/volume 1/GIS Projects/nightlight/providence/final/population_tract.geojson")
