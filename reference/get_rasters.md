# Load the correct raster (single or mosaic) for each location from tile_list, with memoised loading

Load the correct raster (single or mosaic) for each location from
tile_list, with memoised loading

## Usage

``` r
get_rasters(
  tile_list,
  data_directory,
  tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_",
  return_paths = FALSE
)
```

## Arguments

- tile_list:

  A list of tile ID vectors (from get_tile_list)

- data_directory:

  The base directory containing "downloads/" and "mosaics/" folders

- tif_prefix:

  Prefix used in naming the .tif files

- return_paths:

  Logical. If TRUE, returns file paths instead of loading rasters.
  Default is FALSE

## Value

A list of either terra::rast objects or character file paths, one per
entry in tile_list
