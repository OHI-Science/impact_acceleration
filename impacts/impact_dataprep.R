### Calculating impacts: stressor x habitat x vulnerability

#libraries
library(raster)
library(ncdf4)
library(maps)
library(RColorBrewer)
library(sf)
library(dplyr)
library(doParallel)
library(foreach)
library(parallel)

source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

# parallel processing
cl<-makeCluster(5)
registerDoParallel(cl)

########### Years

years <- 2003:2013

years_subset <- paste(years, collapse="|")

########### Vulnerability
# read in vulnerability matrix
vulnerability <- read.csv("vulnerability_weighting_matrix.csv") %>%
  filter(pressure != "pressure")


####### Habitats
# make sure habitat rasters from vulnerability matrix are available
names(vulnerability)
habs <- list.files(file.path(dir_M, "git-annex/impact_acceleration/habitats"))
habs <- habs[-(grep(".vat.dbf|.xml|.ovr", habs))]

# The following should be zero
setdiff(habs, paste0(names(vulnerability), '.tif'))

# a couple things in the vulnerability table that we do not have data for:
# "ice.tif"         "vent.tif"        "Soft.Canyon.tif" "Hard.Canyon.tif"
xtra_vul_habs <- setdiff(paste0(names(vulnerability), '.tif'), habs) 
xtra_vul_habs <- xtra_vul_habs[-which(xtra_vul_habs=="pressure.tif")]
xtra_vul_habs <- gsub(".tif", "", xtra_vul_habs)



####### Stressors
stress_files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors"), recursive = TRUE, 
           pattern = ".tif", full="TRUE")
stress_files <- grep("/final/", stress_files, value=TRUE)

#filter to relevant years
stress_files <- grep(years_subset, stress_files, value=TRUE)

# make sure all stressor files are available
files <- basename(stress_files)
files <- gsub("_rescaled_mol.tif", "", files)
files <- gsub('_[[:digit:]]+', '', files)
files <- unique(files)

#should be no pressures:
setdiff(files, vulnerability$pressure)

# a few pressures that will not be included:
# "inorg_pollution" "invasives"       "ocean_pollution"
xtra_vul_stressor <- setdiff(vulnerability$pressure, files)


######### Clean vulnerability table
vulnerability_clean <- vulnerability %>%
  dplyr::select(-one_of(xtra_vul_habs)) %>%
  dplyr::filter(!(pressure %in% xtra_vul_stressor)) %>%
  tidyr::gather("habitat", "vulnerability", -1) %>%
  merge(data.frame(years), by=NULL) %>%
  dplyr::mutate(stress_loc = NA) %>%
  mutate(output = NA)


########## Loop to create habitat combos
stress_files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors"), recursive = TRUE, 
                           pattern = ".tif", full="TRUE")
stress_files <- grep("/final/", stress_files, value=TRUE)

#filter to relevant years
stress_files <- grep(years_subset, stress_files, value=TRUE)


foreach(row = list_not_done,.packages="dplyr") %dopar%{ # row=12
  #foreach(i = 1:dim(vulnerability_clean)[1],.packages="dplyr") %dopar%{ # i=1
  #for(i in 1:dim(vulnerability_clean)[1]){ #i=1
  
  combo_data <- vulnerability_clean[row, ]
  
  #obtain stressor raster location
  pxy <- paste(combo_data$pressure, combo_data$years, sep="_")
  stress_rast <- grep(pxy, stress_files, value=TRUE)
  
  #obtain habitat raster location
  hab_rast <- sprintf("/home/shares/ohi/git-annex/impact_acceleration/habitats/%s.tif", combo_data$habitat)
  
  #vulnerability
  vuln <- as.numeric(combo_data$vulnerability)
  
  # multiply stressor * habitat * vulnerability:
  combo_stack <- raster::stack(stress_rast, hab_rast)
  raster::overlay(combo_stack, fun=function(x,y){(x*y*vuln)}, 
          filename = file.path(dir_M, sprintf("git-annex/impact_acceleration/hab_stressor_combo/%s__%s__%s.tif", 
                               combo_data$pressure, combo_data$habitat, combo_data$years)), overwrite=TRUE)
  }

# check to see if all combos were created
combos_obs <- list.files(file.path(dir_M, "git-annex/impact_acceleration/hab_stressor_combo"))
length(combos_obs)

dim(vulnerability_clean)

#N = 320 were not created figure out which ones
# all were UV and benthic structures....which we don't have complete years for, so this is fine.
vulnerability_clean$combos_list <- paste(vulnerability_clean$pressure, 
                                         vulnerability_clean$habitat, 
                                         vulnerability_clean$years, sep="__")

not_done <- setdiff(paste0(vulnerability_clean$combos_list, ".tif"), combos_obs)
not_done <- paste(not_done, collapse="|")
not_done <- gsub(".tif", "", not_done)
list_not_done <- grep(not_done, vulnerability_clean$combos_list)


###############################
## Summarize across habitats for each pressure/year

# generate list of year/stressor combinations

# keep all stressors, so comment out this:
#stressors <- vulnerability$pressure[-(which(vulnerability$pressure %in% xtra_vul_stressor))]
stressors <- vulnerability$pressure
stress_combos <- expand.grid(year=years, stressor=stressors)

combos <- list.files(file.path(dir_M, "git-annex/impact_acceleration/hab_stressor_combo"), full=TRUE)

## total habitat num raster
hab_num <- raster(file.path(dir_M, "git-annex/impact_acceleration/habitat_number/habitat_num.tif"))

foreach(i = 1:dim(stress_combos)[1],.packages="dplyr") %dopar%{ # row=12
#for(i in dim(stress_combos)[1]){ # i = 1
  year <- stress_combos$year[i]
  stress <- stress_combos$stressor[i]
  
  tmp <- grep(year, combos, value=TRUE)
  tmp <- grep(stress, tmp, value =TRUE)
  
  
  # realized I need to output warning to file, lost when using multiple cores
  if(length(tmp)!=20){
    warning(sprintf("%s does not have 20 habitats", stress))
  }
  
  stress_stack <- raster::stack(tmp)
  
  raster::calc(stress_stack, fun=sum, na.rm=TRUE,
      filename=file.path(dir_M, sprintf("git-annex/impact_acceleration/tmp/summed_raster_%s_%s.tif", stress, year)), 
      overwrite=TRUE)
  
  summed_rast <- raster::raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/tmp/summed_raster_%s_%s.tif", stress, year)))
  
  ## need to add an ocean mask here!
  raster::overlay(summed_rast, hab_num, fun=function(x,y){x/y},
                  filename=file.path(dir_M, sprintf("git-annex/impact_acceleration/impact/stressor_impact/%s_%s.tif", stress, year)),
                  overwrite=TRUE)

    
  file.remove(file.path(dir_M, sprintf("git-annex/impact_acceleration/tmp/summed_raster_%s_%s.tif", stress, year)))
  
}


###############################
## Summarize across pressures for Cumulative Human Impacts for each year

# select stressors with all years of data to include in model

stressors <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/stressor_impact"))
stress_all <- str_sub(stressors, 1, str_length(stressors)-9)
stress_length <- table(stress_all)
stressors_full <- names(stress_length[stress_length == length(years)])

stressors_chi <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/stressor_impact"),
                            full=TRUE)
stressors_chi <- grep(paste(stressors_full, collapse="|"), stressors_chi, value=TRUE)

length(stressors_chi)/length(years) # needs to be a whole number

# chi_check <- data.frame(year=years, length=c(NA))
# write.csv(chi_check, "impacts/chi_check.csv", row.names=FALSE)

foreach(year = years,.packages="dplyr") %dopar%{ # year=2013
  #for(i in dim(stress_combos)[1]){ # i = 1
  
  ## this does not work....need to create a file for each run.
  stressors_yr <- grep(year, stressors_chi, value=TRUE)
  tmp <- read.csv("impacts/chi_check.csv")
  tmp$length[tmp$year == year] <- length(stressors_yr)
  write.csv(tmp, 'impacts/chi_check.csv')
  
  stress_stack <- raster::stack(stressors_yr)
  
  raster::calc(stress_stack, fun=sum, na.rm=TRUE,
               filename=file.path(dir_M, sprintf("git-annex/impact_acceleration/tmp/summed_raster_%s.tif", year)), 
               overwrite=TRUE)
  
  summed_rast <- raster::raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/tmp/summed_raster_%s.tif", year)))
  
  raster::mask(summed_rast, ocean,
                  filename=file.path(dir_M, sprintf("git-annex/impact_acceleration/impact/cumulative_impact/chi_%s.tif", year)),
                  overwrite=TRUE)
  
  file.remove(file.path(dir_M, sprintf("git-annex/impact_acceleration/tmp/summed_raster_%s.tif", year)))
  
}



########## Calculate stats on pressures and cumulative impacts
stressors <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/stressor_impact"), 
                        full=TRUE)

foreach(stress = stressors,.packages="dplyr") %dopar%{
for(stress in stressors){ # stress = stressors[1]
 st_tmp <- raster::raster(stress) 
 quants <- raster::quantile(st_tmp, c(0.01, 0.05, 0.5, 0.95, 0.99))
 quants_df <- data.frame(quants)
 quants_df$quant <- row.names(quants_df)
 quants_df$impact <- basename(stress)
 fn <- gsub(".tif", "", basename(stress))
 write.csv(quants_df, sprintf("impacts/quantiles/%s.csv", fn), row.names=FALSE)
}


stressors <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/cumulative_impact"), 
                          full=TRUE)
  
  foreach(stress = stressors,.packages="dplyr") %dopar%{
    for(stress in stressors){ # stress = stressors[1]
      st_tmp <- raster::raster(stress) 
      quants <- raster::quantile(st_tmp, c(0.01, 0.05, 0.5, 0.95, 0.99))
      quants_df <- data.frame(quants)
      quants_df$quant <- row.names(quants_df)
      quants_df$impact <- basename(stress)
      fn <- gsub(".tif", "", basename(stress))
      write.csv(quants_df, sprintf("impacts/quantiles/%s.csv", fn), row.names=FALSE)
    }
    
  