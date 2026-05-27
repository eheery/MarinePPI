# Check for missing GHS raster tiles and download them if needed

Check for missing GHS raster tiles and download them if needed

## Usage

``` r
download_ghs_tiles(
  tile_list,
  data_directory,
  URL = NULL,
  ghs_layer = "BUILT_S",
  ghs_year = 2030,
  ghs_epsg = 54009,
  ghs_resolution = "100"
)
```

## Arguments

- tile_list:

  A list of tile ID vectors (e.g., output from get_tile_list)

- data_directory:

  Directory where "downloads" folder will be created and tiles stored

- URL:

  Base URL of the GHSL raster zip file library

- ghs_layer:

  GHS layer of interest (default: BUILT_S)

- ghs_year:

  GHS layer year of interest (default: 2030)

- ghs_epsg:

  GHS layer coordinate reference system of interest (default: 54009 -
  Mollweide)

- ghs_resolution:

  GHS layer resolution of interest (default: 100 meters)

## Value

A named logical vector indicating whether each tile is now present
