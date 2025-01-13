#' Calculate PPI a set of sites or grid cells given one or more buffer distances. 
#' 
#' @param locs  An sf object of geospatial coordinates (POINTS) or grid cells (POLYGONS).
#' @param buffer A vector of one or more buffer distance(s) that should be in focal mean calculations, expressed in kilometers.
#' @param compiled_raster A raster of population densities
#' @param progress if TRUE, display a progress bar while running exactextractr::exact_extract()
#' @return An sf object of PPI estimates for site.
#' @export
calculate_ppi <- function( locs, buffer, compiled_raster, progress = FALSE ){
  # PPI calculations for specific site locations
  print(paste0( "Calculating PPI for ", nrow( locs), " ", tolower(as.vector(unique(sf::st_geometry_type(locs)))), ifelse(nrow( locs)>1, "s")))
  calcs <-  lapply( as.list(stats::setNames(buffer,paste0(paste('PPI', buffer, sep = "-"), "km"))), function(b){
    print(paste0("... ", b, "km buffer"))
    X <- sf::st_buffer( sf::st_transform( locs, raster::crs(compiled_raster)), dist = b*1000)
    exactextractr::exact_extract(compiled_raster[[1]], X, 'mean', progress=progress) })
  
  out <- locs 
  
  out[paste0(paste('PPI', buffer, sep = "-"), "km")] <- as.data.frame( calcs ) 

  return(out)}