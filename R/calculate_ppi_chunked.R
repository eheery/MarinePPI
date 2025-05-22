#' Chunked PPI calculation for each unique tile or mosaic combination
#'
#' @param locations A data frame or matrix with longitude and latitude (in that order)
#' @param tile_schema An sf object of GHSL tile polygons with a `tile_id` column
#' @param data_directory The base directory containing "downloads" and "mosaics" folders
#' @param buffers_km Vector of buffer distances (in km) to use in PPI calculation
#' @param locations_crs CRS code for the input coordinates (default is 4326)
#' @param tif_prefix Prefix used in naming .tif files (default matches GHSL 2023 dataset)
#' @param progress Logical. If TRUE, show progress bars in exact_extract
#'
#' @return An sf object with PPI columns, in the same row order as `locations`
#' @export
calculate_ppi_chunked <- function(locations,
                                  tile_schema,
                                  data_directory,
                                  buffers_km = c(5, 10, 20),
                                  locations_crs = 4326,
                                  tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_",
                                  progress = FALSE) {
  # Step 1: Get locations as an sf object
  if( inherits(locations, "sf") ){
    locs_sf <- sf::st_transform( locations, crs = locations_crs)
  }else{
    # Convert locations to sf
    locs_sf <- sf::st_as_sf(locations, coords = c(1, 2), crs = locations_crs)}
  locs_sf$row_id <- seq_len(nrow(locs_sf))  # preserve original order

  # Step 2: Get tile list and raster paths
  tile_list <- get_tile_list(locs_sf, tile_schema, buffers_km)
  tile_status <- download_tiles(tile_list, data_directory = data_directory)
  mosaic_files <- create_tile_mosaics(tile_list, data_directory = data_directory)
  raster_paths <- get_rasters(tile_list, data_directory = data_directory, tif_prefix = tif_prefix, return_paths = TRUE)

  # Step 3: Assign file path to each location
  locs_sf$path <- unlist(raster_paths)  # safe because output is one path per location

  # Step 4: Split by unique raster file and compute PPI per chunk
  loc_groups <- split(locs_sf, locs_sf$path)
  results <- list()

  for (p in names(loc_groups)) {
    message("Processing raster: ", basename(p))
    r <- terra::rast(p)
    # terra::minmax(r)  # ensure min/max is available
    ppi_result <- calculate_ppi(locs = loc_groups[[p]], buffer = buffers_km, compiled_raster = r, progress = progress)
    results[[p]] <- ppi_result
  }

  # Step 5: Recombine and restore original order
  final <- dplyr::bind_rows( results)
  final <- final[order(final$row_id), ]
  final$row_id <- NULL
  final$path <- sub(paste0("^", normalizePath(data_directory, winslash = "/"), "/?"), "", normalizePath(final$path, winslash = "/"))
  out <- cbind( locations,  sf::st_drop_geometry(final))

  return(out)
}

