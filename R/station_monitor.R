# WARNING - Generated by {fusen} from dev/station_pig_monitor.Rmd: do not edit by hand

#' Feed intake monitor of pig performance test station
#' 
#' @param data A data frame or data table. This is the data to be processed. It should have specific columns depending on the station type.
#' @param begin_date An optional parameter. If provided, only data from this date onwards will be considered. It can be a Date object or a character string in the form 'yyyy-mm-dd'. Default is NULL, which means all dates in the data will be considered.
#' @param station_type A character string specifying the type of station. This must be either 'nedap' or 'fire'.
#' @param save_path A character string specifying the path where the output PNG files will be saved.
#' 
#' @importFrom data.table ":=" "CJ" ".SD"
#' 
#' @return This function does not return a value. It saves PNG files to the specified path.
#' @export
#' 
#' @examples
#' # Load CSV data
#' data <- data.table::fread("C:/Users/Dell/Documents/projects/pptsdm_data/ppt_monitor_test_data.csv")
#' # Station monitor
#' station_monitor(data = data, station_type = "nedap", save_path = "C:/Users/Dell/Downloads/test")
station_monitor <- function (data, begin_date=NULL, station_type, save_path)
{
  if (missing(data)) stop("Please provide 'data' argument.")
  if (missing(station_type)) stop("Please provide 'station_type' argument.")
  if (missing(save_path)) stop("Please provide 'save_path' argument.")
  # Argument checks
  if (!is.data.frame(data) && !data.table::is.data.table(data)) {
    stop("The 'data' argument must be a data.frame or a data.table.")
  }
  
  if (!is.null(begin_date)) {
    if (!inherits(begin_date, "Date") && !is.character(begin_date)) {
      stop("Error: 'begin_date' argument must be a Date object or character string.")
    }
    
    if (is.character(begin_date)) {
      begin_date <- as.Date(begin_date)
    }
  }
  
  if (!is.character(station_type) || !(station_type %in% c("nedap", "fire"))) {
    stop("The 'station_type' argument must be either 'nedap' or 'fire'.")
  }
  
  if (!is.character(save_path) || !dir.exists(save_path)) {
    stop("The 'save_path' argument must be a valid directory path.")
  }
  visit_time <-
    responder <-
    . <-
    location <-
    animal_number <-
    duration <-
    feed_intake <-
    Entry <-
    Exit <- Consumed <- weight <- ndt <- . <- items <- plot1 <- .N <- V1 <- hour <- plot_name <- NULL
  
  if (!data.table::is.data.table(data)) {
    data <- data.table::setDT(data)
  }
  # Prepare data based on station_type
  prepare_nedap_data <- function(data, begin_date = NULL) {
    temp1 <-
      unique(data)[, `:=`(c("date", "time"),data.table::tstrsplit(visit_time," ", fixed = TRUE))
      ][, `:=`(c("date"), data.table::as.IDate(date))
      ][,!c("visit_time", "time")]
    if (!is.null(begin_date)) {
      temp1 <- temp1[date >= begin_date]
    }
    temp2 <- unique(temp1, by = c("location", "responder", "date"))[!is.na(responder)
    ][, keyby = .(location,date), .(animal_number = .N)]
    temp3 <- temp1[!is.na(animal_number)
    ][, keyby = .(location,date), .(`total_intake_duration(min)` = round(sum(duration) / 60,digits = 4),total_intake = round(sum(feed_intake) / 1000,digits = 4),visit_number = .N)]
    temp5 <- merge(temp2, temp3, all.x = TRUE)
    list(temp5 = temp5, temp1 = temp1)
  }
  
  prepare_fire_data <- function(data, begin_date = NULL) {
    temp1 <- unique(data)[, `:=`(Entry,do.call(paste, c(.SD, sep = " "))), .SDcol = c("Date","Entry")
    ][, `:=`(Exit, do.call(paste, c(.SD, sep = " "))),.SDcol = c("Date", "Exit")
    ][, `:=`(c("Entry", "Exit"),lapply(.SD, lubridate::ymd_hms)), .SDcol = c("Entry","Exit")
    ][, `:=`(duration,data.table::fifelse(Exit -Entry < 0 & lubridate::hour(Exit) == 0,Exit - Entry + lubridate::ddays(1), Exit - Entry))]
    data.table::setnames(temp1,
                         c(1:3, 9),
                         c("location",
                           "responder", "date", "weight"))
    temp1 <- unique(temp1)[, `:=`(date, lubridate::ymd(date))]
    if (!is.null(begin_date)) {
      temp1 <- temp1[date >= begin_date]
    }
    temp2 <- unique(temp1, by = c("location", "responder","date"))[!is.na(responder)
    ][, keyby = .(location, date), .(animal_number = .N)]
    temp3 <- temp1[!is.na(responder)
    ][, `:=`(duration, as.numeric(duration))
    ][,keyby = .(location, date), .(`total_intake_duration(min)` = round(sum(duration) / 60,digits = 4), total_intake = round(sum(Consumed),digits = 4),visit_number = .N)]
    temp5 <- merge(temp2, temp3, all.x = TRUE)
    list(temp5 = temp5, temp1 = temp1)
  }
  
  
  # Prepare data based on station_type
  if (station_type == "nedap") {
    prepared_data_list <- prepare_nedap_data(data, begin_date = begin_date)
    prepared_data <- prepared_data_list$temp5
    temp1 <- prepared_data_list$temp1
  } else if (station_type == "fire") {
    prepared_data_list <- prepare_fire_data(data, begin_date = begin_date)
    prepared_data <- prepared_data_list$temp5
    temp1 <- prepared_data_list$temp1
  } else {
    stop("Invalid station_type. Supported types are 'nedap' and 'fire'.")
  }
  
  # The rest of the code remains the same.
  # 将第3到第6列的类型转换为numeric
  prepared_data[, (3:6) := lapply(.SD, as.numeric), .SDcols = 3:6]
  
  # 使用melt函数
  temp6 = data.table::melt(prepared_data,
                           id.vars = c("location", "date"),
                           measure.vars = 3:6,
                           variable.name = "items",
                           value.name = "values")
  
  temp6_2 <- temp1[!is.na(location), .(location, date, weight)
  ][, list(list(.SD)), by = location # nest by location
  ][, `:=`("V1", purrr::map(.SD[[1]], function(data) {data[data.table::CJ(date = tidyr::full_seq(date, 1)), on = .(date)
  ][data.table::CJ(date = date, unique = TRUE), on = .(date)]})), .SDcols = "V1"
  ][, `:=`("plot1", purrr::map2(.SD[[1]], location, ~ggplot2::ggplot(data = .x, ggplot2::aes(x = date, y = weight, group = date)) +
                                  ggplot2::geom_boxplot(outlier.color = "red") +
                                  ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
                                  cowplot::background_grid(minor = "none") +
                                  ggplot2::scale_x_date(date_breaks = "1 day", date_labels = "%d") +
                                  ggplot2::theme_bw() +
                                  ggplot2::theme(legend.position = "none",
                                                 axis.title.x = ggplot2::element_blank(),
                                                 axis.text.x = ggplot2::element_text(angle = -90),
                                                 axis.text = ggplot2::element_text(size = 8)))), .SDcols = "V1"
  ][ , V1 := NULL
  ][]
  
  temp7 <- temp6[, list(list(.SD)), by = location
  ][, `:=`("V1", purrr::map(.SD[[1]], function(data) {data[CJ(date = tidyr::full_seq(date, 1)), on = .(date)
  ][CJ(date = date, items = items, unique = TRUE), on = .(date, items)
  ][!is.na(items)
  ][,`:=`(items, factor(items, labels = c("N", "visit_time/min","feed_intake/kg", "visit_number")))]})), .SDcols = "V1"
  ][, `:=`("plot2", purrr::map2(.SD[[1]], location,~ggplot2::ggplot(data = .x, ggplot2::aes(x = date, y = values)) +
                                  ggplot2::geom_point(ggplot2::aes(col = items)) +
                                  ggplot2::geom_line(ggplot2::aes(col = items)) +
                                  ggplot2::theme_bw() +
                                  ggplot2::facet_grid(items ~ ., scales = "free") +
                                  ggplot2::scale_x_date(date_breaks = "1 day", date_labels = "%m") +
                                  ggplot2::scale_colour_brewer(palette = "Set1") +
                                  ggplot2::theme(strip.text.y = ggplot2::element_text(angle = 0,hjust = 0),
                                                 legend.position = "none",
                                                 axis.title = ggplot2::element_blank(),
                                                 axis.text.x = ggplot2::element_text(angle = -90),
                                                 axis.text = ggplot2::element_text(size = 8),
                                                 strip.placement = "outside",
                                                 strip.background = ggplot2::element_rect(colour = "white", fill = "white")) +
                                  ggplot2::ggtitle(paste0("Location:", .y)) +
                                  cowplot::background_grid(minor = "none"))), .SDcols = "V1"][]
  
  temp8 <- merge(temp7, temp6_2, by = "location", all.x = TRUE)
  temp9 <- temp8[, `:=`("finals", purrr::pmap(.(.SD[[1]], .SD[[2]]), function(x, y) patchwork::wrap_plots(x, y, nrow = 2))), .SDcols = c("plot2","plot1")
  ][, plot_name := paste0(location, "_stations.png")][]
  
  # 根据天数计算图片的长度和宽度
  # 使用 map() 遍历 V1 列中的所有列表，计算唯一日期数
  days <- purrr::map_dbl(temp9$V1, ~ length(unique(.x$date)))
  height <- ifelse(days <= 7, 8, ifelse(days <= 14, 8, ifelse(days <= 30, 8, 8)))
  width <- ifelse(days <= 7, 5, ifelse(days <= 14, 10, ifelse(days <= 30, 13, 16)))
  
  purrr::walk2(
    temp9$plot_name,
    temp9$finals,
    ~ ggplot2::ggsave(
      filename = file.path(save_path, .x),
      plot = .y,
      height = height,
      width = width
    )
  )
}
