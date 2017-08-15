#### SLR
## Based on the degree of yearly variation, we are going to take a running mean of 5 years
## This diverges from how the data are calculated for OHI global

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

### get data
raw <- list.files("../ohiprep/globalprep/prs_slr", full.names = TRUE, pattern = "rast_msla_annual",
                  recursive = TRUE)


### 5 year average
years <- as.numeric(as.character(str_sub(raw, -8, -5)))

min_year <- min(years) + 4

for(year in (min_year):max(years)){ #year = 2016
  year_span <- year:(year-4)
  rasts <- raw[grep(paste(year_span, collapse = "|"), basename(raw))]
  
  r_stack <- stack(rasts) %>%
    calc(fun=mean, na.rm=TRUE, 
         filename = file.path(dir_M, 
                   sprintf("git-annex/impact_acceleration/stressors/slr/int/slr_%s_5mean.tif",
                    max(year_span)), overwrite=TRUE))
}

### rescaling the data
annual_means <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/slr/int"),
                                             pattern = '*.tif', full.names = TRUE)
#plot(raster(annual_means[1]))

vals <- c()
for(file in annual_means){ # file <- annual_means[1]
  print(file)
  m <- raster(file) %>%
    getValues()
  
  vals <- c(vals,m)
  
}

vals <- vals[!is.na(vals)]

ref <- quantile(vals,prob = 0.9999,na.rm=T) # 0.1821333

# # set negative values to zero: use this value
# # not that much different, just use above value
# vals_pos = vals[vals >=0]
# 
# ref_pos <- quantile(vals_pos,prob=0.9999,na.rm=T) # 0.1863667

# rescale data, reproject
annual_means <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/slr/int"),
                           pattern = '*.tif', full.names = TRUE)


for(rast in annual_means){ #rast = annual_means[5]
  
  yr <- as.numeric(as.character(str_sub(rast, -14, -11)))
  
  raster(rast)%>%
    calc(fun=function(x){ifelse(x<0, 0, x)}) %>% #set all negative values to 0
    calc(fun=function(x){ifelse(x>ref, 1, x/ref)}) %>%
    projectRaster(crs = crs(ocean), over=TRUE) %>%
    resample(ocean, method = 'ngb', 
    filename = file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/slr/final/slr_%s_rescaled_mol.tif", yr)))
}

# check 
tmp <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/slr/final/slr_2016_rescaled_mol.tif"))
