---
  title: "Creating direct impacts stressor layers"
author: "*Compiled on `r date()` by `r Sys.info()['user']`*"
output: 
  html_document:
  code_folding: show
toc: true
toc_depth: 1
toc_float: yes
number_sections: false
theme: cerulean
highlight: haddock
includes: 
  in_header: '../../../ohiprep_v2018/src/templates/ohi_hdr.html'
pdf_document:
  toc: true
---
  

## From 2015 paper:
# "..we modeled direct human impact on the coast as the
# sum of the coastal human population, defined as the number of people within a moving
# circular window around each coastal cell of radius 10 km.
# We then cropped the data to include only cells 1km from the coast since this
# driver primarily affects intertidal and very nearshore ecosystems.

# NOTE: 2008 paper used 25 km radius

library(raster)
library(dplyr)
library(RColorBrewer)
library(sp)
library(rgdal)
library(stringr)

cols <- rev(colorRampPalette(brewer.pal(9, 'Spectral'))(255))

source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

land      <- regions %>%
  subset(rgn_type %in% c('land','land-disputed','land-noeez'))
land2 <- as(land, "Spatial")

##############################################
## 10km radius: 
## https://gis.stackexchange.com/questions/151962/calculating-shannons-diversity-using-moving-window-in-r
##############################################

pop_files <- list.files(file.path(dir_M, "git-annex/globalprep/mar_prs_population/v2017/int"),
                        pattern = "count", full=TRUE)

fw<-focalWeight(rast, 10000, "circle") # creates circular filter with a radius of 10km

for(pop_file in pop_files){ # pop_file = pop_files[1]
  
  rast <- raster(pop_file)
  rast_year <- str_sub(pop_file, -12, -9)
  
  #system.time({
  rast_10<-focal(rast,
                 w=fw, 
                 fun=function(x,...){sum(x, na.rm=TRUE) })   
  #})
  
  #plot(test_rast, col = cols)
  #zoom(test_rast)
  writeRaster(rast_10, file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/direct_human/int/pop_count_10km_%s.tif", rast_year)),
              overwrite=TRUE)
}

#############################
### Take ln + 1
#############################

count_files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int"), 
                          pattern = "10km", full = TRUE)

for(file in count_files){ # file = count_files[1]
  
  yr <- as.numeric(as.character(str_sub(file, -8, -5)))
  
  raster(file) %>%
    calc(fun = function(x){log(x + 1)}, 
         filename = file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/direct_human/int/pop_count_10km_%s_log.tif", yr)),
         overwrite =TRUE)
  
}


#################################
### Mask to 1km offshore
#################################
## first make a raster that is limited to 1km offshore
plot(ocean)

subs(ocean, data.frame(id=c(NA,1), v=c(1,NA)),
     filename = file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/ocean_inverse.tif"),
     overwrite =TRUE)

ocean_inverse <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/ocean_inverse.tif"))

land_boundary <- boundaries(ocean_inverse, type="outer", asNA=TRUE, progress="text") 
land_boundary[land_boundary == 0] <- NA

writeRaster(land_boundary, file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/land_boundary.tif"),
     overwrite =TRUE)

mask_1km <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/land_boundary.tif"))

## Also need to make a mask that gets rid of the boundary
block <- projectRaster(ocean, crs=CRS("+init=epsg:4326"))
block[is.na(block)] <- 1
mol_solid <- projectRaster(block, ocean, over=TRUE)
boundary_mask <- boundaries(mol_solid, type="inner", asNA=TRUE, progress="text") 
boundary_mask <- subs(boundary_mask, data.frame(id=c(0,1), v=c(1,NA)))
writeRaster(boundary_mask, file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/boundary_mask.tif"))
boundary_mask <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/boundary_mask.tif"))

## mask the files and save
log_files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int"),
           full=TRUE, pattern = "log.tif")
# subset to current data (not future data)
log_files <- grep(paste(2000:2016, collapse="|"), log_files, value=TRUE)

quant_data <- c()

for(file in log_files){ # file = log_files[1]
  
  yr <- as.numeric(as.character(str_sub(file, -12, -9)))
  
  tmp <- raster(file) %>%
    mask(mask_1km) %>%  # mask to get 1km offshore, unfortunately includes raster boundary
    mask(boundary_mask) # mask to get rid of boundary
  
  ## get values, only want values within 1 km to calcuate 99.99th quantile
  tmp <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/direct_human/int/pop_count_10km_%s_log_mask.tif", yr)))
  vals <- getValues(tmp)
  vals <- na.omit(vals)
  quant_data <- c(quant_data, vals)
  
  ## convert NA's to zero
  tmp[is.na(tmp)] <- 0 
  
  ## mask using the ocean raster
  mask(tmp, ocean, filename = file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/direct_human/int/pop_count_10km_%s_log_mask.tif", yr)),
         overwrite =TRUE)
  
}

ref_point <- quantile(quant_data, 0.9999)
ref_point_df <- data.frame(ref_point)

write.csv(ref_point, file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int/ref_point.csv"))


### Find 99.99th quantile across raster cells/years
rasts <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/int"), full = TRUE, 
           pattern = "mask.tif")

## rescale data
for(rast in rasts){ # rast = rasts[2]
  year <- as.numeric(as.character(str_sub(rast, -17, -14)))
  
  raster(rast) %>%
    calc(fun=function(x){ifelse(x<0,0,
                                ifelse(x>ref_point, 1, x/ref_point))})%>%
    writeRaster(filename = file.path(dir_M, 
                                     sprintf("git-annex/impact_acceleration/stressors/direct_human/final/direct_human_%s_rescaled_mol.tif", year)),
                overwrite=TRUE)
}

tmp <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/direct_human/final/direct_human_2001_rescaled_mol.tif"))
plot(tmp)
