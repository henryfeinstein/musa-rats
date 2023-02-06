# this script calculates spatial variables related to rat observation and treatment data points

library(tidyverse)
library(sf)
library(lubridate)
library(spdep)
library(gridExtra)
library(FNN)

source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

# ------------------------------------------------------------------------------
# setup

# load rat data
rats <- read.csv("./data/rats_to_blocks.csv.gz", header = TRUE) %>%
  na.omit() %>%
  st_as_sf(.,coords=c("LONGITUDE","LATITUDE"),crs=4326) %>%
  st_transform('ESRI:102685') %>%
  mutate(month = month(ymd_hms(SERVICEORDERDATE)),
         year = year(ymd_hms(SERVICEORDERDATE)))

# load city block polygons
centerlines <- st_read("./data/Street_Centerlines_2013/Street_Centerlines_2013.geojson") %>% 
  st_transform("ESRI:102685") %>% 
  filter(ROADTYPE == "Street")
blocks <- as.data.frame(st_collection_extract(st_polygonize(st_union(centerlines)))) %>% 
  mutate(block_id = row_number()) %>% 
  st_as_sf()
boundary <- st_union(blocks)

# ------------------------------------------------------------------------------
# making fishnet and variables 

# create fishnet
fishnet <- 
  st_make_grid(boundary,
               cellsize = 500, 
               square = TRUE) %>%
  .[boundary] %>%          
  st_sf() %>%
  mutate(uniqueID = 1:n())

# assign each inspection a value of 1 and aggregate
inspection_net <- 
  dplyr::select(rats) %>% 
  mutate(count_inspection = 1) %>% 
  aggregate(., fishnet, sum) %>%
  mutate(count_inspection = replace_na(count_inspection, 0),
         uniqueID = 1:n(),
         cvID = sample(round(nrow(fishnet) / 24), 
                       size=nrow(fishnet), replace = TRUE))

# join in rat observed variable
rat_net <- rats %>% filter(activity == 1) %>%
  st_join(fishnet, join=st_within) %>%
  st_drop_geometry() %>%
  group_by(uniqueID) %>%
  summarize(rat_obs_count = n()) %>%
  left_join(inspection_net, ., by = "uniqueID") %>%
  ungroup() %>% 
  mutate(rat_obs_count = replace_na(rat_obs_count, 0))

# ------------------------------------------------------------------------------
# distance and hotspot variable creation

# local Moran's I analysis of rat observations

## {spdep} to make polygon to neighborhoods... 
rat_net.nb <- poly2nb(as_Spatial(rat_net), queen=TRUE)
## ... and neighborhoods to list of weights
rat_net.weights <- nb2listw(rat_net.nb, style="W", zero.policy=TRUE)

local_morans <- localmoran(rat_net$rat_obs_count, rat_net.weights, zero.policy=TRUE) %>% 
  as.data.frame()

# join local Moran's I results to fishnet
rat_net.localMorans <- 
  cbind(local_morans, as.data.frame(rat_net)) %>% 
  st_sf() %>%
  dplyr::select(Rat_Observation_Count = rat_obs_count, 
                Local_Morans_I = Ii, 
                P_Value = `Pr(z != E(Ii))`) %>%
  mutate(Significant_Hotspots = ifelse(P_Value <= 0.001, 1, 0)) %>%
  gather(Variable, Value, -geometry)

# add distance to hot spot var to final fishnet
rat_net <- rat_net %>% 
  mutate(rat_obs.isSig = 
           ifelse(local_morans[,5] <= 0.001, 1, 0)) %>%
  mutate(rat_obs.isSig.dist = 
           nn_function(st_coordinates(st_centroid(rat_net)),
                       st_coordinates(st_centroid(filter(rat_net, 
                                                     rat_obs.isSig == 1))), 
                       k = 1))

# add distance to hot spot var to block dataset
blocks <- blocks %>% 
  mutate(hotspot_dist =
           nn_function(st_coordinates(st_centroid(blocks)),
                       st_coordinates(st_centroid(filter(rat_net, 
                                                         rat_obs.isSig == 1))), 
                       k = 1))

# generating knn features at block level for nearest rat observations
blocks <-
  blocks %>% 
  mutate(
    rat_nn3 = nn_function(st_coordinates(st_centroid(blocks)), st_coordinates(filter(rats, activity == 1)), k = 3), 
    rat_nn4 = nn_function(st_coordinates(st_centroid(blocks)), st_coordinates(filter(rats, activity == 1)), k = 4), 
    rat_nn5 = nn_function(st_coordinates(st_centroid(blocks)), st_coordinates(filter(rats, activity == 1)), k = 5)) 

# save out for later use
save(blocks, file = "./data/city_blocks_dist_vars.Rdata")

# ------------------------------------------------------------------------------
# correlation plots for spatial variables

# join rat obs to blocks
rats_block_join <- st_join(rats, blocks)

# count observations per block for mapping
blocks <- left_join(blocks, rats_block_join %>% 
                         st_drop_geometry() %>% 
                         group_by(block_id) %>% 
                         summarize(inspection_count = n(),
                                   rats_found_yn = ifelse(1 %in% activity, 1, 0),
                                   rats_found_count = sum(activity))) %>% 
  mutate(inspection_count = replace_na(inspection_count, 0),
         rats_found_yn = replace_na(rats_found_yn, 0),
         rats_found_count = replace_na(rats_found_count, 0),
         area_acres = as.numeric(st_area(.)) / 43560)

correlation.long <-
  st_drop_geometry(blocks) %>%
  dplyr::select(-block_id) %>%
  gather(Variable, Value, -rats_found_count)

correlation.cor <-
  correlation.long %>%
  group_by(Variable) %>%
  summarize(correlation = cor(Value, rats_found_count, use = "complete.obs"))

ggplot(correlation.long, aes(Value, rats_found_count)) +
  geom_point(size = 0.1) +
  geom_text(data = correlation.cor, aes(label = paste("r =", round(correlation, 2))),
            x=-Inf, y=Inf, vjust = 1.5, hjust = -.1) +
  geom_smooth(method = "lm", se = FALSE, colour = "black") +
  facet_wrap(~Variable, ncol = 3, scales = "free") +
  labs(title = "Rats Observed per block as a function of spatial varaibles") +
  plotTheme()

# ------------------------------------------------------------------------------
# variable visualization

# rat net vars
ggplot() +
  geom_sf(data = rat_net, aes(fill = count_inspection), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "Count of Rat Inspections per Fishnet Cell") +
  mapTheme()
ggplot() +
  geom_sf(data = rat_net, aes(fill = rat_obs_count), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "Count of Rat Observations per Fishnet Cell") +
  mapTheme()
ggplot() +
  geom_sf(data = rat_net, aes(fill = rat_obs.isSig), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "Fishnet Cell Hotspot Status") +
  mapTheme()
ggplot() +
  geom_sf(data = rat_net, aes(fill = rat_obs.isSig.dist), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "Distance to Nearest Hotspot by Fishnet Cell") +
  mapTheme()

# block-level vars
ggplot() +
  geom_sf(data = blocks, aes(fill = hotspot_dist), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "Distance to Nearest Hotspot by City Block") +
  mapTheme()
ggplot() +
  geom_sf(data = blocks, aes(fill = rat_nn3), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "KNN (K = 3) to Rat Observation by City Block") +
  mapTheme()
ggplot() +
  geom_sf(data = blocks, aes(fill = rat_nn4), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "KNN (K = 4) to Rat Observation by City Block") +
  mapTheme()
ggplot() +
  geom_sf(data = blocks, aes(fill = rat_nn5), color = NA) +
  viridis::scale_fill_viridis() +
  labs(title = "KNN (K = 5) to Rat Observation by City Block") +
  mapTheme()

# plotting moran's i
vars <- unique(rat_net.localMorans$Variable)
varList <- list()

for(i in vars){
  varList[[i]] <- 
    ggplot() +
    geom_sf(data = filter(rat_net.localMorans, Variable == i), 
            aes(fill = Value), colour=NA) +
    viridis::scale_fill_viridis(name="") +
    labs(title=i) +
    mapTheme(title_size = 14) + theme(legend.position="bottom")}

do.call(grid.arrange,c(varList, ncol = 4, top = "Local Morans I statistics, Rat Observation Count"))

