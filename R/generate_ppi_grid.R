#' Generate a Grid and Calculate PPI Across a Marine Study Area
#'
#' Creates a regular spatial grid across a user-specified bounding box with an added buffer.
#' Excludes fully terrestrial grid cells based on land polygon overlap.
#' For the remaining cells (partially or fully marine), it calculates Population Pressure Index (PPI)
#' at one or more buffer distances.
#'
#' @param lon Numeric vector of length 1 or greater: longitudes in decimal degrees representing the range (or centroid) of the study area.
#' @param lat Numeric vector of length 2: latitudes in decimal degrees representing the range (or centroid) of the study area.
#' @param buffers_km Numeric vector of one or more buffer radii (in kilometers) used to estimate PPI.
#' @param tile_schema An sf object of GHSL tile polygons with a `tile_id` column
#' @param data_directory The base directory containing "downloads" and "mosaics" folders
#' @param land_polygons A \code{sf} polygon object for land masses within the study area for which PPI calculations will be skipped (as a means of reducing computation time). Default = NULL.
#' @param grid_resolution_km Numeric. Width and height of grid cells in kilometers. Default is 10 km; a finer resolution (ex: 1km) will provide a finer gradient and nicer visual, but takes a lot longer to run.
#' @param locations_crs CRS code for the input coordinates (default is 4326)
#' @param crs_projected CRS to use for grid generation and area calculations (default: 3857 Web Mercator).
#' @param land_buffer Negative buffer distance (in meters) assumed for the land polygon (if provided) in case of inprecise mapping (so as not to eliminate grid cells from PPI calculations that aren't actually land). Default = 1000 m.
#' @return A \code{list} of PPI, an \code{sf} polygon object of grid cells with computed PPI estimates for each buffer distance, and (if land polygons were provided) Land, the cropped land polygons in the same coordinate reference system as grid polygons.
#' @param tif_prefix Prefix used in naming .tif files (default matches GHSL 2023 dataset)
#' @param progress Logical. If TRUE, show progress bars in exact_extract
#' @export
generate_ppi_grid <- function(lon,
                              lat,
                              buffers_km = c(5, 10, 20),
                              tile_schema,
                              data_directory,
                              land_polygons = NULL,
                              grid_resolution_km = 10,
                              locations_crs = 4326,
                              crs_projected = 3857,
                              land_buffer = -1000,
                              tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_",
                              progress = FALSE) {

  requireNamespace("sf")
  requireNamespace("terra")
  requireNamespace("dplyr")

  # Create buffered bounding box
  locs <- sf::st_as_sf( expand.grid( lon, lat ), coords = c(1, 2), crs = locations_crs)
  bbox_wgs <-  sf::st_bbox( sf::st_buffer( sf::st_transform(locs, crs = crs_projected),  dist = max(buffers_km)*1000) )

  # Generate grid
  grid <- sf::st_make_grid(
    bbox_wgs,
    cellsize = grid_resolution_km * 1000,
    square = TRUE,
    crs = crs_projected )

  # Crop land to grid area
  if(!is.null(land_polygons)){
    land_proj <- sf::st_transform(land_polygons, crs = crs_projected)
    land_reduced <- sf::st_buffer( sf::st_combine( land_proj ), dist = land_buffer)
    area_proj <- sf::st_intersection(land_proj, sf::st_union( grid) ) # for returning
    area_land <- sf::st_intersection(sf::st_as_sfc(bbox_wgs, crs = crs_projected), land_reduced)
    area_water <- sf::st_difference( sf::st_as_sfc(bbox_wgs, crs = crs_projected), area_land )
    # Subset just grids that are not land (to cut down on the number of calculations needed)
    intersection <- sf::st_intersects(grid, area_water)
    calc_i <- which( sapply( intersection, length ) > 0)
  }else{
    calc_i <- 1:length(grid)
  }

  locs_sf <- sf::st_as_sf(grid)
  locs_sf$cell_id <- seq_len(nrow(locs_sf))  # preserve original order
  calcs_sf <- locs_sf[calc_i,]

  # Step 2: Get tile list and raster paths
  tile_list <- get_tile_list(calcs_sf, tile_schema, buffers_km)
  tile_status <- download_tiles(tile_list, data_directory = data_directory)
  mosaic_files <- create_tile_mosaics(tile_list, data_directory = data_directory)
  raster_paths <- get_rasters(tile_list, data_directory = data_directory, tif_prefix = tif_prefix, return_paths = TRUE)

  # Step 3: Assign file path to each location
  calcs_sf$path <- unlist(raster_paths)  # safe because output is one path per location

  # Step 4: Split by unique raster file and compute PPI per chunk
  calc_groups <- split(calcs_sf, calcs_sf$path)
  results <- list()

  for (p in names(calc_groups)) {
    message("Processing raster: ", basename(p))
    r <- terra::rast(p)
    # terra::minmax(r)  # ensure min/max is available
    ppi_result <- calculate_ppi(locs = calc_groups[[p]], buffer = buffers_km, compiled_raster = r, progress = progress)
    results[[p]] <- ppi_result
  }

  # Step 5: Recombine and restore original order
  results_sf <-  dplyr::bind_rows( results )
  results_sf$tile <- sub(paste0("^", normalizePath(data_directory, winslash = "/"), "/?"), "", normalizePath(results_sf$path, winslash = "/"))
  results_sf$path <- NULL
  final <- results_sf[order( results_sf$cell_id),]
  final <- suppressMessages( dplyr::left_join( final, sf::st_drop_geometry(locs_sf)) )
  final <- dplyr::rename( final, geometry = "x")
  out <- list( PPI = final )
  if(!is.null(land_polygons)){  out$Land <- area_proj    }
  return(out)
}
