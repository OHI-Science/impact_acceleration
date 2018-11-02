### Checking ocean layers
### not entirely sure which one is correct

library(raster)
library(RColorBrewer)
library(tidyverse)
library(rgdal)
library(doParallel)
library(foreach)
library(sf)



# the one we have been using (was worried about an alleged 255 value, but this is actually not there)
# /home/shares/ohi/model/GL-NCEAS-Halpern2008/tmp/ocean.tif 
# load spatial files (ocean raster and regions shapefile)
source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

## even though the values are reported as 0 and 255, the 255 is incorrect
tmp <- getValues(ocean)  # all one and NA values
cellStats(ocean, min) 
cellStats(ocean, max)  # max is one 

## Different extents: don't know if there are other differences 
ocean2 <- raster(file.path(dir_M, 
  "marine_threats/impact_layers_2013_redo/impact_layers/work/land_based/before_2007/step0/ocean_mask/ocean_mask.tif"))

## I am pretty sure this is the one used in the land-based models 
## (marine_threats\impact_layers_2013_redo\impact_layers\work\land_based\documentation\land_based_layers_workflow)
## Another land-based one (looks the same as #2):
ocean3 <- raster(file.path(dir_M, 
              "marine_threats/impact_layers_2013_redo/impact_layers/work/land_based/scripts_and_intermediary_layers/[0]_og_input/ocean_mask/ocean_mask.tif"))

## Another one in land-based folder, this one kind of follows the path in the scripts used for calculation 
# (looks the same as what we have been using)
## although the paths have obviously changed:
## in prepare_cumulative_impacdt_rast.py
## ocean_mask_rast="H:\\cumul_impact_model\\ocean_mask\\other_version\\ocean_mask.tif"

ocean4 <- raster(file.path(dir_M, 
          "marine_threats/impact_layers_2013_redo/impact_layers/work/land_based/scripts_and_intermediary_layers/[0]_og_input/ocean_mask/other_version/ocean_mask.tif"))

# This one also appears the same as the one we used:
ocean5 <- raster(file.path(dir_M, 
                           "marine_threats/impact_layers_2013_redo/impact_layers/work/coastal_population/ocean_mask/ocean_mask.tif"))

# different extent
ocean6 <- raster(file.path(dir_M, 
                           "marine_threats/impact_layers_2013_redo/impact_layers/work/land_based/scripts_and_intermediary_layers/[7]_plume_model/grass_plume_run/plume_setup/ocean_mask.tif"))


#### Comparing ocean3 (used in land-based pressures) and our ocean raster

ocean3_extend <- extend(ocean3, ocean, value=1)
ocean3_extend[is.na(ocean3_extend)] <- 0 

ocean[is.na(ocean)] <- 0

ocean_sum <- overlay(ocean3_extend,
        ocean,
        fun=function(r1, r2){return(r1+r2)})

ocean_sum[ocean_sum == 1] <- 999
plot(ocean_sum)
writeRaster(ocean_sum, file.path(dir_M, "git-annex/impact_acceleration/stressors/etc/land_based_plus_ocean.tif"))
# land = 0 
# ocean = 2
# 999 = different classification
# These appear the same with the exception that ocean3 does not include Antarctica, but does include 
# some inland lakes that are not in the ocean raster!
#  Yay!!!


#### Comparing ocean4 (used as mask in previous versions) and our ocean raster

ocean_sum_2 <- overlay(ocean4,
                     ocean,
                     fun=function(r1, r2){return(r1+r2)})

plot(ocean_sum_2)
writeRaster(ocean_sum_2, file.path(dir_M, "git-annex/impact_acceleration/stressors/etc/other_ocean_plus_ocean.tif"))
# land = 0 
# ocean = 2
# 999 = different classification
# These appear the same with the exception that ocean3 does not include Antarctica, but does include 
# some inland lakes that are not in the ocean raster!
#  Yay!!!


