
#----------------------------------------------------------
#   Sub Functions
#----------------------------------------------------------

  RunMD <- function(x) {
    output_file <- paste0("ses_", x[["wbcode"]], ".pdf")

    result <-  tryCatch({
      suppressWarnings(
        rmarkdown::render(
          input = "ses.Rmd",
          #input = "test/test.Rmd",
          output_format = "pdf_document",
          output_file = output_file,
          output_dir = "output/",
          intermediates_dir = "failed_log"
        )
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
  countries <- c("COL", "ETH")
  if (length(countries) > 0) {
    hci <-  hci[hci[["wbcode"]]  %in% countries, ]
  }

  y <- apply(hci, 1, RunMD)

