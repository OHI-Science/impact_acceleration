notes from discussing project organization - 9/30

- Where possible do not duplicate files - just pull in from ohiprep

- write up a 2 page document outlining all of our pressures, time series data and our decisions (as of now) for how to rescale

- We are going to create a few different groups of layers:
  - annual rasters with values NOT normalized, keeping coarsest resolution (not 1km)
- rescaled rasters from 0 to 1 (at 1km res - make sure to take the 99.99th quantile after reprojecting and rescaling)
- impact layers (annual raster times all habitats and weights)

in each stressor folder, no sub folders, just two types of files - "raw" and "rescaled". Make sure these words are in the file path before year.

we have 3 folders: habitats, stressors, impacts. Within stressors we have the raw and rescaled data, within impacts create folders for each stressor that has the stressor*habitat*impact. Make sure that the year is the last part of the file name. 

- average impact (it's own folder?) - per stressor, we calculate an average impact. So if there are 20 habitats, we have the stressor * habitat * weight (20 files) and then we average across these 20 to get average impact per stressor
- cumulative impacts - this is the sum of all average impacts across stressors

- put readme in each folder to explain organization

basic org is:
1. stressor * habitat * weight -> impacts
2. then average impacts
3. then cumulative impacts
