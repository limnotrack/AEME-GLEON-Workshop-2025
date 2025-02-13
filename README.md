# Building and Running an Aquatic Ecosystem Model Ensemble in R

--------------------------------------------------------------------------------

:spiral_calendar: February 16, 2025\
:alarm_clock: 08:30 - 12:00 WIB :busts_in_silhouette: Tadhg Moore, Whitney
Woelmer & Deniz Özkundakci\
:computer: [Material](https://github.com/limnotrack/AEME-GLEON-Workshop-2025)
:open_book:
[Presentation](https://docs.google.com/presentation/d/e/2PACX-1vSQR3RyD4lzG2CUp5-2PGvvX_A5UPBLg39Atl4c0u02du8nNxqNrW74GizQt9BDLvSrQk2-rHAIaCM8/pub?start=false&loop=false&delayms=3000)

--------------------------------------------------------------------------------

## Description

This workshop will guide participants through the process of setting up and
running an aquatic ecosystem model ensemble in R, covering data requirements,
handling missing data, and implementing one-dimensional lake models.
Participants will gain hands-on experience with model setup, execution, and
customization for new lakes, using R-based coding.

## Learning Objectives

1.  Define and understand aquatic ecosystem models.

2.  Identify and source inputs for 1D process-based lake models using national
    or global datasets.

3.  Use the AEME R package to set up, run, and analyze aquatic ecosystem model
    ensembles.

4.  Evaluate the benefits of ensemble modeling and large-scale lake modeling.

5.  Develop a plan to configure inputs and parameters for modeling new lake
    systems.

## Pre-requisites

Running the Aquatic Ecosystem Model Ensemble (AEME) requires a Windows
environment. Participants should have the following software installed on their
computers:

1.  Install [R](https://cran.r-project.org/) and [RStudio
    Desktop](https://posit.co/downloads/) on your computer.

2.  Install the AEME package by running the following code in RStudio:

``` r
install.packages("remotes")
remotes::install_github("limnotrack/AEME")
remotes::install_github("limnotrack/aemetools")
```

## Workshop Outline

|  |  |
|----|----|
| **Time** | **Activity** |
| 08:30 | Welcome & setup |
| 08:45 | Icebreaker activity |
| 09:00 | Introduction to Aquatic Ecosystem Modelling |
| 09:30 | Overview of Lake Ecosystem Research New Zealand (LERNZ) Modelling Platform |
| 10:00 | Break - (Install R packages!) |
| 10:30 | Recap of Platform & Introduction to R Activity |
| 10:45 | R Activity - Setting up and running of AEME in R |
| 11:30 | Using AEME in your lake |

## Useful Links

-   [AEME](https://limnotrack.github.io/AEME/)
-   [aemetools](https://github.com/limnotrack/aemetools)
-   [bathytools](https://github.com/limnotrack/bathytools)
-   [LERNZmp](https://limnotrack.shinyapps.io/LERNZmp/)
-   [LERNZ](https://www.waikato.ac.nz/research/institutes-centres-entities/entities/lake-ecosystem-research-new-zealand-lernz/)
