# READ DATA####
library(geospaar)

# Change Variables====
boundaryFile <- "F:/GIS Projects/nightlight/toBePublished/miami/miami_boundary.geojson"
tractFile <- "F:/GIS Projects/nightlight/toBePublished/miami/miami_boundary.geojson"
populationCSVFile <- "F:/GIS Projects/nightlight/toBePublished/miami/miami_population.csv"
povertyCSVFile <- "F:/GIS Projects/nightlight/toBePublished/miami/miami_poverty.csv"
colExtracted <- c("NAME", "V1","V49")
outPath <- "F:/GIS Projects/nightlight/toBePublished/miami/miami_tract_info.geojson"
# Read Boundary Data====
boundary <- read_sf(boundaryFile) %>%
  st_as_sf()

usedCRS <- st_crs(boundary)

tract <- read_sf(tractFile) %>%
  st_as_sf() %>%
  st_transform(crs = usedCRS)

populationDf <- read.csv(populationCSVFile) %>%
  t() %>%
  as.data.frame()

povertyDf <- read.csv(povertyCSVFile) %>%
  t() %>%
  as.data.frame()

# Create New Columns Containing the Current Row Name====
populationDf <-
  populationDf %>%
  tibble::rownames_to_column("tract")

povertyDf <-
  povertyDf %>%
  tibble::rownames_to_column("NAME")

# Remove the First Row & Extract 3 Columns====
povertyDf2 <- povertyDf[-1, colExtracted]

# Subsetting Data Contained within a Name Column====
povertyDf <- subset(povertyDf2,
                    # Change here if needed!----
                    grepl("Total..Estimate",
                          povertyDf2[["NAME"]]))

# Remove "," and Convert the Value into Numeric====
povertyDf$ totalPop <- as.integer(gsub(",", "", povertyDf$V1))

povertyDf$ est200PrcntPov <- as.integer(gsub(",", "", povertyDf$V49))

# FINALIZE THE OUTPUT####
# Calculate Poverty Rate within the Tract====
povertyDf <- povertyDf %>%
  mutate(est200PrcntPRate = est200PrcntPov/ totalPop * 100) %>%
  select(NAME,
         est200PrcntPRate)

# Format Name for Inner Join====
# Change here if needed!----
povertyDf$NAME <- gsub("Census.Tract.",
                       "",
                       povertyDf$NAME)

povertyDf$NAME <- gsub("..Miami.Dade.County..Florida..Total..Estimate",
                       "",
                       povertyDf$NAME)

# Format Population Df====
populationDf<-
populationDf[-1, ] %>%
  select(tract,
         V1) %>%
  rename(Population= V1)

# Extract Tracts within Miami by St_Intersects and Slice Function====
tractMiami <-
  tract %>%
  slice(st_intersects(x = boundary,
                     tract)[[1]]) %>%
  select(NAME)

# Format Values for Join====
# Change here if needed!----
populationDf$tract <- gsub("Census.Tract.",
                           "",
                           populationDf$ tract)

# Format Values for Join====
# Change here if needed!----
populationDf$ tract <- gsub("..Miami.Dade.County..Florida",
                            "",
                            populationDf$ tract)

# Rename Column Names for Join====
populationDf <- rename(populationDf,
                       NAME = tract)

# Get Information of Tracts by Join====
tractMiami <-
 tractMiami %>%
  inner_join(populationDf,
            by = "NAME")

tractMiami <- tractMiami %>%
  inner_join(povertyDf,
             by = "NAME")

# Format Spatial File and Write the File====
tractMiami %>%
  select(NAME,
         Population,
         est200PrcntPRate) %>%
  st_write(outPath)
