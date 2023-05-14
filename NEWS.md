# pptsdm 0.1.1

* added a `NEWS.md` file to track changes to the package.

# pptsdm 0.1.2

* `fid_monitor()` and `station_monitor()` in the [`pptos`](https://github.com/tony2015116/pptos) package have been reconstructed. Data processing has been optimized by utilizing data.table as much as possible, reducing unnecessary R packages, and improving the speed of function execution.
* added a new function `monitor_schedule()` to schedule the execution of `fid_monitor()` and `station_monitor()` functions, enabling timed monitoring of the data from nedap pig performance test stations.
