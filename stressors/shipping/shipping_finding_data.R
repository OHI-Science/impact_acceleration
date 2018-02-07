### Figuring the shipping data
# Cant find the raw-er version of the original data

cols = rev(colorRampPalette(brewer.pal(11, 'Spectral'))(255)) # rainbow color scheme
cols <- c("#ffffff", cols)

### Correct layer
ship5 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2013_final/normalized_by_one_time_period/shipping.tif"))
plot(ship5, col=cols)


### Given this, it seems like the corresponding data would be in 
### threats_2013_interim/new_layers/shipping

ship4 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2013_interim/new_layers/shipping/moll_nontrans_unclipped_1km/shipping.tif"))
plot(ship4, col=cols)


ln_ship4 = ship4 %>%
  mask(ocean) %>%
  raster::calc(fun_ln)
plot(ln_ship4, col=cols)

ship5 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2013_interim/new_layers/shipping/moll_nontrans_unclipped_1km_transoneperiod/shipping.tif"))
plot(ship5, col=cols)


ln_ship5 = ship5 %>%
  mask(ocean) %>%
  raster::calc(fun_ln)
plot(ln_ship5, col=cols)


### To be thorough, I tried the data in the 2008 interim folder:

ship7 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2008_interim/old_layers/shipping/moll_nontrans_clipped_1km_nonull/shipping.tif"))
plot(ship7, col=cols)
ship7

ln_ship7 = ship7 %>%
  mask(ocean) %>%
  raster::calc(fun_ln)
plot(ln_ship7, col=cols)


ship8 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2008_interim/old_layers/shipping/moll_nontrans_clipped_1km_nonull_transoneperiod/shipping.tif"))
plot(ship8, col=cols)
ship8



#### I also tried the work file:

ship1 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/work/shipping/moll_nontrans_unclipped_1km/shipping.tif"))

plot(ship1, col=cols)

fun_ln <- function(x){log(x + 1)}

ln_ship1 = ship1 %>%
  mask(ocean) %>%
  raster::calc(fun_ln)

plot(ln_ship1, col=cols)

### The shipping file in the 2008 folder is the low resolution version
ship5 <- raster(file.path(dir_M, "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2008_final/normalized_by_one_time_period/shipping.tif"))
plot(ship5, col=cols)


#######################