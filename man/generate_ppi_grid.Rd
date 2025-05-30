% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate_ppi_grid.R
\name{generate_ppi_grid}
\alias{generate_ppi_grid}
\title{Generate a Grid and Calculate PPI Across a Marine Study Area}
\usage{
generate_ppi_grid(
  lon,
  lat,
  buffer_km = c(5, 10, 20),
  tile_schema,
  data_directory,
  land_polygons,
  grid_resolution_km = 1,
  locations_crs = 4326,
  crs_projected = 3857
)
}
\arguments{
\item{lon}{Numeric vector of length 1 or greater: longitudes in decimal degrees representing the range (or centroid) of the study area.}

\item{lat}{Numeric vector of length 2: latitudes in decimal degrees representing the range (or centroid) of the study area.}

\item{buffer_km}{Numeric vector of one or more buffer radii (in kilometers) used to estimate PPI.}

\item{tile_schema}{An sf object of GHSL tile polygons with a \code{tile_id} column}

\item{data_directory}{The base directory containing "downloads" and "mosaics" folders}

\item{land_polygons}{An \code{sf} object representing land areas (e.g., from Natural Earth or OpenStreetMap).}

\item{grid_resolution_km}{Numeric. Width and height of grid cells in kilometers.}

\item{locations_crs}{CRS code for the input coordinates (default is 4326)}

\item{crs_projected}{CRS to use for grid generation and area calculations (default: 3857 Web Mercator).}
}
\value{
A \code{data.frame} of grid centroids and PPI estimates at each buffer distance.
}
\description{
Creates a regular spatial grid across a user-specified bounding box with an added buffer.
Excludes fully terrestrial grid cells based on land polygon overlap.
For the remaining cells (partially or fully marine), it calculates Population Pressure Index (PPI)
at one or more buffer distances.
}
