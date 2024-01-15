library(sf)
library(raster)
library(tidyr)

# DEFINE FUNCTION####
createPhAreaRaster <- function(pathToCityBoundary,
                               pathToPhPoint,
                               pathToRaster,
                               pathToBldFootprint,
                               outPath){
  # Read Raster====
  r <- raster::raster(pathToRaster)

  # Convert Raster to Grid====
  g <<- r %>%
    rasterToPolygons(.) %>%
    st_as_sf() %>%
    mutate(gridID = 1:nrow(.))

  coordsRef <- st_crs(g)

  # Read Boundary and Transform its CRS====
  boundary <- st_read(pathToCityBoundary) %>%
    st_as_sf() %>%
    # Make sure layers have the same crs----
    st_transform(coordsRef) %>%
    # Dissolving layers by calculating summing up dummy id with records sharing the id----
    dplyr::mutate(dummyID = 1) %>%
    dplyr::group_by(dummyID) %>%
    dplyr::summarize(dummyID = sum(dummyID))

  # Read Public Housing Points Data====
  ph <<- st_read(pathToPhPoint) %>%
    st_as_sf() %>%
    st_transform(crs = coordsRef) %>%
    # Extract points in the cities----
    st_intersection(boundary) %>%
    st_intersection(g)

  # Extract Grids with Public Housing====
  gPh <<- g %>%
    # Extract grids containing ph by looking up grid id of ph layer----
    dplyr::filter(gridID %in% unique(ph$ gridID))

  # Read Building Footprint====
  bld <- st_read(pathToBldFootprint) %>%
    st_as_sf() %>%
    st_transform(crs = coordsRef)

  # Drop Out of the Grid & Add Grid Number to Building with Ph by Inner Join====
  bldg <<- bld %>%
    st_join(.,
            gPh,
            st_intersects,
            left = FALSE) %>%
    mutate(barea = st_area(.) %>%
             as.numeric(.)) %>%
    select(barea)
  rm(bld)
  gc()

  # Estimate Building Area by Nearest Neighbor Join====
  phbld <<- st_join(gPh,
                   bldg,
                   join = st_nearest_feature) %>%
    # Reduce file size by dropping geometry----
      st_drop_geometry() %>%
    # Summing up ph area within the same grid----
    group_by(gridID) %>%
    summarize(sumPhArea = sum(barea))

  # Create a Grid Spatial File Having the Sum of the Area====
  g <- left_join(g,
                 phbld,
                 by = "gridID") %>%
    mutate(garea = st_area(.) %>%
             as.numeric(.)) %>%
    mutate(phAreaRatio = sumPhArea/ garea)

  # Insert 0 to NA====
  g[is.na(g)] <- 0

  # Rasterize the Grid and Write the Raster File====
  g %>%
    rasterize(r,
              field = "phAreaRatio") %>%
    writeRaster(outPath,
                overwrite = T)
}

# CREATE GEOJSON FROM CHICAGO DATA PORTAL====
pt <- read.csv("./chicago/Affordable_Rental_Housing_Developments_20240101.csv") %>%
  st_as_sf(coords = c("Longitude", "Latitude"),
           crs = 4326) %>%
  st_write("./chicago/chicagoPh.geojson")


# DEFINE RETURN PATH FUNCTION####
returnPath <- function(fileName){
  return(paste0("C:/Users/NMorishita/Documents/GitHub/nightlight2/data/",
                fileName))
}

# APPLY FUNCTION####
setwd("G:/GIS Projects/nightlight/nightlight2")
createPhAreaRaster("./providence/Nhoods/Nhoods.shp",
                   "./general/Public_Housing_Buildings.geojson",
                   returnPath("providenceNtl.tif"),
                   "./providence/Buildings/Buildings.shp",
                   returnPath("providencePhArea.tif"))

createPhAreaRaster("./la/City_Boundary.geojson",
                   "./la/Affordable_Housing_Development.geojson",
                   returnPath("laNtl.tif"),
                   "./la/Building_Footprints.geojson",
                   returnPath("laPhArea.tif"))

createPhAreaRaster("./chicago/Boundaries - City.geojson",
                   "./chicago/chicagoPh.geojson",
                   returnPath("chicagoNtl.tif"),
                   "./chicago/Building Footprints (current).geojson",
                   returnPath("chicagoPhArea.tif"))

createPhAreaRaster("./philladelphia/City_Limits.geojson",
                   "./philladelphia/Affordable_Housing.geojson",
                   returnPath("phillyNtl.tif"),
                   "./philladelphia/LI_BUILDING_FOOTPRINTS.geojson",
                   returnPath("phillyPhArea.tif"))

createPhAreaRaster("./phoenix/City_Limit_Dark_Outline.geojson",
                   "./general/Public_Housing_Buildings.geojson",
                   returnPath("phoenixNtl.tif"),
                   "./phoenix/Arizona.geojson",
                   returnPath("phoenixPhArea.tif"))

createPhAreaRaster("./miami/miami_boundary_3086.geojson",
                   "./miami/miami_boundary_3086.geojson",
                   returnPath("miamiNtl.tif"),
                   "./miami/miami_bld.geojson",
                   returnPath("miamiPhArea.tif"))

# CREATE PH RASTER IN NYC DISTRIBUTED AS POLYGON####
# Read Raster and Polygonize the Raster====
nyr <- raster::raster(returnPath("nycNtl.tif"))

nyg <- nyr %>%
  raster::rasterToPolygons(.) %>%
  st_as_sf() %>%
  # Get grid id for inner join----
  mutate(gridID = 1:nrow(.)) %>%
  # Get grid area to calculate ratio of ph----
  mutate(garea = st_area(.) %>%
           as.numeric(.))

# Get CRS====
coords <- st_crs(nyg)

# Read Ph Layer and Calculate Area====
nyp <- st_read("./nyc/NYCHA_Developments/NYCHA_Developments.shp") %>%
  st_as_sf() %>%
  st_transform(coords) %>%
  # Get grid id of intersection----
  st_intersection(nyg) %>%
  # Calculate the area of intersection
  dplyr::mutate(phArea = st_area(.) %>%
                  as.numeric(.)) %>%
  # Drop geometry for inner join----
  st_drop_geometry(.)

# Aggregate Ph Area of Ratio to Grid====
nyp <- nyp %>%
  group_by(gridID) %>%
  summarise(sumArea = sum(phArea))

gPh <- nyg %>%
  left_join(nyp,
             by = "gridID") %>%
  mutate(sumArea = ifelse(is.na(sumArea),
                          0,
                          sumArea)) %>%
  mutate(ratio = sumArea/ garea)

gPh %>%
  rasterize(nyr,
            field = "ratio") %>%
  writeRaster(returnPath("nycPhArea"))
