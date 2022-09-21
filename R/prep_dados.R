

library(readr)
library(magrittr)
# recife

# populacao----
pop <- readr::read_rds("../RHA/data/complexidade/complexidade_muni_prep_data/POPULACAO.rds")
pop

# pib----
pib <- readr::read_rds("../RHA/data/complexidade/complexidade_muni_prep_data/pib.rds")
pib <- pib[,.SD,.SDcols = c('code_muni', 'name_muni', 'code_state'
           , 'abbrev_state', 'name_state', 'name_region', 'code_rgi'
           , 'name_rgi', 'code_intermediate', 'name_intermediate'
           , 'mun_sudene', 'mun_pisf', 'mun_bsf', 'mun_bpar'
           , 'regiao_total', 'semi_arido', 'VAB_Adm', 'VAB_Agro'
           , 'VAB_Serv', 'VAB_Ind', 'PIB_Total', 'PIB_capita')]

pib[1]
# IDH ----
idh <- readr::read_rds("../RHA/data/complexidade/complexidade_muni_prep_data/DESV_HUM.rds")

idh[,classe_idhm := NULL]
idh[,classe_ivs := NULL]


# geometria muni ----
geometria <- geobr::read_municipality()
save(geometria,file =  "data/cidades_geometria.RData")


#  geometria rgint ----
geometria <- geobr::read_intermediate_region()
save(geometria,file =  "data/rgint_geometria.RData")


save(idh, pib, pop,file =  "data/cidades.RData")



load("data/cidades.RData")
