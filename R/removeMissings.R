#'
#' @title Remove missing values from data
#' @description Remove missing values from data and assign it to new data or old data.
#' @param symbol [character(1L)] R object from which missings should be removed.
#' @param new_symbol [character(1L)] New R object to which the data is written.
#' @author Daniel S.
#' @export
removeMissings = function(symbol, new_symbol) {
  if (missing(symbol)) stop("Symbol must be given.")
  if (missing(new_symbol)) new_symbol = symbol

  obj = eval(parse(text = symbol))
  return(na.omit(obj))
}
