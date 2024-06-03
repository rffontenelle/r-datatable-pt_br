#!/usr/bin/env Rscript

if (!("potools" %in% installed.packages())) install.packages("potools")
library(potools)

base <- "../data.table"
stopifnot(dir.exists(base))
nomes <- list.files(file.path(base, c("R", "src")), 
                    pattern = ".*\\.R$|.*\\.c$") |> 
         sub(pattern = "(.*)\\.(R|c)", 
             replacement = "\\1") |>
         unique() |>
         sort()

for (nome in nomes) {

  # Neste caso o po_extract() trava porque não tem mensagem alguma
  if (nome == "negate") next
  
  for (dir in file.path(nome, c("", "R", "src"))) { 
    if (!dir.exists(dir)) dir.create(dir)
  }
  
  original_R <- sprintf("%s/R/%s.R", base, nome)
  copia_R <- sprintf("%s/R/%s.R", nome, nome)
  if (file.exists(original_R)) {
    file.copy(original_R, copia_R, copy.date = TRUE)
  }
  
  original_C <- sprintf("%s/src/%s.c", base, nome)
  copia_C <- sprintf("%s/src/%s.c", nome, nome)
  if (file.exists(original_C)) {
    file.copy(original_C, copia_C, copy.date = TRUE)
  }
  
  writeLines(text = c(sprintf("Package: %s", nome), "Version: 0.0"),
             con = file.path(nome, "DESCRIPTION"))
  funcoes <- c('catf:fmt|1', 'stopf:fmt|1', 'warningf:fmt|1', 
               'messagef:fmt|1', 'packageStartupMessagef:fmt|1')
  po_extract(dir = nome, style = "explicit",
             custom_translation_functions = list(R = funcoes, src = NULL))

}

if (!dir.exists("po")) dir.create("po")
arquivos_po <- list.dirs(recursive = TRUE) |>
                 grep(pattern = "^\\./[^/]+/po$", value = TRUE) |>
                 list.files(pattern = "\\.pot$", full.names = TRUE)
file.copy(arquivos_po, file.path("po", basename(arquivos_po)))
unlink(nomes, recursive = TRUE)

