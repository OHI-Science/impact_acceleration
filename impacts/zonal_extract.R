### Summarizing chi and pressure data for various boundaries

library(dplyr)
library(tidyr)


## eez regions
source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

rgns_global <- rgns_global %>%
  filter(type_w_ant == "eez") %>%
  dplyr::select(rgn_id = rgn_ant_id, rgn_name)

chi <- list.files(file.path(dir_M, "git-annex/impact_acceleration/impact/cumulative_impact"), full=TRUE)

chi_stack <- stack(chi)

chi_data <- zonal(chi_stack, zones, fun="mean", progress="text", na.rm=TRUE)

chi_data_df <- data.frame(chi_data) %>%
  gather("pressure", "value", -1) %>%
  rename("rgn_id" = zone) %>%
  mutate(year = as.numeric(substring(pressure, 5, 8))) %>%
  mutate(pressure = "chi") %>%
  inner_join(rgns_global, by="rgn_id")

write.csv(chi_data_df, "impacts/zonal_data/eez_chi.csv", row.names=FALSE)



