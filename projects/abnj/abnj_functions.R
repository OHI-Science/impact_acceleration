

saveClippedRgn <- function(raster_data_path, mask_raster_name, crop_rgn){ # raster_data_path= latlong_impacts[1]
  
  master <- raster(raster_data_path)
  master_name <- gsub(".tif", "", basename(raster_data_path))
  master_crop <- crop(master, crop_rgn)
  
  # save cropped file as tif
  writeRaster(master_crop, file.path(dir_M, sprintf("git-annex/impact_acceleration/projects/abnj/clipped_files/%s_%s.tif", mask_raster_name, master_name)), overwrite=TRUE)
  
  tmp <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/projects/abnj/clipped_files/%s_%s.tif", mask_raster_name, master_name)))
  #plot(tmp)
  
  # save a 2nd version of masked file as tif
  mask_raster <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/projects/abnj/spatial/%s_latlong_raster.tif", mask_raster_name)))
  mask(tmp, mask_raster, 
       file.path(dir_M, sprintf("git-annex/impact_acceleration/projects/abnj/clipped_files/%s_rgn_mask_%s.tif", mask_raster_name, master_name)), overwrite=TRUE)
  
  # check <- raster(file.path(dir_M, sprintf("git-annex/impact_acceleration/projects/abnj/clipped_files/%s_rgn_mask_%s.tif", mask_raster_name, master_name)))
  # plot(check)
}



####################
# Plotting functions
####################
# Controlled color scale


## rgn plot
plot_impact_rgn <- function(impact_crop, region = "wio", 
                            color_breaks = chi_breaks, cols = chi_cols, 
                            legend_break_labels = chi_legend_labels, label_sequence = chi_label_sequence,
                            legend=TRUE, title=TRUE, saveLoc=""){
  # impact_crop = impact_wio[1]
  # color_breaks=chi_breaks
  # region = "wio"  
  # cols=chi_cols
  # legend_break_labels=chi_legend_labels 
  # label_sequence = chi_label_sequence
  
  border_shape = get(region)  
  
  stress <- basename(impact_crop) 
  stress <- gsub("wio", "", stress)
  stress <- gsub("cpps", "", stress)
  stress <- gsub("_latlong_", "", stress)
  stress <- gsub("_2013.tif", "", stress)
  stress <- gsub("_rgn_mask", "", stress)
  stress_plot_name <- gsub("_ln", "", stress)
  stress_plot_name <- pressure_name$pressure_name[pressure_name$pressure == stress_plot_name]
  
  saveFile <-  sprintf("%s_%s_2013.png", region, stress)
  
  impact_rast <- raster(impact_crop)
  
  png(here(sprintf("projects/abnj/figures/rgn_maps%s/%s", saveLoc, saveFile)), 
      res=500, width=7, height=6, units="in")  
  
  par(mar=c(2,2,2,5)) # bottom, left, top, and right
  par(oma=c(0,0,0,1))
  
  plot(extent(impact_rast), 
       type="n", xaxs="i", yaxs="i", axes=FALSE)
  
if(title){
  title(stress_plot_name, line=1) #, cex.main =title_size)
}
  
  plot(land_wgs, add=TRUE, col="gray90", border="gray75", lwd=0.5)
  
  plot(impact_rast, col=cols, add=TRUE, legend=FALSE, breaks=color_breaks)
  
  plot(border_shape, border="red", add=TRUE)
  
  box("plot", col="gray")
  
  if(legend){
  par(mar=c(2,2,2,2)) # bottom, left, top, and right
  par(oma=c(0,0,0,0))
  
  break_locations <- seq(0, length(color_breaks), length.out=length(color_breaks)) # breaks for colors for legend
  legend_label_locations <- break_locations[label_sequence] # label locations (every other color labeled)
  
  fields::image.plot(impact_rast, #zlim = c(min(myBreaks), max(myBreaks)), 
                     legend.only = TRUE, 
                     #legend.shrink=legend.shrink,
                     #legend.width=legend.width,
                     col = chi_cols,
                     #legend.lab=title_legend,
                     breaks=break_locations,
                     axis.args=list(cex.axis=1, at=legend_label_locations, labels=legend_break_labels))
  }
  dev.off()
  
}

##############################

## global plot
plot_impact_global <- function(impact_global, region = NA, 
                            color_breaks = chi_breaks, cols = chi_cols, 
                            legend_break_labels = chi_legend_labels, label_sequence = chi_label_sequence,
                            legend=TRUE, title = TRUE, saveLoc = ""){
  # impact_crop = impact_wio[1]
  # color_breaks=chi_breaks
  # region = "wio"  
  # cols=chi_cols
  # legend_break_labels=chi_legend_labels 
  # label_sequence = chi_label_sequence
  
  border_shape = get(region)  
  
  stress <- basename(impact_global) 
  stress <- gsub("2013.tif", "", stress)
  stress <- gsub("_rgn_mask", "", stress)
  stress_plot_name <- gsub("_ln", "", stress)
  stress_plot_name <- pressure_name$pressure_name[pressure_name$pressure == stress_plot_name]

  saveFile <-  sprintf("global_%s_%s2013.png", region, stress)
  
  impact_rast <- raster(impact_global)
  
  png(here(sprintf("projects/abnj/figures/rgn_maps%s/%s", saveLoc, saveFile)), 
      res=500, width=12, height=6, units="in")  
  
  par(mar=c(1,1,1,1)) # bottom, left, top, and right
  par(oma=c(0,0,0,0))

  plot(impact_rast, col=cols, legend=FALSE, breaks=color_breaks, axes=FALSE, box=FALSE)
  
  if(title){
  title(stress_plot_name, line=1) #, cex.main =title_size)
  }
    
  plot(land_wgs, add=TRUE, col="gray90", border="gray75", lwd=0.25)
  
  if(!is.na(region)){
  plot(border_shape, border="red", add=TRUE, lwd=1)
  }
    
  if(legend){
    # par(mar=c(2,2,2,2)) # bottom, left, top, and right
    # par(oma=c(0,0,0,0))
    
    break_locations <- seq(0, length(color_breaks), length.out=length(color_breaks)) # breaks for colors for legend
    legend_label_locations <- break_locations[label_sequence] # label locations (every other color labeled)
    
    fields::image.plot(impact_rast, #zlim = c(min(myBreaks), max(myBreaks)), 
                       legend.only = TRUE, 
                       legend.shrink = 0.7,
                       legend.width = 0.7,
                       col = chi_cols,
                       #legend.lab=title_legend,
                       breaks=break_locations,
                       axis.args=list(cex.axis=0.6, at=legend_label_locations, labels=legend_break_labels))
  }
  dev.off()
  
}

###################################


# floating color scale

## region plot

plot_impact_rgn_no_brks <- function(impact_crop, region = "wio", 
                            cols = chi_cols, 
                            legend=TRUE, title=TRUE, saveLoc=""){
  # impact_crop = impact_wio[1]
  # region = "wio"  
  # cols=chi_cols
  
  border_shape = get(region)  
  
  stress <- basename(impact_crop) 
  stress <- gsub("wio", "", stress)
  stress <- gsub("cpps", "", stress)
  stress <- gsub("_latlong_", "", stress)
  stress <- gsub("_2013.tif", "", stress)
  stress <- gsub("_rgn_mask", "", stress)
  stress_plot_name <- gsub("_ln", "", stress)
  stress_plot_name <- pressure_name$pressure_name[pressure_name$pressure == stress_plot_name]
  
  saveFile <-  sprintf("float_scale_%s_%s_2013.png", region, stress)
  
  impact_rast <- raster(impact_crop)
  
  png(here(sprintf("projects/abnj/figures/rgn_maps/floating_color_scale%s/%s",  
                   saveLoc, saveFile)), 
      res=500, width=7, height=6, units="in")  
  
  par(mar=c(2,2,2,5)) # bottom, left, top, and right
  par(oma=c(0,0,0,1))
  
  plot(extent(impact_rast), 
       type="n", xaxs="i", yaxs="i", axes=FALSE)
  
  if(title){
    title(stress_plot_name, line=1) #, cex.main =title_size)
  }
  
  plot(land_wgs, add=TRUE, col="gray90", border="gray75", lwd=0.5)
  
  plot(impact_rast, col=cols, add=TRUE, legend=FALSE)
  
  plot(border_shape, border="red", add=TRUE)
  
  box("plot", col="gray")
  
  if(legend){
    par(mar=c(2,2,2,2)) # bottom, left, top, and right
    par(oma=c(0,0,0,0))
    plot(impact_rast, col=cols, legend.only=TRUE)
        
  }
  dev.off()
  
}

