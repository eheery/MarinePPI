#' Download and unzip raster tiles for the study area of interest.
#' 
#' @param tileIDs vector of tile_ids for selected GHS raster tiles
#' @param data_directory  Directory where GHS raster files have been downloaded and unzipped
#' @param URL Weblink for the GHS library of tiled raster zip files
#' @return NA
#' @export
download_ghs_tiles <- function(tileIDs, data_directory = getwd(), URL = "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_BUILT_S_GLOBE_R2023A/GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100/V1-0/tiles/"){

  lookup <- as.list(stats::setNames(tileIDs, tileIDs))
  pg <- rvest::read_html(URL)
  zip_files <- rvest::html_attr(rvest::html_nodes(pg, "a"), "href")
  zip_files <- unique(zip_files[endsWith(zip_files, ".zip")])
  zip_files <- sapply( lookup, function(z){ zip_files[stringr::str_detect(zip_files, z)] })
  lapply( zip_files, function(z){ 
    z_url <- paste0(URL, "/", z)
    temp <- tempfile() 
    utils::download.file(z_url,temp)
    utils::unzip( temp, exdir = data_directory )
    unlink(temp)})
  }
