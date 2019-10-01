#----------------------------------------------------------
#   Sub Functions
#----------------------------------------------------------

RunMD <- function(x, ver = "s") {

  if (!(ver  %in% c("s", "b"))) {
    stop("You must select either `version` = 's' or 'b'")
  }

  if (ver == "s") {
    prefix <- "ses_"
    input <-  "ses.Rmd"
    output_dir <- "output/"
  } else {
    prefix <- "ses_book_"
    input <-  "ses_book.Rmd"
    output_dir <- "book/"
  }


  file_name <- paste0(prefix, x[["wbcode"]])

  result <-  tryCatch({
    rmarkdown::render(
      input = input,
      output_format = "pdf_document",
      output_file = paste0(file_name, ".pdf"),
      intermediates_dir = "failed_log",
      output_dir = output_dir
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

countries <- c("ETH", "COL")
countries <- c("ETH")
countries <- NULL
if (length(countries) > 0) {
  hci <-  hci[hci[["wbcode"]]  %in% countries,]
}

y <- apply(hci, 1, RunMD, ver = "b")


#----------------------------------------------------------
#   Delete and copy files aux files
#----------------------------------------------------------


#--------- copy pdf files and delete them from root

pdf_file <- list.files(pattern = "ses_[A-Z]+\\.pdf$")
pdf_book <- list.files(pattern = "ses_book_[A-Z]+\\.pdf$")

x <- file.copy(from = pdf_file, to = "output", overwrite = TRUE)
y <- file.copy(from = pdf_book, to = "book", overwrite = TRUE)

pdf_file <- pdf_file[x]
pdf_book <- pdf_book[y]

file.remove(pdf_file)
file.remove(pdf_book)

#--------- copy failed log files

aux_log <- list.files(pattern = "\\.log$")
file.copy(from = aux_log, to = "failed_log", overwrite = TRUE)

#--------- remove aux files

aux_files <- list.files(pattern = "\\.(log|aux|out)$")
file.remove(aux_files)

