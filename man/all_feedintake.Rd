% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_feedintake.R
\name{all_feedintake}
\alias{all_feedintake}
\title{Calculate Total Feed Intake Per Location}
\usage{
all_feedintake(data, days, ref_date = Sys.Date())
}
\arguments{
\item{data}{A data table that must include at least 'location', 'date', 'visit_time',
and 'feed_intake' columns. 'visit_time' should be convertible to date and time.}

\item{days}{An integer specifying the number of days to include in the analysis up to and including
the reference date.}

\item{ref_date}{A Date object used as the reference date for filtering data; defaults to the current
system date.}
}
\value{
Returns a data table in wide format with locations as rows and formatted dates as columns.
Each entry is the summed feed intake for that date and location, converted to kilograms.
An additional 'all_feedintake' column is included, showing the total feed intake for each
location across all dates.
}
\description{
This function aggregates total feed intake across a specified date range for each location.
The feed intake data is first summed per location and date, then transformed to kilograms
and formatted to wide format with locations as rows and dates as columns.
}
\note{
This function expects that the input data is pre-cleaned and correctly formatted.
Errors may occur if 'visit_time' cannot be properly converted.
}
\examples{
# Load CSV data
data <- data.table::fread("C:/Users/Dell/Documents/projects/pptsdm_data/ppt_monitor_test_data.csv")
print(all_feedintake(data = data, days = 5))
}
