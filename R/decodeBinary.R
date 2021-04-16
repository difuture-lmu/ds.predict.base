#'
#' @title Deserialize object
#' @description Decode a given string of a serialized object.
#' @param bin (`character(1L)`) Binary string value containing the serialized model.
#' @param sep (`character(1L)`) Separator used to collapse the binary elements (default is `-`).
#' @param package (`character(1L)`) Package required for object deserialization (default is `NULL`).
#' @param install_if_not_available (`logical(1L)`) Install package if it is not installed (default is `TRUE`).
#' @return Deserialized object from `bin`
#' @author Daniel S.
#' @examples
#' mod = lm(Sepal.Width ~ ., data = iris)
#' bin = encodeObject(mod)
#' mod_b = decodeBinary(bin)
#' all.equal(mod, mod_b)
#' @export
decodeBinary = function(bin, sep = "-", package = NULL, install_if_not_available = TRUE) {
  checkmate::assertCharacter(bin, len = 1L, null.ok = FALSE, any.missing = FALSE)
  checkmate::assertCharacter(sep, len = 1L, null.ok = FALSE, any.missing = FALSE)
  checkmate::assertCharacter(package, len = 1L, null.ok = TRUE, any.missing = FALSE)
  checkmate::assertLogical(install_if_not_available, len = 1L, null.ok = FALSE, any.missing = FALSE)

  if (! grepl(sep, bin)) stop("Separator does not appear in binary string.")

  # Check if model is installed and install if not:
  if (! is.null(package) && require(package, quietly = TRUE, character.only = TRUE)) {
    if (install_if_not_available) utils::install.packages(package)
  }

  binary_str_deparse = strsplit(bin, split = sep)[[1]]
  raw = as.raw(as.hexmode(binary_str_deparse))
  obj = unserialize(raw)

  return(obj)
}
