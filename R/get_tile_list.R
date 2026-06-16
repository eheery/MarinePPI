#' Identify GHSL tile IDs needed to cover spatial locations with a specified buffer
#'
#' Given a set of geographic coordinates (e.g., sampling sites or institution locations),
#' this function identifies which GHSL population raster tiles intersect a buffer
#' of a specified radius around each point. It returns a list of tile ID vectors, one per input point.
#'
#' @param locations A data frame or matrix with longitude and latitude
#' @param longitude_col The column containing longitude in decimal degrees (character or numeric); defaults to column 1
#' @param latitude_col The column containing latitude in decimal degrees (character or numeric); defaults to column 2
#' @param tile_schema An `sf` object representing the GHSL tile grid schema, with a `tile_id` column.
#' @param buffers_km Numeric buffer radius in kilometers (default is 10).
#'
#' @return A list of character vectors, each containing the GHSL tile IDs intersecting the buffer around a location.
#'
#' @examples
#' \dontrun{
#' # Example with mock coordinates and GHSL tile schema:
#' coords <- data.frame(lon = c(12.5, -122.3), lat = c(41.9, 37.8))
#' tile_list <- get_tile_list(coords, tile_schema = ghsl_tile_shapefile, buffers_km = 10)
#' }
#'
#' @export
get_tile_list <- function(
    locations,
    longitude_col = 1,
    latitude_col = 2,
    tile_schema,
    locations_crs = 4326,
    buffers_km = 10){


  if( inherits(locations, "sf") ){
    locs_sf <- sf::st_transform( locations, crs = locations_crs)
  }else{
    # Convert locations to sf
    locs_sf <- sf::st_as_sf(locations, coords = c(longitude_col, latitude_col), crs = locations_crs)}

  x <- sf::st_transform(locs_sf, crs = sf::st_crs(tile_schema))

  x_buff <- sf::st_buffer(x, dist = max(buffers_km * 1000))

  int <- sf::st_intersects(x_buff, tile_schema)

  out <- lapply(int, function(i) tile_schema$tile_id[i])

  return(out)
}
