# Script that copies stressor layers from OHI to impact_acceleration folder

# 10/25/16

# Jamie Afflerbach

# This script copies data into input folders on Mazu (mazu/ohi/marine_threats/impact_aceleration) for each of the stressor layers. The input
# files are NOT rescaled. These are the raw annual layers that we will use to calculate rate of change

source('~/github/impact_acceleration/src/R/common.R')

targetdir = file.path(dir_M,'marine_threats/impact_acceleration/v2016')

### Ocean Acidification

#OA yearly means from 2005 - 2016
oa_files <- c(list.files(file.path(dir_M,'git-annex/globalprep/prs_oa/v2015/working/annualmean_2005-2014/moll'), pattern = '.tif',full.names=T),
              list.files(file.path(dir_M,'git-annex/globalprep/prs_oa/v2016/int'), pattern = 'moll', full.names=T))[1:12]


file.copy(oa_files, to=file.path(targetdir, 'stressors/oa/input'), overwrite=T)

### Sea Surface Temperature

sst_files <- list.files(file.path(dir_M,'git-annex/globalprep/prs_sst/v2015/tmp'), pattern = 'annual', full.names=T)

file.copy(sst_files,to = file.path(targetdir,'stressors/sst/input'), overwrite=T)

### Sea Level Rise

slr_files <- list.files('~/github/ohiprep/globalprep/prs_slr/v2016/int/msla_annual_mean', full.names=T)

file.copy(slr_files, to = file.path(targetdir,'stressors/slr/input'), overwrite=T)


### UV

uv_files <- list.files('~/github/ohiprep/globalprep/prs_uv/v2016/int', pattern = 'annual_pos', full.names=T)

file.copy(uv_files, to = file.path(targetdir, 'stressors/uv/input'),overwrite=T)


### Artisanal Fishing

art_files <- list.files('~/github/ohiprep/globalprep/prs_fish/v2016/int/artisanal_npp',full.names=T)

file.copy(art_files, to = file.path(targetdir, 'stressors/art_fish/input'),overwrite=T)


