## "zzz.R" script

.onLoad <- function(libname, pkgname) {
  utils::globalVariables(c("..mean_cols", "..numeric_columns", "..sum_n_cols"))
}
