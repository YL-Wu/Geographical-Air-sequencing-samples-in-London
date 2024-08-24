# Setup -----------------------------------------------------------------------------------------
rm(list = ls())
invisible(gc())
options(stringsAsFactors = F)

# Load libraries --------------------------------------------------------------------------------
library(readr)
library(dplyr)

# load file ---------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Rscript script.R <path_to_folder> <output_file_name>")
}
folder_path <- args[1]
output_file_name <- args[2]

files1 <- list.files(folder_path, full.names = TRUE, pattern = "\\_nt_lcaparse_perread.txt$")

col_types1 <- cols(
  .default = col_skip(),
  Read = col_character(),
  taxid = col_double(),
  taxname = col_character(),
  taxlevel = col_character(),
  identity_max = col_character(),
  identity_mean = col_character()
)
column_names1 <- c("Read", "taxid", "taxname", "taxlevel", "identity_max", "identity_mean")

taxo_list1 <- lapply(files1, function(file) {
  read_delim(file, delim = "\t", col_names = column_names1, col_types = col_types1, skip = 0) %>%
    mutate(filename = sub("_megablast_nt_lcaparse_perread.txt$", "", basename(file)))
})
taxo1 <- bind_rows(taxo_list1)

write.table(taxo1, file = paste0(output_file_name, "_full.txt"), row.names = FALSE, quote = FALSE, sep = "\t")

write.table(taxo1[, c("Read", "taxid")], file = paste0(output_file_name, "_short.txt"), row.names = FALSE, col.names = FALSE, sep = "\t", quote = FALSE)

