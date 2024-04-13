# pptsdm 0.1.1

* added a `NEWS.md` file to track changes to the package.

# pptsdm 0.1.2

* `fid_monitor()` and `station_monitor()` in the [`pptos`](https://github.com/tony2015116/pptos) package have been reconstructed. Data processing has been optimized by utilizing data.table as much as possible, reducing unnecessary R packages, and improving the speed of function execution.
* added a new function `monitor_schedule()` to schedule the execution of `fid_monitor()` and `station_monitor()` functions, enabling timed monitoring of the data from nedap pig performance test stations.

# pptsdm 0.1.3

* add new function `other_monitor()`. This function primarily aims to analyze and monitor, based on the CSV data from the past seven days of measurement stations, the daily counts of missing records, extreme weight recordings, total feeding time at each measurement station, total feeding amount per pen per day, and average weight per pen per day.
