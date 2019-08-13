# The rate of change of Cumulative Human Impacts to global oceans

This repository houses ths scripts used to preare the data for publication: “Recent pace of change in human impact on the world’s ocean” ([Halpern et al. 2019](https://rdcu.be/bOx31)). The goal of this project was to describe the patterns and pace of change in human impacts on ocean ecosystems due to expanding and increasing intensity of human activities. We combined high resolution, annual data on the intensity of 14 human stressors and their impact on 21 marine ecosystems over 11 years (2003-2013).  To determine average annual change in impact, we applied a linear regression model to each raster cell.

Intermediate and final global raster datasets are available here: https://knb.ecoinformatics.org/view/doi:10.5063/F12B8WBS

Folder/file descriptions

folder/file name     |  description    
--------------- | -------------------
stressors       | scripts used to prepare individual stressor files (raw and rescaled from 0-1)
impacts         | scripts used to create stressor and cumulative impact rasters (impact of stressors given habitat vulnerability)
trend           | script used calculate average annual change in stressor and cumulative impacts
habitats        | scripts used to create seaice habitat; csv list of all habitats
vulnerability_weighting_matrix.csv | csv file with vulnerability weights for each stressor and habitat combination
extras          | project planning documents; scripts to check data
habitats        | scripts used to create seaice habitat; csv list of all habitats
no_sst         | impact and trend data after removing SST
paper    | files used to generate data and figures for paper
vulnerability_weighting_matrix.csv | csv file with vulnerability weights for each stressor and habitat combination


