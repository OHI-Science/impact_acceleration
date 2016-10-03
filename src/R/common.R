# set the mazu and neptune data_edit share based on operating system
dir_M             <- c('Windows' = '//mazu.nceas.ucsb.edu/ohi',
                       'Darwin'  = '/Volumes/ohi',    ### connect (cmd-K) to smb://mazu/ohi
                       'Linux'   = '/home/shares/ohi')[[ Sys.info()[['sysname']] ]]

dir_N <- dir_neptune_data <- c('Windows' = '//neptune.nceas.ucsb.edu/data_edit',
                               'Darwin'  = '/Volumes/data_edit',
                               'Linux'   = '/var/data/ohi')[[ Sys.info()[['sysname']] ]]

dir_neptune_local <- c('Windows' = '//neptune.nceas.ucsb.edu/local_edit',
                       'Darwin'  = '/Volumes/local_edit',
                       'Linux'   = '/usr/local/ohi')[[ Sys.info()[['sysname']] ]]

dir_halpern2008   <- c('Windows' = '//neptune.nceas.ucsb.edu/halpern2008_edit',
                       'Darwin'  = '/Volumes/halpern2008_edit',
                       'Linux'   = '/var/cache/halpern-et-al')[[ Sys.info()[['sysname']] ]]

# warning if Neptune or Mazu directory doesn't exist
if (Sys.info()[['sysname']] != 'Linux' & !file.exists(sprintf('%s/', dir_neptune_data))){
  warning(sprintf("The Neptune directory dir_neptune_data set in src/R/common.R does not exist. Do you need to mount Neptune: %s?", dir_neptune_data))
}
if (Sys.info()[['sysname']] != 'Linux' & !file.exists(dir_M)){
  warning(sprintf("The Mazu directory dir_M set in src/R/common.R does not exist. Do you need to mount Mazu: %s?", dir_M))
}
if (Sys.info()[['sysname']] == 'Linux' & (!file.exists(dir_M) & !file.exists(dir_neptune_data))){
  stop(sprintf("Neither Mazu dir_M nor Neptune dir_neptune_data variables (set in src/R/common.R) exist. \n  Do you need to mount Mazu: %s or Neptune: %s?", dir_M, dir_neptune_data))
}



# install (if necessary) and load commonly used libraries
packages <- "tidyverse"
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  cat(sprintf("Installing %s\n", setdiff(packages, rownames(installed.packages()))))
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

library(RColorBrewer)
library(rasterVis)
library(tidyverse)
library(raster)

rm(packages)

#define color scheme for plotting
cols    = rev(colorRampPalette(brewer.pal(11, 'Spectral'))(255)) # rainbow color scheme
mytheme = rasterTheme(region=cols)

#ocean raster at 1km
ocean = raster(file.path(dir_M, 'model/GL-NCEAS-Halpern2008/tmp/ocean.tif'))

#set mollweide projection CRS
mollCRS=crs('+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs')

#paths
dir_anx <- file.path(dir_M,'marine_threats/impact_acceleration')
