# pptsdm <a href='https://tony2015116.github.io/pptsdm/'><img src='man/figures/logo.svg'  width="120" align="right" />
<!--apple-touch-icon-120x120.png-->
<!-- <picture><source srcset="reference/figures/apple-touch-icon-120x120.png" media="(prefers-color-scheme: dark)"></picture> -->

<!-- badges: start -->
[![GitHub R package version](https://img.shields.io/github/r-package/v/tony2015116/pptsdm)](#)
[![GitHub last commit](https://img.shields.io/github/last-commit/tony2015116/pptsdm)](#)
<!-- badges: end -->

**pptsdm** is an R package that enables automatic monitor the stations and pigs in the pig farm which using nedap pig performance test stations.`station_monitor()` can monitor the number of pigs within a testing station, total feed intake, total visit time, total visit frequency, and overall weight condition. `fid_monitor()` can monitor the feed intake and proportion of each pig within a single testing station.`table_monitor()` can monitor several informations in table fromat.`monitor_schedule()` packages the previous two functions into one that can be set to monitor on a regular basis.

# Installation
You can install the development version from GitHub with:
``` r
# install.packages("devtools")
devtools::install_github("tony2015116/pptsdm")
# install.packages("pak")
pak::pak("tony2015116/pptsdm")
```
## Example

This is a basic example which shows you how to download pig performance test CSVs data:

``` r
# Require packages
library(pptsdm)

# Load CSV data
csv_files <- list.files("path/to/csv/data", full.names = T, pattern = ".csv", recursive = T)
csv_data <- pptsda::import_csv(csv_files, package = "data.table")

# Feed intake monitor
fid_monitor(data = csv_data, station_type = "nedap", save_path = "C:/Users/Dell/Downloads/test")

# Station monitor
station_monitor(data = csv_data, station_type = "nedap", save_path = "C:/Users/Dell/Downloads/test")

# Monitor station and data in Excel
res <- table_monitor(data = csv_data, days = n, save_path = "C:/Users/Dell/Downloads/test")
# Monitor the number of times 'na' appears in the last n days
head(res$responder_na)
# Monitor the percentage of extreme weight records in the last n days
head(res$extreme_weight)
# Monitor the visiting time and frequency of pigs in the last n days
head(res$feed_time_n)
# Monitor the low feedintake over the last n days
head(res$low_feedintake)
# Monitor the total feed intake over the last n days
head(res$all_feedintake)
# Monitor the average feed intake over the last n days
head(res$mean_feedintake)
# Monitor the average weight per pen over the last n days
head(res$house_weight)
# Monitor visit time in each hour over the last 1 day.
head(res$visit_n_hour)
# Monitor feed intake time in each hour over the last 1 day.
head(res$feed_time_hour)
# Monitor feed intake in each hour over the last 1 day.
head(res$feed_intake_hour)

# Monitor all by hands
monitor_all(csv_data, begin_date = "2024-05-01", days = 5, save_path = "C:/Users/Dell/Downloads/test")

# Set a monitor task
monitor_schedule(
  taskname = "ppt_csv_monitor",
  schedule = "DAILY",
  starttime = "10:05",
  startdate = format(Sys.Date(), "%Y/%m/%d"),
  rscript_args = list(house_width = "1", 
                      days = 5,
                      begin_date = "2024-05-01", 
                      csv_path = "C:/Users/Dell/Documents/projects/pptsdm_data",
                      save_path = "C:/Users/Dell/Downloads/test"))
# Delete monitor task
taskscheduleR::taskscheduler_delete("ppt_csv_monitor")

# Use hour_stat()
data <- data_csv[, date := as.Date(visit_time)]

# Use nest_dt() in tidyfst
res <- data.table::copy(data) |>
  nest_dt(date, .name = "data") |>
  mutate_dt(data = map2(date, data, \(x, y) hour_stat(data = y, target_date = x))) |>
  mutate_dt(data = map(data, \(x) x$feed_intake)) |>
  unnest_dt("data")
  
# Use functions in tidyverse
## functions about hour_stat()
my_function <- function(x) {
  x <- data.table::as.data.table(x)
  date = unique(x$date)
  res <- hour_stat(data = x, target_date = date)
  res$feed_intake
}
## Use group_split() in tidyverse
data_split <- data |>
  as.data.frame() |>
  group_split(date)

names(data_split) <- data_split |>
  map(.f = ~pull(.x, date)) |>
  map(.f = ~as.character(.x)) |>
  map(.f = ~unique(.x)) 

res <- data_split |>
  map(., \(x) my_function(x)) |>
  map(as.data.frame) |>
  bind_rows(.id = "date")

## Use group_nest() in tidyverse
res <- data |>
  as.data.frame() |>
  group_nest(date, keep = T) |>
  mutate(data = map(data, \(x) my_function(x))) |>
  unnest(data)
```
