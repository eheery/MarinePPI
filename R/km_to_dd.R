#' Convert km to longitude and latitude decimal degrees based on great circle distance
#' 
#' @param km A distance in kilometers that will be converted to decimal degrees in 2 dimensions.
#' @param lat_dd A vector of latitudes in decimal degrees for the study area.
#'
#' @return A data frame of longitudinal and latitudinal equivalencies to input distance.
#' @examples
#' km_to_dd(2, 48.84)
#' @export
km_to_dd <- function(km, lat_dd){
  maxlat <- abs( lat_dd )
  m_londd = (km / 6378) * (180 / pi) / cos(lat_dd * pi/180)
  m_latdd = (km / 6378) * (180 / pi )
  data.frame( lon = m_londd, lat = m_latdd)}
