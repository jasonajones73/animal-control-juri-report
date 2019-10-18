## Purpose: Data pre-processing for Animal Services jurisdictional reporting
## Author: Jason Jones
## Date Created: 2019-10-17


# Load necessary packages
library(tidyverse)
library(lubridate) 
library(sf)
library(extrafont)
library(tigris)
library(ggmap)

# Data read
## Step 1: read csv file
## Step 2: filter for only ACO calls
## Step 3: fill in blanks with Guilford County as the jurisdiction
## Step 4: create a common calltime for grouping
## Step 5: Get rid of leading "Z" character in nature codes
## Step 6: Get rid of all capital letters in nature codes

call_data <- read_csv(here::here("data/callsWithJurisdictions.csv")) %>%
  filter(agency == "ACO") %>%
  mutate(jurisdiction = case_when(is.na(jurisdiction) == TRUE ~ "Guilford County",
                                  is.na(jurisdiction) != TRUE ~ jurisdiction)) %>%
  mutate(common_calltime = floor_date(calltime, unit = "1 month")) %>%
  mutate(nature = str_replace(nature, "Z", "")) %>%
  mutate(nature = str_to_title(nature))


# Create simple feature object
call_dat_sf <- call_data %>%
  filter(long > -81) %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326)

# Create Guilford County boundary object
guil_bound <- counties(state = 37, year = 2017) %>%
  st_as_sf() %>%
  st_transform(crs = 4326) %>%
  filter(NAME == "Guilford")

# Create a places object and filter for Guilford County intersection
guil_places <- places(state = 37, year = 2017) %>%
  st_as_sf() %>%
  st_transform(crs = 4326) %>%
  st_intersection(guil_bound)

