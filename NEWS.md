# tidypptsdm 1.0.0

The package is renamed from pptsdm to **tidypptsdm** and rewritten on top
of [tidypptsda](https://tony2015116.github.io/tidypptsda/). None of the
old functions remain; see the article "从 pptsdm 迁移" for the mapping.

## New design

* Data are read with `read_station()` and prepared with `prep_visits()`
  from tidypptsda (both re-exported): the same columns and units for
  NEDAP and FIRE (feed intake in g, body weight in kg, duration in
  seconds), unidentified visits kept with `identified = FALSE`, pigs
  moved to another station resolved. Every function accepts a folder of
  exports, a raw export in R, or the result of either function, and never
  modifies its input.
* `run_monitor()` computes everything once: `monitor_stations()`,
  `monitor_houses()`, `monitor_pigs()`, `monitor_hours()` and the alerts
  of the last day (`station_down`, `unidentified`, `feed_drop`,
  `pig_no_visit`, `pig_low_feed`). Thresholds are arguments
  (`low_feed_kg`, `max_unidentified_pct`, `max_feed_drop_pct`, `iqr_k`).
* The daily tables are long, with one row per unit and day, also for days
  without any visit; `wide_table()` gives the wide view.
* `plot_monitor()` draws one plot per station: `"trend"`, `"intake"`
  (heat map of feed intake per pig and day), `"weight"` and `"hours"`;
  `save_monitor_plots()` saves them.
* `write_monitor_report()` writes an offline HTML report to browse station
  by station, in the style of `tidypptsda::write_report()`. It replaces
  `fid_monitor()` (PDF) and `station_monitor()` (PNG files).
* `write_monitor_tables()` writes an Excel workbook with colour scales, or
  CSV files. It replaces `table_monitor()`.
* `schedule_monitor()` writes the daily script and registers it in the
  Windows Task Scheduler, or prints the crontab line on Linux and macOS.
  It replaces `monitor_schedule()` and `monitor_all()`.
* Messages with cli and `verbose = 0/1/2`, as in tidypptsda.
* Dependencies: cli, data.table, ggplot2 and tidypptsda. cowplot,
  lubridate, patchwork, pptsda, purrr, scales and tidyr are no longer
  needed; openxlsx and taskscheduleR are optional.
* Examples use the `nedap` and `fire` datasets of tidypptsda and run
  everywhere; the package has tests.

## Fixed problems of pptsdm 0.1.4

* The monitoring window had `days + 1` days, and some tables ended the day
  before the others. Now every table covers the same `days` days ending on
  `end_date`.
* Pigs without any visit on a day were missing from the low feed intake
  table; they are now `"no_visit"` and give an alert.
* Durations were divided by 60 in one table and by 3600 in another;
  NEDAP durations are seconds and every column now says its unit
  (`occupation_h`, `occupation_min`).
* The colour scales of the Excel sheets covered one column too many, and
  the `feed_time_n` sheet had none.
* `station_monitor()` gave every PNG the size of the first station, and
  its date axis showed only the month.
* `fid_monitor()` failed with more pigs at a station than colours.
* `hour_stat()`, `fid_monitor()` and `station_monitor()` modified the data
  passed to them.
* `monitor_schedule()` only worked on Windows with a `C:/Temp` folder.

# pptsdm 0.1.4

* Extract the individual functions that make up `table_monitor()` to allow
  for more flexible monitoring.

# pptsdm 0.1.3

* Add `table_monitor()` (first called `other_monitor()`): missing records,
  extreme weights, feeding time per station, feed intake and mean weight
  per pen over the last days, and visits, feeding time and feed intake per
  hour of the last day.

# pptsdm 0.1.2

* `fid_monitor()` and `station_monitor()` rewritten with data.table.
* Add `monitor_schedule()` to run them on a schedule.

# pptsdm 0.1.1

* Added a `NEWS.md` file to track changes to the package.
