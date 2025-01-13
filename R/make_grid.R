#' Create a grid of empty x by x km cells for which to calculate PPI. 
#' 
#' @param locs  An sf object of grid cells 
#' @param buffer A vector of buffer distances that should be used to compute focal means for population density.
#' @param dimensions A number specifying the desired dimensions of square grid cells in kilometers
#' @param bounds If preferred, the grid can be calculated with specific bounds by providing a vector of bounding values here in the format, c(xmin, ymin, xmax, ymax)
#' @section Details:
#' Are they ungulates?
#'
#' @return An sf object of grid cell polygons.
#' @export

make_grid <- function(locs, buffer, dimensions = 0.5, bounds = NULL){

  max_buff <- max(buffer)
  
  latitudes <- sf::st_coordinates(locs)[,2] 
  
  dims <- with(
    km_to_dd( km = dimensions, lat_dd = latitudes ),
    list( 
      x = min(lon),
      y = min(lat)) )
  
  bb_radius <- with( 
    km_to_dd( km = max_buff, lat_dd = latitudes ),
    max( c(lon, lat)))

  studyarea <- sf::st_make_grid( sf::st_bbox( sf::st_buffer( locs, dist = bb_radius) ), n = c(1,1))
  
 if( !is.null(bounds)){
    boundedarea <- sf::st_make_grid( sf::st_bbox( stats::setNames(bounds, c("xmin", "ymin", "xmax", "ymax")) ), n = c(1,1), crs = sf::st_crs( locs))
    if( sapply( sf::st_covers( boundedarea, studyarea), length) == 0){  
      stop("Error: bounds smaller than buffer area")
    }else{
      studyarea <- boundedarea
    }}
      
  gridcells <- sf::st_make_grid( 
    x = sf::st_bbox( sf::st_buffer( studyarea, dist = bb_radius ) ), 
    cellsize = c(dims$x, dims$y ) )
  
  out <- sf::st_sf(gridcells) 
  
  out$CalculatePPI <- ifelse( sapply( sf::st_intersects( gridcells, studyarea ), length) > 0, 1, 0)
  
  return(out)}

