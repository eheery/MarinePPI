#' Load the correct raster (single or mosaic) for each location from tile_list, with memoised loading
#'
#' @param tile_list A list of tile ID vectors (from get_tile_list)
#' @param data_directory The base directory containing "downloads/" and "mosaics/" folders
#' @param tif_prefix Prefix used in naming the .tif files
#' @param return_paths Logical. If TRUE, returns file paths instead of loading rasters. Default is FALSE
#' @return A list of either terra::rast objects or character file paths, one per entry in tile_list
#' @export
get_rasters <- function(tile_list,
                        data_directory,
                        tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_",
                        return_paths = FALSE) {
  # Load memoise and terra
  if (!requireNamespace("memoise", quietly = TRUE)) {
    stop("The 'memoise' package is required but not installed.")
  }
  if (!requireNamespace("terra", quietly = TRUE)) {
    stop("The 'terra' package is required but not installed.")
  }

  memo_rast <- memoise::memoise(terra::rast)

  download_dir <- file.path(data_directory, "downloads")
  mosaic_dir   <- file.path(data_directory, "mosaics")

  output <- vector("list", length(tile_list))

  for (i in seq_along(tile_list)) {
    tile_ids <- sort(unique(tile_list[[i]]))

    if (length(tile_ids) == 1) {
      # Single-tile case
      file_name <- paste0(tif_prefix, tile_ids, ".tif")
      file_path <- file.path(download_dir, file_name)
    } else {
      # Multi-tile case (mosaic)
      combo_str <- paste(tile_ids, collapse = "_x_")
      file_name <- paste0(tif_prefix, combo_str, ".tif")
      file_path <- file.path(mosaic_dir, file_name)
    }

    if (!file.exists(file_path)) {
      stop("Missing raster file: ", file_path)
    }

    output[[i]] <- if (return_paths) {
      file_path
    } else {
      memo_rast(file_path)
    }
  }

  return(output)
}
