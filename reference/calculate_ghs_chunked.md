# Chunked focal means calculations from the GHS layer specified

Chunked focal means calculations from the GHS layer specified

## Usage

``` r
calculate_ghs_chunked(
  locations,
  longitude_col = 1,
  latitude_col = 2,
  tile_schema,
  data_directory,
  buffers_km = c(5, 10, 20),
  locations_crs = 4326,
  ghs_layer = "BUILT_S",
  ghs_year = 2030,
  ghs_epsg = 54009,
  ghs_resolution = "100",
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

- ghs_layer:

  GHS layer of interest (default: BUILT_S)

- ghs_year:

  GHS layer year of interest (default: 2030)

- ghs_epsg:

  GHS layer coordinate reference system of interest (default: 54009 -
  Mollweide)

- ghs_resolution:

  GHS layer resolution of interest (default: 100 meters)

- progress:

  Logical. If TRUE, show progress bars in exact_extract

## Value

An sf object with PPI columns, in the same row order as `locations`
