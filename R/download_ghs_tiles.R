#' Check for missing GHS raster tiles and download them if needed
#'
#' @param tile_list A list of tile ID vectors (e.g., output from get_tile_list)
#' @param data_directory Directory where "downloads" folder will be created and tiles stored
#' @param URL Base URL of the GHSL raster zip file library
#' @param ghs_layer GHS layer of interest (default: BUILT_S)
#' @param ghs_year GHS layer year of interest (default: 2030)
#' @param ghs_epsg GHS layer coordinate reference system of interest (default: 54009 - Mollweide)
#' @param ghs_resolution GHS layer resolution of interest (default: 100 meters)
#' @return A named logical vector indicating whether each tile is now present
#' @export
download_ghs_tiles <- function(tile_list,
                           data_directory,
                           URL = NULL,
                           ghs_layer = "BUILT_S",
                           ghs_year = 2030,
                           ghs_epsg = 54009,
                           ghs_resolution = "100") {

  ghs_layer_prefix <- paste0( "GHS_", ghs_layer, "_GLOBE_R2023A/")
  tif_prefix <- paste0("GHS_", ghs_layer, "_E", ghs_year, "_GLOBE_R2023A_", ghs_epsg, "_", ghs_resolution, "_V1_0_")

  download_dir <- file.path(data_directory, "downloads")
  if (!dir.exists(download_dir)) dir.create(download_dir, recursive = TRUE)


  if (is.null(URL)) {
    URL <- paste0(
      "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/",
      ghs_layer_prefix,
      gsub("_V1_0_", "", tif_prefix),
      "/V1-0/tiles/"
    )
  }

  tile_ids <- unique(unlist(tile_list))
  if (!is.character(tile_ids)) {
    stop("tile_ids must be a character vector after flattening tile_list")
  }

  expected_files <- paste0(tif_prefix, tile_ids, ".tif")
  existing_files <- list.files(download_dir, pattern = "\\.tif$", full.names = FALSE)
  missing_tiles <- tile_ids[!expected_files %in% existing_files]

  if (length(missing_tiles) > 0) {
    message("Downloading missing tiles: ", paste(missing_tiles, collapse = ", "))

    # -- Begin internal download logic --
    lookup <- as.list(stats::setNames(missing_tiles, missing_tiles))
    pg <- rvest::read_html(URL)
    zip_catalog <- rvest::html_attr(rvest::html_nodes(pg, "a"), "href")
    zip_catalog <- unique(zip_catalog[endsWith(zip_catalog, ".zip")])

    zip_files <- sapply(lookup, function(z) zip_catalog[stringr::str_detect(zip_catalog, z)])
    zip_files <- unlist(zip_files)  # Ensure vector

    lapply(zip_files, function(z) {
      z_url <- paste0(URL, "/", z)
      temp <- tempfile()
      tryCatch({
        utils::download.file(z_url, temp, mode = "wb")
        utils::unzip(temp, exdir = download_dir)
        unlink(temp)
      }, error = function(e) {
        message("Download failed for: ", z_url)
      })
    })
    # -- End internal download logic --

  } else {
    message("All tiles already present in ", download_dir)
  }

  # Confirm which tiles are present now
  downloaded_files <- list.files(download_dir, pattern = "\\.tif$", full.names = FALSE)
  file_status <- paste0(tif_prefix, tile_ids, ".tif") %in% downloaded_files
  names(file_status) <- tile_ids
  return(file_status)
}
