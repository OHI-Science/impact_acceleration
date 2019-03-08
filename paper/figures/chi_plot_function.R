## code used to make chi plots with defined breaks

chi_plot <- function(raster_data, title, title_legend=NULL, title_size = 1, 
                       color_breaks=chi_breaks, cols=chi_cols,
                       legend_break_labels=chi_legend_labels, 
                     label_sequence = chi_label_sequence, 
                     legend=TRUE, condensed=FALSE){
  if(condensed){
  par(mar=c(0,0,1.3,0)) # bottom, left, top, and right
  } else{
    par(mar=c(1,1,1,1)) # bottom, left, top, and right
  }
    
  par(oma=c(0,0,0,0))
  plot(raster_data, col=cols, axes=FALSE, box=FALSE, breaks=color_breaks, legend=FALSE)
  title(title, line=0, cex.main =title_size)
  
  if(legend){
  # add axis with fields package function:
  break_locations <- seq(0, length(color_breaks), length.out=length(color_breaks)) # breaks for colors for legend
  legend_label_locations <- break_locations[label_sequence] # label locations (every other color labeled)
  
  fields::image.plot(raster_data, #zlim = c(min(myBreaks), max(myBreaks)), 
                     legend.only = TRUE, 
                     legend.shrink=legend.shrink,
                     legend.width=legend.width,
                     col = cols,
                     #legend.lab=title_legend,
                     breaks=break_locations,
                     axis.args=list(cex.axis=0.6, at=legend_label_locations, labels=legend_break_labels))
  }
  
  plot(land, add=TRUE, border="gray80", col="gray90", lwd=0.5)
}



trend_plot <- function(plotRaster, scaleRaster=plotRaster, overlay=TRUE, overlay_rast=NA, legend=TRUE,
                       title=""){
  par(mar=c(1, 1, 1, 1))
  par(oma=c(0,0,0,0))
  
  low <- rev(c("#E0F3F8", "#ABD9E9", "#74ADD1", "#5C91C2", "#4575B4"))
  high <- rev(c("#A50026", "#C11B26", "#D02926", "#E14631", "#F46D43", "#F9A669", "#FEE090", "#FFF1CC"))
  
  quants <- quantile(scaleRaster, c(0.00001, 0.99999))
  low_breaks <- c(minValue(scaleRaster)-0.01, 
                  seq(quants[[1]], 0, by=0.005))
  high_breaks <- c(seq(0, quants[[2]], by=0.005),
                   maxValue(scaleRaster)+0.01)
  
  low_cols <- colorRampPalette(low)(length(low_breaks)-1)
  high_cols <- colorRampPalette(high)(length(high_breaks)-1)
  cols <- c(low_cols, "#F4FBFC", "#F4FBFC", high_cols)
  
  plot(plotRaster, col=cols,  
       breaks=c(low_breaks, high_breaks), 
       legend=FALSE, axes=FALSE, box=FALSE)
  title(title, line=0)
  
  if(overlay){
    plot(overlay_rast, col="#ffffff", add=TRUE, legend=FALSE, box=FALSE)
  }
  
  plot(land, add=TRUE, border="gray80", col="gray90", lwd=0.5)
  
  if(legend){
  par(mfrow=c(1, 1), mar=c(1, 0, 1, 0), new=FALSE)
  
  plot(scaleRaster, legend.only=TRUE, legend.shrink=.7, legend.width=.7, col=cols,
       breaks=c(low_breaks, high_breaks),
       axis.args = list(cex.axis = 0.6, 
                        at = c(minValue(scaleRaster), quants[[1]], 
                               -0.1, 0, 0.1, 0.2,
                               quants[[2]], maxValue(scaleRaster)),
                        labels = c(round(minValue(scaleRaster), 2), round(quants[[1]], 2), 
                                   -0.1, 0, 0.1, 0.2,
                                   round(quants[[2]], 2), round(maxValue(scaleRaster), 2))
       ))
  }
}


