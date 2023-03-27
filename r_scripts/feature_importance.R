block_dat_nogeom <- block_dat %>%
  st_drop_geometry() 
block_dat_nogeom$pop_density <- ifelse(block_dat$pop_dens >= 0.0005250146, 'Above Avg', 'Below Avg')
block_dat_nogeom$rats_yn <- ifelse(block_dat_nogeom$rats_found_yn == 1, 'yes','no')
block_dat_nogeom$rats_yn_req <- ifelse(block_dat_nogeom$rats_found_yn == 1, 'yes', ifelse(block_dat_nogeom$rats_found_yn == 0 & block_dat_nogeom$inspection_count == 0 , 'no requests', 'no'))

block_dat_nogeom$dens_rats <- ifelse(block_dat_nogeom$pop_density == 'Above Avg' & block_dat_nogeom$rats_yn_req == 'yes', 'high density with rats', ifelse(block_dat_nogeom$pop_density == 'Above Avg' & block_dat_nogeom$rats_yn_req == 'no', 'high density with no rats', 'na'))

block_dat_nogeom$storm_drain_cat <- ifelse(block_dat_nogeom$storm_drain >= 1, 'storm drains', 'no storm drains')
block_dat_nogeom$sewer_grate_cat <- ifelse(block_dat_nogeom$sewer_grate >= 1, 'sewer grates', 'no sewer grates')
block_dat_nogeom$trash_can_cat <- ifelse(block_dat_nogeom$trash_can >= 1, 'trash cans', 'no trash cans')
block_dat_nogeom$const_permit_cat <- ifelse(block_dat_nogeom$const_permit >= 1, 'const permits', 'no const permits')


block_dat_nogeom %>%
  dplyr::select(rats_yn, zoning) %>%
  gather(Variable, value, -rats_yn) %>%
  count(Variable, value, rats_yn) %>%
  ggplot(., aes(value, n, fill = rats_yn)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable, scales="free") +
  scale_fill_manual(values = c("#E99191", "#E91C1C")) +
  labs(x="Blocks with Rats", y="Value",
       title = "All Blocks & Outcomes") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

block_dat_nogeom %>%
  dplyr::select(rats_yn, pop_density) %>%
  dplyr::filter(block_dat_nogeom$pop_density == 'Above Avg' | block_dat_nogeom$pop_density == 'Below Avg') %>%
  gather(Variable, value, -rats_yn) %>%
  count(Variable, value, rats_yn) %>%
  ggplot(., aes(value, n, fill = rats_yn)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable, scales="free") +
  scale_fill_manual(values = c("#E99191", "#E91C1C")) +
  labs(x="Blocks with Rats", y="Value",
       title = "Blocks with Rat ID by Population Density") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

block_dat_nogeom %>%
  dplyr::select(dens_rats, zoning) %>%
  dplyr::filter(block_dat_nogeom$dens_rats == 'high density with rats' | block_dat_nogeom$dens_rats == 'high density with no rats') %>%
  gather(Variable, value, -dens_rats) %>%
  count(Variable, value, dens_rats) %>%
  ggplot(., aes(value, n, fill = dens_rats)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable, scales="free") +
  scale_fill_manual(values = c("#E99191","#E91C1C", "darkgray")) +
  labs(x="Blocks with Rats", y="Value",
       title = "Blocks with Above Average Population Density") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

block_dat_nogeom %>%
  dplyr::select(rats_yn_req, zoning) %>%
  dplyr::filter(block_dat_nogeom$rats_yn_req == 'yes' | block_dat_nogeom$rats_yn_req == 'no') %>%
  gather(Variable, value, -rats_yn_req) %>%
  count(Variable, value, rats_yn_req) %>%
  ggplot(., aes(value, n, fill = rats_yn_req)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable, scales="free") +
  scale_fill_manual(values = c("#E99191", "#E91C1C")) +
  labs(x="Blocks with Rats", y="Value",
       title = "Removing Blocks without Requests") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

block_dat_nogeom %>%
  dplyr::select(rats_yn, storm_drain_cat, sewer_grate_cat, trash_can_cat, const_permit_cat) %>%
  gather(Variable, value, -rats_yn) %>%
  count(Variable, value, rats_yn) %>%
  ggplot(., aes(value, n, fill = rats_yn)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable,ncol = 2, scales="free") +
  scale_fill_manual(values = c("#E99191","#E91C1C", "darkgray")) +
  labs(x="Blocks with Rats", y="Value",
       title = "All Blocks & Outcomes") +
  theme(axis.text.x = element_text(angle = 0))

block_dat_nogeom %>%
  dplyr::select(rats_yn_req, storm_drain_cat, sewer_grate_cat, trash_can_cat, const_permit_cat) %>%
  dplyr::filter(block_dat_nogeom$rats_yn_req == 'yes' | block_dat_nogeom$rats_yn_req == 'no') %>%
  gather(Variable, value, -rats_yn_req) %>%
  count(Variable, value, rats_yn_req) %>%
  ggplot(., aes(value, n, fill = rats_yn_req)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable,ncol = 2, scales="free") +
  scale_fill_manual(values = c("#E99191", "#E91C1C")) +
  labs(x="Blocks with Rats", y="Value",
       title = "Removing Blocks without Requests") +
  theme(axis.text.x = element_text(angle = 0))

block_dat_nogeom %>%
  dplyr::select(dens_rats, storm_drain_cat, sewer_grate_cat, trash_can_cat, const_permit_cat) %>%
  dplyr::filter(block_dat_nogeom$dens_rats == 'high density with rats' | block_dat_nogeom$dens_rats == 'high density with no rats') %>%
  gather(Variable, value, -dens_rats) %>%
  count(Variable, value, dens_rats) %>%
  ggplot(., aes(value, n, fill = dens_rats)) +   
  geom_bar(position = "dodge", stat="identity") +
  facet_wrap(~Variable, ncol = 2, scales="free") +
  scale_fill_manual(values = c("#E99191","#E91C1C", "darkgray")) +
  labs(x="Blocks with Rats", y="Value",
       title = "Blocks with Above Average Population Density") +
  theme(axis.text.x = element_text(angle = 0))

block_dat_nogeom %>%
  dplyr::select(rats_yn, res_unit_count, inspection_count, hotspot_dist, hotspot_dist_pop_dens,rat_nn5, rat_nn5_log) %>%
  gather(Variable, value, -rats_yn) %>%
  ggplot() + 
  geom_density(aes(value, color = rats_yn), size= 1, fill = "transparent") + 
  facet_wrap(~Variable, ncol = 2, scales = "free") +
  scale_color_manual(values = c("#E99191","#E91C1C")) +
  labs(title = "All Blocks & Outcomes")

block_dat_nogeom %>%
  dplyr::select(rats_yn_req, res_unit_count, inspection_count, hotspot_dist, hotspot_dist_pop_dens,rat_nn5, rat_nn5_log) %>%
  gather(Variable, value, -rats_yn_req) %>%
  ggplot() + 
  geom_density(aes(value, color = rats_yn_req), size= 1, fill = "transparent") + 
  facet_wrap(~Variable, ncol = 2, scales = "free") +
  scale_color_manual(values = c("#E99191","darkgray", "#E91C1C")) +
  labs(title = "Removing Blocks without Requests")

block_dat_nogeom %>%
  dplyr::select(dens_rats, res_unit_count, inspection_count, hotspot_dist, hotspot_dist_pop_dens,rat_nn5, rat_nn5_log) %>%
  dplyr::filter(block_dat_nogeom$dens_rats == 'high density with rats' | block_dat_nogeom$dens_rats == 'high density with no rats') %>%
  gather(Variable, value, -dens_rats) %>%
  ggplot() + 
  geom_density(aes(value, color = dens_rats), size= 1, fill = "transparent") + 
  facet_wrap(~Variable, ncol = 2, scales = "free") +
  scale_color_manual(values = c("#E99191","#E91C1C")) +
  labs(title = "Blocks with Above Average Population Density")