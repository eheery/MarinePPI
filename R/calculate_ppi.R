#' Calculate PPI for a set of sites or grid cells given one or more buffer distances
#'
#' This function computes the focal mean of population density within one or more buffer distances
#' around a set of input locations or polygons, using the exactextractr package for accurate spatial summaries.
#'
#' @param locs An `sf` object of geospatial features (typically POINTS or POLYGONS).
#' @param buffer A numeric vector of one or more buffer distances (in kilometers) to use in focal mean calculations.
#' @param compiled_raster A `terra` raster object containing population densities.
#' @param progress Logical; if TRUE, shows progress bar during `exactextractr::exact_extract()` operations.
#'
#' @return An `sf` object with additional columns for each PPI buffer (e.g., PPI-10km).
#' @export
calculate_ppi <- function(locs, buffer, compiled_raster, progress = FALSE) {
  # Ensure raster has min/max metadata to avoid warnings
  compiled_raster <- terra::setMinMax(compiled_raster)

  # Message about number and type of geometries
  geom_type <- tolower(as.vector(unique(sf::st_geometry_type(locs))))
  geom_suffix <- ifelse(nrow(locs) > 1, "s", "")
  message("Calculating PPI for ", nrow(locs), " ", geom_type, geom_suffix)

  # Perform PPI calculation for each buffer distance
  calcs <- lapply(
    stats::setNames(buffer, paste0("PPI", buffer, "km")),
    function(b) {
      message("... ", b, "km buffer")
      buffered <- sf::st_buffer(sf::st_transform(locs, terra::crs(compiled_raster)), dist = b * 1000)
      exactextractr::exact_extract(compiled_raster[[1]], buffered, 'mean', progress = progress, default_value = 0)
    }
  )

  # Combine results and return
  out <- locs
  out[paste0("PPI", buffer, "km")] <- as.data.frame(calcs)

  return(out)
}
