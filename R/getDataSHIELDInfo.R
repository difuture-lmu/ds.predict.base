#'
#' @title Get the session information of the DataSHIELD server
#' @description This method returns `sessionInfo()` from the used DataSHIELD servers.
#'   The main purpose is for testing and checking the environment used on the remote servers.
#' @return list of session infos returned from `sessionInfo()` of each machine
#' @author Daniel S.
#' @export
getDataSHIELDInfo = function() {
  return(list(session_info = utils::sessionInfo(), pcks = utils::installed.packages()))
}

#'
#' @title Get the session information of the DataSHIELD server
#' @description This method returns `sessionInfo()` from the used DataSHIELD servers.
#'   The main purpose is for testing and checking the environment used on the remote servers.
#' @param ... Path to files
#' @param recursive Path to files
#' @return list of session infos returned from `sessionInfo()` of each machine
#' @author Daniel S.
#' @export
getFiles = function(..., recursive = FALSE) {
  path_parts = do.call(c, list(...))
  #path_parts = eval(parse(text = path_parts))
  if (is.null(path_parts[1]))
    path = "/"
  else
    path = paste0("/", paste(path_parts, collapse = "/"))

  path = path.expand(path)
  files = list.files(path, recursive = recursive)
  return(list(path = path, files = files, wd = getwd()))
}

if (FALSE) {
surl     = "https://opal-demo.obiba.org/"
username = "administrator"
password = "password"
opal = opalr::opal.login(username = username, password = password, url = surl)

pkg = "dsPredictBase"
opalr::dsadmin.install_github_package(opal = opal, pkg = pkg, username = "difuture-lmu", ref = "main")
opalr::dsadmin.publish_package(opal = opal, pkg = pkg)

library(DSI)
library(DSOpal)
library(dsBaseClient)

library(dsPredictBase)
library(dsCalibration)
library(dsROCGLM)

library(ggplot2)

builder = newDSLoginBuilder()

surl     = "https://opal-demo.obiba.org/"
username = "administrator"
password = "password"

datasets = paste0("SRV", seq_len(5L))
for (i in seq_along(datasets)) {
  builder$append(
    server   = paste0("ds", i),
    url      = surl,
    user     = username,
    password = password,
    table    = paste0("DIFUTURE-TEST.", datasets[i])
  )
}

## Get data of the servers:
conn = datashield.login(logins = builder$build(), assign = TRUE)
datashield.symbols(conn)
ds.dim("D")

fs = datashield.aggregate(conn, quote(getFiles()))
datashield.errors()

opal.file(opal, "/projects/DIFUTURE-TEST/mod.Rda")

opal.file_upload(opal,
  source      = "~/repos/datashield-demo-survival/data/mod.Rda",
  destination = "/projects/DIFUTURE-TEST")


path = "/projects/DIFUTURE-TEST/mod.Rda"
append("files", strsplit(substring(path, 2), "/")[[1]])

}
