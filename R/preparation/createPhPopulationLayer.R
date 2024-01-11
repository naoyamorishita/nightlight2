library(sf)
library(raster)
library(tidyr)

# DEFINE FUNCTION####
createPhPopRaster <- function(
    pathToPhLayer,
    numOfResidentsColumn,
    pathToPopulationRaster,
    outPath
){
  # Enquote a Variable so that I can Pass Column Names to Dplyr Functions====
  enquoCol <- dplyr::enquo(numOfResidentsColumn)

  # Read Raster & Polygonize it====
  r <- raster::raster(pathToPopulationRaster)

  g <- r %>%
    rasterToPolygons(.) %>%
    st_as_sf(.) %>%
    # Rename column name and add grid id----
    dplyr::rename(population = layer) %>%
    dplyr::mutate(gridID = 1:nrow(.))

  # Get crs----
  coordsRef <- st_crs(g)

  # Read Ph Layer & Transform Crs====
  ph <- st_read(pathToPhLayer) %>%
    st_as_sf(.) %>%
    st_transform(coordsRef) %>%
    # Remove unused columns----
    dplyr::select(phResidents = !!enquoCol) %>%
    # Add grid id by st_intersection----
    st_intersection(g)

  # Aggregate Ph Area by Grid====
  gph <- ph %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(sumResidents = sum(phResidents)) %>%
    # Drop Geometry for Inner Join====
    st_drop_geometry(.)

  # Rasterize the Grid====
  phr <- g %>%
    # Add geometry by joining the df with the original grid----
    dplyr::left_join(gph,
                     by = "gridID") %>%
    # Calculate population in ph ratio to the grid population----
    dplyr::mutate(ratio = ifelse(sumResidents > 1,
                                 sumResidents/ population,
                                 0)) %>%
    # Rasterize the grid----
    raster::rasterize(r,
              field = "ratio")

  print(phr)
  plot(phr)

  # Export Raster====
  raster::writeRaster(phr,
                      outPath,
                      overwrite = TRUE)
}

# TEST FUNCTION####
# createPhPopRaster("/Volumes/volume/GIS Projects/nightlight/nightlight2/general/Public_Housing_Buildings.geojson",
#                   TOTAL_OCCUPIED,
#                   "./data/providencePop.tif",
#                   "./data/TESTprovidencePop.tif")
