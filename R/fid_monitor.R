# WARNING - Generated by {fusen} from dev/station_pig_monitor.Rmd: do not edit by hand

#' Feed intake monitor of pig performance test station
#' 
#' @param data A data frame or data table containing the nedap or fire pig performance test data to be processed. Columns must include 'visit_time', 'location', 'responder', 'feed_intake'.
#' 
#' @param begin_date An optional Date object or character string specifying the beginning date for the data to be processed. If not provided, all dates in the data will be considered.
#' 
#' @param station_type A character string specifying the type of station. This must be either 'nedap' or 'fire'.
#' @param save_path A character string specifying the path where the output PDF will be saved.
#' 
#' @importFrom data.table ":="
#' @importFrom data.table ".SD"
#' 
#' @return This function does not return a value. It saves a PDF file to the specified path.
#' @export
#' 
#' @examples
#' # Load CSV data
#' data <- data.table::fread("C:/Users/Dell/Documents/projects/pptsdm_data/ppt_monitor_test_data.csv")
#' # Feed intake monitor
#' fid_monitor(data = data, station_type = "nedap", save_path = "C:/Users/Dell/Downloads/test")
fid_monitor <- function(data, begin_date=NULL, station_type, save_path) {
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
  
  visit_time <- . <- location <- responder <- feed_intake <- all_feed_a_station_one_day <- total_intake <- percent_intake <- Date <- Consumed <- total_intake <- percent_intake <- ndt <- plot1 <- plot2 <- NULL
  
  if (!data.table::is.data.table(data)) {
    data <- data.table::setDT(data)
  }
  prepare_nedap_data <- function(data, begin_date = NULL) {
    temp1 <- unique(data)[,`:=`(c("date", "time"),data.table::tstrsplit(visit_time," ", fixed = TRUE))][, `:=`(c("date"), lubridate::ymd(date))][,!c("visit_time", "time")]
    temp2 <- temp1[, keyby = .(location, responder, date),.(total_intake = round(sum(feed_intake) / 1000, digits = 4))][,`:=`(all_feed_a_station_one_day, sum(total_intake)), by = .(location, date)][, `:=`(percent_intake, total_intake / all_feed_a_station_one_day)]
    to_factor = c("location", "responder")
    temp2[, `:=`((to_factor), purrr::map(.SD, as.factor)), .SDcols = to_factor]
    if (!is.null(begin_date)) {
      temp2 <- temp2[date >= begin_date]
    }
    return(temp2)
  }
  
  prepare_fire_data <- function(data, begin_date = NULL) {
    temp1 <- unique(data)[,`:=`(Date, lubridate::ymd(Date))]
    data.table::setnames(temp1, 1:3, c("location", "responder","date"))
    temp2 <- temp1[, keyby = .(location, responder, date),.(total_intake = round(sum(Consumed), digits = 4))][,`:=`(all_feed_a_station_one_day, sum(total_intake)),by = .(location, date)][, `:=`(percent_intake, total_intake / all_feed_a_station_one_day)]
    to_factor = c("location", "responder")
    temp2[, `:=`((to_factor), purrr::map(.SD, as.factor)),.SDcols = to_factor]
    if (!is.null(begin_date)) {
      temp2 <- temp2[date >= begin_date]
    }
    return(temp2)
  }
  
  # Prepare data based on station_type
  if (station_type == "nedap") {
    prepared_data <- prepare_nedap_data(data, begin_date = begin_date)
  } else if (station_type == "fire") {
    prepared_data <- prepare_fire_data(data, begin_date = begin_date)
  } else {
    stop("Invalid station_type. Supported types are 'nedap' and 'fire'.")
  }
  
  # Create the plots
  colors = c("#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#b15928", "#8dd3c7", "#d9d9d9", "#80b1d3", "#00AFBB", "#01665e", "#003c30", "blue", "pink", "yellow", "red", "green", "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#00AFBB", "#E7B800", "#FC4E07", "#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E", "#E6AB02", "#A6761D", "#666666", "purple")
  #colors = as.character(palette.colors(n = 36, "Polychrome 36"))
  
  create_plots <- function(data, ...) {
    data[, list(list(.SD)), by = location
    ][, `:=`("plot1", purrr::map2(.SD[[1]], location, ~ ggplot2::ggplot(
      data = .x,
      ggplot2::aes(y = percent_intake,
                   x = date, fill = responder)
    ) + ggplot2::theme_bw() +
      ggplot2::geom_col(
        width = 0.8,
        na.rm = F,
        show.legend = T
      ) +
      ggplot2::ggtitle(.y) + ggplot2::scale_y_continuous(
        labels = scales::percent,
        limits = c(0, 1),
        breaks = seq(0, 1, 0.1)
      ) + ggplot2::theme(
        plot.title = ggplot2::element_text(
          color = "black",
          hjust = 0.5,
          size = 20
        ),
        axis.title.x = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_text(size = 15),
        axis.text.x = ggplot2::element_text(size = 8, angle = 270),
        axis.text.y = ggplot2::element_text(size = 8),
        legend.title = ggplot2::element_text(size = 8),
        legend.text = ggplot2::element_text(size = 8),
        legend.position = "top",
        legend.margin = ggplot2::margin(10, 10, 10, 10),  # Adjust the legend margin
        legend.box.margin = ggplot2::margin(0, 0, 30, 0)  # Extra space at the bottom for the legend
      ) +
      ggplot2::guides(
        shape = ggplot2::guide_legend(override.aes = list(size = 7)),
        color = ggplot2::guide_legend(override.aes = list(size = 7))
      ) +
      ggplot2::ggtitle(paste0("location:", .y)) + ggplot2::scale_x_date(
        date_breaks = "1 day",
        date_labels = "%m-%d",
        date_minor_breaks = "1 day"
      ) +
      ggplot2::scale_fill_manual(
        na.value = "black",
        values = colors
      ), ...)), .SDcols = "V1"
    ][, `:=`("plot2", purrr::map2(.SD[[1]], location, ~ ggplot2::ggplot(data = .x,
                                                                        ggplot2::aes(
                                                                          y = total_intake, x = date, fill = responder
                                                                        )) +
                                    ggplot2::theme_bw() + ggplot2::geom_col(
                                      width = 0.8,
                                      na.rm = F,
                                      show.legend = F
                                    ) + ggplot2::theme(
                                      plot.title = ggplot2::element_text(
                                        color = "black",
                                        hjust = 0.5,
                                        size = 20
                                      ),
                                      axis.title.x = ggplot2::element_text(size = 15),
                                      axis.title.y = ggplot2::element_text(size = 15),
                                      axis.text.x = ggplot2::element_text(size = 8, angle = 270),
                                      axis.text.y = ggplot2::element_text(size = 8),
                                      legend.position = "none"
                                    ) +
                                    ggplot2::guides(
                                      shape = ggplot2::guide_legend(override.aes = list(size = 7)),
                                      color = ggplot2::guide_legend(override.aes = list(size = 7))
                                    ) +
                                    ggplot2::scale_x_date(
                                      date_breaks = "1 day",
                                      date_labels = "%m-%d",
                                      date_minor_breaks = "1 day"
                                    ) + ggplot2::scale_fill_manual(
                                      na.value = "black",
                                      values = colors
                                    ), ...)), .SDcols = "V1"][]
  }
  
  # Combine and save the plots
  save_combined_plots <- function(path_out, ...) {
    temp_plot <- create_plots(data = prepared_data, value = colors)
    
    # Calculate the number of unique locations
    num_locations <- length(unique(temp_plot$location))
    
    # Calculate the date range
    date_range <- range(prepared_data$date)
    num_days <- as.numeric(difftime(date_range[2], date_range[1], units = "days")) + 1
    
    # Set the minimum days for width calculation to 30
    num_days_for_width <- max(num_days, 50)
    
    # Calculate the PDF dimensions based on the number of locations and date range
    width_per_day <- 0.3 # 0.5 cm per day, you can adjust this value based on your preferences
    pdf_width <- num_days_for_width * width_per_day * 2 # Adjust width according to the date range and number of columns
    
    height_per_location <- 30 # 30 cm per location, you can adjust this value based on your preferences
    pdf_height <- height_per_location * ceiling(num_locations / 2) # Adjust height according to the number of locations and number of rows
    
    temp4 <- temp_plot[, `:=`("finals", purrr::pmap(.(.SD[[1]], .SD[[2]]), function(x, y) patchwork::wrap_plots(x, y, ncol = 1))), .SDcols = c("plot1","plot2")][]
    temp5 <- patchwork::wrap_plots(temp4$finals, ncol = 2)
    
    ggplot2::ggsave(
      file.path(save_path, "feed_intake_monitor.pdf"),
      temp5,
      width = pdf_width,
      height = pdf_height,
      units = "cm",
      dpi = "retina",
      limitsize = FALSE,
      ...
    )
  }
  save_combined_plots(save_path)
}
