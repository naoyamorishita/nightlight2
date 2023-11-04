# Import Libraries====
import geopandas as gpd
import pandas as pd

# Reading Files====
ph = gpd.read_file(r"/Volumes/volume/GIS Projects/nightlight/Public_Housing_Buildings.geojson").to_crs(32130)
building = gpd.read_file(r"/Volumes/volume/GIS Projects/nightlight/providence/Building_Footprints.geojson").to_crs(32130)
grid = gpd.read_file(r"/Volumes/volume/GIS Projects/nightlight/providence/final/grid.geojson").to_crs(32130)

# Changing CRS====
ph = ph[["OBJECTID", "TOTAL_OCCUPIED","geometry"]] # saving important columns only
ph = ph.to_crs(32130)
building = building.to_crs(32130)
grid = grid.to_crs(32130)

# Clipping PH in Providence====
ph_providence = ph.clip(grid)
ph_providence.to_file("/Users/naoyamorishita/Documents/working/nightlight/data/providence_ri/ph_pt.geojson")
# Calculating Areas====
building["area"] = building["geometry"].area

# Creating Building Density Grid====
building_grid = building.sjoin(grid) # spatially joining building layer with grid layer # with intersection
building_grid_agg = building_grid.groupby(by = "id")["area"].sum() # summing up areas in each grid
building_grid_agg = pd.DataFrame(building_grid_agg) # converting the result into PD # for joinning

# Estimating Public Housing Areas====
ph_bld = ph_providence.sjoin_nearest(building) # spatially joining ph layers with building layer # with nearest neighbor join
ph_bld = ph_bld[["TOTAL_OCCUPIED", "area", "geometry"]]

# Creating Public Housing Area Density Grid====
ph_grid_area = ph_bld.sjoin(grid)
ph_grid_agg = ph_grid_area.groupby(by = "id")["area"].sum()
ph_grid_agg = pd.DataFrame(ph_grid_agg)

# Creating Public Housing Residents Density Grid====
ph_grid_res = ph_bld.sjoin(grid)
res_grid_agg = ph_grid_res.groupby(by = "id")["TOTAL_OCCUPIED"].sum()
res_grid_agg = pd.DataFrame(res_grid_agg)

# Joining the Layers with Original Grid to Add Geometry====
bld_grid_final = grid.merge(building_grid_agg, on = "id", how = "left")
ph_area_final = grid.merge(ph_grid_agg, on = "id", how = "left")
ph_res_final = grid.merge(res_grid_agg, on = "id", how = "left")

# Filling NA with 0====
bld_grid_final = bld_grid_final.fillna(0)
ph_area_final = ph_area_final.fillna(0)
ph_res_final = ph_res_final.fillna(0)

# Writing Files====
bld_grid_final.to_file("/Volumes/volume/GIS Projects/nightlight/providence/final/bld_grid.geojson")
ph_area_final.to_file("/Volumes/volume/GIS Projects/nightlight/providence/final/ph_area_grid.geojson")
ph_res_final.to_file("/Volumes/volume/GIS Projects/nightlight/providence/final/ph_res_grid.geojson")


