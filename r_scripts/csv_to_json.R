library(tidyverse)
library(jsonlite)

# change filenames in paths as needed
results <- read_csv("csv_results/GB_results.csv")
json <- toJSON(gb_results)
write(json, "csv_results/GB_results.json")