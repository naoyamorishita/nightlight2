# LOAD LIBRARY####
library(raster)
library(sf)
library(tidyr)

# READ DATA####
# Read NYC Data=====
nyc <- readRDS("./data/nyc.rds")
nycr <- readRDS("./data/nyc.rds")[[1]]
nycp <- nycr %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))

# Read LA Data====
la <- readRDS("./data/la.rds")
lar <- readRDS("./data/la.rds")[[1]]
lap <- lar %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))

# Read Chicago Data====
chicago <- readRDS("./data/chicago.rds")
chicagor <- readRDS("./data/chicago.rds")[[1]]
chicagop <- chicagor %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))

# Read Philly Data====
philly <- readRDS("./data/philly.rds")
phillyr <- readRDS("./data/philly.rds")[[1]]
phillyp <- phillyr %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))

# Read Miami Data====
miami <- readRDS("./data/miami.rds")
miamir <- readRDS("./data/miami.rds")[[1]]
miamip <- miamir %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))

# Read Phoenix Data====
phoenix <- readRDS("./data/phoenix.rds")
phoenixr <- readRDS("./data/phoenix.rds")[[1]]
phoenixp <- phoenixr %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))


# Read Providence Data====
providence <- readRDS("./data/providence.rds")
providencer <- readRDS("./data/providence.rds")[[1]]
providencep <- providencer %>%
  rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  replace_na(.,
             list(0))

# CALCULATE BASIC STATISTICS####


# SAVE POLYGONS####
list(nycp, lap, chicagop, phillyp, miamip,phoenixp, providencep) %>%
  saveRDS("./data/polies.rds")
