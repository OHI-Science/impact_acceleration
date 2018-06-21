### Summarizing chi and pressure data for eez boundaries

library(dplyr)
library(tidyr)
library(googleVis)
library(raster)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(RColorBrewer)
library(ohicore)

## eez regions
source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

rgns_global <- rgns_global %>%
  filter(type_w_ant == "eez") %>%
  dplyr::select(rgn_id = rgn_ant_id, rgn_name)


### chi
chi <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/cumulative_impact"), full=TRUE)

chi_stack <- stack(chi)

chi_data <- zonal(chi_stack, zones, fun="mean", progress="text", na.rm=TRUE)

chi_data_df <- data.frame(chi_data) %>%
  gather("pressure", "value", -1) %>%
  rename("rgn_id" = zone) %>%
  mutate(year = as.numeric(substring(pressure, 5, 8))) %>%
  mutate(pressure = "chi") %>%
  inner_join(rgns_global, by="rgn_id")

write.csv(chi_data_df, "impacts/zonal_data_eez/eez_chi.csv", row.names=FALSE)

plot_data <- read.csv("impacts/zonal_data_eez/eez_chi.csv") %>%
  dplyr::select(rgn_name, year, value)
Motion=gvisMotionChart(plot_data, 
                       idvar="rgn_name", 
                       timevar="year")
plot(Motion)
print(Motion, file="impacts/zonal_data_eez/eez_chi.html")

plot_data <- read.csv("impacts/zonal_data_eez/eez_chi.csv") %>%
  dplyr::select(rgn_name, year, value)

avg <- plot_data %>%
  group_by(rgn_name) %>%
  summarize(average=mean(value))

plot_data <- plot_data %>%
  left_join(avg, by="rgn_name")

plot_data$rgn_name <- factor(plot_data$rgn_name, 
                             levels = unique(plot_data$rgn_name)[order(plot_data$average, decreasing = TRUE)])
cols = rev(colorRampPalette(brewer.pal(11, 'Spectral'))(255)) # 

tmp <- ggplot(plot_data, aes(y=year, x=rgn_name, text=)) +
  geom_tile(aes(fill=value, 
      text=sprintf("region: %s \nyear: %s \npressure: %s" , rgn_name, year, round(value, 2))), color="white") +
  scale_fill_gradientn(colors=rev(brewer.pal(11, 'Spectral'))) +
  ylab("Year") + 
  xlab("Region") +
theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) 
  
tmp_plotly <- ggplotly(tmp, tooltip = "text")
htmlwidgets::saveWidget(widget=tmp_plotly, "eez_chi_heat.html", selfcontained = TRUE)

### Trend 

trend <- raster(file.path(dir_M, "git-annex/impact_acceleration/trend/chi_coef_slope.tif"))

trend_data <- zonal(trend, zones, fun="mean", progress="text", na.rm=TRUE)

trend_data_df <- data.frame(trend_data) %>%
  rename("rgn_id" = zone, "value"=mean) %>%
  mutate(pressure = "chi_trend") %>%
  inner_join(rgns_global, by="rgn_id")

write.csv(trend_data_df, "impacts/zonal_data_eez/eez_chi_trend.csv", row.names=FALSE)

plot_data <- read.csv("impacts/zonal_data_eez/eez_chi_trend.csv") 
  
plot_data$rgn_name <- factor(plot_data$rgn_name, 
                    levels = unique(plot_data$rgn_name)[order(plot_data$value, decreasing = TRUE)])

tmp <- ggplot(plot_data, aes(y=value, x=rgn_name, color=value)) +
  geom_bar(aes(text=sprintf("region: %s \n trend: %s", rgn_name, round(value, 4))), stat="identity") +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                    panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) 
  
tmp_plotly <- ggplotly(tmp, tooltip = "text")
htmlwidgets::saveWidget(widget=tmp_plotly, "eez_chi_trend.html", selfcontained = TRUE)



# scatterplot comparing the data
chi <- read.csv("impacts/zonal_data_eez/eez_chi.csv") %>%
  dplyr::select(rgn_name, year, value)

avg <- chi %>%
  group_by(rgn_name) %>%
  summarize(average_chi=mean(value))

UNrgns <- UNgeorgn_nm %>%
  select(rgn_name=rgn_label, r2_label, r1_label)

plot_data <- read.csv("impacts/zonal_data_eez/eez_chi_trend.csv") %>%
  left_join(avg, by="rgn_name") %>%
  select(rgn_name, rgn_id, trend_chi=value, average_chi)%>%
  left_join(UNrgns, by="rgn_name")


tmp <- ggplot(plot_data, aes(y=average_chi, x=trend_chi, color=r1_label)) +
  geom_point(aes(text=sprintf("%s\ntrend: %s\naverage: %s", rgn_name, 
                              round(trend_chi, 4), round(average_chi, 2))), 
             alpha=0.5, size=2)+
  xlab("Trend CHI") +
  ylab("Average CHI") + 
  theme_bw()
tmp_plotly <- ggplotly(tmp, tooltip = "text")
htmlwidgets::saveWidget(widget=tmp_plotly, "eez_chi_avg_trend.html", selfcontained = TRUE)

## pressures

########### Years

years <- 2003:2013

years_subset <- paste(years, collapse="|")


####### Stressors
stress_files <- list.files(file.path(dir_M, "git-annex/impact_acceleration/stressors"), recursive = TRUE, 
                           pattern = ".tif", full="TRUE")
stress_files <- grep("/final/", stress_files, value=TRUE)

#filter to relevant years
stress_files <- grep(years_subset, stress_files, value=TRUE)

stress_stack <- stack(stress_files)

hab_data <- raster::zonal(stress_stack, zones, fun="mean", progress="text", na.rm=TRUE)
  
  hab_data_df <- data.frame(hab_data) %>%
    tidyr::gather("pressure", "value", -1) %>%
    dplyr::rename("rgn_id" = zone) %>%
    dplyr::mutate(pressure = gsub("_rescaled_mol", "", pressure)) %>%
    dplyr::mutate(year = as.numeric(stringr::str_sub(pressure, -4,-1))) %>%
    dplyr::mutate(pressure = stringr::str_sub(pressure, 1, stringr::str_length(pressure)-5)) %>%
    inner_join(rgns_global, by="rgn_id")
  
  write.csv(hab_data_df, "impacts/zonal_data_eez/eez_pressure.csv", row.names=FALSE)




##########################################
#### 3nm eez regions

rgns_3nm <- raster::raster(file.path(dir_M, "git-annex/globalprep/spatial/v2018/rgns_3nm_offshore_mol.tif"))


### chi
chi <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/cumulative_impact"), full=TRUE)

chi_stack <- stack(chi)

chi_data <- zonal(chi_stack, rgns_3nm, fun="mean", progress="text", na.rm=TRUE)

chi_data_df <- data.frame(chi_data) %>%
  gather("pressure", "value", -1) %>%
  rename("rgn_id" = zone) %>%
  mutate(year = as.numeric(substring(pressure, 5, 8))) %>%
  mutate(pressure = "chi") %>%
  inner_join(rgns_global, by="rgn_id")

write.csv(chi_data_df, "impacts/zonal_data_eez/eez_3nm_chi.csv", row.names=FALSE)

plot_data <- read.csv("impacts/zonal_data_eez/eez_3nm_chi.csv") %>%
  dplyr::select(rgn_name, year, value)

Motion=gvisMotionChart(plot_data, 
                       idvar="rgn_name", 
                       timevar="year")
plot(Motion)
print(Motion, file="impacts/zonal_data_eez/eez_3nm_chi.html")

plot_data <- read.csv("impacts/zonal_data_eez/eez_3nm_chi.csv") %>%
  dplyr::select(rgn_name, year, value)

avg <- plot_data %>%
  group_by(rgn_name) %>%
  summarize(average=mean(value))

plot_data <- plot_data %>%
  left_join(avg, by="rgn_name")

plot_data$rgn_name <- factor(plot_data$rgn_name, 
                             levels = unique(plot_data$rgn_name)[order(plot_data$average, decreasing = TRUE)])
cols = rev(colorRampPalette(brewer.pal(11, 'Spectral'))(255)) # 

tmp <- ggplot(plot_data, aes(y=year, x=rgn_name, text=)) +
  geom_tile(aes(fill=value, 
                text=sprintf("region: %s \nyear: %s \npressure: %s" , rgn_name, year, round(value, 2))), color="white") +
  scale_fill_gradientn(colors=rev(brewer.pal(11, 'Spectral'))) +
  ylab("Year") + 
  xlab("Region") +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) 

tmp_plotly <- ggplotly(tmp, tooltip = "text")
htmlwidgets::saveWidget(widget=tmp_plotly, "eez_3nm_chi_heat.html", selfcontained = TRUE)

### Trend 

trend <- raster(file.path(dir_M, "git-annex/impact_acceleration/trend/chi_coef_slope.tif"))

trend_data <- zonal(trend, rgns_3nm, fun="mean", progress="text", na.rm=TRUE)

trend_data_df <- data.frame(trend_data) %>%
  rename("rgn_id" = zone, "value"=mean) %>%
  mutate(pressure = "chi_trend") %>%
  inner_join(rgns_global, by="rgn_id")

write.csv(trend_data_df, "impacts/zonal_data_eez/eez_chi_3nm_trend.csv", row.names=FALSE)

plot_data <- read.csv("impacts/zonal_data_eez/eez_chi_3nm_trend.csv") 

plot_data$rgn_name <- factor(plot_data$rgn_name, 
                             levels = unique(plot_data$rgn_name)[order(plot_data$value, decreasing = TRUE)])

tmp <- ggplot(plot_data, aes(y=value, x=rgn_name, color=value)) +
  geom_bar(aes(text=sprintf("region: %s \n trend: %s", rgn_name, round(value, 4))), stat="identity") +
  theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) 

tmp_plotly <- ggplotly(tmp, tooltip = "text")
htmlwidgets::saveWidget(widget=tmp_plotly, "eez_chi_3nm_trend.html", selfcontained = TRUE)


