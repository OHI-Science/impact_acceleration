### transfering habitat files

#The habitat files have not been updated from the previous Cumulative Human Impacts assessment.
#To keep all relevant files in one location this script transfers these files into our current working
#directory.  

source("src/R/common.R")

habitat_files <- list.files(file.path(dir_M, "marine_threats/impact_layers_2013_redo/supporting_layers/habitats"), 
                            full=TRUE, pattern="tif")

file.copy(habitat_files, to = file.path(dir_M, "git-annex/impact_acceleration/habitats"), overwrite=TRUE)

hab_files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/habitats"), full=TRUE)
hab_names <- gsub("_lzw", "", hab_files)
  
file.rename(hab_files, hab_names)


### habitat number raster
habitat_num <- list.files(file.path(dir_M, "marine_threats/impact_layers_2013_redo/supporting_layers/habitat_num"), 
                            full=TRUE, pattern="tif")

file.copy(habitat_num, to = file.path(dir_M, "git-annex/impact_acceleration/habitat_number"), overwrite=TRUE)
