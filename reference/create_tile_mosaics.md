# Create raster mosaics for unique tile combinations

Create raster mosaics for unique tile combinations

## Usage

``` r
create_tile_mosaics(
  tile_list,
  data_directory,
  tif_prefix = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0_"
)
```

## Arguments

- tile_list:

  A list of character vectors (as output by get_tile_list)

- data_directory:

  Directory where "downloads" and "mosaics" folders are/will be created

- tif_prefix:

  Prefix used in .tif file naming

## Value

A character vector of created mosaic file paths (empty if none were
created)
