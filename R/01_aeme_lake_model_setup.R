# Load the libraries ----
library(AEME)
library(dplyr)
library(ggplot2)
library(sf)
library(tmap)
tmap_mode("view")

#' Define the location of Lake Wainamu data
lake_dir <- "data/LID45819_wainamu/"

#' Let's list the files in the directory 
files <- list.files(lake_dir, full.names = TRUE)
files
#> [1] "data/LID45819_wainamu/inflows_factors.csv"    "data/LID45819_wainamu/inflows_lumped.csv"
#> ...
#' We can see that all the files are .csv files. These files can be read into R
#' using the `read.csv()` function or you can view the files in a text editor 
#' or spreadsheet program like Excel.

# Constructing the AEME object ----
## Lake ----
# Load the lake data
lake_data <- read.csv("data/LID45819_wainamu/lake.csv")
lake_data

#' For inputting into the AEME model we need to convert the data into a list.
lake <- as.list(lake_data)
lake

#' Let's view where Lake Wainamu is located on a map.
#' First convert to a spatial feature with the sf package
coords <- data.frame(lat = lake$latitude, lon = lake$longitude) |> 
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

#' Them plot the location on a map with tmap
tm_shape(coords) +
  tm_dots(fill = "red", size = 2)


## Time ----
# Load the time data
time_data <- read.csv("data/LID45819_wainamu/time.csv")
time_data

#' Here we have a start and stop time for the model. We also have a time step
#' which is the time interval between each model time step. We also have a 
#' spin-up time which is the time before the start time that the model will
#' run for. This is useful for allowing the model to reach a steady state
#' before the start time.

time <- list(
  start = as.POSIXct(time_data$start, tz = "UTC"),
  stop = as.POSIXct(time_data$stop, tz = "UTC"),
  time_step = time_data$time_step,
  spin_up = list(
    dy_cd = 3 * 365, # 3 years spin up
    glm_aed = 3 * 365, # 3 years spin up
    gotm_wet = 3 * 365 # 3 years spin up
  )
)
time

## Input ----
#' Next we will load in our input data for the model. This includes the 
#' hypsograph, meteorological data, initial depth, and initial profile. We will 
#' start with the hypsograph data.

hypsograph <- read.csv("data/LID45819_wainamu/input_hypsograph.csv")
hypsograph

#' Plot the hypsograph
ggplot(hypsograph, aes(x = area, y = depth)) +
  geom_line() +
  geom_hline(yintercept = 0) +
  labs(y = "Depth (m)", x = "Area (m^2)") +
  theme_bw(16)

#' Notice how the hypsograph extends above the lake surface (depth > 0), this is
#' crucial to ensure that the model can simulate lake level fluctuations.

#' Next we will load in the meteorological data.
met <- read.csv("data/LID45819_wainamu/input_meteo.csv") 
met$Date <- as.Date(met$Date) # Convert the Date column to a Date object
summary(met)

#' For information on the meteorological data columns see the AEME documentation
#' here: https://limnotrack.github.io/AEME/articles/aeme-inputs.html#meteorological-data

#' Load in light extinction data
Kw <- read.csv("data/LID45819_wainamu/input_Kw.csv")
Kw 

#' Load in the initial profile data
init_profile <- read.csv("data/LID45819_wainamu/input_init_profile.csv")
init_profile

#' Load in the initial depth data
init_depth <- read.csv("data/LID45819_wainamu/input_init_depth.csv")
init_depth

#' Define input list
input = list(
  init_depth = init_depth$init_depth,
  init_profile = init_profile,
  hypsograph = hypsograph,
  meteo = met,
  use_lw = TRUE,
  Kw = Kw$Kw
)


#' Construct AEME object ----
aeme <- aeme_constructor(lake = lake, 
                         time = time,
                         input = input)
aeme

#' Model controls
model_controls <- get_model_controls(use_bgc = FALSE)
View(model_controls) # View the model controls

#' Select models
model <- get_models()
model

#' For this workshop we will only use the General Lake Model (GLM) and the 
#' General Ocean Turbulence Model (GOTM) for the water column. 
model <- c("glm_aed", "gotm_wet")

#' Path for model directory
#' This is the directory where the model configuration files will be saved
#' and where the model output will be stored.
path <- "aeme"
dir.create(path)

# Build the AEME model ensemble ----
aeme
aeme <- build_aeme(aeme = aeme, model = model, model_controls = model_controls,
                   path = path, wb_method = 1)
aeme
#' Notice that in the 'Configuration' section it now says 'Present' under the 
#' Physical models. This means that the models have been successfully added to
#' the AEME object.

list.files(path, recursive = TRUE, full.names = TRUE)
#' The models have been added to the 'aeme' directory. The 'glm_aed' and 
#' 'gotm_wet' directories contain the model configuration files.


#' Run the ensemble ----
aeme <- run_aeme(aeme = aeme, model = model, path = path, parallel = FALSE)
#' The model is now running. This may take some time depending on the number of
#' models and the length of the simulation.
aeme
#' Notice that in the Output section it now has a number 1 beside GLM-AED & 
#' GOTM-WET. This means that the models have run and their output has been 
#' aded to the AEME object.

#' View the output ----
plot_output(aeme = aeme, model = model, var_sim = "HYD_temp")
#' This plot shows the simulated water temperature for the lake. The x-axis is
#' time and the y-axis is depth. The colour represents the temperature in
#' degrees Celsius.
#' Plot the lake level
plot_output(aeme = aeme, model = model, var_sim = "LKE_lvlwtr", facet = FALSE)

# Compare modelled output to observations ----
#' Load the observed data
lake_obs <- read.csv("data/LID45819_wainamu/observations_lake.csv")
lake_obs$Date <- as.Date(lake_obs$Date) # Convert the Date column to a Date object

#' Summary of the observed data
summary(lake_obs)

#' Summary of the data by variable
lake_obs |> 
  group_by(var_aeme) |> 
  summarise(
    min_date = min(Date),
    max_date = max(Date),
    min = min(value),
    mean = mean(value),
    median = median(value),
    max = max(value),
    n = n()
  ) |> 
  print(n = 30)

## Adding to the aeme object ----
#' There are two ways to add the observed data to the AEME object. The first is
#' to add the data to the AEME object directly. The second is to add the data
#' to the AEME object using the `add_obs()` function.

aeme <- add_obs(aeme = aeme, lake = lake_obs)
plot_obs(aeme = aeme, var_sim = "HYD_temp")
pre <- assess_model(aeme = aeme, model = model,
                                  var_sim = "HYD_temp")
pre # Print the model performance to the console

#' Plot the residuals
plot_resid(aeme = aeme, model = model, var_sim = "HYD_temp")

## Inflows ----
#' Load the inflow data
inflow_files <- list.files(lake_dir, pattern = "inflows", full.names = TRUE)
inflow_data <- lapply(inflow_files, function(f){
  df <- read.csv(f)
  df$Date <- as.Date(df$Date)
  df
})

inflow_names <- basename(inflow_files) |> 
  gsub("inflows_", "", x = _) |> 
  gsub(".csv", "", x = _)
inflow_names

names(inflow_data) <- inflow_names
aeme <- add_inflows(aeme = aeme, data = inflow_data)
aeme

## Parameters ----
#' Add parameters to the AEME object which have been calibrated for water level
param_file <- list.files(lake_dir, pattern = "parameters", full.names = TRUE)
param_data <- read.csv(param_file)
param_data

aeme <- add_pars(aeme = aeme, pars = param_data)
aeme

# Re-build the model ensemble with the inflow data & parameters
aeme <- build_aeme(aeme = aeme, model = model, model_controls = model_controls,
                   path = path, wb_method = 2)
aeme <- run_aeme(aeme = aeme, model = model, path = path, parallel = TRUE)

post <- assess_model(aeme = aeme, model = model, var_sim = "HYD_temp")

#' Plot the lake level
plot_output(aeme = aeme, model = model, var_sim = "LKE_lvlwtr", facet = FALSE,
            remove_spin_up = FALSE)

plot_output(aeme = aeme, model = model, var_sim = "HYD_temp")


# Biogeochemical Model ----
#' Oh wow, lake physics... That's so 2010. Let's get with the times and add a
#' biogeochemical model to our ensemble. We will use GLM (General Lake Model) &
#' GOTM (General Ocean Turbulence Model)  with the biogeochemical model switched
#' on.

## Switch on the biogeochemical model ----
#' Get model controls with biogeochmical variables switched on as default
model_controls <- get_model_controls(use_bgc = TRUE)
View(model_controls)

#' Build the model ensemble with the biogeochemical model switched on
aeme <- build_aeme(aeme = aeme, model = model, model_controls = model_controls,
                   path = path, use_bgc = TRUE)
#' Run the ensemble in parallel - this may take some time [~1]
aeme <- run_aeme(aeme = aeme, model = model, path = path)

plot_output(aeme = aeme, model = model, var_sim = "HYD_temp") # Temperature
plot_output(aeme = aeme, model = model, var_sim = "CHM_oxy") # Oxygen
plot_output(aeme = aeme, model = model, var_sim = "PHY_tchla") # Total chla
plot_output(aeme = aeme, model = model, var_sim = "PHS_tp") # Total P
plot_output(aeme = aeme, model = model, var_sim = "NIT_tn") # Total N

## Assess the model performance ----
vars <- c("HYD_temp", "CHM_oxy", "PHY_tchla", "PHS_tp", "NIT_tn")
assessment <- assess_model(aeme = aeme, model = model, var_sim = vars)
assessment
