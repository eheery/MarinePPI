#' Identify GHSL tile IDs needed to cover spatial locations with a specified buffer
#'
#' Given a set of geographic coordinates (e.g., sampling sites or institution locations),
#' this function identifies which GHSL population raster tiles intersect a buffer
#' of a specified radius around each point. It returns a list of tile ID vectors, one per input point.
#'
#' @param locs_sf An sf object of sites (or grid polygons).
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
    locs_sf,
    tile_schema,
    buffers_km = 10){


  x <- sf::st_transform(locs_sf, crs = sf::st_crs(tile_schema))

  x_buff <- sf::st_buffer(x, dist = max(buffers_km * 1000))

  int <- sf::st_intersects(x_buff, tile_schema)

  out <- lapply(int, function(i) tile_schema$tile_id[i])

  return(out)
}
