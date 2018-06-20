## evaluating quantile info

library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)


files <- list.files("impacts/quantiles", full=TRUE, pattern=".csv")



filter_str <- function(stressor){ #stressor <- "art_fish"
stress_files <- grep(stressor, files, value=TRUE)

all_data <- c()
for (file in stress_files){ # file = stress_files[1]
  little_data <- read.csv(file)
  all_data <- rbind(all_data, little_data)
}

all_data$year <- as.numeric(str_sub(all_data$impact,-8,-5))
all_data
}

### Ocean acidification 
plot_data <- filter_str(stressor="oa") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Ocean acification")

##SST
plot_data <- filter_str(stressor="sst") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "SST")

### Sea level rise
plot_data <- filter_str(stressor="slr") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Sea level rise")


## Artisanal fishing
plot_data <- filter_str(stressor="art_fish")  %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "artisanal fishing")

###Pelagic low bycatch
plot_data <- filter_str(stressor="pel_lb") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Pelagic low bycatch")

###Pelagic high bycatch
plot_data <- filter_str(stressor="pel_hb") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Pelagic high bycatch")

### Demersal destructive
plot_data <- filter_str(stressor="dem_des") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Demersal destructive")

### Demersal nondestructive high bycatch 
plot_data <- filter_str(stressor="dem_nondest_hb") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Demersal nondestructive high bycatch")



###Shipping
plot_data <- filter_str(stressor="shipping") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "shipping")



### Organic pollution
plot_data <- filter_str(stressor="organic") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Landbased organic pollution")

### Nutrient pollution
plot_data <- filter_str(stressor="nutrient") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Landbased nutrient pollution")

### Light
plot_data <- filter_str(stressor="light") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Light pollution")

### Direct human
plot_data <- filter_str(stressor="human") %>%
  mutate(quant = gsub("%", "", quant)) %>%
  mutate(quant = paste0("quant_", quant)) %>%
  filter(quant %in% c("quant_50", "quant_95", "quant_99"))

ggplot(plot_data, aes(x=year, y=quants, group=quant, col=quant)) +
  geom_point(size=3) +
  geom_line() +
  theme_bw() +
  labs(title = "Human")
