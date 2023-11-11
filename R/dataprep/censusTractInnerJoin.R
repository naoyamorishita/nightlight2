# READ DATA####
library(geospaar)
boundary <- read_sf("F:/GIS Projects/nightlight/toBePublished/miami/miami_boundary.geojson") %>%
  st_as_sf()

tract <- read_sf("F:/GIS Projects/nightlight/toBePublished/miami/florida_tract/cb_2020_12_tract_500k.shp") %>%
  st_as_sf() %>%
  st_transform(crs = st_crs(boundary))

populationDf <- read.csv("F:/GIS Projects/nightlight/toBePublished/miami/miami_population.csv") %>%
  t() %>%
  as.data.frame()

povertyDf <- read.csv("F:/GIS Projects/nightlight/toBePublished/miami/miami_poverty.csv") %>%
  t() %>%
  as.data.frame()

populationDf <- tibble::rownames_to_column(populationDf, "tract")


povertyDf <-
  povertyDf %>%
  tibble::rownames_to_column(., "NAME")

povertyDf2 <- povertyDf[-1, c("NAME", "V1","V49")]


povertyDf <- subset(povertyDf2,
                    grepl("Total..Estimate", povertyDf2[["NAME"]]
                            ))

povertyDf$ totalPop <- as.integer(gsub(",", "", povertyDf$V1))
povertyDf$ est200PrcntPov <- as.integer(gsub(",", "", povertyDf$V49))
povertyDf <- povertyDf %>%
  mutate(est200PrcntPRate = est200PrcntPov/ totalPop * 100) %>%
  select(NAME,
         est200PrcntPRate)

povertyDf <- povertyDf %>%
  select(NAME,
         est200PrcntPRate)

povertyDf$NAME <- gsub("Census.Tract.",
                       "",
                       povertyDf$NAME)

povertyDf$NAME <- gsub("..Miami.Dade.County..Florida..Total..Estimate",
                       "",
                       povertyDf$NAME)


populationDf<-
populationDf[-1, ] %>%
  select(tract,
         V1) %>%
  rename(Population= V1)

tractMiami <-
  tract %>%
  slice(st_intersects(x = boundary,
                     tract)[[1]]) %>%
  select(NAME)

populationDf$tract <- gsub("Census.Tract.",
                           "",
                           populationDf$ tract)

populationDf$ tract <- gsub("..Miami.Dade.County..Florida",
                            "",
                            populationDf$ tract)

populationDf <- rename(populationDf,
                       NAME = tract)

tractMiami <-
 tractMiami %>%
  inner_join(populationDf,
            by = "NAME")

tractMiami <- tractMiami %>%
  inner_join(povertyDf,
             by = "NAME")

tractMiami %>%
  select(NAME,
         Population,
         est200PrcntPRate) %>%
  st_write("F:/GIS Projects/nightlight/toBePublished/miami/miami_tract_info.geojson")
