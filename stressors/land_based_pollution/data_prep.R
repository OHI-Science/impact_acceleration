########################################
## land-based pollution data
########################################
source('../ohiprep/src/R/common.R')

library(raster)
library(rgdal)

library(dplyr)
library(stringr)

library(parallel)
library(foreach)
library(doParallel)

# masking file
ocean = raster(file.path(dir_M,'git-annex/globalprep/spatial/ocean.tif'))


# location of raw data
rast_locs <- file.path(dir_M, 
          "marine_threats/impact_layers_2013_redo/impact_layers/work/land_based/before_2007/raw_global_results")

## peak at raster to see what is up:
check <- raster(file.path(rast_locs, 'global_plumes_fert_2012_raw.tif'))
## darn: different extents and such...need to make these the same
plot(check)



## mask ocean and extend raster to make consistent with standard OHI global region file
## considered the 'raw' data
registerDoParallel(10)

files <- list.files(rast_locs, full.names = TRUE, pattern = "tif")

foreach(file = files)%dopar% { #file = files[1]
  
  year <- str_sub(file,-12,-9)
  
  raster(file) %>%
    raster::extend(ocean) %>%
    mask(ocean, 
         filename = file.path(dir_M, sprintf('git-annex/impact_acceleration/stressors/land_based/int/%s', basename(file))),
         overwrite = TRUE, progress = "text")
  
}


## Some exploration to determine whether we should log the data
## Given the skew in the data, I think we should

tmp <- raster(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002.tif'))
plot(tmp) # making sure land is gone
quantile(tmp, .9999) # value = 373.1765

calc(tmp, fun=function(x){ifelse(x>0, x, NA)},
     progress='text',
     filename=file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002_nozero.tif'), 
     overwrite = TRUE)

tmp2 <- raster(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002_nozero.tif'))
histogram(tmp2)

calc(tmp, function(x){log(x+1)}, 
     progress = "text", 
     filename = file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002_log.tif'),
     overwrite=TRUE)

tmp3 = raster(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002_log.tif'))
quantile(tmp3, .9999) # value = 5.925

calc(tmp3, fun=function(x){ifelse(x>0, x, NA)},
     progress='text',
     filename=file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002_nozero_log.tif'), 
     overwrite = TRUE)

tmp4 = raster(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/nutrient_2002_nozero_log.tif'))
histogram(tmp4)

### end of exploration

### log raster

files <- list.files(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int'), 
                    full.names = TRUE, pattern = "raw.tif")

foreach(file = files) %dopar% { #file = files[9]
  name <- basename(file)
  name <- sub('\\.tif$', '', name)
  name <- gsub("_raw", "", name)
  tmp <- raster(file)
  calc(tmp, function(x){log(x+1)}, 
       filename = file.path(dir_M, 
        sprintf("git-annex/impact_acceleration/stressors/land_based/int/%s_log.tif", name)), 
       overwrite=TRUE)
}

### Collect quantile data

files <- list.files(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int'), 
                    full.names = TRUE, pattern = "log.tif")

quantiles <- data.frame(plumeData = basename(files), quantile_9999_ln=NA)

for(file in files) { #file = files[9]
  
  tmp <- raster(file)
  quantiles$quantile_9999_ln[quantiles$plumeData == basename(file)] <- quantile(tmp, .9999)
  
}

write.csv(quantiles, 
          file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/extras/quantiles.csv'),
                               row.names = FALSE)

### rescale data to mean 99.99th quantile

## fertilizer/nutrient
quantiles <- read.csv(
          file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/extras/quantiles.csv'))

fert <- quantiles$quantile_9999_ln[grepl("fert", quantiles$plumeData)]
ref_point_fert <- mean(fert)

files <- list.files(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int'), 
                    full.names = TRUE, pattern = "fert")
files <- files[grep("log", files)]

for (file in files) { #file = files[9]
  year <- str_sub(file,-12,-9)
  
  tmp <- raster(file)
  
  calc(tmp, fun=function(x){ifelse(x>ref_point_fert, 1, x/ref_point_fert)},
       filename = file.path(dir_M, 
            sprintf("git-annex/impact_acceleration/stressors/land_based/final/nutrient/nutrient_%s_rescaled_mol.tif", year)), 
       overwrite=TRUE)
}

## pesticide/organic
quantiles <- read.csv(
  file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int/extras/quantiles.csv'))

pest <- quantiles$quantile_9999_ln[grepl("pest", quantiles$plumeData)]
ref_point_pest <- mean(pest)

files <- list.files(file.path(dir_M, 'git-annex/impact_acceleration/stressors/land_based/int'), 
                    full.names = TRUE, pattern = "pest")
files <- files[grep("log", files)]

for (file in files) { #file = files[9]
  year <- str_sub(file,-12,-9)
  
  tmp <- raster(file)
  
  calc(tmp, fun=function(x){ifelse(x>ref_point_pest, 1, x/ref_point_pest)},
       filename = file.path(dir_M, 
                            sprintf("git-annex/impact_acceleration/stressors/land_based/final/organic/organic_%s_rescaled_mol.tif", year)), 
       overwrite=TRUE)
}
