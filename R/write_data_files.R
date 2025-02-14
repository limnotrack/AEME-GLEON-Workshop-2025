# Used to create the input data for the workshop
library(AEME)
dir.create("data")

aeme_file <- system.file("extdata/lernzmp/LID45819.rds", package = "AEME")
aeme <- readRDS(aeme_file)
write_aeme_to_files(aeme = aeme, path = "data")
