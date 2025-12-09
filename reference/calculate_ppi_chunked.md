# Chunked PPI calculation for each unique tile or mosaic combination

Chunked PPI calculation for each unique tile or mosaic combination

## Usage

``` r
calculate_ppi_chunked(
  locations,
  longitude_col = 1,
  latitude_col = 2,
  tile_schema,
  data_directory,
  buffers_km = c(5, 10, 20),
  locations_crs = 4326,
  tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_",
  progress = FALSE
)
```

## Arguments

- locations:

  A data frame or matrix with longitude and latitude

- longitude_col:

  The column containing longitude in decimal degrees (character or
  numeric); defaults to column 1

- latitude_col:

  The column containing latitude in decimal degrees (character or
  numeric); defaults to column 2

- tile_schema:

  An sf object of GHSL tile polygons with a `tile_id` column

- data_directory:

  The base directory containing "downloads" and "mosaics" folders

- buffers_km:

  Vector of buffer distances (in km) to use in PPI calculation

- locations_crs:

  CRS code for the input coordinates (default is 4326)

- tif_prefix:

  Prefix used in naming .tif files (default matches GHSL 2023 dataset)

- progress:

  Logical. If TRUE, show progress bars in exact_extract

## Value

An sf object with PPI columns, in the same row order as `locations`
