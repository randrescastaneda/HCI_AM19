#----------------------------------------------------------
#   Libraries
#----------------------------------------------------------
pkg <-
  c(
    "tidyverse",
    "readr",
    "haven"
  )
new.pkg <-
  pkg[!(pkg %in% installed.packages()[, "Package"])] # check installed packages
load.pkg <-
  pkg[!(pkg %in% loadedNamespaces())]              # check loaded packages

if (length(new.pkg)) {
  install.packages(new.pkg)     # Install missing packages
}

if (length(load.pkg)) {
  inst = lapply(load.pkg, library, character.only = TRUE) # load all packages
}

#----------------------------------------------------------
#   Sub Functions
#----------------------------------------------------------


RunMDok <- function(handout_name, countrOK, r, countrycode, ok ) {
  if (ok == 1) {
    rmarkdown::render(input = "ses.Rmd",
                      output_format = "pdf_document",
                      output_file = handout_name,
                      output_dir = "output/")
  }
  countrOK[ r, 1] <- as.character(countrycode)
  countrOK[ r, 2] <- ok
  return(countrOK)
}

RunMD <- function(x) {

  output_file <- paste0("ses_", x[["wbcode"]], ".pdf")
  rmarkdown::render(
    #input = "ses.Rmd",
    input = "test/test.Rmd",
    output_format = "pdf_document",
    output_file = output_file,
    output_dir = "test/"
  )

}

#----------------------------------------------------------
#   Initional parameters
#----------------------------------------------------------

hci <- haven::read_dta("input/hci_ses.dta")

countries <- c("COL", "ALB")
if (length(countries) > 0) {
  hci <-  hci %>%
    filter(wbcode %in%  countries)
}

apply(hci, 1, RunMD)










#----------------------------------------------------------
#   TEsting file
#----------------------------------------------------------



hci_names <- names(hci)

give_names <- function(x) {
  if (is.numeric(x) & !is.na(x)) {
    y <- round(x, digits = 2)
  } else if (is.na(x)) {
    y <- character(0)
  } else {
    y <- x
  }
  assign(x, y)
}

walk(hci_names, give_names)


for (x in hcic_names) {
  if (is.numeric(hcicfilt[[x]]) & !is.na(hcicfilt[[x]])) {
    y <- round(hcicfilt[x], digits = 2)
  } else if (is.na(hcicfilt[[x]])) {
    y <- character(0)
  } else {
    y <- hcicfilt[[x]]
  }
  assign(x, y)
}


rmarkdown::render(input = "test/test.Rmd",
                  output_format = "pdf_document",
                  output_file = "test",
                  output_dir = "test")






