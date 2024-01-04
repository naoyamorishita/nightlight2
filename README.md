# ReadMe
## Explanation about Individual Files in Preparation Folder
R files in this folder will prepare data that can be used night light analysis associated with and developed [this repository](https://github.com/agroimpacts/USFlite).
Users are recommended to refer to files in the following order.
1. `converth5ToTif.R`, which converts `.h5` format file to `.tif` format file and calculate average the NTL radiance of images in a folder you specified. The `.h5` format is the default format of NTL image if you download the images from [LAADS DAAC](https://ladsweb.modaps.eosdis.nasa.gov/search/), and the image is **NOT GEOREFERENCED.** Note that you have to [download BlackMarbleTile File](https://blackmarble.gsfc.nasa.gov/Tools.html) and locate it in your computer. 
2. `createNDVI.R`, which calculate and clip NDVI from Landsat imagery for a specific city. See this website for further information about [NDVI with Landsat Image](https://www.usgs.gov/landsat-missions/landsat-normalized-difference-vegetation-index)
3. `formatRaster.R`, which clips the NTL layer to a city boundary. The R code also coarsens NDVI file to align the NDVI image to the NTL image. 
