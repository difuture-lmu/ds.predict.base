#'
#' @title Serialize R object
#' @description This function serializes a given R object and creates a character string
#'   containing the binary of the object. This object can be send to the DataSHIELD servers.
#' @param obj (arbitrary R object) Object which should be send to DataSHIELD.
#' @param obj_name (`character(1L)`) Name of the object (default is `NULL`). If name is set to
#'   `NULL`, then the object name passed to the function is used.
#' @param sep (`character(1L)`) Separator used to collapse the binary elements (default is `-`).
#' @param check_serialization (`logical(1L)`) Check if the serialized model can be deserialized
#'   locally (default is `TRUE`).
#' @return Character of length 1 containing the serialized object as string.
#' @author Daniel S.
#' @examples
#' mod = lm(Sepal.Width ~ ., data = iris)
#' bin = encodeObject(mod)
#' substr(bin, 1, 50)
#' @export
encodeObject = function(obj, obj_name = NULL, sep = "-", check_serialization = TRUE) {
  checkmate::assertCharacter(sep, len = 1L, null.ok = FALSE, any.missing = FALSE)
  checkmate::assertCharacter(obj_name, len = 1L, null.ok = TRUE, any.missing = FALSE)

  if (is.null(obj_name)) obj_name = deparse(substitute(obj))

  obj_binary = serialize(obj, connection = NULL)
  obj_binary_str = as.character(obj_binary)
  obj_binary_str_collapsed = paste(obj_binary_str, collapse = sep)

  ## Pre check if object serialization works locally:
  if (check_serialization) {
    # get object back from serialization
    binary_str_deparse = strsplit(obj_binary_str_collapsed, split = sep)[[1]]
    raw = as.raw(as.hexmode(binary_str_deparse))
    obj_b = unserialize(raw)

    if (! all.equal(obj, obj_b)) stop("Model cannot serialized and deserialized into equal object!")
  }

  osize = utils::object.size(obj_binary_str_collapsed)
  if (osize > 1024^2) {
    message("[", Sys.time(), "] Your object is bigger than 1 MB (", round(osize, 1),
      " MB). Uploading larger objects may take some time.")
  }
  names(obj_binary_str_collapsed) = obj_name
  attr(obj_binary_str_collapsed, "sep") = sep

  return(obj_binary_str_collapsed)
}


