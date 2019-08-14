
aux_files <- data.frame(x = list.files(pattern = "\\.(log|aux|out)"))

move_files <- function(x) {
  if (grepl("log$", x)) {
    file.copy(x, "failed_log")
  }

}

apply(aux_files, 1, move_files)

c <- sapply(aux_files, move_files)


if (grep("log$", x)) {
  print(x)
}


x <- apply(as.data.frame(aux_files), 2, move_files)
x
