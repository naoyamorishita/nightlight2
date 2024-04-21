# READ LIBRARIES####
library(raster)
library(sf)
library(tidyverse)

# READ DATA####
miami <- readRDS("./data/miami.rds")[[1]] %>%
  # Convert to Polygon====
  raster::rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  # Remove NA====
  na.omit(.) %>%
  # Drop Geometry====
  st_drop_geometry(.)

# Scale Data=====
miami_scaled <- miami %>%
  mutate_all(.,
             ~scale(.))

# Add PH Status====
miami$ ph_category <- ifelse(PublicHousingAreaRatio)
