
# limpa arquivos
rm(list=ls())
# limpa memoria
gc(reset= TRUE)

# cria pasta
dir.create("inst/cidades/")

# meus municipios
codigos <- c(2300150, 2300309, 2300408, 2300606, 2300754)

i = 2300150
for(i in codigos){
  message(i)
  # copia arquivo
  file.copy(from = "inst/relatorio_joao.html"
            ,to = sprintf("inst/cidades/%s.html",i))
  
  # ajusta caminho
  arquivo_input <- normalizePath(path = sprintf("inst/cidades/%s.html",i))
  
  # aplica funcao
  rmarkdown::render(
    input = "inst/relatorio_joao.Rmd"
    , output_file = arquivo_input
    , params = list(my_code = i)
    ,quiet = TRUE
  )
}
