# Generate a Grid and Calculate PPI Across a Marine Study Area

Creates a regular spatial grid across a user-specified bounding box with
an added buffer. Excludes fully terrestrial grid cells based on land
polygon overlap. For the remaining cells (partially or fully marine), it
calculates Population Pressure Index (PPI) at one or more buffer
distances.

## Usage

``` r
generate_ppi_grid(
  lon,
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
  progress = FALSE
)
```

## Arguments

- lon:

  Numeric vector of length 1 or greater: longitudes in decimal degrees
  representing the range (or centroid) of the study area.

- lat:

  Numeric vector of length 2: latitudes in decimal degrees representing
  the range (or centroid) of the study area.

- buffers_km:

  Numeric vector of one or more buffer radii (in kilometers) used to
  estimate PPI.

- tile_schema:

  An sf object of GHSL tile polygons with a `tile_id` column

- data_directory:

  The base directory containing "downloads" and "mosaics" folders

- land_polygons:

  A `sf` polygon object for land masses within the study area for which
  PPI calculations will be skipped (as a means of reducing computation
  time). Default = NULL.

- grid_resolution_km:

  Numeric. Width and height of grid cells in kilometers. Default is 10
  km; a finer resolution (ex: 1km) will provide a finer gradient and
  nicer visual, but takes a lot longer to run.

- locations_crs:

  CRS code for the input coordinates (default is 4326)

- crs_projected:

  CRS to use for grid generation and area calculations (default: 3857
  Web Mercator).

- land_buffer:

  Negative buffer distance (in meters) assumed for the land polygon (if
  provided) in case of inprecise mapping (so as not to eliminate grid
  cells from PPI calculations that aren't actually land). Default = 1000
  m.

- tif_prefix:

  Prefix used in naming .tif files (default matches GHSL 2023 dataset)

- progress:

  Logical. If TRUE, show progress bars in exact_extract

## Value

A `list` of PPI, an `sf` polygon object of grid cells with computed PPI
estimates for each buffer distance, and (if land polygons were provided)
Land, the cropped land polygons in the same coordinate reference system
as grid polygons.
