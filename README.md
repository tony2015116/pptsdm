# pptsdm <a href='https://tony2015116.github.io/pptsdm/'><img src='man/figures/logo.svg'  width="120" align="right" />
<!--apple-touch-icon-120x120.png-->
<!-- <picture><source srcset="reference/figures/apple-touch-icon-120x120.png" media="(prefers-color-scheme: dark)"></picture> -->

<!-- badges: start -->
[![GitHub R package version](https://img.shields.io/github/r-package/v/tony2015116/pptsdm)](#)
[![GitHub last commit](https://img.shields.io/github/last-commit/tony2015116/pptsdm)](#)
<!-- badges: end -->

**pptsdm** is an R package that enables automatic monitor the stations and pigs in the pig farm which using nedap pig performance test stations.`station_monitor()` can monitor the number of pigs within a testing station, total feed intake, total visit time, total visit frequency, and overall weight condition. `fid_monitor()` can monitor the feed intake and proportion of each pig within a single testing station.`monitor_schedule()` packages the previous two functions into one that can be set to monitor on a regular basis.

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
# Install packages
install.packages("pak")
pak::pak("tony2015116/pptsdd")

# Require packages
library(pptsdd)

# Load CSV data
csv_files <- list.files("path/to/csv/data", full.names = T, pattern = ".csv", recursive = T)
csv_data <- pptsda::import_csv(csv_files, package = "data.table")

# Feed intake monitor
fid_monitor(data = csv_data, station_type = "nedap", save_path = "C:/Users/Dell/Downloads/test")

# Station monitor
station_monitor(data = csv_data, station_type = "nedap", save_path = "C:/Users/Dell/Downloads/test")

# Monitor station and data
res <- other_monitor(data = data, house_width = "1", save_path = "C:/Users/Dell/Downloads/test")
## Monitor the number of times 'na' appears in the last 7 days
res$responder_na
## Monitor the percentage of extreme weight records in the last 7 days
res$extreme_weight
## Monitor the visiting time and frequency of pigs in the last 7 days
res$feed_time_n
## Monitor the total feed intake over the last 7 days
res$all_feedintake
## Monitor the average feed intake over the last 7 days
res$mean_feedintake
## Monitor the average weight per pen over the last 7 days
res$house_weight

# Set monitor task
monitor_schedule(
  taskname = "ppt_csv_monitor",
  schedule = "DAILY",
  starttime = "10:05",
  startdate = format(Sys.Date(), "%Y/%m/%d"),
  rscript_args = list(house_width = "1", 
                      begin_date = "2024-04-01", 
                      csv_path = "path/to/csv/data",
                      save_path = "C:/Users/Dell/Downloads/test"))
# Delete monitor task
taskscheduleR::taskscheduler_delete("ppt_csv_monitor")
```
