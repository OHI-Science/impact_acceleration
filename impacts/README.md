After stressor rasters are created (impact_acceleration/stressors) that describe each stressor on a scale of 0-1, the following is run:
  
Calc_stressor_habita_vuln_combos.Rmd: Multiplies the stressor x habitat x vulnerability layers to get the stressor/habitat combos for each year.
  
Calc_stressor_impacts.Rmd: For each pressure/year sums the relevant stressor x habitat x vulnerability rasters and then divides by the number of habitats.
   
Calc_CHI.Rmd: For each year, sums the individual impacts to get a cumulative human impacts raster for each year 

Calc_habitat_impacts.Rmd: Caculate impact on each habitat by summing the stressor x habitat x vulnerability rasters for each habitat. (an alternative way to look at the data; instead of summarizing data by impact, this summarizes data by habitat) 

### Visualization
cumulative_impact_vis.Rmd: plot all the CHI rasters for all years


