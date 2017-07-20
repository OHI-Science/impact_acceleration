# Script that copies stressor layers from OHI to impact_acceleration folder

# Jamie's original script is below for reference.  I am going through this now (with a bit different
# organization).  We will delete the information starting after 10/25/16 after I finish 
# reorganizing

source('~/impact_acceleration/src/R/common.R')

targetdir = file.path(dir_M,'git-annex/impact_acceleration/stressors')


### SST organize
sst_files <- list.files(file.path(dir_M,'git-annex/globalprep/prs_sst/v2016/output'), pattern = 'sst', 
                        full.names=TRUE)

file.copy(sst_files,to = file.path(targetdir,'sst/final'), overwrite=TRUE)

list.files(file.path(targetdir, "sst/final"), pattern = 'sst', full.names=TRUE)
sst_files <- list.files(file.path(targetdir, "sst/final"), pattern = 'sst')

tmp <- data.frame(old_name = sst_files, year = NA, new_name = NA)
tmp <- tmp %>%
  mutate(year = substring(sst_files, 10,13)) %>%
  mutate(old_name = paste0("/home/shares/ohi/git-annex/impact_acceleration/stressors/sst/final/", old_name)) %>%
  mutate(new_name = sprintf("/home/shares/ohi/git-annex/impact_acceleration/stressors/sst/final/sst_%s_rescaled_mol.tif", year))

file.rename(from=tmp$old_name, to=tmp$new_name)


### UV organize
# ultimately, we will want to replace these files with the 2017 version.  This will give us an 
# additional years of data (2010 and 2016) and the data is higher resolution

uv_files <- list.files(file.path(dir_M,'git-annex/globalprep/prs_uv/v2016/output'), pattern = 'uv', 
                        full.names=TRUE)

file.copy(uv_files, to = file.path(targetdir,'uv/final'), overwrite=TRUE)

list.files(file.path(targetdir, "uv/final"), pattern = 'uv', full.names=TRUE)
uv_files <- list.files(file.path(targetdir, "uv/final"), pattern = 'uv')

tmp <- data.frame(old_name = uv_files, year = NA, new_name = NA)
tmp <- tmp %>%
  mutate(year = substring(uv_files, 9,12)) %>%
  mutate(old_name = paste0("/home/shares/ohi/git-annex/impact_acceleration/stressors/uv/final/", old_name)) %>%
  mutate(new_name = sprintf("/home/shares/ohi/git-annex/impact_acceleration/stressors/uv/final/uv_%s_rescaled_mol.tif", year))

file.rename(from=tmp$old_name, to=tmp$new_name)


## Commercial fisheries.  Calculated locally using github:OHI-Science/impact_acceleration/stressors/comm_fish!

## Ocean acidification
## Jul 20 2017: Some of the files did not work...redo when Jamie sends word

oa_files <- list.files(file.path(dir_M,'git-annex/globalprep/prs_oa/v2017/output'), pattern = 'oa', 
                       full.names=TRUE)
years <- 1990:2016
oa_files <- oa_files[grep(paste(years, collapse = "|"), oa_files)]

file.copy(oa_files, to = file.path(targetdir,'oa/final'), overwrite=TRUE)

list.files(file.path(targetdir, "oa/final"), pattern = 'oa', full.names=TRUE)
oa_files <- list.files(file.path(targetdir, "oa/final"), pattern = 'oa')

tmp <- data.frame(old_name = oa_files, year = NA, new_name = NA)
tmp <- tmp %>%
  mutate(year = substring(oa_files, 14, 17)) %>%
  mutate(old_name = paste0("/home/shares/ohi/git-annex/impact_acceleration/stressors/oa/final/", old_name)) %>%
  mutate(new_name = sprintf("/home/shares/ohi/git-annex/impact_acceleration/stressors/oa/final/oa_%s_rescaled_mol.tif", year))

file.rename(from=tmp$old_name, to=tmp$new_name)



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


