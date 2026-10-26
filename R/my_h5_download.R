#Função p/ extração OCO-2
## Função p/ download dos arquivos OCO-2 (.h5)
my_h5_download <- function(url_unique,
                           user     = "input your user",
                           password = "input your password",
                           pasta    = "data-raw/OCO-2_h5/",
                           max_tentativas = 5){
  if(!is.character(user) | !is.character(password)){
    stop("user e password devem ser texto (string).")
  }

  dir.create("data-raw/oco2_test", recursive = TRUE, showWarnings = FALSE)
  filename_h5 <- basename(url_unique)
  destino     <- file.path("data-raw/oco2_test", filename_h5)

  ## Pula arquivos que já foram baixados.
  if(file.exists(destino) && file.size(destino) > 0) return(invisible(destino))

  for(i in seq_len(max_tentativas)){
    dw <- try(download.file(url_unique, destino,
                            method = "wget", mode = "wb",
                            extra  = paste0("--user=", user,
                                            " --password=", password,
                                            " --auth-no-challenge=on",
                                            " --keep-session-cookies")),
              silent = TRUE)
    if(!inherits(dw, "try-error") && dw == 0) return(invisible(destino))
    message("Falha (tentativa ", i, ") em: ", filename_h5)
    Sys.sleep(2)
  }
  warning("Não foi possível baixar: ", filename_h5)
}

## Lista de URLs, mantendo só os arquivos .h5.
url_filename <- list.files("url/", pattern = "\\.txt$", full.names = TRUE)

urls <- read.table(url_filename) |>
  dplyr::filter(stringr::str_detect(V1, "\\.h5$"))
n_urls <- nrow(urls)

## Download em paralelo.
future::plan(future::multisession, workers = 4)

tictoc::tic()
furrr::future_pmap(list(urls$V1, "witoria.araujo", "Wictoria1234."), my_h5_download)
tictoc::toc()

future::plan(future::sequential)
