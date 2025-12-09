# Check for missing GHS raster tiles and download them if needed

Check for missing GHS raster tiles and download them if needed

## Usage

``` r
download_tiles(
  tile_list,
  data_directory,
  URL = NULL,
  tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_"
)
```

## Arguments

- tile_list:

  A list of tile ID vectors (e.g., output from get_tile_list)

- data_directory:

  Directory where "downloads" folder will be created and tiles stored

- URL:

  Base URL of the GHSL raster zip file library

- tif_prefix:

  Prefix used in naming the .tif files

## Value

A named logical vector indicating whether each tile is now present
