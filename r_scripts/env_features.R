# Temp
source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")
root.dir = "https://github.com/henryfeinstein/musa-rats/blob/main/data/"
# Etc
options(scipen=999)
options(tigris_class = "sf")

## Address Points
addresses <- read.csv("./data/Address_Points.csv", header = TRUE) 
addresses.sf <- st_as_sf(addresses, coords = c("X", "Y"), crs = 4326, agr = "constant")

## Community Garden Polygons
comm_gardens <- st_read("./data/Community_Garden_Areas.geojson") %>%
  st_transform('ESRI:102685')

## CAMA Commercial
cama_comm <- read.csv("./data/Computer_Assisted_Mass_Appraisal_-_Commercial.csv", header = TRUE)

## CAMA Condominium 
cama_condo <- read.csv("./data/Computer_Assisted_Mass_Appraisal_-_Condominium.csv", header = TRUE)

## CAMA Residential
cama_res <- read.csv("./data/Computer_Assisted_Mass_Appraisal_-_Residential.csv", header = TRUE)

## Construction Permits 2015
const_permits15 <- read.csv("./data/Construction_Permits_in_2015.csv", header = TRUE)
const_permits15.sf <- st_as_sf(const_permits15, coords = c("LONGITUDE", "LATITUDE"), crs = 4326, agr = "constant")

## Construction Permits 2016
const_permits16 <- read.csv("./data/Construction_Permits_in_2016.csv", header = TRUE)
const_permits16.sf <- st_as_sf(const_permits16, coords = c("LONGITUDE", "LATITUDE"), crs = 4326, agr = "constant")

## Impervious Surfaces 2015
imp_surfaces <- st_read("./data/Impervious_Surface_2017.geojson") %>%
  st_transform('ESRI:102685')

## Public Trash Cans
trash_cans <- read.csv("./data/Litter_Cans.csv", header = TRUE)
trash_cans.sf <- st_as_sf(trash_cans, coords = c("X", "Y"), crs = 4326, agr = "constant")

## National Parks
nat_parks <- st_read("./data/National_Parks.geojson") %>%
  st_transform('ESRI:102685')

## Parks and Rec Parks
dc_parks <- st_read("./data/Parks_and_Recreation_Areas.geojson") %>%
  st_transform('ESRI:102685')

## Sidewalk Grates (Sewer)
sewer_grates <- read.csv("./data/Sidewalk_Grates_2019.csv", header = TRUE)
sewer_grates.sf <- st_as_sf(sewer_grates, coords = c("X", "Y"), crs = 4326, agr = "constant")

## Storm Drains (Markers)
storm_drains <- read.csv("./data/Storm_Drain_Marker_Installations.csv", header = TRUE)
storm_drains.sf <- st_as_sf(storm_drains, coords = c("LONGITUDE", "LATITUDE"), crs = 4326, agr = "constant")

## Urban Ag Area
urban_ag <- st_read("./data/Urban_Agriculture_Areas.geojson") %>%
  st_transform('ESRI:102685')

## Zoning Map
zoning <- st_read("C./data/Zoning_Regulations_of_2016.geojson") %>%
  st_transform('ESRI:102685')


## Joining construction permits 
const_permits_all <- rbind(const_permits15, const_permits16)
const_permits.sf <- st_as_sf(const_permits_all, coords = c("LONGITUDE", "LATITUDE"), crs = 4326, agr = "constant")
