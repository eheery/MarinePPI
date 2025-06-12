#' Generate a Grid and Calculate PPI Across a Marine Study Area
#'
#' Creates a regular spatial grid across a user-specified bounding box with an added buffer.
#' Excludes fully terrestrial grid cells based on land polygon overlap.
#' For the remaining cells (partially or fully marine), it calculates Population Pressure Index (PPI)
#' at one or more buffer distances.
#'
#' @param lon Numeric vector of length 1 or greater: longitudes in decimal degrees representing the range (or centroid) of the study area.
#' @param lat Numeric vector of length 2: latitudes in decimal degrees representing the range (or centroid) of the study area.
#' @param buffer_km Numeric vector of one or more buffer radii (in kilometers) used to estimate PPI.
#' @param tile_schema An sf object of GHSL tile polygons with a `tile_id` column
#' @param data_directory The base directory containing "downloads" and "mosaics" folders
#' @param land_polygons A \code{sf} polygon object for land masses within the study area for which PPI calculations will be skipped (as a means of reducing computation time). Default = NULL.
#' @param grid_resolution_km Numeric. Width and height of grid cells in kilometers.
#' @param locations_crs CRS code for the input coordinates (default is 4326)
#' @param crs_projected CRS to use for grid generation and area calculations (default: 3857 Web Mercator).
#' @return A \code{data.frame} of grid centroids and PPI estimates at each buffer distance.
#' @export
generate_ppi_grid <- function(lon,
                              lat,
                              buffer_km = c(5, 10, 20),
                              tile_schema,
                              data_directory,
                              land_polygons = NULL,
                              grid_resolution_km = 1,
                              locations_crs = 4326,
                              crs_projected = 3857) {

  requireNamespace("sf")
  requireNamespace("terra")
  requireNamespace("dplyr")

  # Create buffered bounding box
  locs <- sf::st_as_sf( expand.grid( x = lon, y = lat ), coords = c("x", "y"), crs = locations_crs)
  bbox_wgs <-  sf::st_bbox( sf::st_buffer( sf::st_transform(locs, crs = crs_projected),  dist = max(buffer_km)*1000) )

  # Generate grid
  grid <- sf::st_make_grid(
    bbox_wgs,
    cellsize = grid_resolution_km * 1000,
    square = TRUE,
    crs = crs_projected )

  # Crop land to grid area
  if(!is.null(land_polygons)){
    land_proj <- sf::st_transform(land_polygons, crs = crs_projected)
    area_land <- sf::st_intersection(sf::st_as_sfc(bbox_wgs, crs = crs_projected), land_proj$geometry)
    area_water <- sf::st_difference( sf::st_as_sfc(bbox_wgs, crs = crs_projected), area_land)
    # Subset just grids that are not land (to cut down on the number of calculations needed)
    intersection <- sf::st_intersects(grid, area_water)
    grid_filtered <- grid[ which( sapply( intersection, length ) > 0),]
  }else{
    grid_filtered <- grid
  }

  # Run PPI estimation for all buffer distances
  message("Calculating PPI... this may take time.")
  calcs <- calculate_ppi_chunked(
    locations = sf::st_as_sf(grid_filtered),
    tile_schema = tile_schema,  # if using GHSL logic, update here
    data_directory = data_directory,  # update as needed
    buffers_km = buffer_km,
    locations_crs = locations_crs,
    progress = TRUE)

  out <- list(
    PPI = calcs,
    Land = area_land)
  return(out)
}
