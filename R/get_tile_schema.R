#' Download and load the GHSL tile schema shapefile (land tiles only)
#'
#' This function checks for the GHSL tile schema shapefile in a given local directory.
#' If the shapefile is missing, it downloads and unzips the schema from the official
#' GHSL (Global Human Settlement Layer) repository. It returns the tile schema as an `sf` object.
#'
#' The function ensures that the returned object includes a `tile_id` column, which is
#' required for matching spatial buffers to the correct raster tiles. It also filters to
#' land tiles only, based on filenames that include `"tile_schema_land.shp"`.
#'
#' @param data_directory A character string specifying the directory where the tile schema
#'        shapefile should be stored. If it is not present, it will be downloaded here.
#' @param tile_schema_URL A character string specifying the URL of the zipped tile schema
#'        shapefile. Defaults to the GHSL land tile schema URL.
#'
#' @return An `sf` object containing the tile schema polygons with a `tile_id` column.
#'
#' @examples
#' \dontrun{
#' schema <- get_tile_schema(data_directory = "Reference Files/rasters")
#' plot(schema["tile_id"])
#' }
#'
#' @export
get_tile_schema <- function(
    data_directory,
    tile_schema_URL = "https://ghsl.jrc.ec.europa.eu/download/GHSL_data_54009_shapefile.zip") {

  # List all files in target directory
  fls <- list.files(data_directory, full.names = TRUE)

  # Download and unzip if needed
  if (length(fls) == 0 || !any(endsWith(fls, "tile_schema_land.shp"))) {
    message("Tile schema not found locally. Downloading from GHSL...")
    temp <- tempfile()
    utils::download.file(tile_schema_URL, temp, mode = "wb")
    utils::unzip(temp, exdir = data_directory)
    unlink(temp)
    fls <- list.files(data_directory, full.names = TRUE)
  }

  # Locate shapefile
  fn <- fls[which(endsWith(fls, "tile_schema_land.shp"))]
  if (length(fn) == 0) stop("tile_schema_land.shp not found after download.")

  # Read as sf object
  out <- sf::st_read(fn, quiet = TRUE)

  # Check for required column
  if (!"tile_id" %in% names(out)) {
    stop("The tile schema does not contain a 'tile_id' column.")
  }

  return(out)
}
