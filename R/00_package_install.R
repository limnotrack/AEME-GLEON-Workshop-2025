# Install the required packages from CRAN
install.packages("remotes")
install.packages("osmdata")
install.packages("tmap") # v4 is required

# Install the required packages from GitHub
remotes::install_github("limnotrack/AEME")
remotes::install_github("limnotrack/aemetools")

# Run check on AEME package
library(AEME)
check <- check_AEME()

if (check) {
  message("AEME package is installed correctly.")
} else {
  message("AEME package is not installed correctly.")
}
