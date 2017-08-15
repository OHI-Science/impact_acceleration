#### Direct human impact

source('../ohiprep/src/R/common.R')

library(raster)
library(rgdal)

library(dplyr)
library(stringr)

library(parallel)
library(foreach)
library(doParallel)

### sample raster for projecting
ocean = raster(file.path(dir_M,'git-annex/globalprep/spatial/ocean.tif'))

### reproject and resample density data
raw <- list.files(file.path(dir_M, "git-annex/globalprep/_raw_data/CIESEandCIAT_population/d2017"), 
                  full.names = TRUE, pattern = "\\.tif$",
                  recursive = TRUE)
raw <- raw[grep("density", raw)]


for(rast in raw){ #rast = raw[1]
  
  yr <- as.numeric(as.character(str_sub(rast, -8, -5)))
  
  raster(rast)%>%
    projectRaster(crs = crs(ocean), method = "ngb", over=TRUE, overwrite = TRUE,
    filename = file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/direct_human/int/human_density_%s_mol.tif", yr)))

  }

# check 
