## figuring out gapfilling using average of nearest neighbors

## convert missing values to 999 to see what needs to be gapfilled:
npp_rast <- raster(npp_files[1])
npp_rast[is.na(npp_rast)] <- 999
plot(npp_rast)

npp_rast_mol <- resample(npp_rast, ocean, method="ngb")
npp_rast_mol_mask <- mask(npp_rast, ocean)  
writeRaster(npp_rast_mol_mask, )


## Gapfill using mean of surrounding cells that are NA
gf_raster <- function(x){focal(x, w = matrix(1,3,3), fun = mean, na.rm=TRUE, pad = TRUE, NAonly=TRUE)}

r <- raster(npp_files[1])
## Repeat 400 times (I found this was enough iterations to gapfill all missing values)
i <- 0
while (i <= 5000){
  r <- gf_raster(r)
  i <- i + 1
  print(i)
}

r[is.na(r)] <- 999
plot(r)

r_mol <- resample(r, ocean, method="ngb")
r_mol_mask <- mask(r_mol, ocean)  
plot(r_mol_mask)
r_mol_mask

