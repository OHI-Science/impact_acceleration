###############################
## downloading fisheries data
###############################

# paper url: https://www.nature.com/articles/sdata201739
# data url: http://metadata.imas.utas.edu.au/geonetwork/srv/eng/metadata.show?uuid=c1fefb3d-7e37-4171-b9ce-4ce4721bbc78
# V2.0 of the data, downloaded 4/20/2017
# issue: #776

source("../ohiprep/src/R/common.R")

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic1014.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic1014.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic0509.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic0509.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic0004.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic0004.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic9599.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic9599.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic9094.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic9094.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic8589.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic8589.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic8084.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic8084.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic7579.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic7579.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic7074.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic7074.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic6569.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic6569.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic6064.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic6064.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic5559.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic5559.rds"))

data <- read.csv("http://data1.tpac.org.au/thredds/fileServer/CatchPublic/CatchPublic5054.csv")
saveRDS(data, 
        file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic5054.rds"))


##### exploring data
data <- readRDS(file.path(dir_M, "marine_threats/impact_acceleration/v2016/stressors/comm_fish/data/CatchPublic1014.rds"))
head(data)
