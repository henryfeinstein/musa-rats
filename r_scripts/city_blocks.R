library(tidyverse)
library(sf)
library(mapview)

options(scipen=999)

# load street centerlines from DC open data
centerlines <- st_read("./data/Street_Centerlines_2013/Street_Centerlines_2013.geojson") %>% 
  st_transform("ESRI:102685") %>% 
  filter(ROADTYPE == "Street")

# wards
wards <- st_read("./data/Wards.geojson") %>% 
  st_transform("ESRI:102685") %>% 
  select(ward_name = NAME,
         ward_pop_15 = POP_2011_2015)

# convert street centerlines to block polygons
centerlines_pg <- as.data.frame(st_collection_extract(st_polygonize(st_union(centerlines)))) %>% 
  mutate(block_id = row_number()) %>% 
  st_as_sf()

# join wards to centerline polygons
centerlines_pg <- st_join(centerlines_pg, wards)

st_write(centerlines_pg, "data/city_blocks.geojson")

# load rat infestation dataset and spatialize
rats <- read.csv("./data/rats_to_blocks.csv.gz") %>% 
  na.omit() %>% 
  st_as_sf(. ,coords = c("LONGITUDE","LATITUDE"), crs = 4326) %>% 
  st_transform(crs = "ESRI:102685")

# spatial join to assign each rat datapoint to a block polygon
rats_block_join <- st_join(rats, centerlines_pg)

# count observations per block for mapping
block_dat <- left_join(centerlines_pg, rats_block_join %>% 
                                          st_drop_geometry() %>% 
                                          group_by(block_id) %>% 
                                          summarize(inspection_count = n(),
                                                    rats_found_yn = ifelse(1 %in% activity, 1, 0),
                                                    rats_found_count = sum(activity))) %>% 
  mutate(inspection_count = replace_na(inspection_count, 0),
         rats_found_yn = replace_na(rats_found_yn, 0),
         rats_found_count = replace_na(rats_found_count, 0),
         area_acres = as.numeric(st_area(.)) / 43560)

# number of inspections
ggplot() + geom_sf(data = block_dat, aes(fill = inspection_count), color = "transparent")

# rats found y/n
ggplot() + geom_sf(data = block_dat, aes(fill = rats_found_yn), color = "transparent")

# count of rats found
ggplot() + geom_sf(data = block_dat, aes(fill = rats_found_count), color = "transparent")

# rat id rate (count of rats found / number of inspections)
ggplot() + geom_sf(data = block_dat, aes(fill = rats_found_count / inspection_count), color = "transparent")

# block size
ggplot() + geom_sf(data = block_dat, aes(fill = area_acres), color = "transparent")

# distribution of block size
ggplot() + geom_density(data = block_dat %>% filter(area_acres < 100), aes(area_acres))

# inspections by ward mapped
ggplot() + geom_sf(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count)),
                   aes(fill = inspections), color = "transparent") +
           geom_sf_text(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count)),
                     aes(label = ward_name))

# inspections by ward bar chart
ggplot() + geom_bar(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count)),
                   aes(y = inspections, x = ward_name), stat = "identity")

# rat id rate by ward mapped
ggplot() + geom_sf(data = block_dat %>% 
                     group_by(ward_name) %>% 
                     summarize(inspections = sum(inspection_count),
                               rats_found_count = sum(rats_found_count)) %>% 
                     mutate(rats_found_rate = rats_found_count / inspections),
                   aes(fill = rats_found_rate), color = "transparent") +
  geom_sf_text(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count)),
               aes(label = ward_name))

# inspections per person by ward
ggplot() + geom_sf(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count),
                                                                          pop15 = first(ward_pop_15)),
                   aes(fill = inspections / pop15), color = "transparent") +
  geom_sf_text(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count)),
               aes(label = ward_name))

# rats found per person by ward
ggplot() + geom_sf(data = block_dat %>% 
                     group_by(ward_name) %>% 
                     summarize(inspections = sum(inspection_count),
                               rats_found_count = sum(rats_found_count),
                               pop15 = first(ward_pop_15)) %>% 
                     mutate(rats_found_rate = rats_found_count / inspections),
                   aes(fill = rats_found_count / pop15), color = "transparent") +
  geom_sf_text(data = block_dat %>% group_by(ward_name) %>% summarize(inspections = sum(inspection_count)),
               aes(label = ward_name))
