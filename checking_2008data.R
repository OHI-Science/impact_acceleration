## checking data

source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/gh-pages/src/R/spatial_common.R")

library(raster)
library(rgdal)
library(here)

## rescaled pressure
oa <- raster(file.path(dir_M, 
  "nceas_website2008/completed/impacts/transformed/ocean_acidification/tif/ocean_acidification_lzw.tif"))
setMinMax(oa)
plot(oa)

oa_raw <- raster(file.path(dir_M, 
                       "nceas_website2008/completed/impacts/raw_data/ocean_acidification/tif/acid_lzw.tif"))
setMinMax(oa_raw)
plot(oa_raw)



pop <- raster(file.path(dir_M, 
                       "nceas_website2008/completed/impacts/transformed/population/tif/population_lzw.tif"))
setMinMax(pop)
plot(pop)

pop_raw <- raster(file.path(dir_M, 
                        "nceas_website2008/completed/impacts/raw_data/population/tif/population_lzw.tif"))
setMinMax(pop_raw)
plot(pop_raw)


art <- raster(file.path(dir_M, 
                        "nceas_website2008/completed/impacts/transformed/artisanal_fishing/tif/artisanal_fishing_lzw.tif"))
setMinMax(art)
plot(art)

art_raw <- raster(file.path(dir_M, 
                        "nceas_website2008/completed/impacts/raw_data/artisanal_fishing/tif/artisanal_lzw.tif"))
setMinMax(art_raw)
plot(art_raw)


###

pel_lb <- raster(file.path(dir_M, 
"git-annex/Global/SAUP-FishCatchByGearType_Halpern2008/data/fishprod_pel_lb_gcs.tif"))
setMinMax(pel_lb)
plot(pel_lb)

# lzw has land masked as NA:
pel_lb2 <- raster(file.path(dir_M, 
                           "nceas_website2008/completed/impacts/raw_data/pel_lb/tif/pel_lb.tif"))
setMinMax(pel_lb2)
plot(pel_lb2)

pel_lb3 <- raster(file.path(dir_M, 
                            "nceas_website2008/completed/impacts/raw_data/pel_lb/tif/pel_lb_lzw.tif"))
setMinMax(pel_lb3)
plot(pel_lb3)


pel_lb_trans <- raster(file.path(dir_M, 
                            "nceas_website2008/completed/impacts/transformed/pel_lb/tif/pel_lb_lzw.tif"))
setMinMax(pel_lb_trans)
plot(pel_lb_trans)

pel_lb_trans2 <- raster(file.path(dir_M, 
                                 "nceas_website2008/completed/impacts/transformed/pel_lb/tif/pel_lb.tif"))
setMinMax(pel_lb_trans2)
plot(pel_lb_trans2)

