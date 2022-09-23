# load-----
rm(list=ls())
gc(reset = TRUE)
library(readr)
library(magrittr)
library(data.table)
# recife

RData_files <- list.files(path = "."
                          ,pattern = ".RData"
                          ,recursive = TRUE
                          ,full.names = TRUE)
RData_files
unlink(RData_files)
# populacao----
munis_list <- readr::read_rds("../RHA/data/munis_list.rds")

pop <- munis_list$pop_censo_br[,.SD,.SDcols = c('municipio_codigo'
                                                ,'municipio'
                                                ,'code_intermediate'
                                                ,'name_intermediate'
                                                ,'code_imediate'
                                                ,'name_imediate'
                                                ,'ano'
                                                ,'situacao_do_domicilio'
                                                ,'valor')]

pop[is.na(valor), valor := 0]
pop[situacao_do_domicilio != "Total"
    ,proporcao := round(100 * valor / sum(valor),2)
    ,by = .(municipio_codigo,ano)]
pop[situacao_do_domicilio == "Total",proporcao := 100]


setnames(pop,"municipio_codigo","code_muni")

munis_list$municipality$code_muni <- as.character(munis_list$municipality$code_muni)
pop <- pop[munis_list$municipality[,.SD,.SDcols = c("code_muni","code_state", "abbrev_state")] 
           ,on = "code_muni"]

popCols <- c("situacao_do_domicilio",   "valor", "proporcao")
muniCols <- names(pop)[!(names(pop) %in% popCols)]

muniCols

pop <- pop[,.SD,.SDcols = c(muniCols,popCols)]
pop <- pop[situacao_do_domicilio != "Total"]
pop[,code_muni := as.integer(code_muni)]

rm(muniCols)
rm(popCols)
rm(munis_list)

# pib----
pib <- readr::read_rds("../RHA/data/complexidade/complexidade_muni_prep_data/pib.rds")
pib <- pib[,.SD,.SDcols = c('code_muni', 'name_muni', 'code_state'
                            , 'abbrev_state', 'name_state', 'name_region', 'code_rgi'
                            , 'name_rgi', 'code_intermediate', 'name_intermediate'
                            , 'mun_sudene', 'mun_pisf', 'mun_bsf', 'mun_bpar'
                            , 'regiao_total', 'semi_arido', 'VAB_Adm', 'VAB_Agro'
                            , 'VAB_Serv', 'VAB_Ind', 'PIB_Total', 'PIB_capita')]

pib[,code_muni := as.integer(code_muni)]
pib[1]

# IDH ----
idh <- readr::read_rds("../RHA/data/complexidade/complexidade_muni_prep_data/DESV_HUM.rds")

idh[,":="(
  classe_idhm = NULL
  ,renda_per_capita = NULL
  ,pndr_renda = NULL            
  ,pndr_dinamismo = NULL
  ,ivs = NULL
  ,ivs_infraestrutura_urbana = NULL
  ,ivs_capital_humano  = NULL
  ,ivs_renda_e_trabalho = NULL
  ,classe_ivs = NULL
)]


idh[,code_muni := as.integer(code_muni)]

idh[1]

idh <- setDF(idh)
pib <- setDF(pib)
pop <- setDF(pop)
class(idh)
class(pib)
class(pop)



# geometria muni ----
geom_muni <- geobr::read_municipality()



#  geometria rgint ----
geom_rgint <- geobr::read_intermediate_region()



# pib historico----
pibh <- readr::read_rds("../RHA/data/pib_total.rds")
pibh <- pibh[variavel == "Produto Interno Bruto a preços correntes",]
pibh <- pibh[,.SD,.SDcols = c("municipio_codigo","ano","valor")]

setnames(pibh,"municipio_codigo","code_muni")
setnames(pibh,"valor","pib")

df_geral <- readr::read_rds("../RHA/data/df_geral_muni.rds")

pib_historico <- df_geral[pibh, on = c("code_muni")]

pib_historico[,code_muni := as.integer(code_muni)]
pib_historico[,ano := as.integer(ano)]

rm(pibh)
rm(df_geral)
pib_historico <- setDF(pib_historico)


# FILTRO REGIAO-----
nordeste_state <- pib[pib$name_region == "Nordeste","abbrev_state"]
nordeste_state <- unique(nordeste_state)


pib_historico <- pib_historico[pib_historico$abbrev_state %in% nordeste_state,]
idh <- idh[idh$abbrev_state %in% nordeste_state,]
pib <- pib[pib$abbrev_state %in% nordeste_state,]
pop <- pop[pop$abbrev_state %in% nordeste_state,]
geom_rgint <- geom_rgint[geom_rgint$abbrev_state %in% nordeste_state,]
geom_muni <- geom_muni[geom_muni$abbrev_state %in% nordeste_state,]

# mapa IDH - Maranhao----

geom_det <- geobr::read_municipality(simplified = FALSE)
geom_ma <- geom_det[geom_det$abbrev_state == "MA",]

geom_ma <- merge(x = geom_ma
                         ,y = idh[,c("code_muni","idhm")]
                         ,by = "code_muni")
geom_ma$idhm <- as.numeric(geom_ma$idhm)

save(geom_ma,file =  "data/idh_maranhao.RData")
# save----

save(pib_historico,file =  "data/pib_historico.RData")
save(idh,pib ,pop ,file =  "data/cidades.RData")
save(geom_rgint,file =  "data/rgint_geometria.RData")
save(geom_muni,file =  "data/cidades_geometria.RData")

# TESTE-----
break()
rm(list=ls())
load("data/pib_historico.RData")
class(pib_historico)
load("data/cidades_geometria.RData")
load("data/cidades.RData")
class(pib)
class(pop)
class(idh)
load("data/rgint_geometria.RData")
rm(list=ls())
