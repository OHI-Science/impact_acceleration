############################
## preparing shipping data
## MRF Jan 31 2018
############################

### looking at shipping density data

library(raster)
library(ncdf4)
library(maps)
library(RColorBrewer)
library(sf)
library(dplyr)

source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

cols  = rev(colorRampPalette(brewer.pal(9, 'Spectral'))(255)) # rainbow color scheme


# explore the data
ncin <- nc_open(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/prod_gridded_1992-2017.nc"))
#ncin <- nc_open(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/ships.nc"))
print(ncin)
attributes(ncin$var)$names
nc_close(ncin)


## get the data and create a raster stack
raw <- stack(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/prod_gridded_1992-2017.nc",
             varname="nships_smoothed")) #nships_smoothed
raw <- rotate(flip(flip(t((raw[[25]])), direction = 'y'), direction = 'x'))
plot(raw, col=cols)
#click(tmp)
maps::map('world', col='gray95', fill=T, border='gray80', add=T)

# data standardized to 62,000 ships in 2009
cellStats(raw[[18]], stat='sum')
# I get exactly 62,000 (using non-smoothed data)! 


# convert names to year (equal to days since 1992)
names(raw) <- round(as.numeric(sub("X", "", names(raw)))/365.2422)


## convert 0 values to NA (since not clear for each raster whether it is NA or zero)
for (year in 1994:2016){ #year = 1994
  rast_year <- grep(year, names(raw))
  tmp <- raw[[rast_year]]
  tmp[tmp==0] <- NA 
  writeRaster(tmp, file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/shipping/int/shipping_raw_%s.tif", year)),
              overwrite=TRUE)
}


## each year will be mean of current and previous 2 years to smooth
## stochasticity of data

files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int"), 
                    pattern = "raw", full = TRUE)

for (year in 1994:2016){ # year = 1994
  
  year_range <- paste(year:(year+2), collapse="|")
  
  names_years_3 <- grep(year_range, files, value = TRUE)
  years_3 <- stack(names_years_3)
  mean_narm = function(x,...){mean(x, na.rm=TRUE)} 
  datasum<- calc(years_3, fun = mean_narm)
  #plot(datasum, col=cols)
  
  writeRaster(datasum, 
      file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/shipping/int/shipping_3_yr_%s.tif", year)),
              overwrite=TRUE)
}


### Calculate the reference raster (mean of 2011 and previous and post 2 years - to help
### stochastic NA values)

files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int"), 
                              pattern = "raw", full = TRUE)
ref_years <- grep("2009|2010|2011|2012|2013", files)
ref <- stack(files[ref_years]) #nships_smoothed

mean_narm = function(x,...){mean(x, na.rm=TRUE)} 
ref_mean <- calc(ref, fun = mean_narm)
plot(ref_mean, col=cols)
click(ref_mean)

writeRaster(ref_mean, file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int/reference_mean_2009_2013.tif")
ref_mean <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int/reference_mean_2009_2013.tif"))
ref_total_ships <- cellStats(ref_mean, stat='sum', na.rm=TRUE)

## divide each 3 year raster by the reference raster and transform to mollweide and save
for(year in 1994:2016){ # year = 2016
  scen_rast <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/shipping/int/shipping_3_yr_%s.tif", year)))
  prop <- overlay(scen_rast, ref_mean, fun=function(x,y)x/y)
  vals <- getValues(prop)
  scen_total_ships <- cellStats(scen_rast, stat="sum", na.rm=TRUE)
  prop[is.na(prop)] <- scen_total_ships/ref_total_ships 
  proj4string(prop) <- CRS("+init=epsg:4326")
  prop <- shift(prop, x = -1)
  
  
  projectRaster(prop, ocean, over=TRUE, method = "ngb", overwrite=TRUE,
      filename = file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/shipping/int/prop_change_%s_mol.tif", year)))
    # check: 
  # tmp <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int/prop_change_2016_mol.tif"))
  #  plot(tmp)
  #  tmp
  #  plot(land, add = TRUE, fill = NA)
  print(year)
}


### CHI shipping pressure data from Sean Jan 29 2018
# This matches the data that we were using!

ship_chi <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/rasters_sailwx_tmp_plus_all_ais_lzw.tif"))
projectRaster(ship_chi, ocean, over=TRUE, method="ngb", overwrite=TRUE,
              filename = file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int/shipping_mol.tif"))

ship_chi <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int/shipping_mol.tif"))
plot(ship_chi)

########## Multiply 1 year of CHI shipping data by the yearly correction factor
ship_master <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/int/shipping_mol.tif"))

for(year in 1994:2016){ # year = 2016
  adjust <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/shipping/int/prop_change_%s_mol.tif", year)))
  ship_adjust <- overlay(adjust, ship_master, fun=function(x,y)x*y)
  
  ## checkforNAs, there were none
  #ship_adjust[is.na(ship_adjust)] <- 999999
  #na_count <- mask(ship_adjust, ocean)
  #vals <- getValues(na_count)
  #sum(vals==999999)
  
    mask(ship_adjust, ocean,
         filename=file.path(dir_M, 
              sprintf("git-annex/impact_acceleration/stressors/shipping/int/adjusted_shipping_%s_mol.tif", year)))
    print(year)
}
  

#### Take the log and find the 99.99th quantile

shipping_ref_pts <- data.frame()

for(year in 1994:2016){ # year = 2016
  shipping <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/stressors/shipping/int/adjusted_shipping_%s_mol.tif", year)))
  shipping_ln <- calc(shipping, fun=function(x)log(x+1))
  raster::writeRaster(shipping_ln, overwrite=TRUE, 
       filename=file.path(dir_M, 
        sprintf("git-annex/impact_acceleration/stressors/shipping/int/adjusted_shipping_%s_mol_log.tif", year)))
  
  vals <- getValues(shipping_ln)
  ref <- quantile(vals, 0.9999, na.rm=TRUE)
  ref_add <- data.frame(year_shipping = year, quantile_9999 = as.numeric(ref))
  shipping_ref_pts <- rbind(shipping_ref_pts, ref_add)
  print(year)
}

write.csv(shipping_ref_pts, file.path(dir_M,                                      
                    "git-annex/impact_acceleration/stressors/shipping/int/shipping_ref_quantiles.csv"), 
          row.names = FALSE)

## use mean of all years as reference
ref <- read.csv(file.path(dir_M,                                      
                          "git-annex/impact_acceleration/stressors/shipping/int/shipping_ref_quantiles.csv"))
ref_point <- mean(ref$quantile_9999, na.rm=TRUE)


## rescale data
for(year in 1994:2016){ # year = 2016
  raster(file.path(dir_M, 
      sprintf("git-annex/impact_acceleration/stressors/shipping/int/adjusted_shipping_%s_mol_log.tif", year))) %>%
  calc(fun=function(x){ifelse(x<0,0,
                              ifelse(x>ref_point, 1, x/ref_point))})%>%
  writeRaster(filename = file.path(dir_M, 
                    sprintf("git-annex/impact_acceleration/stressors/shipping/final/shipping_%s_rescaled_mol.tif", year)),
              overwrite=TRUE)
}

tmp <- raster(file.path(dir_M, "git-annex/impact_acceleration/stressors/shipping/final/shipping_2016_rescaled_mol.tif"))
plot(tmp)
