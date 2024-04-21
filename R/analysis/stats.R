# READ LIBRARIES####
library(raster)
library(sf)
library(tidyverse)
library(psych)

# READ DATA####
providence <- readRDS("./data/providence.rds")[[1]] %>%
  # Convert to Polygon====
  raster::rasterToPolygons(.) %>%
  st_as_sf(.) %>%
  # Remove NA====
  na.omit(.) %>%
  # Drop Geometry====
  st_drop_geometry(.)

# Add PH Status====
providence$ ph_category <- ifelse(providence$ PublicHousingAreaRatio > 0, "Y", "N")

# Scale Data=====
providence_scaled <- providence %>%
  mutate_if(is.numeric,
            ~scale(.))

# CALCULATE STATISTICS####
# Calculate Descriptive Statistic of Grids with Ph====
providence %>%
  # Extract those with ph----
  filter(ph_category == "Y") %>%
  # Remove ph category column----
  select(-ph_category) %>%
  # Print stats----
  psych::describe(.)

# Calculate Descriptive Statistics of Grids without Ph====
providence %>%
  filter(ph_category == "N") %>%
  select(-ph_category) %>%
  psych::describe(.)

# VISUALIZE PLOTS####
plot_scatter <- function(
    x_val,
    main_title){

  # Enquo Value to Pass the Parameter====
  x_val_enquo <- dplyr::enquo(x_val)

  # Calculate Correlation of X and Y of Grids With Ph=====
  corr_ph <- cor(providence_scaled %>%
                   # Extract those with public housing----
                   filter(ph_category == "Y") %>%
                   # Select x variable (use !! to pass the enquoted variable)----
                   select(!!x_val_enquo),

                 # Specify y variable----
                 providence_scaled %>%
                   # Extract those with ph----
                   filter(ph_category == "Y") %>%
                   # Use NTL as y variable----
                   select(NTL)) %>%
    # Round the correlation coef----
    round(2)

  # Calculate Correlationof X and Y of Grids Without Ph====
  corr_noph <- cor(providence_scaled %>%
                     # Extract those without ph----
                     filter(ph_category == "N") %>%
                     select(!!x_val_enquo),
                   providence_scaled %>%
                     filter(ph_category == "N") %>%
                     select(NTL)) %>%
    round(2)

  # Edit Subtitle that Showing the Correlation Coef for the 2 Categories====
  title_text <- paste0("Corr of Grid w/ Ph: ",
                       corr_ph,
                       "; Corr of Grid w/o Ph: ",
                       corr_noph)

  # Plot the Scatter and LM Line====
  ggplot(
    # Specify data----
    data = providence_scaled,
    # Specify x variable----
    aes(x = !!x_val_enquo,
    # Specify y variable----
    y = NTL,
    # Differentiate the Scatter and the Line by the Ph Category----
    color = ph_category)
         )+
    # Add scatter----
    geom_point()+
    # Add linear line with standard error----
    geom_smooth(method = lm,
                se = TRUE)+
    # Add title & the subtitle edited above----
    ggtitle(main_title,
            subtitle = title_text)

}

# Apply the Function====
plot_scatter(NDVI, "NDVI vs NTL in Providence")
plot_scatter(BuildingDensity, "Building Density vs NTL in Providence")
plot_scatter(Population, "Population vs NTL in Providence")
plot_scatter(PovertyRate, "Poverty Rate vs NTL in Providence")

# COMPARE NTL FROM GRIDS OF SIMILAR POPULATION WITH OR WITHOUT PH####
# Categorize by Quantile====
pop <- providence$ Population

# Calculate 20 Percentile Thresholds====
tiles <- quantile(pop, probs = c(0.2, 0.4, 0.6, 0.8, 1.0)) %>%
  # Convert named number to numeric vector----
  unname(.)

# Reclassify Values: Please LMK If You Have a Better Way=====
pop_level <- ifelse(pop < tiles[1], 1,
                    ifelse(pop < tiles[2], 2,
                           ifelse(pop < tiles[3], 3,
                                  ifelse(pop < tiles[4], 4,
                                         5)))) %>%
  # Convert numeric to factor----
  as.factor(.)

# Combine the Population Level====
providence <- cbind(providence, pop_level)

# Compare NTL from Grids With vs Without Ph at Same Population Level====
ggplot(providence,
       # Compare the ntl by population level and public housing category----
       aes(x = pop_level,
           y = NTL,
           fill = ph_category))+
  # Show the result by box plots----
  geom_boxplot()

# Compare the Values in Table====
summary_tbl <- providence %>%
  # Group by population level and public housing----
  group_by(pop_level,
           ph_category) %>%
  # Calculate median population by the group----
  summarize(median_pop = median(Population))
