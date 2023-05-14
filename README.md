
# pptsdm

<!-- badges: start -->
<!-- badges: end -->

**pptsdm** is an R package that enables automatic monitor the stations and pigs in the pig farm which using nedap pig performance test stations.`station_monitor()` can monitor the number of pigs within a testing station, total feed intake, total visit time, total visit frequency, and overall weight condition. `fid_monitor()` can monitor the feed intake and proportion of each pig within a single testing station.`monitor_schedule()` packages the previous two functions into one that can be set to monitor on a regular basis.

# Installation
You can install the development version from GitHub with:
``` r
# install.packages("devtools")
devtools::install_github("tony2015116/pptsdm")

```
