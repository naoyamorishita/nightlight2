# ReadMe
## Preparation Folder

R files in this folder will prepare data that can be used night light analysis associated with and developed [this repository](https://github.com/agroimpacts/USFlite).
Users are recommended to refer to, modify, and run files in the following order.
1. [`converth5ToTif.R`](R/preparation/converth5ToTif.R), which converts `.h5` format file to `.tif` format file and calculate average NTL radiance of images in a folder you specified.
- If you download the images from [LAADS DAAC](https://ladsweb.modaps.eosdis.nasa.gov/search/), then the `.h5` format is the default format of the NTL image, and the image is **NOT georeferenced.** - Note that you have to [download BlackMarbleTile](https://blackmarble.gsfc.nasa.gov/Tools.html) and locate it in your computer.
2. [`createNDVI.R`](R/preparation/createNDVI.R), which calculate and clip NDVI from Landsat imagery for a specific city.
- Visit [NDVI with Landsat Image](https://www.usgs.gov/landsat-missions/landsat-normalized-difference-vegetation-index) for further information.
3. [`formatRaster.R`](R/preparation/formatRaster.R), which clips the NTL layer to a city boundary.
4. [`coarsenRaster.R`](R/preparation/coarsenRaster.R), which aligns the NDVI layers to the NTL layer.
5. [`addInfoToTract.R`](R/preparation/addInfoToTract.R), which create population and poverty layer.
- You need to download [census tract layer](https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.2020.html#list-tab-1883739534) - I would recommend download a city boundary file of your interest to reduce a resulting file size.
- I used P1 file of Decennial Census [(e.g., New York State)](https://data.census.gov/table/DECENNIALPL2020.P1?q=census&t=Populations%20and%20People&g=040XX00US36$1400000&y=2020).
I would recommend to select **all tracts in a State**, **not to open the table in the webpage** and to download it, because I was able to handle the file easily in this way.
- I used S1701 file of ACS [(e.g., New York State)](https://data.census.gov/table/ACSST5Y2020.S1701?q=Poverty&g=040XX00US36$1400000&y=2020), and selected 200% poverty and population column.
I would recommend to select **all tracts in a State**, **not to open the table in the webpage** and to download it, because I was able to handle the file easily in this way.
- I wrote a code to format the files to join the files together.
- However, note that you may want to modify it, depending on which file you have downloaded.
6. [`createDemographicRasters.R`](R/preparation/createDemographicRasters.R), which converts the tract layer into raster layer using areal interpolation. The output is population raster from census population and poverty ratio from ACS 200% poverty divided by ACS population.
7. [`calculateBuildingDensity.R`](R/preparation/calculateBuildingDensity.R), which calculates percentage of building areas within a grid. **Note that the building footprint files are often heavy and may crush R.** If users does not feel unconfortable with running Python, then they may want to use this code instead of R.

## Discuss Analysis Ideas

-   Compare NTL at two time points using strata of with/ withoutUse PH.
    -   Use interval metrics presented by Prof. Gil Pontius for NTL.
-   Apply [time trajectory analysis by Thomas Bilintoh](https://github.com/bilintoh/timeseriesTrajectories)
    -   Analyze dynamics of hotspots/ cold spot of NTL in a time series.
-   Use time series analysis, such as linear regression and Theil- sen estimator over a decade.
