#finding zoning for each block 
block_centroid <-
  st_centroid(block_dat.sf) %>%
  st_transform(block_dat.sf, crs= 4326)

sf_use_s2(FALSE)

block_centroid$row_number <- st_intersects(block_centroid,zoning.sf) #row number = zoning polygon id
zoning.sf$row_number <- rownames(zoning.sf)
address_zoning <- data.frame(addresses.sf$block_id,addresses.sf$RES_TYPE)

#blocks_zoning <- st_join(block_centroid,zoning.sf,by = "row_number", left=TRUE, drop=FALSE)

block_zone <- st_join(block_dat.sf, zoning.sf)
zoning_by_block <- block_zone %>%
  dplyr::select(block_id,ZONE_DISTRICT)

zoning_by_block$Residential_Zone <- ifelse(zoning_by_block$ZONE_DISTRICT == "Residential Zone", 1, 0)
zoning_by_block$Residential_Flat_Zone <- ifelse(zoning_by_block$ZONE_DISTRICT == "Residential Flat Zone", 1, 0)
zoning_by_block$Unzoned <- ifelse(zoning_by_block$ZONE_DISTRICT == "Unzoned", 1, 0)
zoning_by_block$Residential_Apt_Zone <- ifelse(zoning_by_block$ZONE_DISTRICT == "Residential Apartment Zone", 1, 0)
zoning_by_block$Mixed_Use <- ifelse(zoning_by_block$ZONE_DISTRICT== "Mixed-Use Zone", 1, 0)
zoning_by_block$Downtown_Zone <- ifelse(zoning_by_block$ZONE_DISTRICT== "Downtown Zone", 1, 0)
zoning_by_block$Prod_Dist_Repair <- ifelse(zoning_by_block$ZONE_DISTRICT== "Production, Distribution, and Repair Zone", 1, 0)
zoning_by_block$Special_Purpose <- ifelse(zoning_by_block$ZONE_DISTRICT== "Special Purpose Zone", 1, 0)
zoning_by_block$Neighborhood_Mixed_Use <- ifelse(zoning_by_block$ZONE_DISTRICT == "Neighborhood Mixed-Use Zone", 1, 0)

zoning_by_block <- zoning_by_block %>%
  group_by(block_id)

zoning_by_block <- zoning_by_block %>%
  dplyr::select(-ZONE_DISTRICT) %>%
  group_by(block_id,geometry) %>%
  summarize_all(.funs=sum)

zoning_by_block %>%
  dplyr::select(-block_id, geometry) %>%
  mutate(Zone= names(.)[which.max(c(Residential_Zone, Residential_Flat_Zone, Unzoned, Residential_Apt_Zone, Mixed_Use, Downtown_Zone, Prod_Dist_Repair, Special_Purpose, Neighborhood_Mixed_Use))])

zoning_by_block <- zoning_by_block %>%
  group_by(block_id) %>%
  st_drop_geometry() %>% 
  rowwise() %>%
  mutate(max = names(cur_data())[which.max(c_across(everything()))])

block_dat.sf$zoning <- zoning_by_block$max[match(block_dat.sf$block_id, zoning_by_block$block_id)]

#        (Residential_Zone, Residential_Flat_Zone, Unzoned, Residential_Apt_Zone, Mixed_Use, Downtown_Zone, Prod_Dist_Repair, Special_Purpose, Neighborhood_Mixed_Use)
#        ("Residential_Zone", "Residential_Flat_Zone", "Unzoned", "Residential_Apt_Zone", "Mixed_Use", "Downtown_Zone", "Prod_Dist_Repair", "Special_Purpose", "Neighborhood_Mixed_Use")
```

```{r}
#finding density (aka units) by block
addresses.sf <- st_join(addresses.sf, block_dat.sf)

block_units.sf <- addresses.sf %>%
  dplyr::select(geometry, ACTIVE_RES_UNIT_COUNT, block_id)

block_units.sf <- block_units.sf %>%
  st_drop_geometry()%>%
  group_by(block_id) %>%
  summarize(unit_count = sum(ACTIVE_RES_UNIT_COUNT))

block_dat.sf$res_unit_count <- block_units.sf$unit_count[match(block_dat.sf$block_id, block_units.sf$block_id)]
```

```{r}
# residential units by block 
ggplot() + geom_sf(data = block_dat.sf, aes(fill = res_unit_count), color = "transparent") +
  labs(title = "Count of Residential Units by Block") +
  mapThememin2()
```

```{r}
#most common zoning code by block 
ggplot() + geom_sf(data = block_dat.sf, aes(fill = zoning), color = "transparent") +
  labs(title = "Count of Residential Units by Block")
```
```{r,warning = FALSE, message = FALSE}
numericVars <-
  select_if(st_drop_geometry(block_dat.sf), is.numeric) %>% na.omit()


ggcorrplot(
  round(cor(numericVars), 1),
  p.mat = cor_pmat(numericVars),
  colors = c("#7fcdbb", "white", "#2c7fb8"),
  type="lower",
  insig = "blank") +  
  labs(title = "Correlation across numeric variables")  
```
```{r}
ggplot(data=block_dat.sf, aes(x=zoning, y=rats_found_count)) +
  geom_bar(stat="identity", width=0.5) + coord_flip()

```