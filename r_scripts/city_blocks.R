library(tidyverse)
library(sf)
library(mapview)

# load street centerlines from DC open data
centerlines <- st_read("data/Street_Centerlines_2013.geojson") %>% 
  st_transform("ESRI:102685") %>% 
  filter(ROADTYPE == "Street")

# convert street centerlines to block polygons
centerlines_pg <- as.data.frame(st_collection_extract(st_polygonize(st_union(centerlines)))) %>% 
  mutate(block_id = row_number()) %>% 
  st_as_sf()

# load rat infestation dataset and spatialize
rats <- read.csv("data/rats_to_blocks.csv.gz") %>% 
  na.omit() %>% 
  st_as_sf(. ,coords = c("LONGITUDE","LATITUDE"), crs = 4326) %>% 
  st_transform(crs = "ESRI:102685")

# spatial join to assign each rat datapoint to a block polygon
rats_block_join <- st_join(rats, centerlines_pg)

# count observations per block for mapping
centerlines_pg <- left_join(centerlines_pg, rats_block_join %>% 
                                            st_drop_geometry() %>% 
                                            group_by(block_id) %>% 
                                            summarize(rat_count = n())) %>% 
  mutate(rat_count= replace_na(rat_count, 0))

ggplot() +
  geom_sf(data = centerlines_pg, aes(fill = rat_count), color = "transparent")
