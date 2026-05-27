#' Chunked focal means calculations from the GHS layer specified
#'
#' @param locations A data frame or matrix with longitude and latitude
#' @param longitude_col The column containing longitude in decimal degrees (character or numeric); defaults to column 1
#' @param latitude_col The column containing latitude in decimal degrees (character or numeric); defaults to column 2
#' @param tile_schema An sf object of GHSL tile polygons with a `tile_id` column
#' @param data_directory The base directory containing "downloads" and "mosaics" folders
#' @param buffers_km Vector of buffer distances (in km) to use in PPI calculation
#' @param locations_crs CRS code for the input coordinates (default is 4326)
#' @param ghs_layer GHS layer of interest (default: BUILT_S)
#' @param ghs_year GHS layer year of interest (default: 2030)
#' @param ghs_epsg GHS layer coordinate reference system of interest (default: 54009 - Mollweide)
#' @param ghs_resolution GHS layer resolution of interest (default: 100 meters)
#' @param progress Logical. If TRUE, show progress bars in exact_extract
#'
#' @return An sf object with PPI columns, in the same row order as `locations`
#' @export
calculate_ghs_chunked <- function(locations,
                                  longitude_col = 1,
                                  latitude_col = 2,
                                  tile_schema,
                                  data_directory,
                                  buffers_km = c(5, 10, 20),
                                  locations_crs = 4326,
                                  ghs_layer = "BUILT_S",
                                  ghs_year = 2030,
                                  ghs_epsg = 54009,
                                  ghs_resolution = "100",
                                  progress = FALSE) {

  # Step 1: Get locations as an sf object
  if( inherits(locations, "sf") ){
    locs_sf <- sf::st_transform( locations, crs = locations_crs)
  }else{
    # Convert locations to sf
    locs_sf <- sf::st_as_sf(locations, coords = c(longitude_col, latitude_col), crs = locations_crs)}
  locs_sf$row_id <- seq_len(nrow(locs_sf))  # preserve original order

  # Step 2: Get tile list and raster paths
  tile_list <- get_tile_list(locs_sf, tile_schema, buffers_km)
  tile_status <- download_ghs_tiles(tile_list,
                                    data_directory = data_directory,
                                    ghs_layer = ghs_layer,
                                    ghs_year = ghs_year,
                                    ghs_epsg = ghs_epsg,
                                    ghs_resolution = ghs_resolution  )
  tif_prefix <- paste0("GHS_", ghs_layer, "_E", ghs_year, "_GLOBE_R2023A_", ghs_epsg, "_", ghs_resolution, "_V1_0_")
  mosaic_files <- create_tile_mosaics(tile_list, data_directory = data_directory,  tif_prefix = tif_prefix)
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
  final$tile <- sub(paste0("^", normalizePath(data_directory, winslash = "/"), "/?"), "", normalizePath(final$path, winslash = "/"))
  final$path <- NULL
  final[[longitude_col]] <- locations[[longitude_col]]
  final[[latitude_col]] <- locations[[latitude_col]]
  final_df <- sf::st_drop_geometry(final)
  out <- final_df[,c(colnames(locations), colnames(final_df)[!colnames(final_df) %in% colnames(locations)])]

  return(out)
}

