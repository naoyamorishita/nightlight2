# ReadMe
## Preparation Folder
R files in this folder will prepare data that can be used night light analysis associated with and developed [this repository](https://github.com/agroimpacts/USFlite).
Users are recommended to refer to, modify, and run files in the following order.
1. [`converth5ToTif.R`](R/preparation/converth5ToTif.R), which converts `.h5` format file to `.tif` format file and calculate average NTL radiance of images in a folder you specified.
  - If you download the images from [LAADS DAAC](https://ladsweb.modaps.eosdis.nasa.gov/search/), then the `.h5` format is the default format of the NTL image, and the image is **NOT georeferenced.**
  - Note that you have to [download BlackMarbleTile](https://blackmarble.gsfc.nasa.gov/Tools.html) and locate it in your computer.
2. [`createNDVI.R`](R/preparation/createNDVI.R), which calculate and clip NDVI from Landsat imagery for a specific city.
  - Visit [NDVI with Landsat Image](https://www.usgs.gov/landsat-missions/landsat-normalized-difference-vegetation-index) for further information.
3. [`formatRaster.R`](R/preparation/formatRaster.R), which clips the NTL layer to a city boundary.
  - The R code also coarsens NDVI file to align the NDVI image to the NTL image. (TODO: Create an individual file for the coarsening.)
  
**Note that the building footprint files are often heavy and may crush R.** If users does not feel unconfortable with running Python, then they may want to use this code instead of R.
