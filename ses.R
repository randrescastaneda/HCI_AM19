#----------------------------------------------------------
#   Sub Functions
#----------------------------------------------------------

RunMD <- function(x) {
  file_name <- paste0("ses_", x[["wbcode"]])

  result <-  tryCatch({
    rmarkdown::render(
      input = "ses.Rmd",
      #input = "test/test.Rmd",
      output_format = "pdf_document",
      output_file = paste0(file_name, "t_color.pdf"),
      output_dir = "test/",
      intermediates_dir = "failed_log"
    )

    r <- c(x[["wbcode"]], "OK")

  }, warning = function(w) {
    r <- c(x[["wbcode"]], "warning")
    return(r)

  }, error = function(e) {
    r <- c(x[["wbcode"]], "error")
    return(r)
  }, finally = {
    print(paste(x[["wbcode"]], x[['wbcountrynamet']], "- Done.", sep = " "))
  })

  return(result)

}

#----------------------------------------------------------
#   Initional parameters
#----------------------------------------------------------

hci <- haven::read_dta("input/hci_ses.dta")

countries <- NULL
countries <- c("ETH", "COL")
countries <- c("ETH")
if (length(countries) > 0) {
  hci <-  hci[hci[["wbcode"]]  %in% countries,]
}

y <- apply(hci, 1, RunMD)


#----------------------------------------------------------
#   Delete and copy files aux files
#----------------------------------------------------------


#--------- copy pdf files and delete them from root

pdf_file <- list.files(pattern = "ses_.+\\.pdf$")
x <- file.copy(from = pdf_file, to = "output", overwrite = TRUE)

pdf_file <- pdf_file[x]
file.remove(pdf_file)

#--------- copy failed log files

aux_log <- list.files(pattern = "\\.log$")
file.copy(from = aux_log, to = "failed_log", overwrite = TRUE)

#--------- remove aux files

aux_files <- list.files(pattern = "\\.(log|aux|out)$")
file.remove(aux_files)

