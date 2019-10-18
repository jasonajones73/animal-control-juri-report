## Purpose: Data pre-processing for Animal Services jurisdictional reporting
## Author: Jason Jones
## Date Created: 2019-10-17


# Load necessary packages
library(tidyverse)
library(lubridate)
library(sf)
library(extrafont)
#library(tigris) # Necessary for initially creating spatial objects

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
# guil_bound <- counties(state = 37, year = 2017) %>%
#   st_as_sf() %>%
#   st_transform(crs = 4326) %>%
#   filter(NAME == "Guilford")
#write_rds(guil_bound, "data/guil_bound.rds")

guil_bound <- read_rds("data/guil_bound.rds")

# Create a places object and filter for Guilford County intersection
# guil_places <- places(state = 37, year = 2017) %>%
#   st_as_sf() %>%
#   st_transform(crs = 4326)
# 
# make_filt <- guil_places %>%
#   st_intersection(guil_bound) %>%
#   pull(NAME)
# 
# guil_places <- guil_places %>%
#   filter(NAME %in% make_filt)
# 
# write_rds(guil_places, "data/guil_places.rds")

guil_places <- read_rds("data/guil_places.rds")

# Make an object for adding labels to maps
# places_labels <- guil_places %>%
#   st_centroid() %>%
#   st_coordinates() %>%
#   data.frame() %>%
#   mutate(NAME = guil_places$NAME) %>%
#   rename(long = X, lat = Y)
# 
# write_rds(places_labels, "data/places_labels.rds")

places_labels <- read_rds("data/places_labels.rds")

  
