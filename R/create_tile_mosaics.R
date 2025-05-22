#' Create raster mosaics for unique tile combinations
#'
#' @param tile_list A list of character vectors (as output by get_tile_list)
#' @param data_directory Directory where "downloads" and "mosaics" folders are/will be created
#' @param tif_prefix Prefix used in .tif file naming
#' @return A character vector of created mosaic file paths (empty if none were created)
#' @export
create_tile_mosaics <- function(tile_list,
                                data_directory,
                                tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_") {
  download_dir <- file.path(data_directory, "downloads")
  mosaic_dir   <- file.path(data_directory, "mosaics")
  if (!dir.exists(mosaic_dir)) dir.create(mosaic_dir, recursive = TRUE)

  # Get unique, sorted tile combinations
  combo_list <- unique(lapply(tile_list, function(x) sort(unique(x))))

  # Early exit if all combinations involve only one tile (no mosaicking needed)
  if (all(sapply(combo_list, length) == 1)) {
    message("No mosaicking needed \u2014 all locations fall within single tiles.")
    return(character(0))
  }

  # Generate output filenames
  combo_strings <- sapply(combo_list, function(x) paste(x, collapse = "_x_"))
  mosaic_paths <- file.path(mosaic_dir, paste0(tif_prefix, combo_strings, ".tif"))

  created_mosaics <- character()

  for (i in seq_along(combo_list)) {
    combo <- combo_list[[i]]
    mosaic_file <- mosaic_paths[i]

    if (file.exists(mosaic_file)) {
      message("Mosaic already exists: ", basename(mosaic_file))
      next
    }

    # Build list of raster tile paths
    tile_files <- paste0(tif_prefix, combo, ".tif")
    tile_paths <- file.path(download_dir, tile_files)

    if (!all(file.exists(tile_paths))) {
      stop("Some required tiles for mosaicking are missing: ",
           paste(combo[!file.exists(tile_paths)], collapse = ", "))
    }

    # Load and mosaic rasters
    rasters <- lapply(tile_paths, terra::rast)
    message("Creating mosaic: ", basename(mosaic_file))
    mosaic <- rasters[[1]]

    if (length(rasters) > 1) {
      for (j in 2:length(rasters)) {
        mosaic <- terra::mosaic(mosaic, rasters[[j]], fun = "mean")
      }
    }

    # Save mosaic
    terra::writeRaster(mosaic, mosaic_file, overwrite = TRUE)
    created_mosaics <- c(created_mosaics, mosaic_file)
  }

  if (length(created_mosaics) == 0) {
    message("All mosaics already exist. Nothing new was created.")
  }

  return(created_mosaics)
}
