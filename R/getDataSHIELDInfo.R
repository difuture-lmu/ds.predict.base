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
#' @param path Path to files
#' @return list of session infos returned from `sessionInfo()` of each machine
#' @author Daniel S.
#' @export
getFiles = function(path) {
  return(list.files(path))
}
