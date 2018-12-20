After stressor rasters are created (impact_acceleration/stressors) that describe stressor on a scale of 0-1,
the following is run:
  
Calc_stressor_habita_vuln_combos.Rmd: Multiplies the stressor x habitat x vulnerability layers to get the 
  stressor/habitat combos for each year.
  
Calc_stressor_impacts.Rmd: For each pressure/year sums the relevant stressor x habitat x vulnerability rasters and then 
   divides by the number of habitats
   
Calc_CHI: For each year, sums the individual impacts to get a cumulative human impacts raster for each year 


### Visualization
cumulative_impact_vis.Rmd: plot all the CHI rasters for all years
individual_impact_same_legend_vis.Rmd: plot each pressure impact for all years

### Analysis
Calc_quantiles.Rmd: Calculate global quantiles of data and visualize

